//
//  MRContactDetailViewController.m
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/22/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRContactDetailViewController.h"
#import "MRGroupPostItemTableViewCell.h"
#import "MRContactWithinGroupCollectionCellCollectionViewCell.h"
#import "KLCPopup.h"
#import "MRContact.h"
#import "MRGroup.h"
#import "CommonBoxView.h"
@interface MRContactDetailViewController ()<MRGroupPostItemTableViewCellDelegate,CommonBoxViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView* mainImageView;
@property (weak, nonatomic) IBOutlet UILabel* mainLabel;
@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;
@property (weak, nonatomic) IBOutlet UITableView* postsTableView;
@property (strong, nonatomic) UIActionSheet* moreOptions;

@property (strong, nonatomic) NSArray* contactsUnderGroup;
@property (strong, nonatomic) NSArray* groupsUnderContact;
@property (strong, nonatomic) NSArray* posts;

@property (strong, nonatomic) MRContact* mainContact;
@property (strong, nonatomic) MRGroup* mainGroup;
@property (strong,nonatomic) KLCPopup *commentBoxKLCPopView;
@property (strong,nonatomic) CommonBoxView *commentBoxView;

@end

@implementation MRContactDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView* titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navLogo.png"]];
    [self.navigationItem setTitleView:titleImage];
    
    // Do any additional setup after loading the view from its nib.
    [self.collectionView registerNib:[UINib nibWithNibName:@"MRContactWithinGroupCollectionCellCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"contactWithinGroupCell"];
    [self.postsTableView registerNib:[UINib nibWithNibName:@"MRGroupPostItemTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"groupCell"];
    self.postsTableView.estimatedRowHeight = 250;
    self.postsTableView.rowHeight = UITableViewAutomaticDimension;
    if (self.mainContact) {
        self.mainImageView.image = [UIImage imageNamed:self.mainContact.profilePic];
        self.mainLabel.text = self.mainContact.name;
        self.groupsUnderContact = [self.mainContact.groups allObjects];
        self.posts = [self.mainContact.groupPosts allObjects];
    } else {
        self.mainImageView.image = [UIImage imageNamed:self.mainGroup.groupPicture];
        self.mainLabel.text = self.mainGroup.name;
        self.contactsUnderGroup = [self.mainGroup.contacts allObjects];
        self.posts = [self.mainGroup.groupPosts allObjects];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setContact:(MRContact*)contact {
    self.mainContact = contact;
}

- (void)setGroup:(MRGroup*)group {
    self.mainGroup = group;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRGroupPostItemTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell"];
    cell.delegate = self;
    [cell setPostContent:[self.posts objectAtIndex:indexPath.row]];
    return cell;
}


-(void)mrGroupPostItemTableViewCell:(MRGroupPostItemTableViewCell *)cell withCommentButtonTapped:(id)sender{
    [self setupCommentBox];
    //    [self.commentBoxKLCPopView show];
    [_commentBoxKLCPopView showWithLayout:KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutAboveCenter)];
}

-(void)setupCommentBox{
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"commentBox" owner:self options:nil];
    
    _commentBoxView = (CommonBoxView *)[arr objectAtIndex:0];
    
    self.commentBoxView.delegate = self;
    
    self.commentBoxView.frame =     CGRectMake(self.commentBoxView.frame.origin.x, self.commentBoxView.frame.origin.y, 300,316);
    [self.commentBoxView setContact:self.mainContact];
    [self.commentBoxView setGroup:self.mainGroup];
    [self.commentBoxView setData];
    
    _commentBoxKLCPopView = [KLCPopup popupWithContentView:self.commentBoxView];
    
    
}
-(void)commonBoxCameraButtonTapped{
    [self takePhoto];
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.contactsUnderGroup.count > 0) {
        return self.contactsUnderGroup.count;
    } else {
        return self.groupsUnderContact.count;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRContactWithinGroupCollectionCellCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"contactWithinGroupCell" forIndexPath:indexPath];
    if (self.contactsUnderGroup.count > 0) {
        [cell setContact:self.contactsUnderGroup[indexPath.row]];
    } else {
        [cell setGroup:self.groupsUnderContact[indexPath.row]];
    }
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(110, collectionView.bounds.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 4; // This is the minimum inter item spacing, can be more
}

- (IBAction)moreOptionsTapped:(id)sender {
    if (!self.moreOptions) {
        self.moreOptions = [[UIActionSheet alloc] initWithTitle:@"More Options"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Add Members",@"Pending Members", nil];
    }
    [self.moreOptions showInView:self.view];
}
#pragma mark
#pragma CAMERA IMAGE CAPTURE

-(void)takePhoto {
    [_commentBoxKLCPopView dismiss:YES];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //    self.imageView.image = chosenImage;
    
    
    [_commentBoxView setImageForShareImage:chosenImage];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [_commentBoxKLCPopView showWithLayout:KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutAboveCenter)];
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


@end

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
#import "MRGroupPost.h"
#import "MRGroup.h"
#import "CommonBoxView.h"
#import "AppDelegate.h"
#import "MRDatabaseHelper.h"
#import "MRConstants.h"
#import "GroupPostChildTableViewCell.h"
#import "MrGroupChildPost.h"
#import "MRCommon.h"
#import "MRWebserviceHelper.h"
#import "MRGroupObject.h"
#import "MRGroupUserObject.h"
#import "MRContactWithinGroupCollectionViewCell.h"
#import "MRGroupUserObject.h"
#import "MRAddMembersViewController.h"
#import "MRAppControl.h"
#import "MRCreateGroupViewController.h"
#import "PendingContactsViewController.h"

@interface MRContactDetailViewController () <MRGroupPostItemTableViewCellDelegate, CommonBoxViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MRUpdateMemberProtocol> {
    NSMutableArray *groupsArrayObj;
    NSMutableArray *groupMemberArray;
    BOOL canEditGroup;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionHeight;
@property (weak, nonatomic) IBOutlet UIImageView* mainImageView;
@property (weak, nonatomic) IBOutlet UILabel* mainLabel;
@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;
@property (weak, nonatomic) IBOutlet UITableView* postsTableView;
@property (strong, nonatomic) UIActionSheet* moreOptions;

@property (strong, nonatomic) NSArray* contactsUnderGroup;
@property (strong, nonatomic) NSArray* groupsUnderContact;
@property (strong, nonatomic) NSArray* posts;

@property (strong, nonatomic) MRGroupUserObject* mainContact;
//@property (strong, nonatomic) MRContact* mainContact;
@property (strong, nonatomic) MRGroup* mainGroup;
@property (strong, nonatomic) MRGroupObject* mainGroupObj;
@property (strong,nonatomic) KLCPopup *commentBoxKLCPopView;
@property (strong,nonatomic) CommonBoxView *commentBoxView;
@property (strong, nonatomic) IBOutlet UIView *navView;

@end

@implementation MRContactDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Contact Details";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    // Do any additional setup after loading the view from its nib.
    [self.collectionView registerNib:[UINib nibWithNibName:@"MRContactWithinGroupCollectionCellCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"contactWithinGroupCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MRContactWithinGroupCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MRContactWithinGroupCollectionViewCell"];
//    [self.postsTableView registerNib:[UINib nibWithNibName:@"MRGroupPostItemTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"groupCell"];
    self.postsTableView.estimatedRowHeight = 250;
    self.postsTableView.rowHeight = UITableViewAutomaticDimension;
    if (self.mainContact) {
        for (UIView *view in self.mainImageView.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                [view removeFromSuperview];
            }
        }
        
        self.mainImageView.image = [MRCommon getImageFromBase64Data:[_mainContact.imgData dataUsingEncoding:NSUTF8StringEncoding]];
        self.mainLabel.text = [NSString stringWithFormat:@"%@ %@",_mainContact.firstName, _mainContact.lastName];
        self.groupsUnderContact = @[]; //[self.mainContact.groups allObjects];
        self.posts = @[]; //[self.mainContact.groupPosts allObjects];
        _collectionHeight.constant = 0;
        
        if (!_mainContact.imgData.length)
        {
            NSString *fullName = [NSString stringWithFormat:@"%@ %@",_mainContact.firstName, _mainContact.lastName];
            self.mainImageView.image = nil;
            if (fullName.length > 0) {
                UILabel *subscriptionTitleLabel = [[UILabel alloc] initWithFrame:self.mainImageView.bounds];
                subscriptionTitleLabel.textAlignment = NSTextAlignmentCenter;
                subscriptionTitleLabel.font = [UIFont systemFontOfSize:15.0];
                subscriptionTitleLabel.textColor = [UIColor lightGrayColor];
                subscriptionTitleLabel.layer.cornerRadius = 5.0;
                subscriptionTitleLabel.layer.masksToBounds = YES;
                subscriptionTitleLabel.layer.borderWidth =1.0;
                subscriptionTitleLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
                
                NSArray *substrngs = [fullName componentsSeparatedByString:@" "];
                NSString *imageString = @"";
                for(NSString *str in substrngs){
                    if (str.length > 0) {
                        imageString = [imageString stringByAppendingString:[NSString stringWithFormat:@"%c",[str characterAtIndex:0]]];
                    }
                }
                subscriptionTitleLabel.text = imageString.length > 2 ? [imageString substringToIndex:2] : imageString;
                [self.mainImageView addSubview:subscriptionTitleLabel];
            }
        }
        
    } else {
//        self.mainImageView.image = [UIImage imageNamed:self.mainGroup.groupPicture];
//        self.mainLabel.text = self.mainGroup.name;
//        self.contactsUnderGroup = [self.mainGroup.contacts allObjects];
//        self.posts = [self.mainGroup.groupPosts allObjects];
        for (UIView *view in self.mainImageView.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                [view removeFromSuperview];
            }
        }
        
        self.mainImageView.image = [MRCommon getImageFromBase64Data:[self.mainGroupObj.group_img_data dataUsingEncoding:NSUTF8StringEncoding]];
        self.mainLabel.text = self.mainGroupObj.group_name;
        self.contactsUnderGroup = @[];
        self.posts = @[];
        _collectionHeight.constant = self.view.frame.size.height - 65;
        
        if (self.mainGroupObj.group_name.length > 0 && !self.mainGroupObj.group_img_data.length) {
            UILabel *subscriptionTitleLabel = [[UILabel alloc] initWithFrame:self.mainImageView.bounds];
            subscriptionTitleLabel.textAlignment = NSTextAlignmentCenter;
            subscriptionTitleLabel.font = [UIFont systemFontOfSize:15.0];
            subscriptionTitleLabel.textColor = [UIColor lightGrayColor];
            subscriptionTitleLabel.layer.cornerRadius = 5.0;
            subscriptionTitleLabel.layer.masksToBounds = YES;
            subscriptionTitleLabel.layer.borderWidth =1.0;
            subscriptionTitleLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
            
            NSArray *substrngs = [self.mainGroupObj.group_name componentsSeparatedByString:@" "];
            NSString *imageString = @"";
            for(NSString *str in substrngs){
                if (str.length > 0) {
                    imageString = [imageString stringByAppendingString:[NSString stringWithFormat:@"%c",[str characterAtIndex:0]]];
                }
            }
            subscriptionTitleLabel.text = imageString.length > 2 ? [imageString substringToIndex:2] : imageString;
            [self.mainImageView addSubview:subscriptionTitleLabel];
        }
        
        [self getGroupMembersStatusWithGroupId:self.mainGroupObj.group_id];
    }
    
    [self totalPosts];
    [self.postsTableView reloadData];
    self.postsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

/*- (void)setContact:(MRContact*)contact {
    self.mainContact = contact;
}*/

- (void)setContact:(MRGroupUserObject*)contact {
    self.mainContact = contact;
}

- (void)setGroup:(MRGroup*)group {
    self.mainGroup = group;
    
}

- (void)setGroupData:(MRGroupObject*)group {
    self.mainGroupObj = group;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self countForTableView];
}

-(void)totalPosts {
   __block NSMutableArray *arra = [NSMutableArray array];
    
    [self.posts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MRGroupPost *postGroup = (MRGroupPost *)obj;
        [arra addObject:postGroup];
        if (postGroup.replyPost!=nil && postGroup.replyPost.count >0) {
            
            [postGroup.replyPost enumerateObjectsUsingBlock:^(MrGroupChildPost * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [arra addObject:(MrGroupChildPost *)obj];
                
            }];
        }
        
    }];
    
    self.posts = nil;
    self.posts = [NSMutableArray arrayWithArray:arra] ;
    
    }
-(NSInteger)countForTableView{

    
   return  self.posts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id postObject = [self.posts objectAtIndex:indexPath.row];
    if ([postObject isKindOfClass:[MRGroupPost class]]) {
        
        return 260;
    }else {
        
        MrGroupChildPost *childPost = (MrGroupChildPost *)postObject;
        
        if ([childPost.postPic isEqualToString:@""]) {
            return 44;
            
        }else {
            
            return 182;
        }
       
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
   
    id postObject = [self.posts objectAtIndex:indexPath.row];
    if ([postObject isKindOfClass:[MRGroupPost class]]) {
        
        MRGroupPostItemTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell"];
    
        if (cell == nil) {
            NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"MRGroupPostItemTableViewCell" owner:self options:nil];
            cell = (MRGroupPostItemTableViewCell *)[arr objectAtIndex:0];
        }
        
        cell.delegate = self;
        [cell setPostContent:[self.posts objectAtIndex:indexPath.row]];
         return cell;
    }else {
    
        GroupPostChildTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"groupChildCell"];
        if (cell == nil) {
            NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"GroupPostChildTableViewCell" owner:self options:nil];
            cell = (GroupPostChildTableViewCell *)[arr objectAtIndex:0];
        }
        MrGroupChildPost *childPost = (MrGroupChildPost *)postObject;
        
        if ([childPost.postPic isEqualToString:@""]) {
           cell.heightConstraint.constant = 0;
            cell.verticalContstraint.constant = 0;
            [cell setNeedsUpdateConstraints];
        }else {
            NSString * imagePath = childPost.postPic;
            
            cell.commentPic.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
            
        }
          cell.postText.text = childPost.postText;
        return cell;
        
    }
    
    
    return nil;
}


-(void)mrGroupPostItemTableViewCell:(MRGroupPostItemTableViewCell *)cell withCommentButtonTapped:(id)sender{
    [self setupCommentBox];
    //    [self.commentBoxKLCPopView show];
    
    NSIndexPath *indexPath = [self.postsTableView indexPathForCell:cell];
    
    
    [_commentBoxKLCPopView showWithLayout:KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutAboveCenter)];
    
    [_commentBoxView setData:indexPath];
}

-(void)setupCommentBox{
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"commentBox" owner:self options:nil];
    
    _commentBoxView = (CommonBoxView *)[arr objectAtIndex:0];
    
    self.commentBoxView.delegate = self;
    
    self.commentBoxView.frame =     CGRectMake(self.commentBoxView.frame.origin.x, self.commentBoxView.frame.origin.y, 300,316);
    [self.commentBoxView setContact:self.mainContact];
    [self.commentBoxView setGroup:self.mainGroup];
    _commentBoxKLCPopView = [KLCPopup popupWithContentView:self.commentBoxView];
    
    
}
-(void)commonBoxCameraButtonTapped{
    [self takePhoto];
    
}
-(void)commonBoxOkButtonPressedWithData:(NSDictionary *)dictData withIndexPath:(NSIndexPath *)indexPath{
    
    [_commentBoxKLCPopView dismiss:YES];
    
    MRGroupPost *post = [self.posts objectAtIndex:indexPath.row];
    //obtaining saving path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSInteger childPostCounter =[APP_DELEGATE counterForChildPost];
    
    NSString *postID = [NSString stringWithFormat:@"%lld_%ld",post.groupPostId,(long)childPostCounter];
    
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",postID]];
    NSDictionary *saveData;
    //extracting image from the picker and saving it
    if (![[dictData objectForKey:@"profile_pic"] isKindOfClass:[NSString class]]) {
        UIImage *editedImage = [dictData objectForKey:@"profile_pic"];
        NSData *webData = UIImagePNGRepresentation(editedImage);
        [webData writeToFile:imagePath atomically:YES];
       saveData = [NSDictionary dictionaryWithObjectsAndKeys:[dictData objectForKey:@"postText"],@"postText",imagePath,@"post_pic",postID,@"postID", nil];

    }else {
        saveData = [NSDictionary dictionaryWithObjectsAndKeys:[dictData objectForKey:@"postText"],@"postText",@"",@"post_pic",postID,@"postID", nil];
        

    }
    

    [MRDatabaseHelper addGroupChildPost:post withPostDict:saveData];
    
    
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
//    if (self.contactsUnderGroup.count > 0) {
//        return self.contactsUnderGroup.count;
//    } else {
//        return self.groupsUnderContact.count;
//    }
    
    if (groupMemberArray.count) {
        return groupMemberArray.count;
    } else {
        return self.groupsUnderContact.count;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    /*MRContactWithinGroupCollectionCellCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"contactWithinGroupCell" forIndexPath:indexPath];
    if (self.contactsUnderGroup.count > 0) {
        [cell setContact:self.contactsUnderGroup[indexPath.row]];
    } else {
        [cell setGroup:self.groupsUnderContact[indexPath.row]];
    }
    return cell;*/
    
    if (groupMemberArray.count > 0) {
        MRContactWithinGroupCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MRContactWithinGroupCollectionViewCell" forIndexPath:indexPath];
        cell.cellDelegate = self;
        cell.acceptBtn.tag = indexPath.row;
        cell.rejectBtn.tag = indexPath.row;
        
        MRGroupUserObject *user = groupMemberArray[indexPath.row];
        cell.nameTxt.text = user.firstName;
        cell.imgView.image = [MRCommon getImageFromBase64Data:[user.imgData dataUsingEncoding:NSUTF8StringEncoding]];
        
        if ([user.status caseInsensitiveCompare:@"Active"] == NSOrderedSame) {
            cell.acceptBtn.hidden = YES;
            cell.rejectBtn.hidden = YES;
        }else{
            cell.acceptBtn.hidden = NO;
            cell.rejectBtn.hidden = NO;
        }
        
        return cell;
    } else {
        MRContactWithinGroupCollectionCellCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"contactWithinGroupCell" forIndexPath:indexPath];
        [cell setGroup:self.groupsUnderContact[indexPath.row]];
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //return CGSizeMake(110, collectionView.bounds.size.height);
    return CGSizeMake(collectionView.bounds.size.width, 60);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 4; // This is the minimum inter item spacing, can be more
}

-(void) acceptAction:(NSInteger)index{
    MRGroupUserObject *user = groupMemberArray[index];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.mainGroupObj.group_id,@"group_id", [NSString stringWithFormat:@"%@",user.member_id],@"member_id",@"ACTIVE",@"status", nil];
    
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] updateGroupMembersStatus:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            NSArray *erros =  [details componentsSeparatedByString:@"-"];
            if (erros.count > 0)
                [MRCommon showAlert:[erros lastObject] delegate:nil];
        }
    }];
}

-(void) rejectAction:(NSInteger)index{
    MRGroupUserObject *user = groupMemberArray[index];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.mainGroupObj.group_id,@"group_id",@[[NSString stringWithFormat:@"%@",user.member_id]],@"memberList", nil];
    
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] removeGroupMember:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            NSArray *erros =  [details componentsSeparatedByString:@"-"];
            if (erros.count > 0)
                [MRCommon showAlert:[erros lastObject] delegate:nil];
        }
    }];
}

- (IBAction)moreOptionsTapped:(id)sender {
    if (!self.moreOptions) {
        self.moreOptions = [[UIActionSheet alloc] initWithTitle:@"More Options"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Add Connections",@"Pending Connections", nil];
    }
    
    canEditGroup = self.mainGroupObj && (self.mainGroupObj.admin_id == [MRAppControl sharedHelper].userRegData[@"doctorId"]);
    if (canEditGroup) {
        self.moreOptions = [[UIActionSheet alloc] initWithTitle:@"More Options"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Add Members",@"Pending Members", @"Update Group", @"Delete Group", nil];
    }
    
    [self.moreOptions showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        MRAddMembersViewController* detailViewController = [[MRAddMembersViewController alloc] init];
        if (self.mainGroupObj)
            detailViewController.groupID = [self.mainGroupObj.group_id integerValue];
        else
            detailViewController.groupID = 0;
        [self.navigationController pushViewController:detailViewController animated:NO];
    }else if (buttonIndex == 1) {
        PendingContactsViewController* pendingContactsViewController = [[PendingContactsViewController alloc] init];
        pendingContactsViewController.isFromGroup = NO;
        pendingContactsViewController.isFromMember = canEditGroup;
        pendingContactsViewController.gid = self.mainGroupObj.group_id;
        [self.navigationController pushViewController:pendingContactsViewController animated:NO];
    }else if (buttonIndex == 2 && canEditGroup) {
        MRCreateGroupViewController* createGroupVC = [[MRCreateGroupViewController alloc] init];
        createGroupVC.group = self.mainGroupObj;
        [self.navigationController pushViewController:createGroupVC animated:NO];
    }else if (buttonIndex == 3 && canEditGroup) {
        [self removeGroup];
    }
}

-(void) removeGroup{
    [MRCommon showActivityIndicator:@"Deleting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] removeGroup:[NSDictionary dictionaryWithObjectsAndKeys:self.mainGroupObj.group_id, @"group_id", nil] withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Group Deleted!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag = 11;
            [alert show];
        }
        else
        {
            NSArray *erros =  [details componentsSeparatedByString:@"-"];
            if (erros.count > 0)
                [MRCommon showAlert:[erros lastObject] delegate:nil];
        }
    }];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 11) {
        [self.navigationController popViewControllerAnimated:YES];
    }
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

- (void)getGroupMembersStatus{
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getGroupMembersStatuswithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            NSArray *responseArray = responce[@"Responce"];
            groupsArrayObj = [NSMutableArray array];
            groupMemberArray = [NSMutableArray array];
            
            for (NSDictionary *memberDict in responseArray) {
                MRGroupObject *groupObj = [[MRGroupObject alloc] initWithDict:memberDict];
                [groupsArrayObj addObject:groupObj];
                if ([groupObj.group_name isEqualToString:self.mainGroupObj.group_name]) {
                    groupMemberArray = groupObj.member;
                }
            }
            [self.collectionView reloadData];
        }
        else
        {
            NSArray *erros =  [details componentsSeparatedByString:@"-"];
            if (erros.count > 0)
                [MRCommon showAlert:[erros lastObject] delegate:nil];
        }
    }];
}

- (void)getGroupMembersStatusWithGroupId:(NSString *)groupId{
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getGroupMembersStatusWithId:groupId withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            NSArray *responseArray = responce[@"Responce"];
            groupsArrayObj = [NSMutableArray array];
            groupMemberArray = [NSMutableArray array];
            
            for (NSDictionary *memberDict in responseArray) {
                MRGroupObject *groupObj = [[MRGroupObject alloc] initWithDict:memberDict];
                [groupsArrayObj addObject:groupObj];
                if ([groupObj.group_name isEqualToString:self.mainGroupObj.group_name]) {
                    groupMemberArray = groupObj.member;
                }
            }
            [self.collectionView reloadData];
        }
        else
        {
            NSArray *erros =  [details componentsSeparatedByString:@"-"];
            if (erros.count > 0)
                [MRCommon showAlert:[erros lastObject] delegate:nil];
        }
    }];
}

@end

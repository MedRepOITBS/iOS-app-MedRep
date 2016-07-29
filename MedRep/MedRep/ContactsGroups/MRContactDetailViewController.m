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
#import "CommonBoxView.h"
#import "AppDelegate.h"
#import "MRConstants.h"
#import "GroupPostChildTableViewCell.h"
#import "MRContactWithinGroupCollectionViewCell.h"
#import "MRAddMembersViewController.h"
#import "MRCreateGroupViewController.h"
#import "PendingContactsViewController.h"
#import "MRPostedReplies.h"
#import "MRSharePost.h"
#import "MRGroupMembers.h"
#import "MRContact.h"
#import "MRGroupPost.h"
#import "MRGroup.h"
#import "MrGroupChildPost.h"

@interface MRContactDetailViewController () <MRGroupPostItemTableViewCellDelegate, CommonBoxViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MRUpdateMemberProtocol> {
    NSMutableArray *groupsArrayObj;
    NSMutableArray *groupMemberArray;
    BOOL canEditGroup;
}

@property (weak, nonatomic) IBOutlet UIButton *deleteConnectionButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionHeight;
@property (weak, nonatomic) IBOutlet UIImageView* mainImageView;
@property (weak, nonatomic) IBOutlet UILabel* mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subHeadingLabel;
@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;
@property (weak, nonatomic) IBOutlet UITableView* postsTableView;
@property (weak, nonatomic) IBOutlet UIButton* plusBtn;
@property (weak, nonatomic) IBOutlet UILabel *city;
@property (strong, nonatomic) UIActionSheet* moreOptions;
@property (weak, nonatomic) IBOutlet UILabel *therapueticArea;
@property (weak, nonatomic) IBOutlet UIView *contactDetailView;
@property (weak, nonatomic) IBOutlet UIView *groupDetailView;
@property (weak, nonatomic) IBOutlet UILabel *groupDesc;

@property (strong, nonatomic) NSArray* contactsUnderGroup;
@property (strong, nonatomic) NSArray* groupsUnderContact;
@property (strong, nonatomic) NSArray* posts;

@property (strong, nonatomic) MRContact* mainContact;
@property (strong, nonatomic) MRGroup* mainGroup;
@property (strong,nonatomic) KLCPopup *commentBoxKLCPopView;
@property (strong,nonatomic) CommonBoxView *commentBoxView;
@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteBtnHeight;

@end

@implementation MRContactDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Contact Details";
    //[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    // Do any additional setup after loading the view from its nib.
    [self.collectionView registerNib:[UINib nibWithNibName:@"MRContactWithinGroupCollectionCellCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"contactWithinGroupCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MRContactWithinGroupCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MRContactWithinGroupCollectionViewCell"];
//    [self.postsTableView registerNib:[UINib nibWithNibName:@"MRGroupPostItemTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"groupCell"];
    self.postsTableView.estimatedRowHeight = 283;
    self.postsTableView.rowHeight = UITableViewAutomaticDimension;
    
    if (self.mainContact) {
        [self setupUIWithContactDetails];
    } else {
        [self setupUIWithGroupDetails];
    }
    
    [self.postsTableView reloadData];
    self.postsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.launchMode == kContactDetailLaunchModeSuggestedContact) {
        [self.deleteConnectionButton setTitle:NSLocalizedString(kAddConnection, "")
                               forState:UIControlStateNormal];
        [self.deleteConnectionButton addTarget:self
                                  action:@selector(addConnection:)
                        forControlEvents:UIControlEventTouchUpInside];
        [self.deleteConnectionButton setBackgroundColor:[MRCommon colorFromHexString:@"#20B18A"]];
    } else {
        [self.deleteConnectionButton setTitle:NSLocalizedString(kDeleteConnection, "")
                               forState:UIControlStateNormal];
        [self.deleteConnectionButton addTarget:self
                                  action:@selector(deleteConnection:)
                        forControlEvents:UIControlEventTouchUpInside];
        [self.deleteConnectionButton setBackgroundColor:[MRCommon colorFromHexString:@"#FF0000"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupUIWithContactDetails {
    [MRAppControl getContactImage:self.mainContact andImageView:self.mainImageView];
    self.mainLabel.text = [MRAppControl getContactName:self.mainContact];
    
    NSString *therapauticArea = @"";
    if (_mainContact.therapeuticArea != nil && _mainContact.therapeuticArea.length > 0) {
        therapauticArea = _mainContact.therapeuticArea;
    } else if (_mainContact.therapeuticName != nil && _mainContact.therapeuticName.length > 0) {
        therapauticArea = _mainContact.therapeuticName;
    }
    
    _therapueticArea.text = [NSString stringWithFormat:@"Therapeutic Area: %@", therapauticArea];
    
    NSString *city = @"";
    if (_mainContact.city != nil && _mainContact.city.length > 0) {
        city = _mainContact.city;
    }
    
    _city.text = [NSString stringWithFormat:@"City: %@",city];
    
    self.groupsUnderContact = [self.mainContact.groups allObjects];
    if (self.mainContact.comments != nil && self.mainContact.comments.count > 0) {
        self.posts = self.mainContact.comments.allObjects;
    } else {
        self.posts = [[NSArray alloc] init];
    }
    [self.subHeadingLabel setHidden:YES];
    
    _collectionHeight.constant = 0;
    _deleteBtnHeight.constant = 40;
    _contactDetailView.hidden = NO;
    _groupDetailView.hidden = YES;
    _plusBtn.hidden = YES;
}

- (void)setupUIWithGroupDetails {
    self.navigationItem.title = @"Group Details";
    [MRAppControl getGroupImage:self.mainGroup andImageView:self.mainImageView];
    self.mainLabel.text = self.mainGroup.group_name;
    self.subHeadingLabel.text = self.mainGroup.group_short_desc;
    self.groupDesc.text = self.mainGroup.group_long_desc;

    if (self.mainGroup.members != nil && self.mainGroup.members.count > 0) {
        self.contactsUnderGroup = [self.mainGroup.members allObjects];
    } else {
        self.contactsUnderGroup = [NSArray new];
    }
    
    if (self.mainGroup.comment != nil && self.mainGroup.comment.count > 0) {
        self.posts = [self.mainGroup.comment allObjects];
    } else {
        self.posts = [[NSArray alloc] init];
    }

    [self getGroupMembersStatusWithGroupId];
    
}

/*- (void)setContact:(MRContact*)contact {
    self.mainContact = contact;
}*/

- (void)setContact:(MRContact*)contact {
    self.mainContact = contact;
}

- (void)setGroup:(MRGroup*)group {
    self.mainGroup = group;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self countForTableView];
}

-(NSInteger)countForTableView{

    
   return  self.posts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = 283;
    MRPostedReplies *post = [self.posts objectAtIndex:indexPath.row];
    
    if (post.image == nil) {
        rowHeight -= 146;
    }
    
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MRPostedReplies *childPost = [self.posts objectAtIndex:indexPath.row];
    
    GroupPostChildTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"groupChildCell"];
    if (cell == nil) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"GroupPostChildTableViewCell" owner:self options:nil];
        cell = (GroupPostChildTableViewCell *)[arr objectAtIndex:0];
    }
    
    [cell fillCellWithData:childPost];

    return cell;
}

- (void)commentButtonTapped:(MRSharePost *)post {
    [self setupCommentBox];
    [_commentBoxView setData:nil group:nil andSharedPost:post];
}

- (void)setupCommentBox {
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"commentBox" owner:self options:nil];
    
    _commentBoxView = (CommonBoxView *)[arr objectAtIndex:0];
    _commentBoxKLCPopView = [KLCPopup popupWithContentView:self.commentBoxView];
    [_commentBoxKLCPopView showWithLayout:KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutCenter)];
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
    
    NSString *postID = [NSString stringWithFormat:@"%ld_%ld",post.groupPostId.longValue,(long)childPostCounter];
    
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
    
    if (self.launchMode == kContactDetailLaunchModeGroup ||
        self.launchMode == kContactDetailLaunchModeSuggestedGroup) {
        return self.contactsUnderGroup.count;
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
    
    if (self.contactsUnderGroup.count > 0) {
        MRContactWithinGroupCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MRContactWithinGroupCollectionViewCell" forIndexPath:indexPath];
        cell.cellDelegate = self;
        cell.acceptBtn.tag = indexPath.row;
        cell.rejectBtn.tag = indexPath.row;
        
        MRGroupMembers *user = self.contactsUnderGroup[indexPath.row];
        cell.nameTxt.text = [MRAppControl getGroupMemberName:user];
        [MRAppControl getGroupMemberImage:user andImageView:cell.imgView];
        
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
    MRGroupMembers *user = self.contactsUnderGroup[index];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithLong:self.mainGroup.group_id.longValue],@"group_id", [NSString stringWithFormat:@"%@",user.member_id],@"member_id",@"ACTIVE",@"status", nil];
    
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] updateGroupMembersStatus:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] updateGroupMembersStatus:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status)
                     {
                         [self.navigationController popViewControllerAnimated:YES];
                     }else
                     {
                         NSArray *erros =  [details componentsSeparatedByString:@"-"];
                         if (erros.count > 0)
                             [MRCommon showAlert:[erros lastObject] delegate:nil];
                     }
                 }];
             }];
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
    MRGroupMembers *user = self.contactsUnderGroup[index];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithLong:self.mainGroup.group_id.longValue],@"group_id",@[[NSString stringWithFormat:@"%@",user.member_id]],@"memberList", nil];
    
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] removeGroupMember:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] removeGroupMember:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status)
                     {
                         [self.navigationController popViewControllerAnimated:YES];
                     }else
                     {
                         NSArray *erros =  [details componentsSeparatedByString:@"-"];
                         if (erros.count > 0)
                             [MRCommon showAlert:[erros lastObject] delegate:nil];
                     }
                 }];
             }];
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
                                              otherButtonTitles:@"Pending Connections", @"Add Connections", nil];
    }
    
    canEditGroup = self.mainGroup && (self.mainGroup.admin_id == [MRAppControl sharedHelper].userRegData[@"doctorId"]);
    
    if (self.mainGroup) {
        self.moreOptions = [[UIActionSheet alloc] initWithTitle:@"More Options"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Pending Members", @"Leave Group", nil];
        if (canEditGroup) {
            self.moreOptions = [[UIActionSheet alloc] initWithTitle:@"More Options"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Pending Members", @"Invite Members", @"Update Group", @"Delete Group", @"Leave Group", nil];
        }
    }
    
    [self.moreOptions showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (!_mainGroup) {
            MRAddMembersViewController* detailViewController = [[MRAddMembersViewController alloc] init];
            detailViewController.groupID = 0;
            [self.navigationController pushViewController:detailViewController animated:NO];
        }else{
            if (canEditGroup) {
                MRAddMembersViewController* detailViewController = [[MRAddMembersViewController alloc] init];
                detailViewController.groupID = [self.mainGroup.group_id longValue];
                [self.navigationController pushViewController:detailViewController animated:NO];
            }else{
                [self leaveGroup];
            }
        }
    }else if (buttonIndex == 0) {
        PendingContactsViewController* pendingContactsViewController = [[PendingContactsViewController alloc] init];
        pendingContactsViewController.isFromGroup = NO;
        pendingContactsViewController.isFromMember = _mainGroup ? YES : NO;
        pendingContactsViewController.canEdit = canEditGroup;
        pendingContactsViewController.gid = [NSNumber numberWithLong:self.mainGroup.group_id.longValue];
        [self.navigationController pushViewController:pendingContactsViewController animated:NO];
    }else if (buttonIndex == 2 && canEditGroup) {
        MRCreateGroupViewController* createGroupVC = [[MRCreateGroupViewController alloc] init];
        createGroupVC.group = self.mainGroup;
        [self.navigationController pushViewController:createGroupVC animated:NO];
    }else if (buttonIndex == 3 && canEditGroup) {
        [self removeGroup];
    }else if (buttonIndex == 4 && canEditGroup) {
        [self leaveGroup];
    }
}

-(void) removeGroup{
    [MRCommon showActivityIndicator:@"Deleting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] removeGroup:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:self.mainGroup.group_id.longValue], @"group_id", nil] withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Group Deleted!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag = 11;
            [alert show];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] removeGroup:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                           [NSNumber numberWithLong:self.mainGroup.group_id.longValue], @"group_id", nil] withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status)
                     {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Group Deleted!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                         alert.tag = 11;
                         [alert show];
                     }else
                     {
                         NSArray *erros =  [details componentsSeparatedByString:@"-"];
                         if (erros.count > 0)
                             [MRCommon showAlert:[erros lastObject] delegate:nil];
                     }
                 }];
             }];
        }
        else
        {
            NSArray *erros =  [details componentsSeparatedByString:@"-"];
            if (erros.count > 0)
                [MRCommon showAlert:[erros lastObject] delegate:nil];
        }
    }];
}

-(void) leaveGroup{
    NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithLong:self.mainGroup.group_id.longValue], @"group_id",
                         @"EXIT", @"status",
                         [MRAppControl sharedHelper].userRegData[@"doctorId"], @"member_id",
                         nil];
    
    [MRCommon showActivityIndicator:@"Leaving..."];
    [[MRWebserviceHelper sharedWebServiceHelper] leaveGroup:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You left group!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag = 11;
            [alert show];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] leaveGroup:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status)
                     {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You left group!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                         alert.tag = 11;
                         [alert show];
                     } else
                     {
                         NSArray *erros =  [details componentsSeparatedByString:@"-"];
                         if (erros.count > 0)
                             [MRCommon showAlert:[erros lastObject] delegate:nil];
                     }
                 }];
             }];
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
    
    if (alertView.tag == 12) {
        if (buttonIndex) {
            [self deleteConnection];
        }
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
    
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [_commentBoxKLCPopView showWithLayout:KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutAboveCenter)];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)getGroupMembersStatusWithGroupId{
    [MRDatabaseHelper getGroupMemberStatusWithId:self.mainGroup.group_id.longValue
                                      andHandler:^(id result) {
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"group_id", self.mainGroup.group_id.longValue];
        NSArray *tempResults = result;
        tempResults = [tempResults filteredArrayUsingPredicate:predicate];
          if (tempResults != nil && tempResults.count > 0) {
              MRGroup *tempGroup = tempResults.firstObject;
              if (tempGroup.members != nil && tempGroup.members.count > 0) {
                  self.contactsUnderGroup = tempGroup.members.allObjects;
              } else {
                  self.contactsUnderGroup = [NSArray new];
              }
          } else {
              self.contactsUnderGroup = [NSArray new];
          }
        [self.collectionView reloadData];
    }];
}

- (void)deleteFromCoreData:(NSInteger)contactId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"contactId", contactId];
    
    MRDataManger *sharedManager = [MRDataManger sharedManager];
    [sharedManager removeAllObjects:kContactEntity inContext:sharedManager.managedObjectContext
                       andPredicate:predicate];
}

-(void) deleteConnection {
    NSDictionary *dict;
    
    if (self.mainContact != nil) {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithLong:self.mainContact.doctorId.longValue], @"connID",
                               [MRAppControl sharedHelper].userRegData[@"doctorId"], @"docID",
                               @"EXIT", @"status",
                               nil];
    } else {
        [self removeGroup];
        return;
    }
    
    [MRCommon showActivityIndicator:@"Deleting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] deleteConnection:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            [self deleteFromCoreData:self.mainContact.contactId.longValue];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Connection deleted!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag = 11;
            [alert show];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                                object:nil];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] deleteConnection:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status)
                     {
                         [self deleteFromCoreData:self.mainContact.contactId.longValue];
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Connection deleted!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                         alert.tag = 11;
                         [alert show];
                         [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                                             object:nil];
                     }else
                     {
                         NSArray *erros =  [details componentsSeparatedByString:@"-"];
                         if (erros.count > 0)
                             [MRCommon showAlert:[erros lastObject] delegate:nil];
                     }
                 }];
             }];
        }
        else
        {
            NSArray *erros =  [details componentsSeparatedByString:@"-"];
            if (erros.count > 0)
                [MRCommon showAlert:[erros lastObject] delegate:nil];
        }
    }];
}

- (IBAction)deleteConnection:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to delete connection?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = 12;
    [alert show];
}

- (IBAction)addConnection:(id)sender {
    [MRDatabaseHelper addConnections:@[[NSNumber numberWithLong:self.mainContact.doctorId.longValue]]
                  andResponseHandler:^(id result) {
                      [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                                          object:nil];
                      
                      for (UIViewController *vc in self.parentViewController.childViewControllers) {
                          if ([vc isKindOfClass:[MRContactDetailViewController class]]) {
                              [self.navigationController popToViewController:vc animated:YES];
                          }
                      }
                  }];
}

@end

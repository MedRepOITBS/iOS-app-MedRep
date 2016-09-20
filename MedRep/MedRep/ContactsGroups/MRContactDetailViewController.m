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
#import "MRContactsViewController.h"
#import "MemberListViewController.h"
#import "MRGroupMembersViewController.h"

@interface MRContactDetailViewController () <MRGroupPostItemTableViewCellDelegate, CommonBoxViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MRUpdateMemberProtocol> {
    NSMutableArray *groupsArrayObj;
    NSMutableArray *groupMemberArray;
    BOOL canEditGroup;
}


@property (weak, nonatomic) IBOutlet UIView *viewAllGroupMembers;

@property (weak, nonatomic) IBOutlet UILabel *postedMessagesTitleLabel;

@property (weak, nonatomic) IBOutlet UIButton *postTopicButton;

@property (weak, nonatomic) IBOutlet UIView *groupMembersView;
@property (weak, nonatomic) IBOutlet UILabel *emptyPostsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupMembersHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupDescHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *deleteConnectionButton;

@property (weak, nonatomic) IBOutlet UIImageView* mainImageView;
@property (weak, nonatomic) IBOutlet UILabel* mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subHeadingLabel;
@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;
@property (weak, nonatomic) IBOutlet UITableView* postsTableView;
@property (weak, nonatomic) IBOutlet UIButton* plusBtn;
@property (weak, nonatomic) IBOutlet UILabel *city;
@property (strong, nonatomic) UIActionSheet* moreOptions;
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
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(viewAllGroupMembersTapped)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.viewAllGroupMembers addGestureRecognizer:tapGesture];
    
    if (self.mainContact) {
        [self setupUIWithContactDetails];
    } else {
        [self setupUIWithGroupDetails];
    }
    
    self.postsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self fetchPosts];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.launchMode == kContactDetailLaunchModeSuggestedContact) {
        [self.postTopicButton setHidden:YES];
        [self.plusBtn setHidden:YES];
        [self.postsTableView setHidden:YES];
        [self.postedMessagesTitleLabel setHidden:YES];
        [self.emptyPostsLabel setHidden:YES];
        
        [self.deleteConnectionButton setTitle:NSLocalizedString(kAddConnection, "")
                               forState:UIControlStateNormal];
        [self.deleteConnectionButton addTarget:self
                                  action:@selector(addConnection:)
                        forControlEvents:UIControlEventTouchUpInside];
        [self.deleteConnectionButton setBackgroundColor:[MRCommon colorFromHexString:@"#20B18A"]];
    } else if (self.launchMode == kContactDetailLaunchModeGroup) {
        [self.deleteConnectionButton setTitle:NSLocalizedString(kLeaveGroup, "")
                                     forState:UIControlStateNormal];
        [self.deleteConnectionButton addTarget:self
                                        action:@selector(leaveGroup)
                              forControlEvents:UIControlEventTouchUpInside];
        [self.deleteConnectionButton setBackgroundColor:[MRCommon colorFromHexString:@"#FF0000"]];
    } else if (self.launchMode == kContactDetailLaunchModeSuggestedGroup) {
        [self.postTopicButton setHidden:YES];
        [self.plusBtn setHidden:YES];
        [self.postsTableView setHidden:YES];
        [self.postedMessagesTitleLabel setHidden:YES];
        [self.emptyPostsLabel setHidden:YES];
        
        [self.deleteConnectionButton setTitle:NSLocalizedString(kJoinGroup, "")
                                     forState:UIControlStateNormal];
        [self.deleteConnectionButton addTarget:self
                                        action:@selector(joinGroup)
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

- (void)fetchPosts {
    NSInteger memberId = 0;
    if (self.mainContact != nil && self.mainContact.doctorId != nil) {
        memberId = self.mainContact.doctorId.longValue;
    }
    
    NSInteger groupId = 0;
    if (self.mainGroup != nil && self.mainGroup.group_id != nil) {
        groupId = self.mainGroup.group_id.longValue;
    }
    
    [MRDatabaseHelper getMessagesOfAMember:memberId groupId:groupId
                               withHandler:^(id result) {
                                   if (self.mainContact != nil) {
                                       if (self.mainContact.comments != nil && self.mainContact.comments.count > 0) {
                                           self.posts = self.mainContact.comments.allObjects;
                                       } else {
                                           self.posts = [NSArray new];
                                       }
                                   } else if (self.mainGroup != nil) {
                                       if (self.mainGroup.comment != nil && self.mainGroup.comment.count > 0) {
                                           self.posts = self.mainGroup.comment.allObjects;
                                       } else {
                                           self.posts = [NSArray new];
                                       }
                                   }
                                   if (self.posts != nil && self.posts.count > 0) {
                                       NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"postedOn"
                                                                                                        ascending:NO];
                                       self.posts = [self.posts sortedArrayUsingDescriptors:@[sortDescriptor]];
                                       
                                       [self.emptyPostsLabel setHidden:YES];
                                       [self.postsTableView setHidden:NO];
                                       [self.postsTableView reloadData];
                                   } else {
                                       self.posts = [[NSArray alloc] init];
                                       [self.postsTableView setHidden:YES];
                                       if (self.launchMode == kContactDetailLaunchModeSuggestedGroup ||
                                           self.launchMode == kContactDetailLaunchModeSuggestedContact) {
                                       } else {
                                           [self.emptyPostsLabel setHidden:NO];
                                       }
                                   }
                               }];
}

- (void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupUIWithContactDetails {
    
    [self.groupDesc setHidden:YES];
    [self.groupMembersView setHidden:true];
    self.groupMembersHeightConstraint.constant = 0;
    self.groupDescHeightConstraint.constant = 0;
    
    _deleteBtnHeight.constant = 40;
    _city.hidden = NO;
    
    [MRAppControl getContactImage:self.mainContact andImageView:self.mainImageView];
    self.mainLabel.text = [MRAppControl getContactName:self.mainContact];
    
    NSString *therapauticArea = @"";
    if (_mainContact.therapeuticArea != nil && _mainContact.therapeuticArea.length > 0) {
        therapauticArea = _mainContact.therapeuticArea;
    } else if (_mainContact.therapeuticName != nil && _mainContact.therapeuticName.length > 0) {
        therapauticArea = _mainContact.therapeuticName;
    }
    
    [self.subHeadingLabel setText:[NSString stringWithFormat:@"Therapeutic Area: %@", therapauticArea]];
    
    NSString *city = @"";
    if (_mainContact.city != nil && _mainContact.city.length > 0) {
        city = _mainContact.city;
    }
    
    _city.text = [NSString stringWithFormat:@"City: %@",city];
    
    self.groupsUnderContact = [self.mainContact.groups allObjects];
}

- (IBAction)viewMoreOption:(id)sender{
   MemberListViewController *membeVC = [[MemberListViewController alloc] init];
    membeVC.contactsUnderGroup = [self.contactsUnderGroup copy];
    [self.navigationController pushViewController:membeVC animated:NO];
}

- (void)setupUIWithGroupDetails {
    self.navigationItem.title = @"Group Details";
   
    if (self.launchMode == kContactDetailLaunchModeSuggestedGroup) {
        [self.groupMembersView setHidden:true];
        self.groupMembersHeightConstraint.constant = 0;
    } else {
        [self.groupMembersView setHidden:false];
    }
    
    [_city setHidden:YES];
    
    [MRAppControl getGroupImage:self.mainGroup andImageView:self.mainImageView];
    self.mainLabel.text = self.mainGroup.group_name;
    self.subHeadingLabel.text = self.mainGroup.group_short_desc;
    self.groupDesc.text = self.mainGroup.group_long_desc;
    
    if (self.mainGroup.members != nil && self.mainGroup.members.count > 0) {
        self.contactsUnderGroup = [self.mainGroup.members allObjects];
    } else {
        self.contactsUnderGroup = [NSArray new];
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
    CGFloat rowHeight = 240;
    MRPostedReplies *post = [self.posts objectAtIndex:indexPath.row];
    
    if (post.fileUrl == nil || post.fileUrl.length == 0) {
        rowHeight -= 146;
    }
    
    if (post.message == nil && post.message.length == 0) {
        rowHeight -= 15;
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
    
    [cell fillCellWithData:childPost andParentViewController:self];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)commentButtonTapped:(MRSharePost *)post {
    [self setupCommentBox];
    [_commentBoxView setData:nil group:nil andSharedPost:post];
}

- (void)setupCommentBox {
    _commentBoxKLCPopView = [MRAppControl setupCommentBox:self];
    _commentBoxView = (CommonBoxView*)(_commentBoxKLCPopView.contentView);
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
        if (self.contactsUnderGroup.count>2) {
            return 2;
        }else{
            return self.contactsUnderGroup.count;
        }
//        return 2;
//        return self.contactsUnderGroup.count;
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
    return CGSizeMake(150, 60);
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
    
    if (self.mainGroup != nil && self.mainGroup.admin_id != nil) {
        NSInteger adminId = self.mainGroup.admin_id.longValue;
        NSNumber *loggedInDoctorId = [MRAppControl sharedHelper].userRegData[@"doctorId"];
        if (loggedInDoctorId != nil && loggedInDoctorId.longValue == adminId) {
            canEditGroup = true;
        }
    }
    
    if (self.mainGroup) {
        self.moreOptions = [[UIActionSheet alloc] initWithTitle:@"More Options"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Pending Members", nil];
        if (canEditGroup) {
            self.moreOptions = [[UIActionSheet alloc] initWithTitle:@"More Options"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Pending Members", @"Invite Members", @"Update Group", @"Leave Group", nil];
        }
    }
    
    [self.moreOptions showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (self.launchMode == kContactDetailLaunchModeContact) {
            MRAddMembersViewController* detailViewController = [[MRAddMembersViewController alloc] init];
            detailViewController.groupID = 0;
            [self.navigationController pushViewController:detailViewController animated:NO];
        } else {
            if (self.mainGroup != nil && canEditGroup) {
                MRAddMembersViewController* detailViewController = [[MRAddMembersViewController alloc] init];
                detailViewController.groupID = self.mainGroup.group_id.longValue;
                [self.navigationController pushViewController:detailViewController animated:NO];
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

- (void)joinGroup {
    NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithLong:self.mainGroup.group_id.longValue], @"group_id",
                         @"PENDING", @"status",
                         [MRAppControl sharedHelper].userRegData[@"doctorId"], @"member_id",
                         nil];
    
    [MRCommon showActivityIndicator:@"Joining..."];
    [[MRWebserviceHelper sharedWebServiceHelper] joinGroup:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                                object:nil];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:NSLocalizedString(kJoinedGroup, "")
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag = 11;
            [alert show];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] joinGroup:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status)
                     {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                         message:NSLocalizedString(kJoinedGroup, "")
                                                                        delegate:self
                                                               cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
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
        [self fetchPosts];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                            object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else if (alertView.tag == 12) {
        if (buttonIndex) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                                object:nil];
            
            [self deleteConnection];
        }
    }
}

#pragma mark
-(void)takePhoto:(UIImagePickerControllerSourceType)type {
    [_commentBoxKLCPopView setHidden:YES];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = type;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [_commentBoxView setImageForShareImage:chosenImage];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [_commentBoxKLCPopView setHidden:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [_commentBoxKLCPopView setHidden:NO];
}

- (void)getGroupMembersStatusWithGroupId{
    [MRDatabaseHelper getGroupMemberStatusWithId:self.mainGroup.group_id.longValue
                                      andHandler:^(id result) {
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"group_id", self.mainGroup.group_id.longValue];
        NSArray *tempResults = result;
        tempResults = [tempResults filteredArrayUsingPredicate:predicate];
          if (tempResults != nil && tempResults.count > 0) {
              MRGroup *tempGroup = tempResults.firstObject;
              self.mainGroup = tempGroup;
              if (tempGroup.members != nil && tempGroup.members.count > 0) {
                  self.contactsUnderGroup = tempGroup.members.allObjects;
              } else {
                  self.contactsUnderGroup = [NSArray new];
              }
          } else {
              self.contactsUnderGroup = [NSArray new];
          }
                                          
//        if (self.contactsUnderGroup.count>2) {
//            [self.viewAllGroupMembers setHidden:NO];
//            
//        } else {
//            [self.viewAllGroupMembers setHidden:YES];
//        }
                                          
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
                          if ([vc isKindOfClass:[MRContactsViewController class]]) {
                              [self.navigationController popToViewController:vc animated:YES];
                          }
                      }
                  }];
}

- (IBAction)postTopicButtonTapped:(id)sender {
    _commentBoxKLCPopView = [MRAppControl setupCommentBox:self];
    _commentBoxView = (CommonBoxView*)(_commentBoxKLCPopView.contentView);
}

#pragma mark - CommonBoxView Delegate methods
- (void)commonBoxCancelButtonPressed {
    [_commentBoxKLCPopView dismissPresentingPopup];
}

- (void)commentPosted {
    [_commentBoxKLCPopView dismissPresentingPopup];
    
    [MRDatabaseHelper postANewTopic:nil withHandler:^(id result) {
        
    }];
    
//    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(refetchPost:)]) {
//        [self.delegate refetchPost:self.indexPath];
//    }
//    
//    [_commentBoxKLCPopView dismissPresentingPopup];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"sharePostId", self.post.sharePostId.longValue];
//    self.post = [[MRDataManger sharedManager] fetchObject:kMRSharePost predicate:predicate];
//    
//    self.recentActivity = nil;
//    if (self.post.postedReplies != nil && self.post.postedReplies.count > 0) {
//        self.recentActivity = self.post.postedReplies.allObjects;
//    }
//    
//    [self setCountInLabels];
//    [self.activitiesTable reloadData];
}

- (void)commentPostedWithData:(NSString *)message andImageData:(NSData *)imageData
                withSharePost:(MRSharePost *)sharePost {
    [_commentBoxKLCPopView dismissPresentingPopup];
    
    NSString *messageType = @"Text";
    
    if (imageData != nil) {
        messageType = @"image";
    }
    
    NSMutableDictionary *postMessage = [NSMutableDictionary new];
    
    NSInteger receiverId = 0;
    if (self.mainContact != nil) {
        receiverId = self.mainContact.doctorId.longValue;
        [postMessage setObject:@[[NSNumber numberWithLong:receiverId]] forKey:@"receiverId"];
    } else {
        receiverId = self.mainGroup.group_id.longValue;
        [postMessage setObject:@[[NSNumber numberWithLong:receiverId]] forKey:@"groupId"];
    }
    
    [postMessage setObject:[NSNumber numberWithInteger:2] forKey:@"postType"];
    [postMessage setObject:messageType forKey:@"message_type"];
    
    if (imageData != nil) {
       [postMessage setObject:[MRAppControl getFileName] forKey:@"fileName"];
        
        NSString *jsonData = [imageData base64EncodedStringWithOptions:0];
        [postMessage setObject:jsonData forKey:@"fileData"];
    }
    
    NSDictionary *dataDict = @{@"detail_desc" : message,
                               @"title_desc" : @"",
                               @"short_desc" : @"",
                               @"postMessage" : postMessage
                               };

    [MRDatabaseHelper postANewTopic:dataDict withHandler:^(id result) {
        [self fetchPosts];
    }];
}

-(void)commonBoxCameraGalleryButtonTapped{
    [self takePhoto:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)commonBoxCameraButtonTapped {
    [self takePhoto:UIImagePickerControllerSourceTypeCamera];
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

- (void)viewAllGroupMembersTapped {
    MRGroupMembersViewController *groupMembersViewController = [MRGroupMembersViewController new];
    [groupMembersViewController setGroup:self.mainGroup];
    [self.navigationController pushViewController:groupMembersViewController
                                         animated:YES];
}

@end

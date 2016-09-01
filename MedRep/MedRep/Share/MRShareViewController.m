//
//  MRContactDetailViewController.m
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/22/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRShareViewController.h"
#import "MRGroupPostItemTableViewCell.h"
#import "MRContactWithinGroupCollectionCellCollectionViewCell.h"
#import "MRDatabaseHelper.h"
#import "SWRevealViewController.h"
#import "MRContact.h"
#import "MRGroup.h"
#import "MRTransformViewController.h"
#import "MRGroupsListViewController.h"
#import "PendingContactsViewController.h"
#import "MRContactsViewController.h"
#import "MRServeViewController.h"
#import "MRCustomTabBar.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRShareOptionsViewController.h"
#import "MRShareDetailViewController.h"
#import "MRGroupPost.h"
#import "KLCPopup.h"
#import "CommonBoxView.h"
#import "MRCommentViewController.h"
#import "MRWebserviceHelper.h"
#import "MRSharePost.h"

@interface MRShareViewController () <UISearchBarDelegate, SWRevealViewControllerDelegate, MRGroupPostItemTableViewCellDelegate, MRShareOptionsSelectionDelegate,
    CommonBoxViewDelegate,
    UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, PostDataUpdated,
UIImagePickerControllerDelegate>

@property (nonatomic) NSIndexPath *reloadIndexPath;
@property (nonatomic) BOOL reloadRows;

@property (weak, nonatomic) IBOutlet UILabel *emptyMessage;

@property (weak, nonatomic) IBOutlet UITableView* postsTableView;
@property (weak,nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray* contactsUnderGroup;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;
@property (strong, nonatomic) NSArray* groupsUnderContact;
@property (strong, nonatomic) NSArray* posts;
@property (strong, nonatomic) IBOutlet UIView *navView;

@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;

@property (strong, nonatomic) UIView *tabBarView;
@property (nonatomic) MRShareOptionsViewController *shareOptionsVC;


@property (strong,nonatomic) KLCPopup *commentBoxKLCPopView;
@property (strong,nonatomic) CommonBoxView *commentBoxView;
@property (strong, nonatomic) NSMutableArray *serachResults;
@end

@implementation MRShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Share";
    
    SWRevealViewController *revealController = [self revealViewController];
    revealController.delegate = self;
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController
                                                                        action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    self.tapGesture.numberOfTapsRequired = 1;
    self.tapGesture.cancelsTouchesInView = YES;
    self.tapGesture.enabled = NO;
    [self.view addGestureRecognizer:self.tapGesture];
        
//    [self fetchPosts];
    
    MRCustomTabBar *tabBarView = (MRCustomTabBar*)[MRCommon createTabBarView:self.view];
    [tabBarView setNavigationController:self.navigationController];
    [tabBarView setShareViewController:self];
    [tabBarView updateActiveViewController:self andTabIndex:DoctorPlusTabShare];
    
    self.tabBarView = (UIView*)tabBarView;
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.postsTableView
                                                                        attribute:NSLayoutAttributeBottomMargin
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0 constant:0];
    
    [self.view addConstraint:bottomConstraint];
    
    // Do any additional setup after loading the view from its nib.
    [self.postsTableView registerNib:[UINib nibWithNibName:@"MRGroupPostItemTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"groupCell"];
    self.postsTableView.estimatedRowHeight = 250;
    self.postsTableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MRCommon applyNavigationBarStyling:self.navigationController];
    
    if (self.reloadRows) {
        [self reloadView];
    }
    
    [self fetchPostsFromServer];
}

- (void)fetchPostsFromServer {
    [MRDatabaseHelper fetchShare:^(id result) {
        [MRCommon stopActivityIndicator];

        [self fetchPosts];
        [self.postsTableView reloadData];
    }];
    self.reloadRows = false;
}

- (void)setEmptyMessage {
    if (self.posts.count == 0) {
        [self.emptyMessage setHidden:false];
        [self.postsTableView setHidden:true];
    } else {
        [self.emptyMessage setHidden:true];
        [self.postsTableView setHidden:false];
    }
}

- (void)fetchPosts {
    self.posts = [MRDatabaseHelper getShareArticles];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"postedOn" ascending:false];
    NSSortDescriptor *sortTitleDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"titleDescription" ascending:true];
    NSSortDescriptor *sortNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sharedByProfileName" ascending:true];
    self.posts = [self.posts sortedArrayUsingDescriptors:@[sortDescriptor, sortTitleDescriptor, sortNameDescriptor]];
    
    self.serachResults = [self.posts mutableCopy];
    [self setEmptyMessage];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 200;
        
    }
    return UITableViewAutomaticDimension;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    
    return self.serachResults.count;
}
- (void)viewTapped:(UITapGestureRecognizer*)tapGesture {
    [self.searchBar resignFirstResponder];
    self.tapGesture.enabled = NO;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRGroupPostItemTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell"];
    
    NSInteger tagIndex = (indexPath.section + indexPath.row) * 100;
    [cell setTag:tagIndex];
    [cell setParentTableView:self.postsTableView];
    [cell setDelegate:self];
    
    if (cell == nil)
    {
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"MRGroupPostItemTableViewCell" owner:nil options:nil];
        cell = (MRGroupPostItemTableViewCell *)[nibViews lastObject];
    }
    
    
    [cell setPostContent:[self.serachResults objectAtIndex:indexPath.row] tagIndex:tagIndex
 andParentViewController:self];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    MRShareDetailViewController *shareDetailViewController =
                [[MRShareDetailViewController alloc] initWithNibName:@"MRShareDetailViewController"
                                                              bundle:nil];
    [shareDetailViewController setDelegate:self];
    [shareDetailViewController setIndexPath:indexPath];
    
    [shareDetailViewController setPost:self.serachResults[indexPath.row]];
    
    [self.navigationController pushViewController:shareDetailViewController animated:true];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)connectButtonTapped {
    MRContactsViewController* contactsViewCont = [[MRContactsViewController alloc] initWithNibName:@"MRContactsViewController" bundle:nil];
    MRGroupsListViewController* groupsListViewController = [[MRGroupsListViewController alloc] initWithNibName:@"MRGroupsListViewController" bundle:[NSBundle mainBundle]];
    contactsViewCont.groupsListViewController = groupsListViewController;
    
    [self.navigationController pushViewController:contactsViewCont animated:NO];
}

- (void)transformButtonTapped {
    MRTransformViewController *notiFicationViewController = [[MRTransformViewController alloc] initWithNibName:@"MRTransformViewController" bundle:nil];
    [self.navigationController pushViewController:notiFicationViewController animated:NO];
}

- (void)serveButtonTapped {
    MRServeViewController *notiFicationViewController = [[MRServeViewController alloc] initWithNibName:@"MRServeViewController" bundle:nil];
    [self.navigationController pushViewController:notiFicationViewController animated:NO];
}





- (void)likeButtonTapped:(NSInteger)index {
    MRSharePost *currentPost;
    if (self.posts != nil && self.posts.count > 0) {
        currentPost = [self.posts objectAtIndex:index];
    }
    
    [[MRWebserviceHelper sharedWebServiceHelper] updateLikes:3
                                                   likeCount:currentPost.likesCount.longValue
                                                commentCount:currentPost.commentsCount.longValue
                                                  shareCount:currentPost.shareCount.longValue
                                                   messageId:currentPost.sharePostId.longValue
                                                 withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                                                     [self fetchPosts];
                                                 }];
}

- (void)shareButtonTapped:(MRSharePost*)groupPost {
    self.shareOptionsVC = [[MRShareOptionsViewController alloc] initWithNibName:@"MRShareOptionsViewController" bundle:nil];
    [self.shareOptionsVC setDelegate:self];
    [self.shareOptionsVC setParentPost:groupPost];
    [self.navigationController pushViewController:self.shareOptionsVC animated:YES];
}

- (void)shareToSelected {
    [self.postsTableView reloadData];
}

- (void)commentButtonTapped:(MRSharePost *)post {
    [self setupCommentBox];
    [_commentBoxView setData:nil group:nil andSharedPost:post];
}

- (void)setupCommentBox {
    _commentBoxKLCPopView = [MRAppControl setupCommentBox:self];
    _commentBoxView = (CommonBoxView*)(_commentBoxKLCPopView.contentView);
}

#pragma mark
#pragma CAMERA IMAGE CAPTURE

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

- (void)refetchPost:(NSIndexPath *)indexPath {
    self.reloadRows = true;
    self.reloadIndexPath = indexPath;
}

- (void)reloadView {
    [self fetchPosts];
    [self.postsTableView reloadRowsAtIndexPaths:@[self.reloadIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark - SearchBar Delegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    
    if ([searchText isEqualToString:@""]) {
        self.serachResults = [self.posts  mutableCopy];
        //        [self.contentTableView reloadData];
        
    }else{
        
        self.serachResults  =  [[self.posts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K contains[cd] %@)",@"titleDescription",searchText]] mutableCopy];
        
           }
  [self. postsTableView reloadData];
    
    
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    searchBar.text=@"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.postsTableView.allowsSelection = YES;
    self.postsTableView.scrollEnabled = YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.tapGesture.enabled = YES;
}

- (IBAction)postANewShareTopicButtonTapped:(id)sender {
}

#pragma mark - CommonBoxView Delegate methods
- (void)commonBoxCancelButtonPressed {
    [_commentBoxKLCPopView dismiss:YES];
}

- (void)commentPosted {
    [_commentBoxKLCPopView dismissPresentingPopup];
    [self fetchPosts];
    [self.postsTableView reloadData];
}

- (void)commentPostedWithData:(NSString *)message andImageData:(NSData *)imageData
                withSharePost:(MRSharePost *)sharePost {
    [_commentBoxKLCPopView dismissPresentingPopup];
    
    NSString *messageType = @"Text";
    
    if (imageData != nil) {
        messageType = @"image";
    }
    
    NSInteger messageIndex = 4;
    NSMutableDictionary *postMessage = [NSMutableDictionary new];
    
    if (_commentBoxView.tag == 1000) {
        messageIndex = 1;
    }
    [postMessage setObject:[NSNumber numberWithInteger:messageIndex] forKey:@"postType"];
    
    [postMessage setObject:messageType forKey:@"message_type"];
    
    if (imageData != nil) {
        [postMessage setObject:[MRAppControl getFileName] forKey:@"fileName"];

        NSString *jsonData = [imageData base64EncodedStringWithOptions:0];
        [postMessage setObject:jsonData forKey:@"fileData"];
    }
    
    NSDictionary *dataDict;
    if (_commentBoxView.tag == 1000) {
        dataDict = @{@"detail_desc" : message,
                     @"title_desc" : @"",
                     @"short_desc" : @"",
                     @"postMessage" : postMessage
                     };
    } else {
        [postMessage setObject:message forKey:@"message"];
        dataDict = @{@"topic_id" : [NSNumber numberWithLong:sharePost.sharePostId.longValue],
                               @"postMessage" : postMessage
                    };
    }
    
    [MRDatabaseHelper postANewTopic:dataDict withHandler:^(id result) {
        NSInteger commentsCount = 0;
        if (sharePost != nil && sharePost.commentsCount != nil) {
            commentsCount = sharePost.commentsCount.longValue;
        }
        
        sharePost.commentsCount = [NSNumber numberWithLong:commentsCount+1];
        [sharePost.managedObjectContext save:nil];
        
        [self fetchPostsFromServer];
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
    
    MRGroupPost *post = [self.serachResults objectAtIndex:indexPath.row];
    //obtaining saving path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSInteger childPostCounter = [APP_DELEGATE counterForChildPost];
    
    NSString *postID = [NSString stringWithFormat:@"%ld_%ld",post.groupPostId.integerValue,(long)childPostCounter];
    
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
    //    self.mainContact =  [[MRDatabaseHelper getContactListForContactID:self.mainContact.contactId]  objectAtIndex:0];
    //    self.posts = [self.mainContact.groupPosts allObjects];
    //    [self totalPosts];
    //    [self.postsTableView reloadData];
}

- (IBAction)postANewTopicButtonClicked:(id)sender {
    [self setupCommentBox];
    [_commentBoxView setData:nil group:nil andSharedPost:nil];
    
    [_commentBoxView setTag:1000];
}

@end

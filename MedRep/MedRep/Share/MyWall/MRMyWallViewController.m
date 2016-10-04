//
//  MRMyWallViewController.m
//  MedRep
//
//  Created by Vamsi Katragadda on 10/1/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRMyWallViewController.h"
#import "MRCustomTabBar.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRDatabaseHelper.h"
#import "SWRevealViewController.h"
#import "MRMyWallItemTableViewCell.h"
#import "MRShareViewController.h"
#import "MRShareDetailViewController.h"
#import "MRContactDetailViewController.h"
#import "MRSharePost.h"
#import "MRPostedReplies.h"
#import "MRGroup.h"
#import "MRContact.h"

@interface MRMyWallViewController () <UITableViewDelegate, UITableViewDataSource,
                                      SWRevealViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *emptyMessage;
@property (weak, nonatomic) IBOutlet UITableView* postsTableView;
@property (weak,nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *takeMeToGlobalShare;

@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;

@property (strong, nonatomic) NSArray* searchResults;
@property (strong, nonatomic) NSArray* posts;

@end

@implementation MRMyWallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"My Share";
    
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
    
    MRCustomTabBar *tabBarView = (MRCustomTabBar*)[MRCommon createTabBarView:self.view];
    [tabBarView setNavigationController:self.navigationController];
    [tabBarView setShareViewController:self];
    [tabBarView updateActiveViewController:self andTabIndex:DoctorPlusTabShare];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.takeMeToGlobalShare
                                                                        attribute:NSLayoutAttributeBottomMargin
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0 constant:0];
    
    [self.view addConstraint:bottomConstraint];
    
    // Do any additional setup after loading the view from its nib.
    [self.postsTableView registerNib:[UINib nibWithNibName:@"MRMyWallItemTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"wallCell"];
    
    self.postsTableView.estimatedRowHeight = 250;
    self.postsTableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.takeMeToGlobalShare.layer setCornerRadius:5.0];
    [self.takeMeToGlobalShare.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.takeMeToGlobalShare.layer setBorderWidth:1.0f];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    self.tapGesture.numberOfTapsRequired = 1;
    self.tapGesture.cancelsTouchesInView = YES;
    self.tapGesture.enabled = NO;
    [self.view addGestureRecognizer:self.tapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MRCommon applyNavigationBarStyling:self.navigationController];
    [self fetchPostsFromServer];
}

- (void)fetchPostsFromServer {
    [MRDatabaseHelper fetchMyWallPosts:^(id result) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSDate date] forKey:kLastSyncTimeForMyWall];
        [userDefaults synchronize];
        
        [MRCommon stopActivityIndicator];
        
        [self fetchPosts];
        [self.postsTableView reloadData];
    }];
}

- (void)setEmptyMessage {
    if (self.searchResults.count == 0) {
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
    
    self.searchResults = self.posts;
    [self setEmptyMessage];
}

- (void)viewTapped:(UITapGestureRecognizer*)tapGesture {
    [self.searchBar resignFirstResponder];
//    self.tapGesture.enabled = NO;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 200;
        
    }
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionsCount = 0;
    
    if (self.searchResults != nil) {
        sectionsCount = self.searchResults.count;
    }
    
    return sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    
    if (self.searchResults != nil && self.searchResults.count > 0) {
        MRSharePost *sharePost = [self.searchResults objectAtIndex:section];
        if (sharePost != nil && sharePost.postedReplies != nil) {
            rows = sharePost.postedReplies.count;
        }
    }
    
    return rows;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [UIView new];
    [view setBackgroundColor:[UIColor whiteColor]];
    return view;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    MRMyWallItemTableViewCell *cell = [self createCell:tableView subLevel:NO andIndexPath:indexPath];
    [cell setTag:section];
    [cell.contentView setTag:section];
    
    NSInteger rows = 0;
//    if (self.searchResults != nil && self.searchResults.count > 0) {
//        MRSharePost *sharePost = [self.searchResults objectAtIndex:section];
//        if (sharePost != nil && sharePost.postedReplies != nil) {
//            rows = sharePost.postedReplies.count;
//        }
//    }
    
    if (rows == 0) {
        [cell.borderView setHidden:YES];
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(sectionTapped:)];
    [tapGesture setNumberOfTapsRequired:1];
    [cell.contentView addGestureRecognizer:tapGesture];
    [cell layoutIfNeeded];
    
    return cell.contentView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRMyWallItemTableViewCell* cell = [self createCell:tableView subLevel:YES andIndexPath:indexPath];
    
    NSInteger rows = 0;
    if (self.searchResults != nil && self.searchResults.count > 0) {
        MRSharePost *sharePost = [self.searchResults objectAtIndex:indexPath.section];
        if (sharePost != nil && sharePost.postedReplies != nil) {
            rows = sharePost.postedReplies.count;
        }
    }
    
    if (rows == 0 || indexPath.row == rows - 1) {
        [cell.borderView setHidden:YES];
    }
    
    [cell layoutIfNeeded];
    return cell;
}

- (MRMyWallItemTableViewCell*)createCell:(UITableView*)tableView subLevel:(BOOL)subLevel
                  andIndexPath:(NSIndexPath*)indexPath {
    MRMyWallItemTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"wallCell"];
    
    NSInteger tagIndex = (indexPath.section + indexPath.row) * 100;
    [cell setTag:tagIndex];
    [cell setParentTableView:self.postsTableView];
    
    if (cell == nil)
    {
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"MRMyWallItemTableViewCell" owner:nil options:nil];
        cell = (MRMyWallItemTableViewCell *)[nibViews lastObject];
    }
    
    if (subLevel) {
        MRSharePost *sharePost =  [self.searchResults objectAtIndex:indexPath.section];
        if (sharePost != nil && sharePost.postedReplies.count > 0) {
            NSArray *postedReplies = sharePost.postedReplies.allObjects;
            [cell setPostedReplyContent:[postedReplies objectAtIndex:indexPath.row]
                               tagIndex:tagIndex
                andParentViewController:self];
        }
    } else {
        [cell setPostContent:[self.searchResults objectAtIndex:indexPath.section]
                    tagIndex:tagIndex
                        andParentViewController:self];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self launchShareDetailPage:indexPath.section];
}

- (void)sectionTapped:(id)sender {
    NSInteger section = [(UIGestureRecognizer *)sender view].tag;
    [self launchShareDetailPage:section];
}

- (void)launchShareDetailPage:(NSInteger)section {
    MRSharePost *post = [self.searchResults objectAtIndex:section];
    if (post != nil) {
        if (post.parentSharePostId != nil && post.parentSharePostId.longValue > 0) {
            MRShareDetailViewController *shareDetailViewController =
            [[MRShareDetailViewController alloc] initWithNibName:@"MRShareDetailViewController"
                                                          bundle:nil];
            
            [shareDetailViewController setPost:post];
            
            [self.navigationController pushViewController:shareDetailViewController animated:true];
        } else {
            ContactDetailLaunchMode launchMode = kContactDetailLaunchModeNone;
            
            if (post.groupId != nil && post.groupId.longValue > 0) {
                launchMode = kContactDetailLaunchModeGroup;
                [MRDatabaseHelper getGroupDetail:post.groupId.longValue
                                       withHandler:^(id result) {
                                           if (result != nil) {
                                               NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"group_id",post.groupId.longValue];
                                               id object = [[MRDataManger sharedManager] fetchObject:kGroupEntity predicate:predicate];
                                               
                                               MRContactDetailViewController* detailViewController = [[MRContactDetailViewController alloc] init];
                                               [detailViewController setGroup:object];
                                               [detailViewController setLaunchMode:launchMode];
                                               [self.navigationController pushViewController:detailViewController animated:YES];
                                           } else {
                                               [MRCommon stopActivityIndicator];
                                               [MRCommon showAlert:@"Failed to fetch group !!!" delegate:nil];
                                           }
                                       }];
            } else if (post.contactId != nil && post.contactId.longValue > 0) {
                launchMode = kContactDetailLaunchModeContact;
                [MRDatabaseHelper getContactDetail:post.contactId.longValue
                                       withHandler:^(id result) {
                                           if (result != nil) {
                                               NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"contactId",post.contactId.longValue];
                                               id object = [[MRDataManger sharedManager] fetchObject:kContactEntity predicate:predicate];
                                               
                                               MRContactDetailViewController* detailViewController = [[MRContactDetailViewController alloc] init];
                                               [detailViewController setContact:object];
                                               [detailViewController setLaunchMode:launchMode];
                                               [self.navigationController pushViewController:detailViewController animated:YES];
                                           } else {
                                               [MRCommon stopActivityIndicator];
                                               [MRCommon showAlert:@"Failed to fetch contact !!!" delegate:nil];
                                           }
                                       }];
            } else {
                
            }
        }
    }
}

- (IBAction)takeMeToGlobalShareButtonTapped:(id)sender {
    MRShareViewController *shareViewController = [[MRShareViewController alloc] initWithNibName:@"MRShareViewController" bundle:nil];

    [self.navigationController pushViewController:shareViewController animated:YES];
}

#pragma mark - SearchBar Delegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        self.searchResults = self.posts;
    }else{
        self.searchResults  =  [[self.posts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K contains[cd] %@)",@"titleDescription",searchText]] mutableCopy];
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

@end

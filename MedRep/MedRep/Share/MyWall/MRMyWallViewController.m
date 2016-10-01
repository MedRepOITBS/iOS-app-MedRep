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
#import "MRSharePost.h"

@interface MRMyWallViewController () <UITableViewDelegate, UITableViewDataSource,
                                      SWRevealViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *emptyMessage;
@property (weak, nonatomic) IBOutlet UITableView* postsTableView;
@property (weak,nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSArray* searchResults;
@property (strong, nonatomic) NSArray* posts;

@end

@implementation MRMyWallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    
    MRCustomTabBar *tabBarView = (MRCustomTabBar*)[MRCommon createTabBarView:self.view];
    [tabBarView setNavigationController:self.navigationController];
    [tabBarView setShareViewController:self];
    [tabBarView updateActiveViewController:self andTabIndex:DoctorPlusTabShare];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.postsTableView
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
    return UITableViewAutomaticDimension;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 250;
//}

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
    rows++;
    
    return rows;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width - 70, 200);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [view setTag:section];
    [view setBackgroundColor:[UIColor redColor]];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    UITableViewCell *cell = [self createCell:tableView subLevel:NO andIndexPath:indexPath];
    [view addSubview:cell];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(sectionTapped:)];
    [tapGesture setNumberOfTapsRequired:1];
    [view addGestureRecognizer:tapGesture];
    
    return view;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL subLevel = NO;
    if (indexPath.row > 0) {
        subLevel = YES;
    }
    
    UITableViewCell* cell = [self createCell:tableView subLevel:subLevel andIndexPath:indexPath];
    [cell layoutIfNeeded];
    return cell;
}

- (UITableViewCell*)createCell:(UITableView*)tableView subLevel:(BOOL)subLevel
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
            [cell setPostedReplyContent:[postedReplies objectAtIndex:indexPath.row - 1]
                               tagIndex:tagIndex
                andParentViewController:self];
        }
    } else {
        [cell setPostContent:[self.searchResults objectAtIndex:indexPath.row]
                    tagIndex:tagIndex
                        andParentViewController:self];
    }
    
    return cell;
}

- (void)sectionTapped:(id)selector {
    
}

@end

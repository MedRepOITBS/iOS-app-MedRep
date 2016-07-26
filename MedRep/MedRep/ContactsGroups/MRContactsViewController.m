    //
//  MRContactsViewController.m
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRContactsViewController.h"
#import "MRContactCollectionCell.h"
#import "MRGroupsListViewController.h"
#import "UIPopoverController+iPhone.h"
#import "MRPopoverControllerViewController.h"
#import "MRContactDetailViewController.h"
#import "PendingContactsViewController.h"
#import "PieMenu.h"
#import "MRConstants.h"
#import "MRServeViewController.h"
#import "MRShareViewController.h"
#import "MRTransformViewController.h"
#import "SWRevealViewController.h"
#import "MRTransformTitleCollectionViewCell.h"
#import "MRGroup.h"
#import "MRCreateGroupViewController.h"
#import "MRAddMembersViewController.h"
#import "MRJoinGroupViewController.h"
#import "MRCustomTabBar.h"

@interface MRContactsViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate,UISearchBarDelegate, SWRevealViewControllerDelegate>{
    
    NSArray *groupsArray;
    NSMutableArray *filteredGroupsArray;
    
    NSArray *suggestedGroupsArray;
    NSMutableArray *filteredSuggestedGroupsArray;
    int i;
    NSTimer *timer;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreOptionsWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreOptionsTrailingConstraint;

@property (weak, nonatomic) IBOutlet UICollectionView* myContactsCollectionView;
//@property (weak, nonatomic) IBOutlet UICollectionView* suggestedContactsCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView* titlesCollectionView;
@property (weak, nonatomic) IBOutlet UISearchBar* searchBar;
@property (weak, nonatomic) IBOutlet UIButton* switchButton;
@property (weak, nonatomic) IBOutlet UIButton* moreOptions;
@property (weak, nonatomic) IBOutlet UITabBar* tabBar;
//@property (weak, nonatomic) IBOutlet UITabBarItem* myContactsButton;
//@property (weak, nonatomic) IBOutlet UITabBarItem* suggestedContactsButton;
@property (strong, nonatomic) UIActionSheet *menu;
@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;
//@property (strong, nonatomic) IBOutlet PieMenu *pieMenu;
@property NSArray *categories;
@property NSInteger currentIndex;
@property (strong, nonatomic) NSMutableArray* myContacts;
@property (strong, nonatomic) NSMutableArray* fileredContacts;
@property (strong, nonatomic) NSMutableArray* suggestedContacts;
@property (strong, nonatomic) NSMutableArray* allContactsByCity;
@property (strong, nonatomic) NSMutableArray* doctorContacts;
@property (strong, nonatomic) NSMutableArray* fileredSuggestedContacts;
@property (weak, nonatomic) IBOutlet UILabel *noContactErrorMsgLbl;
@property (weak, nonatomic) IBOutlet UIButton *clickHereToAddBtn;
@property (strong, nonatomic) IBOutlet UIView *navView;

@end

@implementation MRContactsViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    self.tapGesture.numberOfTapsRequired = 1;
    self.tapGesture.cancelsTouchesInView = YES;
    self.tapGesture.enabled = NO;
    [self.view addGestureRecognizer:self.tapGesture];
    
    //[self setupPieMenu];
    //[self.tabBar setSelectedItem:self.myContactsButton];
    //self.suggestedContactsCollectionView.hidden = YES;
    [self.myContactsCollectionView registerNib:[UINib nibWithNibName:@"MRContactCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"contactCell"];
    [self.titlesCollectionView registerNib:[UINib nibWithNibName:@"MRTransformTitleCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"transformTitleCollectionViewCell"];
    //[self.suggestedContactsCollectionView registerNib:[UINib nibWithNibName:@"MRContactCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"contactCell"];
    [self readData];
    self.fileredContacts = self.myContacts;
    
    self.navigationItem.title = @"Connect";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
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
    
    self.categories = @[@"My Connections", @"Suggested Connections", @"My Groups", @"Suggested Groups"];
    _currentIndex = 0;
    
    filteredGroupsArray = [NSMutableArray array];
    groupsArray = [NSMutableArray array];
    filteredSuggestedGroupsArray = [NSMutableArray array];
    suggestedGroupsArray = [NSMutableArray array];
    
    self.noContactErrorMsgLbl.hidden = YES;
    self.clickHereToAddBtn.hidden = YES;
    
    MRCustomTabBar *tabBarView = (MRCustomTabBar*)[MRCommon createTabBarView:self.view];
    [tabBarView setNavigationController:self.navigationController];
    [tabBarView setContactsViewController:self];
    [tabBarView updateActiveViewController:self andTabIndex:DoctorPlusTabConnect];

    [self fetchDataFromServer];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.searchBar resignFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshData)
                                                 name:kNotificationRefreshContactList                                               object:nil];
    
    [self updatePlusButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(AutoScroll) userInfo:nil repeats:YES];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    i = 0;
    [timer invalidate];
}

- (void)updatePlusButton {
    if (self.currentIndex == 1 || self.currentIndex == 3) {
        [self.moreOptions setHidden:true];
        self.moreOptionsWidthConstraint.constant = 0;
        self.moreOptionsTrailingConstraint.constant = 0;
    } else {
        [self.moreOptions setHidden:false];
        self.moreOptionsWidthConstraint.constant = 30;
        self.moreOptionsTrailingConstraint.constant = 20;
    }
}

- (void)refreshData {
    [self fetchDataFromServer];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationRefreshContactList object:nil];
}

- (void)fetchDataFromServer {
    if (self.currentIndex == 0) {
        [self getContactList];
    }else if (self.currentIndex == 1) {
        [self getSuggestedContactList];
    }else if (self.currentIndex == 2) {
        [self getGroupList];
    }else if (self.currentIndex == 3) {
        [self getSuggestedGroupList];
    }
}

-(void)AutoScroll
{
    int width = _titlesCollectionView.contentSize.width - _titlesCollectionView.frame.size.width;
    if (i >= (width > 0 ? width + 10 : 0)) {
        i= 0;
    }
    [self.titlesCollectionView setContentOffset:CGPointMake(i++, 0)];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    i = scrollView.contentOffset.x;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)readData {
    self.myContacts = [NSMutableArray array];//[[MRDatabaseHelper getContacts] mutableCopy];
    self.suggestedContacts = [NSMutableArray array];//[[MRDatabaseHelper getSuggestedContacts] mutableCopy];
    
    if (self.myContacts != nil && self.myContacts.count >0) {
        self.noContactErrorMsgLbl.hidden = YES;
        self.clickHereToAddBtn.hidden = YES;
    }else {
        self.noContactErrorMsgLbl.hidden = NO;
        self.clickHereToAddBtn.hidden = NO;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _titlesCollectionView) {
        return self.categories.count;
    }
    if (self.currentIndex == 0) {
        return self.fileredContacts.count;
    }else if (self.currentIndex == 1) {
        return _fileredSuggestedContacts.count;
    }else if (self.currentIndex == 2) {
        return filteredGroupsArray.count;
    }else if (self.currentIndex == 3) {
        return filteredSuggestedGroupsArray.count;
    }
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _titlesCollectionView) {
        MRTransformTitleCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"transformTitleCollectionViewCell" forIndexPath:indexPath];
        [cell setHeading:self.categories[indexPath.row]];
        
        if (self.currentIndex == indexPath.row) {
            [cell setCorners];
        } else {
            [cell clearCorners];
        }
        
        return cell;
    }
    
    if (self.currentIndex == 0) {
        MRContactCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"contactCell" forIndexPath:indexPath];
        [cell setData:[self.fileredContacts objectAtIndex:indexPath.row]];
        return cell;
    }else if (self.currentIndex == 1) {
        MRContactCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"contactCell" forIndexPath:indexPath];
        [cell setData:[self.fileredSuggestedContacts objectAtIndex:indexPath.row]];
        return cell;
    }else if (self.currentIndex == 2) {
        MRContactCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"contactCell" forIndexPath:indexPath];
        [cell setGroupData:[filteredGroupsArray objectAtIndex:indexPath.row]];
        return cell;
    }else if (self.currentIndex == 3) {
        MRContactCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"contactCell" forIndexPath:indexPath];
        [cell setGroupData:[filteredSuggestedGroupsArray objectAtIndex:indexPath.row]];
        return cell;
    }
    return [UICollectionViewCell init];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _titlesCollectionView) {
        float widthIs = [self.categories[indexPath.row] boundingRectWithSize:CGSizeMake(500, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0] } context:nil].size.width;
        return CGSizeMake(widthIs+30, 30);
    }
    return CGSizeMake(self.view.bounds.size.width/2 - 2, 50);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 4; // This is the minimum inter item spacing, can be more
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.titlesCollectionView) {
        //NSInteger prevIndex = self.currentIndex;
        //NSString *currentString = self.categories[indexPath.row];
        
        NSInteger previousIndex = self.currentIndex;
        self.currentIndex = indexPath.row;
        [self updatePlusButton];
        
        [_titlesCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:previousIndex inSection:0],
                                                             [NSIndexPath indexPathForRow:self.currentIndex inSection:0]]];
        
        [_titlesCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex
                                                                          inSection:0]
                                      atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
        if (self.currentIndex == 0) {
            [self getContactList];
        }else if (self.currentIndex == 1) {
            [self getSuggestedContactList];
        }else if (self.currentIndex == 2) {
            [self getGroupList];
        }else if (self.currentIndex == 3) {
            [self getSuggestedGroupList];
        }
        
        self.searchBar.text = @"";
        return;
    }
    
    ContactDetailLaunchMode launchMode = kContactDetailLaunchModeNone;
    MRContactDetailViewController* detailViewController = [[MRContactDetailViewController alloc] init];
    
    if (self.currentIndex == 0) {
        launchMode = kContactDetailLaunchModeContact;
        [detailViewController setContact:self.fileredContacts[indexPath.row]];
    }else if (self.currentIndex == 1) {
        launchMode = kContactDetailLaunchModeSuggestedContact;
        [detailViewController setContact:self.fileredSuggestedContacts[indexPath.row]];
    }else if (self.currentIndex == 2) {
        launchMode = kContactDetailLaunchModeGroup;
        [detailViewController setGroup:filteredGroupsArray[indexPath.row]];
    }else if (self.currentIndex == 3) {
        launchMode = kContactDetailLaunchModeSuggestedGroup;
        [detailViewController setGroup:filteredSuggestedGroupsArray[indexPath.row]];
        detailViewController.isSuggestedGroup = YES;
    }
    
    [detailViewController setLaunchMode:launchMode];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

-(void) refreshLabels{
    if (self.currentIndex == 0) {
        self.fileredContacts = self.myContacts;
        if (self.myContacts != nil && self.myContacts.count >0) {
            self.noContactErrorMsgLbl.hidden = YES;
            self.clickHereToAddBtn.hidden = YES;
        }else {
            self.noContactErrorMsgLbl.text = @"LOOKS LIKE YOU DON'T HAVE ANY CONNECTIONS";
            self.noContactErrorMsgLbl.hidden = NO;
            self.clickHereToAddBtn.hidden = NO;
        }
    } else if (self.currentIndex == 1) {
        self.fileredSuggestedContacts = self.suggestedContacts;
        if (self.suggestedContacts != nil && self.suggestedContacts.count >0) {
            self.noContactErrorMsgLbl.hidden = YES;
            self.clickHereToAddBtn.hidden = YES;
        }else {
            self.noContactErrorMsgLbl.text = @"LOOKS LIKE YOU DON'T HAVE ANY SUGGESTED CONNECTIONS";
            self.noContactErrorMsgLbl.hidden = NO;
            self.clickHereToAddBtn.hidden = YES;
        }
    } else if (self.currentIndex == 2) {
        if (filteredGroupsArray.count > 0) {
            self.noContactErrorMsgLbl.hidden = YES;
            self.clickHereToAddBtn.hidden = YES;
        }else {
            self.noContactErrorMsgLbl.text = @"LOOKS LIKE YOU DON'T HAVE ANY GROUPS";
            self.noContactErrorMsgLbl.hidden = NO;
            self.clickHereToAddBtn.hidden = NO;
        }
    } else if (self.currentIndex == 3) {
        if (filteredSuggestedGroupsArray.count > 0) {
            self.noContactErrorMsgLbl.hidden = YES;
            self.clickHereToAddBtn.hidden = YES;
        }else {
            self.noContactErrorMsgLbl.text = @"LOOKS LIKE YOU DON'T HAVE ANY SUGGESTED GROUPS";
            self.noContactErrorMsgLbl.hidden = NO;
            self.clickHereToAddBtn.hidden = YES;
        }
    }
    
    [_myContactsCollectionView reloadData];
//    [_titlesCollectionView reloadData];
}

//- (void)setupPieMenu {
//    self.pieMenu = [[PieMenu alloc] init];
//    PieMenuItem *itemA = [[PieMenuItem alloc] initWithTitle:@"Connect"
//                                                      label:nil
//                                                     target:self
//                                                   selector:@selector(itemSelected:)
//                                                   userInfo:nil
//                                                       icon:[UIImage imageNamed:@"Contact.png"]];
//
//    PieMenuItem *itemB = [[PieMenuItem alloc] initWithTitle:@"Share"
//                                                      label:nil
//                                                     target:self
//                                                   selector:@selector(itemSelected:)
//                                                   userInfo:nil
//                                                       icon:[UIImage imageNamed:@"Contact.png"]];
//
//    PieMenuItem *itemC = [[PieMenuItem alloc] initWithTitle:@"Transform"
//                                                      label:nil
//                                                     target:self
//                                                   selector:@selector(itemSelected:)
//                                                   userInfo:nil
//                                                       icon:[UIImage imageNamed:@"Contact.png"]];
//
//    PieMenuItem *itemD = [[PieMenuItem alloc] initWithTitle:@"Serve"
//                                                      label:nil
//                                                     target:self
//                                                   selector:@selector(itemSelected:)
//                                                   userInfo:nil
//                                                       icon:[UIImage imageNamed:@"Contact.png"]];
//
//    //[pieMenu addItem:itemD];
//    [self.pieMenu addItem:itemA];
//    [self.pieMenu addItem:itemB];
//    [self.pieMenu addItem:itemC];
//    [self.pieMenu addItem:itemD];
//}

- (void)viewTapped:(UITapGestureRecognizer*)tapGesture {
    [self.searchBar resignFirstResponder];
    self.tapGesture.enabled = NO;
}

- (IBAction)switchButtonTapped:(id)sender {
    /*[UIView transitionWithView:self.navigationController.view
                      duration:0.75
                       options:UIViewAnimationOptionTransitionCurlUp
                    animations:^{
                        [self.navigationController pushViewController:self.groupsListViewController animated:NO];
                    }
                    completion:nil];*/
}

- (IBAction)addButtonClicked:(id)sender {
    MRAddMembersViewController* detailViewController = [[MRAddMembersViewController alloc] init];
    detailViewController.groupID = 0;
    [self.navigationController pushViewController:detailViewController animated:NO];
}

- (IBAction)popOverTapped:(id)sender {
    if (self.currentIndex == 0 || self.currentIndex == 1) {
        self.menu = [[UIActionSheet alloc] initWithTitle:@"More Options"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"Pending Connections",@"Add Connections", nil];
    }else{
        self.menu = [[UIActionSheet alloc] initWithTitle:@"More Options"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"Pending Groups", @"Create Group", @"More Groups", nil];
    }
    
    [self.menu showFromRect:self.moreOptions.frame inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.currentIndex == 0 || self.currentIndex == 1) {
        if (buttonIndex == 0) {
            [UIView transitionWithView:self.navigationController.view
                              duration:0.75
                               options:UIViewAnimationOptionTransitionCurlUp
                            animations:^{
                                PendingContactsViewController *pendingViewController =[[PendingContactsViewController alloc] initWithNibName:@"PendingContactsViewController" bundle:[NSBundle mainBundle]];
                                
                                pendingViewController.isFromGroup = NO;
                                pendingViewController.gid = 0;
                                [self.navigationController pushViewController:pendingViewController animated:NO];
                            }
                            completion:nil];
        }else if (buttonIndex == 1){
            MRAddMembersViewController* detailViewController = [[MRAddMembersViewController alloc] init];
            detailViewController.groupID = 0;
            [self.navigationController pushViewController:detailViewController animated:NO];
        }
    }else{
        if (buttonIndex == 0) {
            [UIView transitionWithView:self.navigationController.view
                              duration:0.75
                               options:UIViewAnimationOptionTransitionCurlUp
                            animations:^{
                                PendingContactsViewController *pendingViewController =[[PendingContactsViewController alloc] initWithNibName:@"PendingContactsViewController" bundle:[NSBundle mainBundle]];
                                
                                pendingViewController.isFromGroup = YES;
                                pendingViewController.gid = 0;
                                [self.navigationController pushViewController:pendingViewController animated:NO];
                            }
                            completion:nil];
        }else if (buttonIndex == 1) {
            [UIView transitionWithView:self.navigationController.view
                              duration:0.75
                               options:UIViewAnimationOptionTransitionCurlUp
                            animations:^{
                                MRCreateGroupViewController* detailViewController = [[MRCreateGroupViewController alloc] init];
                                [self.navigationController pushViewController:detailViewController animated:NO];
                            }
                            completion:nil];
        }else if (buttonIndex == 2){
            MRJoinGroupViewController* detailViewController = [[MRJoinGroupViewController alloc] init];
            [self.navigationController pushViewController:detailViewController animated:NO];
        }
    }
}

- (void)getGroupList{
    [MRDatabaseHelper getGroups:^(id result) {
        groupsArray = result;
        filteredGroupsArray = [groupsArray mutableCopy];
        [self refreshLabels];
    }];
}

- (void)getSuggestedGroupList{
    [MRDatabaseHelper getSuggestedGroups:^(id result) {
        suggestedGroupsArray = result;
        filteredSuggestedGroupsArray = [suggestedGroupsArray mutableCopy];
        [self refreshLabels];
    }];
}

- (void)getSuggestedContactList{
    [MRDatabaseHelper getSuggestedContacts:^(id result) {
        _suggestedContacts = result;
        _fileredSuggestedContacts = [_suggestedContacts mutableCopy];
        [self refreshLabels];
    }];
}

- (void)getContactList {
    [MRDatabaseHelper getContacts:^(id results) {
        self.myContacts = results;
        _fileredContacts = [self.myContacts mutableCopy];
        [self refreshLabels];
    }];
}


/*- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item == self.myContactsButton) {
//        [self.switchButton setImage:[UIImage imageNamed:@"Group.png"] forState:UIControlStateNormal];
//        [self.switchButton setImage:[UIImage imageNamed:@"Group.png"] forState:UIControlStateSelected];
        //self.myContactsCollectionView.hidden = NO;
        //self.suggestedContactsCollectionView.hidden = YES;
        self.fileredContacts = self.myContacts;
        [self.myContactsCollectionView reloadData];
    } else {
//        [self.switchButton setImage:[UIImage imageNamed:@"Contact.png"] forState:UIControlStateNormal];
//        [self.switchButton setImage:[UIImage imageNamed:@"Contact.png"] forState:UIControlStateSelected];
        //self.myContactsCollectionView.hidden = YES;
        //self.suggestedContactsCollectionView.hidden = NO;
        self.fileredContacts = self.suggestedContacts;
        [self.myContactsCollectionView reloadData];
    }
    self.searchBar.text = @"";
}*/

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (self.currentIndex == 0) {
        if (searchText.length == 0) {
            self.fileredContacts = self.myContacts;
        } else {
            self.fileredContacts = [[self.myContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K contains[cd] %@) OR (%K contains[cd] %@)",@"firstName",searchText,@"lastName",searchText]] mutableCopy];
        }
    } else if(self.currentIndex == 1){
        if (searchText.length == 0) {
            self.fileredSuggestedContacts = self.suggestedContacts;
        } else {
            self.fileredSuggestedContacts = [[self.suggestedContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K contains[cd] %@) OR (%K contains[cd] %@)",@"firstName",searchText,@"lastName",searchText]] mutableCopy];
        }
    }else if (self.currentIndex == 2){
        if (searchText.length == 0) {
            filteredGroupsArray = groupsArray;
        } else {
            filteredGroupsArray = [[groupsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[cd] %@",@"group_name",searchText]] mutableCopy];
        }
    }else if (self.currentIndex == 3){
        if (searchText.length == 0) {
            filteredSuggestedGroupsArray = suggestedGroupsArray;
        } else {
            filteredSuggestedGroupsArray = [[suggestedGroupsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[cd] %@",@"group_name",searchText]] mutableCopy];
        }
    }
    [self.myContactsCollectionView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.tapGesture.enabled = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)transformButtonTapped {
    MRTransformViewController *notiFicationViewController = [[MRTransformViewController alloc] initWithNibName:@"MRTransformViewController" bundle:nil];
    [self.navigationController pushViewController:notiFicationViewController animated:NO];
}

- (void)serveButtonTapped {
    MRServeViewController *notiFicationViewController = [[MRServeViewController alloc] initWithNibName:@"MRServeViewController" bundle:nil];
    [self.navigationController pushViewController:notiFicationViewController animated:NO];
}

- (void)shareButtonTapped {
    MRShareViewController* contactsViewCont = [[MRShareViewController alloc] initWithNibName:@"MRShareViewController" bundle:nil];
    [self.navigationController pushViewController:contactsViewCont animated:NO];
}

@end

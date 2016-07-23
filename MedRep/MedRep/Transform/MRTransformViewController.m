//
//  MRTransformViewController.m
//  MedRep
//
//  Created by Vamsi Katragadda on 6/13/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTransformViewController.h"
#import "MRTransformTitleCollectionViewCell.h"
#import "MRTransformPost.h"
#import "MRTransformDetailViewController.h"
#import "MPTransformTableViewCell.h"
#import "SWRevealViewController.h"
#import "MRContactsViewController.h"
#import "MRGroupsListViewController.h"
#import "PendingContactsViewController.h"
#import "MRShareViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MRServeViewController.h"
#import "MRConstants.h"
#import "MRCustomTabBar.h"

@interface MRTransformViewController () <UICollectionViewDelegate, UICollectionViewDataSource,
                                         UITableViewDelegate, UITableViewDataSource,
SWRevealViewControllerDelegate, UISearchBarDelegate>{
    int i;
    NSTimer *timer;
}

@property (strong, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UICollectionView *titleCollectionView;

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property NSArray *categories;
@property (strong, nonatomic) NSArray *contentData;
@property (strong, nonatomic) NSMutableArray *filteredData;
@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;
@property (strong, nonatomic) NSMutableArray *searchResults;

@property NSInteger currentIndex;

@property (strong, nonatomic) UIView *tabBarView;

@end

@implementation MRTransformViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
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
    
    self.navigationItem.title = @"Transform";
    
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    
    self.currentIndex = 0;

//    self.prevIndex = 0;
    self.categories = @[@"News & Updates", @"Therapeutic Area", @"Regulatory", @"Education", @"Journals", @"Medical Innovation", @"Podcasts / Webcasts", @"Best Practices", @"Case Studies", @"Whitepapers", @"Videos", @"Clinical Trials"];
    
    [self.contentTableView setDelegate:self];
    [self.contentTableView setDataSource:self];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"MPTransformTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MPTransformTableViewCell"];
    
    [self.titleCollectionView setDelegate:self];
    [self.titleCollectionView setDataSource:self];
    
    [self.titleCollectionView registerNib:[UINib nibWithNibName:@"MRTransformTitleCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"transformTitleCollectionViewCell"];
    
    [self createDummyData];
    self.filteredData = [self.contentData mutableCopy];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    self.tapGesture.numberOfTapsRequired = 1;
    self.tapGesture.cancelsTouchesInView = YES;
    self.tapGesture.enabled = NO;
    [self.view addGestureRecognizer:self.tapGesture];
    
    MRCustomTabBar *tabBarView = (MRCustomTabBar*)[MRCommon createTabBarView:self.view];
    [tabBarView setNavigationController:self.navigationController];
    [tabBarView setTransformViewController:self];
    [tabBarView updateActiveViewController:self andTabIndex:DoctorPlusTabTransform];
    
    self.tabBarView = (UIView*)tabBarView;

    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.contentTableView
                                                                        attribute:NSLayoutAttributeBottomMargin
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0 constant:0];
    
    [self.view addConstraint:bottomConstraint];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [MRCommon applyNavigationBarStyling:self.navigationController];
    
    //timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(AutoScroll) userInfo:nil repeats:YES];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    i = 0;
    [timer invalidate];
}

-(void)AutoScroll
{
    int width = _titleCollectionView.contentSize.width - _titleCollectionView.frame.size.width;
    if (i >= (width > 0 ? width + 10 : 0)) {
        i= 0;
    }
    [self.titleCollectionView setContentOffset:CGPointMake(i++, 0)];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    i = scrollView.contentOffset.x;
}

- (void)viewTapped:(UITapGestureRecognizer*)tapGesture {
    [self.searchBar resignFirstResponder];
    self.tapGesture.enabled = NO;
}

#pragma mark - UICollectionView methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categories.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRTransformTitleCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"transformTitleCollectionViewCell" forIndexPath:indexPath];
    [cell setHeading:self.categories[indexPath.row]];
    
    if (self.currentIndex == indexPath.row) {
        [cell setCorners];
    } else {
        [cell clearCorners];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float widthIs = [self.categories[indexPath.row] boundingRectWithSize:CGSizeMake(500, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0] } context:nil].size.width;
    return CGSizeMake(widthIs+30, 30);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 4; // This is the minimum inter item spacing, can be more
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger prevIndex = self.currentIndex;
    self.currentIndex = indexPath.row;
    
    NSString *currentCategory = self.categories[indexPath.row];
    if (currentCategory != nil && [currentCategory caseInsensitiveCompare:@"Latest"] == NSOrderedSame) {
        self.filteredData = [self.contentData mutableCopy];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.source == %@", currentCategory];
        self.filteredData = [[self.contentData filteredArrayUsingPredicate:predicate] mutableCopy];
    }
    
    [self.titleCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:prevIndex
                                                                           inSection:0],
                                                        indexPath]];
    [self.contentTableView reloadData];
}


#pragma mark - SearchBar Delegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//    if (self.currentIndex == 0) {
//        if (searchText.length == 0) {
//            self.fileredContacts = self.myContacts;
//        } else {
//            self.fileredContacts = [[self.myContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K contains[cd] %@) OR (%K contains[cd] %@)",@"firstName",searchText,@"lastName",searchText]] mutableCopy];
//        }
//    } else if(self.currentIndex == 1){
//        if (searchText.length == 0) {
//            self.fileredSuggestedContacts = self.suggestedContacts;
//        } else {
//            self.fileredSuggestedContacts = [[self.suggestedContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K contains[cd] %@) OR (%K contains[cd] %@)",@"firstName",searchText,@"lastName",searchText]] mutableCopy];
//        }
//    }else if (self.currentIndex == 2){
//        if (searchText.length == 0) {
//            filteredGroupsArray = groupsArray;
//        } else {
//            filteredGroupsArray = [[groupsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[cd] %@",@"group_name",searchText]] mutableCopy];
//        }
//    }else if (self.currentIndex == 3){
//        if (searchText.length == 0) {
//            filteredSuggestedGroupsArray = suggestedGroupsArray;
//        } else {
//            filteredSuggestedGroupsArray = [[suggestedGroupsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[cd] %@",@"group_name",searchText]] mutableCopy];
//        }
//    }
//    [self.myContactsCollectionView reloadData];
    
    if ([searchText isEqualToString:@""]) {
        self.filteredData = [self.contentData mutableCopy];
//        [self.contentTableView reloadData];
        
    }else{
        self.filteredData  =  [[self.contentData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K contains[cd] %@)",@"titleDescription",searchText]] mutableCopy];
//        [
    }
     [self.contentTableView reloadData];
    
    
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    searchBar.text=@"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.contentTableView.allowsSelection = YES;
    self.contentTableView.scrollEnabled = YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.tapGesture.enabled = YES;
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (tableView == self.searchDisplayController.searchResultsTableView) {
//        return self.searchResults.count;
//        
//    }
//    
    return self.filteredData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 112.0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"MPTransformTableViewCell";
    MPTransformTableViewCell *regCell = (MPTransformTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (regCell == nil)
    {
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"MPTransformTableViewCell" owner:nil options:nil];
        regCell = (MPTransformTableViewCell *)[nibViews lastObject];
    }
    MRTransformPost *transformData;
//    if (tableView == self.searchDisplayController.searchResultsTableView) {
//
//   transformData = self.searchResults[indexPath.row];
//    }else{
       transformData = self.filteredData[indexPath.row];
        
//    }
    
        if (transformData != nil) {
        if (transformData.url != nil && transformData.url.length > 0) {
            if (transformData.contentType.integerValue == kTransformContentTypeImage) {
                regCell.img.image = [UIImage imageNamed:transformData.url];
            } else if (transformData.contentType.integerValue == kTransformContentTypeVideo) {
                regCell.img.image = [UIImage imageNamed:@"video"];
            } else if (transformData.contentType.integerValue == kTransformContentTypePDF) {
                regCell.img.image = [UIImage imageNamed:@"pdf"];
            } else {
                regCell.img.image = nil;
            }
        }
        
        if (transformData.titleDescription != nil && transformData.titleDescription.length > 0) {
            regCell.titleLbl.text = transformData.titleDescription;
            [regCell.titleLbl sizeToFit];
            [regCell.titleLbl layoutIfNeeded];
        }
        
        if (transformData.shortArticleDescription != nil && transformData.shortArticleDescription.length > 0) {
            regCell.descLbl.text = transformData.shortArticleDescription;
        }
        
        if (transformData.source != nil && transformData.source.length > 0) {
            regCell.sourceLabel.text = [NSString stringWithFormat:@"SOURCE : %@", transformData.source];
        }
    }
    
    return regCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MRTransformDetailViewController *notiFicationViewController = [[MRTransformDetailViewController alloc] initWithNibName:@"MRTransformDetailViewController" bundle:nil];
    
//    if (tableView == self.searchDisplayController.searchResultsTableView) {
//
//        notiFicationViewController.post = self.searchResults[indexPath.row];
//        
//    }else{
        notiFicationViewController.post = self.filteredData[indexPath.row];
        
//    }
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}

#pragma mark - Dummy Data

- (void)createDummyData {
    // Create Dummy Data
    
    self.contentData = [MRDatabaseHelper getTransformArticles];
    
    if (self.contentData == nil || self.contentData.count == 0) {
        
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"TransformPosts" ofType:@"json"];
        NSData* data = [NSData dataWithContentsOfFile:filePath];
        NSError *error;
        NSArray* transformArticles = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        [MRDatabaseHelper addTransformArticles:transformArticles];
    
        self.contentData = [MRDatabaseHelper getTransformArticles];
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{

    self.searchResults  =  [[self.filteredData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K contains[cd] %@)",@"titleDescription",searchText]] mutableCopy];
//    self.searchResults  =  [[self.filteredData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K contains[cd] %@) OR (%K contains[cd] %@)",@"titleDescription",searchText,@"lastName",searchText]] mutableCopy];

}

#pragma mark - UISearchDisplayController delegate methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

-(UIImage *)generateImageForVideoLink:(NSString *)str
{
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:[NSURL URLWithString:str] options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
    __block UIImage *thumbImg;
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        }
        thumbImg=[UIImage imageWithCGImage:im];
    };
    
    CGSize maxSize = CGSizeMake(320, 180);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
    return thumbImg;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

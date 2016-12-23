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
#import "MRMyWallViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MRServeViewController.h"
#import "MRConstants.h"
#import "MRCustomTabBar.h"
#import "TransformSubCategories.h"

@interface MRTransformViewController () <UICollectionViewDelegate, UICollectionViewDataSource,
                                         UITableViewDelegate, UITableViewDataSource,
SWRevealViewControllerDelegate, UISearchBarDelegate>{
    int i;
    NSTimer *timer;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *therapeuticAreaDropDownWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *therapeuticAreaDropDown;
@property (weak, nonatomic) IBOutlet UILabel *currentTherapeuticAreaTitleView;
@property (weak, nonatomic) IBOutlet UITableView *therapeuticAreaListTableView;
@property (weak, nonatomic) IBOutlet UIControl *therapeuticAreaListTableViewContainerview;

@property (strong, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UICollectionView *titleCollectionView;

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property NSArray *categories;
@property (strong, nonatomic) NSArray *contentData;
@property (strong, nonatomic) NSArray *filteredData;
@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;
@property (strong, nonatomic) NSMutableArray *searchResults;

@property NSArray *therapeuticAreasList;

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
    
    UITapGestureRecognizer *recoginzer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(dropDownClicked)];
    [recoginzer setNumberOfTapsRequired:1];
    [self.therapeuticAreaDropDown addGestureRecognizer:recoginzer];
    [self.therapeuticAreaDropDown.layer setCornerRadius:5.0];
    self.therapeuticAreaDropDownWidthConstraint.constant = 0.0;
    [self.therapeuticAreaDropDown setHidden:YES];
    
    [self.therapeuticAreaListTableViewContainerview addTarget:self
                                                       action:@selector(therapeuticAreaListTableViewContainerviewTapped)
                                             forControlEvents:UIControlEventTouchUpInside];
    [self.therapeuticAreaListTableViewContainerview setHidden:YES];
    
//    self.prevIndex = 0;
    self.categories = @[@"News & Updates", @"Therapeutic Area", @"Regulatory", @"Education", @"Journals", @"Medical Innovation", @"Podcasts / Webcasts", @"Best Practices", @"Case Studies", @"Whitepapers", @"Videos", @"Clinical Trials"];
    
    [self.contentTableView setDelegate:self];
    [self.contentTableView setDataSource:self];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"MPTransformTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MPTransformTableViewCell"];
    
    [self.titleCollectionView setDelegate:self];
    [self.titleCollectionView setDataSource:self];
    
    [self.titleCollectionView registerNib:[UINib nibWithNibName:@"MRTransformTitleCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"transformTitleCollectionViewCell"];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    self.tapGesture.numberOfTapsRequired = 1;
    self.tapGesture.cancelsTouchesInView = YES;
    self.tapGesture.enabled = NO;
    [self.view addGestureRecognizer:self.tapGesture];
    [self.therapeuticAreaListTableView.layer setCornerRadius:5.0];
//    [self.therapeuticAreaListTableView setHidden:YES];
    
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
    
    [self resetDashboardCounter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MRCommon applyNavigationBarStyling:self.navigationController];
    [self fetchNewsAndUpdates:[self.categories objectAtIndex:self.currentIndex]];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    i = 0;
    [timer invalidate];
}

- (void)resetDashboardCounter {
    NSDictionary *dict = @{@"resetDoctorPlusCount":[NSNumber numberWithBool:true],
                           @"resetNotificationCount":[NSNumber numberWithBool:false],
                           @"resetSurveyCount": [NSNumber numberWithBool:false]};
    [[MRWebserviceHelper sharedWebServiceHelper] getPendingCount:dict andHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getPendingCount:dict andHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       
                   }];
                  
              }];
         }
     }];
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
    if (self.currentIndex != indexPath.row) {
        NSInteger prevIndex = self.currentIndex;
        self.currentIndex = indexPath.row;
        
        if (self.currentIndex == 1) {
            self.therapeuticAreaDropDownWidthConstraint.constant = 142.0;
            [self.therapeuticAreaDropDown setHidden:NO];
            [self.currentTherapeuticAreaTitleView setText:@"All"];
        } else {
            self.therapeuticAreaDropDownWidthConstraint.constant = 0.0;
            [self.therapeuticAreaDropDown setHidden:YES];
        }
        
        NSString *currentCategory = self.categories[indexPath.row];
        [self fetchNewsAndUpdates:currentCategory];
        
        [self.titleCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:prevIndex
                                                                               inSection:0],
                                                            indexPath]];
    }
}


#pragma mark - SearchBar Delegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    
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
    if (tableView.tag == 500) {
        return self.therapeuticAreasList.count;
    } else {
        return self.filteredData.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 500) {
        return UITableViewAutomaticDimension;
    } else {
        return 112.0;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 500) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"cellIdentifier"];
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
            [cell.textLabel setBackgroundColor:[UIColor clearColor]];
            [cell setBackgroundColor:[UIColor clearColor]];
        }
        [cell.textLabel setText:[self.therapeuticAreasList objectAtIndex:indexPath.row]];
        
        return cell;
    } else {
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
            NSLog(@"Image URL ; %@", transformData.coverImgUrl);
            if (transformData.coverImgUrl != nil && transformData.coverImgUrl.length > 0) {
                
                if (transformData.newsId != nil && transformData.newsId.integerValue == 1082) {
                    NSLog(@"Image URL ; %@", transformData.coverImgUrl);
                }
                
                regCell.img.image = [UIImage imageNamed:@"RssNew"];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *key = [NSString stringWithFormat:@"%ld_fileUrl", transformData.newsId.longValue];
                    [[MRAppControl sharedHelper].globalCache objectForKey:key];
                    
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:transformData.coverImgUrl]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (imageData != nil) {
                            regCell.img.image = [UIImage imageWithData:imageData];
                        }
                    });
                });
            } else {
                if (transformData.url != nil && transformData.url.length > 0) {
                    if (transformData.contentType.integerValue == kTransformContentTypeImage) {
                        regCell.img.image = [UIImage imageNamed:transformData.url];
                    } else if (transformData.contentType.integerValue == kTransformContentTypeVideo) {
                        regCell.img.image = [UIImage imageNamed:@"video"];
                    } else if (transformData.contentType.integerValue == kTransformContentTypePDF) {
                        regCell.img.image = [UIImage imageNamed:@"pdf"];
                    } else {
                        regCell.img.image = [UIImage imageNamed:@"RssNew"];
                    }
                } else {
                    regCell.img.image = [UIImage imageNamed:@"RssNew"];
                }
            }
            
            if (transformData.titleDescription != nil && transformData.titleDescription.length > 0) {
                regCell.titleLbl.text = transformData.titleDescription;
                [regCell.titleLbl sizeToFit];
                [regCell.titleLbl layoutIfNeeded];
            } else {
                regCell.titleLbl.text = @"";
            }
            
            if (transformData.shortArticleDescription != nil && transformData.shortArticleDescription.length > 0) {
                regCell.descLbl.text = transformData.shortArticleDescription;
            } else {
                regCell.descLbl.text = @"";
            }
            
            NSString *source = @"";
            if (transformData.source != nil && transformData.source.length > 0) {
                source = transformData.source;
            }
                
            regCell.sourceLabel.text = [NSString stringWithFormat:@"SOURCE : %@, %@", source, [MRCommon stringFromDate:transformData.postedOn withDateFormate:@"YYYY-MM-dd"]];
        }
        
        return regCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 500) {
        [self therapeuticAreaListTableViewContainerviewTapped];
        if (indexPath.row == 0) {
            self.filteredData = self.contentData;
            [self.currentTherapeuticAreaTitleView setText:@"All"];
        } else {
            NSString *category = [self.therapeuticAreasList objectAtIndex:indexPath.row];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"subCategory",
                                      category];
            self.filteredData = [self.contentData filteredArrayUsingPredicate:predicate];
            [self.currentTherapeuticAreaTitleView setText:category];
        }
        
        [self.contentTableView reloadData];
        
        if (self.filteredData != nil && self.filteredData.count > 0) {
            [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                     atScrollPosition:UITableViewScrollPositionTop
                                             animated:YES];
        }
    } else {
        MRTransformDetailViewController *notiFicationViewController = [[MRTransformDetailViewController alloc] initWithNibName:@"MRTransformDetailViewController" bundle:nil];
        
    //    if (tableView == self.searchDisplayController.searchResultsTableView) {
    //
    //        notiFicationViewController.post = self.searchResults[indexPath.row];
    //        
    //    }else{
        notiFicationViewController.currentTabIndex = self.currentIndex;
            notiFicationViewController.post = self.filteredData[indexPath.row];
            
    //    }
        [self.navigationController pushViewController:notiFicationViewController animated:YES];
    }
}

#pragma mark - Fetch News & Updates
- (void)fetchNewsAndUpdates:(NSString*)category {
    NSString *methodName = kNewsAndTransformAPIMethodName;
    if (self.currentIndex == 0) {
        methodName = kNewsAndUpdatesAPIMethodName;
        category = nil;
    } else {
        category = [category stringByReplacingOccurrencesOfString:@" "  withString:@""];
    }
    
    [MRDatabaseHelper fetchNewsAndUpdates:category methodName:methodName
                              withHandler:^(id result) {
        self.contentData = result;
        
//        NSString *currentCategory = self.categories[self.currentIndex];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.source == %@", currentCategory];
//        self.filteredData = [[self.contentData filteredArrayUsingPredicate:predicate] mutableCopy];

        self.filteredData = self.contentData;
        NSMutableArray *therapeuticAreasList = [NSMutableArray new];

        if (self.currentIndex == 1) {
            
            NSArray *subCategories = [[MRDataManger sharedManager] fetchObjectList:NSStringFromClass(TransformSubCategories.class)];

            [therapeuticAreasList addObject:@"All"];
            [therapeuticAreasList addObjectsFromArray:[subCategories valueForKey:@"title"]];
                                  
            NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:therapeuticAreasList];
                                  
            self.therapeuticAreasList = orderedSet.array;
        }
                                  
        [self.contentTableView reloadData];
    }];
}

#pragma mark - Dummy Data

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

#pragma mark - drop down clicked
- (void)dropDownClicked {
    [self.therapeuticAreaListTableViewContainerview setHidden:NO];
    [self.therapeuticAreaListTableView setHidden:NO];
    [self.therapeuticAreaListTableView reloadData];
}

- (void)therapeuticAreaListTableViewContainerviewTapped {
    [self.therapeuticAreaListTableView setHidden:YES];
    [self.therapeuticAreaListTableViewContainerview setHidden:YES];
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

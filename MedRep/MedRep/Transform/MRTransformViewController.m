//
//  MRTransformViewController.m
//  MedRep
//
//  Created by Vamsi Katragadda on 6/13/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRTransformViewController.h"
#import "MRTransformTitleCollectionViewCell.h"
#import "MPTransformData.h"
#import "MRDatabaseHelper.h"
#import "MRTransformDetailViewController.h"
#import "MPTransformTableViewCell.h"
#import "SWRevealViewController.h"
#import "MRContactsViewController.h"
#import "MRGroupsListViewController.h"
#import "PendingContactsViewController.h"
#import "MRShareViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MRTabView.h"
#import "MRServeViewController.h"

@interface MRTransformViewController () <UICollectionViewDelegate, UICollectionViewDataSource,
                                         UITableViewDelegate, UITableViewDataSource,
                                        SWRevealViewControllerDelegate, UISearchBarDelegate, MRTabViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UICollectionView *titleCollectionView;

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (weak, nonatomic) IBOutlet UIView *connectView;

@property (weak, nonatomic) IBOutlet UIView *transformView;

@property (weak, nonatomic) IBOutlet UIView *shareView;

@property (weak, nonatomic) IBOutlet UIView *serveView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property UIView *activeView;

@property NSArray *categories;
@property (strong, nonatomic) NSMutableArray *contentData;
@property (strong, nonatomic) NSMutableArray *filteredData;
@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;

@property NSInteger currentIndex;

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
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    self.currentIndex = 0;
    self.activeView = self.transformView;
//    self.prevIndex = 0;
    self.categories = @[@"Latest", @"Trending", @"BBC", @"Journals", @"Case Studies"];
    
    [self.contentTableView setDelegate:self];
    [self.contentTableView setDataSource:self];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"MPTransformTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MPTransformTableViewCell"];
    
    [self.titleCollectionView setDelegate:self];
    [self.titleCollectionView setDataSource:self];
    
    [self.titleCollectionView registerNib:[UINib nibWithNibName:@"MRTransformTitleCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"transformTitleCollectionViewCell"];
    
    [self createDummyData];
    self.filteredData = self.contentData;
    
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

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"MRTabView" owner:self options:nil];
    MRTabView *tabView = (MRTabView *)[subviewArray objectAtIndex:0];
    tabView.delegate = self;
    tabView.transformView.backgroundColor = [UIColor colorWithRed:26/255.0 green:133/255.0 blue:213/255.0 alpha:1];
    [self.view addSubview:tabView];
    
    [tabView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:NSLayoutFormatAlignAllBottom metrics:nil views:@{@"view":tabView}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tabView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:tabView
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:50]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tabView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger prevIndex = self.currentIndex;
    self.currentIndex = indexPath.row;
    
    NSString *currentCategory = self.categories[indexPath.row];
    if (currentCategory != nil && [currentCategory caseInsensitiveCompare:@"Latest"] == NSOrderedSame) {
        self.filteredData = self.contentData;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.source == %@", currentCategory];
        self.filteredData = [[self.contentData filteredArrayUsingPredicate:predicate] mutableCopy];
    }
    
    [self.titleCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:prevIndex
                                                                           inSection:0],
                                                        indexPath]];
    [self.contentTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.tapGesture.enabled = YES;
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    
    MPTransformData *transformData = self.filteredData[indexPath.row];
    if (transformData != nil) {
        if (transformData.icon != nil && transformData.icon.length > 0) {
            regCell.img.image = [UIImage imageNamed:transformData.icon];
            
            /*if ([transformData.contentType isEqualToString:@"Video"]) {
                regCell.img.image = [self generateImageForVideoLink:@"https://dl.dropboxusercontent.com/u/104553173/PK%20Song.mp4"];
            }*/
        }
        
        if (transformData.title != nil && transformData.title.length > 0) {
            regCell.titleLbl.text = transformData.title;
            [regCell.titleLbl sizeToFit];
            [regCell.titleLbl layoutIfNeeded];
        }
        
        if (transformData.shortDescription != nil && transformData.shortDescription.length > 0) {
            regCell.descLbl.text = transformData.shortDescription;
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
    notiFicationViewController.selectedContent = self.contentData[indexPath.row];
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}

- (IBAction)connectButtonTapped:(id)sender {
    self.connectView = sender;
    
    MRContactsViewController* contactsViewCont = [[MRContactsViewController alloc] initWithNibName:@"MRContactsViewController" bundle:nil];
    MRGroupsListViewController* groupsListViewController = [[MRGroupsListViewController alloc] initWithNibName:@"MRGroupsListViewController" bundle:[NSBundle mainBundle]];
    contactsViewCont.groupsListViewController = groupsListViewController;
    
    PendingContactsViewController *pendingViewController =[[PendingContactsViewController alloc] initWithNibName:@"PendingContactsViewController" bundle:[NSBundle mainBundle]];
    
    contactsViewCont.pendingContactsViewController = pendingViewController;
    [self.navigationController pushViewController:contactsViewCont animated:true];

}

- (IBAction)transformButtonTapped:(id)sender {
    self.transformView = sender;
}

- (IBAction)shareButtonTapped:(id)sender {
    self.shareView = sender;
    
    MRShareViewController* contactsViewCont = [[MRShareViewController alloc] initWithNibName:@"MRShareViewController" bundle:nil];
    [self.navigationController pushViewController:contactsViewCont animated:true];
}

- (IBAction)serveButtonTapped:(id)sender {
    self.serveView = sender;
}

- (void)connectButtonTapped {
    MRContactsViewController* contactsViewCont = [[MRContactsViewController alloc] initWithNibName:@"MRContactsViewController" bundle:nil];
    MRGroupsListViewController* groupsListViewController = [[MRGroupsListViewController alloc] initWithNibName:@"MRGroupsListViewController" bundle:[NSBundle mainBundle]];
    contactsViewCont.groupsListViewController = groupsListViewController;
    
    PendingContactsViewController *pendingViewController =[[PendingContactsViewController alloc] initWithNibName:@"PendingContactsViewController" bundle:[NSBundle mainBundle]];
    
    contactsViewCont.pendingContactsViewController = pendingViewController;
    [self.navigationController pushViewController:contactsViewCont animated:NO];
}

- (void)shareButtonTapped {
    MRShareViewController* contactsViewCont = [[MRShareViewController alloc] initWithNibName:@"MRShareViewController" bundle:nil];
    [self.navigationController pushViewController:contactsViewCont animated:NO];
}

- (void)serveButtonTapped {
    MRServeViewController *notiFicationViewController = [[MRServeViewController alloc] initWithNibName:@"MRServeViewController" bundle:nil];
    [self.navigationController pushViewController:notiFicationViewController animated:NO];
}

#pragma mark - Dummy Data

- (void)createDummyData {
    // Create Dummy Data
    self.contentData = [NSMutableArray new];
    
    MPTransformData *transformData = [MPTransformData new];
    [transformData setSource:@"BBC"];
    [transformData setIcon:@"comapny-logo.png"];
    [transformData setContentType:@"Image"];
    [transformData setTitle:@"Could High-Dose Vitamin D Help Fight Multiple Sclerosis"];
    [transformData setShortDescription:@"Supplementation appears safe but experts says it's too soon for general..."];
    [transformData setDetailDescription:@"Supplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for general"];
    [self.contentData addObject:transformData];
    
    transformData = [MPTransformData new];
    [transformData setSource:@"BBC"];
    [transformData setIcon:@"pdf"];
    [transformData setContentType:@"Pdf"];
    [transformData setTitle:@"Painkillers Often Gateway to Heroin for U.S Teens: Survey"];
    [transformData setShortDescription:@"Heroin is cheaper, easier to obtain than narcotics like OxyContin experts say..."];
    [transformData setDetailDescription:@""];
    [self.contentData addObject:transformData];
    
    transformData = [MPTransformData new];
    [transformData setSource:@"BBC"];
    [transformData setIcon:@"video"];
    [transformData setContentType:@"Video"];
    [transformData setTitle:@"It's Not Too late"];
    [transformData setShortDescription:@"Influenza activity usually active in Janurary or February..."];
    [transformData setDetailDescription:@""];
    [self.contentData addObject:transformData];
    
    transformData = [MPTransformData new];
    [transformData setSource:@"My own source defined"];
    [transformData setIcon:@"comapny-logo2.png"];
    [transformData setContentType:@"Text"];
    [transformData setTitle:@"Best Cancer Screening Methods"];
    [transformData setShortDescription:@"Source:HealthDay - Related Medline Plus"];
    [transformData setDetailDescription:@""];
    [self.contentData addObject:transformData];
    
    transformData = [MPTransformData new];
    [transformData setSource:@"ABC"];
    [transformData setIcon:@"bg.png"];
    [transformData setContentType:@"Image"];
    [transformData setTitle:@"Could High-Dose Vitamin D Help Fight Multiple Sclerosis"];
    [transformData setShortDescription:@"Supplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for general"];
    [transformData setDetailDescription:@""];
    [self.contentData addObject:transformData];
    
    transformData = [MPTransformData new];
    [transformData setSource:@"XYZ"];
    [transformData setIcon:@"latestNotificatins.png"];
    [transformData setContentType:@"Image"];
    [transformData setTitle:@"Painkillers Often Gateway to Heroin for U.S Teens: Survey"];
    [transformData setShortDescription:@"Heroin is cheaper, easier to obtain than narcotics like OxyContin experts say..."];
    [transformData setDetailDescription:@"Heroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts say"];
    [self.contentData addObject:transformData];
    
    if ([MRDatabaseHelper getContacts].count == 0) {
        
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"groupList" ofType:@"json"];
        NSData* data = [NSData dataWithContentsOfFile:filePath];
        NSError *error;
        NSArray* groupsArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        [MRDatabaseHelper addGroups:groupsArray];
        
        filePath = [[NSBundle mainBundle] pathForResource:@"my_contacts" ofType:@"json"];
        data = [NSData dataWithContentsOfFile:filePath];
        NSArray* contactsArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        [MRDatabaseHelper addContacts:contactsArray];
        
        filePath = [[NSBundle mainBundle] pathForResource:@"suggested_contacts" ofType:@"json"];
        data = [NSData dataWithContentsOfFile:filePath];
        contactsArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        [MRDatabaseHelper addSuggestedContacts:contactsArray];
        
        filePath = [[NSBundle mainBundle] pathForResource:@"posts" ofType:@"json"];
        data = [NSData dataWithContentsOfFile:filePath];
        NSArray* postsArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        [MRDatabaseHelper addGroupPosts:postsArray];
        
        
    }
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

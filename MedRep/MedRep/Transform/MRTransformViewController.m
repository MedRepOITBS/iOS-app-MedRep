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

@interface MRTransformViewController () <UICollectionViewDelegate, UICollectionViewDataSource,
                                         UITableViewDelegate, UITableViewDataSource,
                                        SWRevealViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UICollectionView *titleCollectionView;

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (weak, nonatomic) IBOutlet UIView *connectView;

@property (weak, nonatomic) IBOutlet UIView *transformView;

@property (weak, nonatomic) IBOutlet UIView *shareView;

@property (weak, nonatomic) IBOutlet UIView *serveView;

@property UIView *activeView;

@property NSArray *categories;
@property (strong, nonatomic) NSMutableArray *contentData;
@property (strong, nonatomic) NSMutableArray *filteredData;

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
    self.navigationItem.title = @"VAMSI";
    self.navigationController.navigationBar.topItem.title = @"VAMSI";
    self.title = @"VAMSI";
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"XXX";
    self.navigationItem.titleView = titleLabel;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    //notiFicationViewController.selectedContent = [self.contentData objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}

- (IBAction)connectButtonTapped:(id)sender {
    self.activeView = sender;
    
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
}

- (IBAction)serveButtonTapped:(id)sender {
    self.serveView = sender;
}



#pragma mark - Dummy Data

- (void)createDummyData {
    // Create Dummy Data
    self.contentData = [NSMutableArray new];
    
    MPTransformData *transformData = [MPTransformData new];
    [transformData setSource:@"BBC"];
    [transformData setIcon:@"comapny-logo.png"];
    [transformData setTitle:@"Could High-Dose Vitamin D Help Fight Multiple Sclerosis"];
    [transformData setShortDescription:@"Supplementation appears safe but experts says it's too soon for general..."];
    [transformData setDetailDescription:@"Supplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for general"];
    [self.contentData addObject:transformData];
    
    transformData = [MPTransformData new];
    [transformData setSource:@"BBC"];
    [transformData setIcon:@"PHdashboard-banner.png"];
    [transformData setTitle:@"Painkillers Often Gateway to Heroin for U.S Teens: Survey"];
    [transformData setShortDescription:@"Heroin is cheaper, easier to obtain than narcotics like OxyContin experts say..."];
    [transformData setDetailDescription:@""];
    [self.contentData addObject:transformData];
    
    transformData = [MPTransformData new];
    [transformData setSource:@"BBC"];
    [transformData setIcon:@"PHdashboard-bg.png"];
    [transformData setTitle:@"It's Not Too late"];
    [transformData setShortDescription:@"Influenza activity usually active in Janurary or February..."];
    [transformData setDetailDescription:@""];
    [self.contentData addObject:transformData];
    
    transformData = [MPTransformData new];
    [transformData setSource:@"My own source defined"];
    [transformData setIcon:@"comapny-logo2.png"];
    [transformData setTitle:@"Best Cancer Screening Methods"];
    [transformData setShortDescription:@"Source:HealthDay - Related Medline Plus"];
    [transformData setDetailDescription:@""];
    [self.contentData addObject:transformData];
    
    transformData = [MPTransformData new];
    [transformData setSource:@"ABC"];
    [transformData setIcon:@"bg.png"];
    [transformData setTitle:@"Could High-Dose Vitamin D Help Fight Multiple Sclerosis"];
    [transformData setShortDescription:@"Supplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for general"];
    [transformData setDetailDescription:@""];
    [self.contentData addObject:transformData];
    
    transformData = [MPTransformData new];
    [transformData setSource:@"XYZ"];
    [transformData setIcon:@"latestNotificatins.png"];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

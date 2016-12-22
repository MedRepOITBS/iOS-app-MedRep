//
//  MRFavoritesNotificationsViewController.m
//  MedRep
//
//  Created by MedRep Developer on 10/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRFavoritesNotificationsViewController.h"
#import "SWRevealViewController.h"
#import "MPNotificatinsTableViewCell.h"
#import "MRFavoriteFilterViewController.h"
#import "MRNotificationInsiderViewController.h"
#import "MRDatabaseHelper.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRNotifications.h"

@interface MRFavoritesNotificationsViewController ()<UITableViewDataSource, UITableViewDelegate, MRFavoriteFilterViewControllerDelegate, SWRevealViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *titletextlabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *notificationsTableView;
@property (nonatomic, retain) NSArray *notificationDetailsList;

@end

@implementation MRFavoritesNotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Favorites";
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    UIBarButtonItem *sortButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cnsort.png"] style:UIBarButtonItemStylePlain target:self action:@selector(sortByButtonAction:)];
    
    [self.navigationItem setRightBarButtonItems:@[rightButtonItem, sortButtonItem]];
    
    // Do any additional setup after loading the view from its nib.
    [self fetchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)fetchData {
    [MRDatabaseHelper getNotifications:NO withFavourite:YES withNotificationsList:^(NSArray *fetchList) {
        self.notificationDetailsList = fetchList;
        [self.notificationsTableView reloadData];
    }];
}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES]; 
}
- (IBAction)sortByButtonAction:(id)sender
{
    MRFavoriteFilterViewController *favFiletrViewController =[[MRFavoriteFilterViewController alloc] initWithNibName:@"MRFavoriteFilterViewController" bundle:nil];
    favFiletrViewController.delegate = self;
    [self.navigationController pushViewController:favFiletrViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notificationDetailsList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier                = @"MRRegTableViewCell";
    MPNotificatinsTableViewCell *regCell    = (MPNotificatinsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (regCell == nil)
    {
        NSArray *nibViews                   = [[NSBundle mainBundle] loadNibNamed:@"MPNotificatinsTableViewCell" owner:nil options:nil];
        regCell                             = (MPNotificatinsTableViewCell *)[nibViews lastObject];
        
    }
    MRNotifications *currentNotification = [self.notificationDetailsList objectAtIndex:indexPath.row];
    NSDictionary *notification = [currentNotification toDictionary];
    
    regCell.notificationLetter.hidden       = NO;
    regCell.notificationLetter.backgroundColor = [MRCommon getColorForIndex:indexPath.row];
    regCell.notificationLetter.text            = [MRCommon getUpperCaseLetter:[notification objectForKey:@"notificationName"]];
    regCell.companyLogo.hidden              = YES;
    regCell.backgroundImage.image           = [UIImage imageNamed:@"transperent-bg.png"];
    regCell.companyLabel.hidden             =
    regCell.medicineLabel.hidden            = NO;
    regCell.companyLabel.text               = [notification objectForKey:@"notificationName"];
    regCell.medicineLabel.text              = [notification objectForKey:@"notificationDesc"];
    
    regCell.arrowImage.image                = [UIImage imageNamed:@"White-right-arrow@2x.png"];
    return regCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[MRCommon showAlert:kComingsoonMSG delegate:nil];
    MRNotificationInsiderViewController *notificationInsiderVc =[[MRNotificationInsiderViewController alloc] initWithNibName:@"MRNotificationInsiderViewController" bundle:nil];
    
    MRNotifications *selectedNotification = [self.notificationDetailsList objectAtIndex:indexPath.row];
    notificationInsiderVc.notificationId = [NSNumber numberWithLong:selectedNotification.notificationId.longValue];
    
    [self.navigationController pushViewController:notificationInsiderVc animated:YES];
}


- (void)loadNotificationsOnFilter:(NSString*)companyName
               withTherapiticName:(NSString*)therapeuticName
{
    [MRDatabaseHelper getNotificationsByFilter:companyName withTherapeuticName:therapeuticName
                                                isRead:NO
             isFavourite:YES
                                  withNotificationsList:^(NSArray *fetchList) {
                             
                             self.notificationDetailsList = fetchList;
                            [self.notificationsTableView reloadData];
                         }];
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (position == FrontViewPositionRight)
    {
        self.view.userInteractionEnabled = NO;
    }
    else if (position == FrontViewPositionLeft)
    {
        self.view.userInteractionEnabled = YES;
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

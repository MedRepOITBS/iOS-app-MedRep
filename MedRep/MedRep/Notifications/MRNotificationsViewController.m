//
//  MRNotificationsViewController.m
//  MedRep
//
//  Created by MedRep Developer on 07/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRNotificationsViewController.h"
#import "MPNotificatinsTableViewCell.h"
#import "MRNotificationsDetailsViewController.h"
#import "MRWebserviceHelper.h"
#import "SWRevealViewController.h"
#import "MRFavoritesNotificationsViewController.h"
#import "MRReadNotificationsViewController.h"
#import "MRDatabaseHelper.h"
#import "MRConstants.h"
#import "MRCommon.h"
#import "MRAppControl.h"
#import "MRNotifications.h"

#define kImagesArray [NSArray arrayWithObjects:@"comapny-logo@2x.png",@"comapny-logo2@2x.png",@"", nil]

@interface MRNotificationsViewController ()<UITableViewDataSource,UITableViewDelegate, SWRevealViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *favoritesButton;
@property (weak, nonatomic) IBOutlet UIButton *readNotifications;

@property (weak, nonatomic) IBOutlet UITableView *notificationTableview;
@property (strong, nonatomic) IBOutlet UIView *navView;
@property (strong, nonatomic) NSMutableArray *notifications;

@end

@implementation MRNotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"Notifications";
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [MRCommon showActivityIndicator:@"Loading..."];
    
    NSString *notificationsDate = ([MRDatabaseHelper getObjectDataExistance:kNotificationsEntity]) ?  [MRCommon stringFromDate:[MRDefaults objectForKey:kNotificationFetchedDate] withDateFormate:@"YYYYMMdd"] : @"20150101";
    notificationsDate = @"20160101";
    
    self.notifications = nil;
    
    [[MRWebserviceHelper sharedWebServiceHelper] getMyNotifications:notificationsDate withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             
             [MRCommon stopActivityIndicator];
             [MRAppControl sharedHelper].notifications = [responce objectForKey:kResponce];
             
             if (nil == self.notifications)
                 self.notifications = [[NSMutableArray alloc] init];
             
             [self getMutableNotifications:[responce objectForKey:kResponce]];
             
             if (self.notifications.count == 0)
             {
                 [MRCommon showAlert:@"No Notifications found." delegate:nil];
             }
             
             [self resetNotificationsCounter];
             [self.notificationTableview reloadData];
            // NSLog(@"%@",self.notifications);
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getMyNotifications:[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMdd"] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       [MRCommon stopActivityIndicator];
                       [self resetNotificationsCounter];
                       if (status)
                       {
                           [MRAppControl sharedHelper].notifications = [responce objectForKey:kResponce];
                           
                           if (nil == self.notifications)
                               self.notifications = [[NSMutableArray alloc] init];
                           
                           [self getMutableNotifications:[responce objectForKey:kResponce]];
                           
                           if (self.notifications.count == 0)
                           {
                               [MRCommon showAlert:@"No Notifications found." delegate:nil];
                           }

                           [self.notificationTableview reloadData];
                           NSLog(@"%@",self.notifications);
                           
                       }
                   }];
              }];
         }
         else
         {
             [MRCommon stopActivityIndicator];
             [self resetNotificationsCounter];
             [MRCommon showAlert:@"No New Notifications found." delegate:nil];
             if (nil == self.notifications)
                 self.notifications = [[NSMutableArray alloc] init];

             [self getMutableNotifications:[NSArray array]];
         }

    }];

    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MRCommon applyNavigationBarStyling:self.navigationController];
}

- (void)resetNotificationsCounter {
    NSDictionary *dict = @{@"resetDoctorPlusCount":[NSNumber numberWithBool:false],
                           @"resetNotificationCount":[NSNumber numberWithBool:true],
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

- (void)getMutableNotifications:(NSArray*)notifictions
{
    if(self.notifications.count > 0) [self.notifications removeAllObjects];
    
    if (notifictions.count > 0)
    {
        [MRDatabaseHelper addNotifications:notifictions];
    }
    
    [MRDatabaseHelper getNotifications:NO withFavourite:NO withNotificationsList:^(NSArray *fetchList)
    {
        [MRAppControl sharedHelper].notifications = fetchList;
        
        NSArray *uniqueCompanies = [fetchList valueForKeyPath:@"@distinctUnionOfObjects.companyId"];
        
        for (NSString *companyId in uniqueCompanies)
        {
            NSArray *filteredArray          = [fetchList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"companyId == %@", companyId]];
            
            if (filteredArray && filteredArray.count > 0) {
                [self.notifications addObject:filteredArray.firstObject];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonAction:(id)sender
{
    if (self.isFromMenu)
    {
         [[NSNotificationCenter defaultCenter] postNotificationName:kDashboardNotificationFromRegistartionScren object:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)favoritesButtonAction:(id)sender
{
    MRFavoritesNotificationsViewController *notiFicationViewController = [[MRFavoritesNotificationsViewController alloc] initWithNibName:@"MRFavoritesNotificationsViewController" bundle:nil];
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}

- (IBAction)readNotificationsActions:(id)sender
{
    MRReadNotificationsViewController *notiFicationViewController = [[MRReadNotificationsViewController alloc] initWithNibName:@"MRReadNotificationsViewController" bundle:nil];
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
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
    return [self getCompanyCount];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier                = @"MRRegTableViewCell";
    MPNotificatinsTableViewCell *regCell     = (MPNotificatinsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (regCell == nil)
    {
        NSArray *nibViews                   = [[NSBundle mainBundle] loadNibNamed:@"MPNotificatinsTableViewCell" owner:nil options:nil];
        regCell                             = (MPNotificatinsTableViewCell *)[nibViews lastObject];
        
    }
    
    MRNotifications *notification = [self.notifications objectAtIndex:indexPath.row];
    NSDictionary *dict = [notification toDictionary];
    
    regCell.notificationLetter.hidden           = YES;
    
    regCell.indicatorNewXCoordinate.constant    = 10;
    
    regCell.indicationNewLabel.hidden           = ([[[dict objectForKey:@"status"] uppercaseString] isEqualToString:[@"New" uppercaseString]]) ? NO : YES;
    regCell.companyLabel.hidden             = NO;
    regCell.companyLabel.text               = [dict objectForKey:@"companyName"];
    id displayPicture = [dict objectForKey:@"dPicture"];
    if (displayPicture != nil) {
//        NSDictionary *comapnyDetails                = [[MRAppControl sharedHelper] getCompanyDetailsByID:[[dict objectForKey:@"companyId"] intValue]];
        [MRAppControl getNotificationImage:[dict objectForKey:@"companyId"]
                             displayPicture:displayPicture andImageView:regCell.companyLogo];
    } else {
        regCell.companyLogo.image = nil;
    }
    
    return regCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MRNotificationsDetailsViewController *notiFicationViewController = [[MRNotificationsDetailsViewController alloc] initWithNibName:@"MRNotificationsDetailsViewController" bundle:nil];
    notiFicationViewController.selectedNotification = [self.notifications objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}

- (NSInteger)getCompanyCount
{
    NSMutableArray * array= [[NSMutableArray alloc] init];
    for (MRNotifications *notification in self.notifications)
    {
        if (NO == [array containsObject:notification.companyId])
        {
            [array addObject:notification.companyId];
        }
    }
    return array.count;
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

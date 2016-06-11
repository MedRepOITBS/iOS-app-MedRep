//
//  MRNewProductCompaignsViewController.m
//  MedRep
//
//  Created by MedRep Developer on 27/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRNewProductCompaignsViewController.h"
#import "SWRevealViewController.h"
#import "MRNewProductCell.h"
//#import "MRConvertAppointmentViewController.h"
#import "MRPharmaNotificationDetailsViewController.h"
#import "MRWebserviceHelper.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRAppControl.h"
#import "MPNotificatinsTableViewCell.h"

@interface MRNewProductCompaignsViewController ()<UITableViewDataSource,UITableViewDelegate, SWRevealViewControllerDelegate>
{
    NSArray *dataSourceArray;
}

@property (weak, nonatomic) IBOutlet UIImageView *companyImage;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *pcTableView;

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (nonatomic, retain) NSMutableArray *notifications;

@end

@implementation MRNewProductCompaignsViewController

- (void)getMenuNavigationButtonWithController:(SWRevealViewController *)revealViewCont NavigationItem:(UINavigationItem *)navigationItem1
{
    SWRevealViewController *revealController = revealViewCont;
    revealController.delegate = self;
    //[NSArray arrayWithObjects:@"pcselect@2x.png",@"pcfedback@2x.png",@"pcplus@2x.png",nil];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    revealButtonItem.tintColor = [UIColor blackColor];
    navigationItem1.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataSourceArray = @[@"Test 1",@"Test 2",@"Test 3",@"Test 4"];
    
    
    [self getMenuNavigationButtonWithController:[self revealViewController] NavigationItem:self.navigationItem];
    [self getCompanyDetails];
    [self loadPharamaNotifications];
    // Do any additional setup after loading the view from its nib.
}

- (void)loadPharamaNotifications
{
    [MRCommon showActivityIndicator:@"Loading..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getPharmaNotifications:[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMdd"] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             [MRCommon stopActivityIndicator];
             [MRAppControl sharedHelper].notifications = [responce objectForKey:kResponce];
             
             if (nil == self.notifications)
                 self.notifications = [[NSMutableArray alloc] init];
             
             self.notifications =  [responce objectForKey:kResponce];
             
             if (self.notifications.count == 0)
             {
                 [MRCommon showAlert:@"No Notifications found." delegate:nil];
             }
//
            [self.pcTableView reloadData];
             // NSLog(@"%@",self.notifications);
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getPharmaNotifications:[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMdd"] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       [MRCommon stopActivityIndicator];
                       if (status)
                       {
                           [MRAppControl sharedHelper].notifications = [responce objectForKey:kResponce];
                           
                           if (nil == self.notifications)
                               self.notifications = [[NSMutableArray alloc] init];
                           
                           self.notifications =  [responce objectForKey:kResponce];
                           
                           if (self.notifications.count == 0)
                           {
                               [MRCommon showAlert:@"No Notifications found." delegate:nil];
                           }
                           
                           [self.pcTableView reloadData];
                           NSLog(@"%@",self.notifications);
                       }
                   }];
              }];
         }
         else
         {
             [MRCommon stopActivityIndicator];
             [MRCommon showAlert:@"No Notifications found." delegate:nil];
         }
         
     }];
}

- (void)getCompanyDetails
{
    [MRCommon showActivityIndicator:@"Loading..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getCompanyDetails:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             self.companyImage.image = [self companyImage:[responce objectForKey:kResponce]];
             //[UIImage imageWithData:[[responce objectForKey:@"displayPicture"] objectForKey:@"data"]];
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getCompanyDetails:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       [MRCommon stopActivityIndicator];
                       if (status)
                       {
                           self.companyImage.image = [self companyImage:[responce objectForKey:kResponce]];
                       }
                   }];
              }];
         }
         else
         {
             [MRCommon stopActivityIndicator];
             [MRCommon showAlert:@"No Details found." delegate:nil];
         }
         
     }];

}

- (UIImage*)companyImage:(NSArray*)responce
{
    NSString *company = [[MRAppControl sharedHelper].userRegData objectForKey:KDoctorRegID];
    for (NSDictionary *data in responce)
    {
        if ([[data objectForKey:@"companyId"] longLongValue] == [company longLongValue]) {
            return[MRCommon getImageFromBase64Data:[[data objectForKey:@"displayPicture"] objectForKey:@"data"]];
        }
    }
    
    return [UIImage imageWithData:nil];
}
- (IBAction)backButttonAction:(id)sender
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

#pragma mark Table View Data Source ---

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

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier                = @"MRRegTableViewCell";
    MPNotificatinsTableViewCell *regCell    = (MPNotificatinsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (regCell == nil)
    {
        NSArray *nibViews                   = [[NSBundle mainBundle] loadNibNamed:@"MPNotificatinsTableViewCell" owner:nil options:nil];
        regCell                             = (MPNotificatinsTableViewCell *)[nibViews lastObject];
        
    }
    NSDictionary *notification              = [self.notifications objectAtIndex:indexPath.row];
    
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

//    static NSString *productCelId = @"productCellIdentity";
//    
//    MRNewProductCell *productCell = (MRNewProductCell*)[tableView dequeueReusableCellWithIdentifier:productCelId];
//    
//    if (productCell == nil)
//    {
//        NSArray *bundleCell = [[NSBundle mainBundle] loadNibNamed:@"MRNewProductCell" owner:nil options:nil];
//        productCell = (MRNewProductCell *)[bundleCell lastObject];
//    }
//    
//    productCell.productNameLabel.text = [dataSourceArray objectAtIndex:indexPath.row];
//    
//    return productCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MRPharmaNotificationDetailsViewController *notificationInsiderVc = [[MRPharmaNotificationDetailsViewController alloc] initWithNibName:@"MRPharmaNotificationDetailsViewController" bundle:nil];
    notificationInsiderVc.notificationDetails = [self.notifications objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:notificationInsiderVc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

@end

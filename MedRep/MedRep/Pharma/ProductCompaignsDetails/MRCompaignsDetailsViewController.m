//
//  MRCompaignsDetailsViewController.m
//  MedRep
//
//  Created by MedRep Developer on 28/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRCompaignsDetailsViewController.h"
#import "MRConvertAppointmentViewController.h"
#import "SWRevealViewController.h"
#import "MRWebserviceHelper.h"
#import "MRFeedBackResultViewController.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"

@interface MRCompaignsDetailsViewController ()<SWRevealViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@end
// ten label height 10
@implementation MRCompaignsDetailsViewController

- (void)getMenuNavigationButtonWithController:(SWRevealViewController *)revealViewCont NavigationItem:(UINavigationItem *)navigationItem1
{
    SWRevealViewController *revealController = revealViewCont;
    revealController.delegate = self;
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
    self.convertedAppointmentCountLabel.text = @"";
    self.sentAppointmentCountLabel.text = @"";
    self.viewedAppointmentCountLabel.text = @"";

    [self getMenuNavigationButtonWithController:[self revealViewController] NavigationItem:self.navigationItem];
    self.titleLabel.text = [NSString stringWithFormat:@"%@ Campaign Details", self.titleText];
    [self callService];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)callService
{
    [MRCommon showActivityIndicator:@"Loading..."];

    [[MRWebserviceHelper sharedWebServiceHelper] getNotificationStatsForPharma:[NSString stringWithFormat:@"%ld", self.notificationID] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             /*
              {"notificationId":2,"notificationName":"Becovit - Z","totalSentNotification":3,"totalPendingNotifcation":2,"totalViewedNotifcation":1,"totalConvertedToAppointment":4}
              */
             [MRCommon stopActivityIndicator];
             self.convertedAppointmentCountLabel.text = [NSString stringWithFormat:@"%ld",[[responce objectForKey:@"totalConvertedToAppointment"] integerValue]];
              self.sentAppointmentCountLabel.text = [NSString stringWithFormat:@"%ld",[[responce objectForKey:@"totalSentNotification"] integerValue]];
             self.viewedAppointmentCountLabel.text = [NSString stringWithFormat:@"%ld",[[responce objectForKey:@"totalViewedNotifcation"] integerValue]];
             
             // NSLog(@"%@",self.notifications);
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                   [[MRWebserviceHelper sharedWebServiceHelper] getNotificationStatsForPharma:[NSString stringWithFormat:@"%ld", self.notificationID] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       [MRCommon stopActivityIndicator];
                       if (status)
                       {
                           self.convertedAppointmentCountLabel.text = [NSString stringWithFormat:@"%ld",[[responce objectForKey:@"totalConvertedToAppointment"] integerValue]];
                           self.sentAppointmentCountLabel.text = [NSString stringWithFormat:@"%ld",[[responce objectForKey:@"totalSentNotification"] integerValue]];
                           self.viewedAppointmentCountLabel.text = [NSString stringWithFormat:@"%ld",[[responce objectForKey:@"totalViewedNotifcation"] integerValue]];
                       }
                   }];
              }];
         }
         else
         {
             [MRCommon stopActivityIndicator];
             self.convertedAppointmentCountLabel.text = @"0";
             self.sentAppointmentCountLabel.text = @"0";
             self.viewedAppointmentCountLabel.text = @"0";
             [MRCommon showAlert:@"No Details found." delegate:nil];
         }
         
     }];
}

- (void)updateTitleLabel
{
    self.titleLabel.text = [NSString stringWithFormat:@"%@ Camaign Details", self.titleText];
}

- (IBAction)checkFeedbackButtonAction:(id)sender
{
    MRFeedBackResultViewController *feedbackResult = [[MRFeedBackResultViewController alloc] initWithNibName:@"MRFeedBackResultViewController" bundle:nil];
    feedbackResult.notificationID = self.notificationID;
    feedbackResult.productName = self.titleText;
    [self.navigationController pushViewController:feedbackResult animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)clickHereButtonAction:(id)sender
{
    MRConvertAppointmentViewController *convertAppointment =[[MRConvertAppointmentViewController alloc] initWithNibName:@"MRConvertAppointmentViewController" bundle:nil];
    convertAppointment.notificationID = self.notificationID;
    convertAppointment.productName =self.titleText;
    [self.navigationController pushViewController:convertAppointment animated:YES];
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

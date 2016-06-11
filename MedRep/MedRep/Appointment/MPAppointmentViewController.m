//
//  MPAppointmentViewController.m
//  MedRep
//
//  Created by MedRep Developer on 08/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MPAppointmentViewController.h"
#import "SWRevealViewController.h"
#import "MRNotificationInsiderViewController.h"
#import "MPCallMedrepViewController.h"
#import "MRConstants.h"
#import "MRCommon.h"
#import "NSDate+Utilities.h"
#import "MRWebserviceHelper.h"
#import "MRAppControl.h"

@interface MPAppointmentViewController ()<SWRevealViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *productDetailsButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *datelabel;
@property (weak, nonatomic) IBOutlet UIButton *rescheduleButton;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *companylabel;
@property (weak, nonatomic) IBOutlet UILabel *drugLabel;

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drugViewBottomConstaint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *companyViewBottomConstaint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationViewBottomConstaint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateViewBottomConstaint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeViewBottomConstaint;
@end

@implementation MPAppointmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealController = [self revealViewController];
    revealController.delegate = self;
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self setUpView];

    // Do any additional setup after loading the view from its nib.
}

- (void)setUpView
{
    if ([MRCommon deviceHasThreePointFiveInchScreen])
    {
        self.drugViewBottomConstaint.constant = 10;
        self.companyViewBottomConstaint.constant =
        self.locationViewBottomConstaint.constant =
        self.dateViewBottomConstaint.constant =
        self.timeViewBottomConstaint.constant = 0;
    }
    else if ([MRCommon deviceHasFourInchScreen])
    {
        self.drugViewBottomConstaint.constant = 60;
        self.companyViewBottomConstaint.constant =
        self.locationViewBottomConstaint.constant =
        self.dateViewBottomConstaint.constant =
        self.timeViewBottomConstaint.constant = 0;

    }
    else if ([MRCommon deviceHasFourPointSevenInchScreen])
    {
        self.drugViewBottomConstaint.constant = 60;
        self.companyViewBottomConstaint.constant =
        self.locationViewBottomConstaint.constant =
        self.dateViewBottomConstaint.constant =
        self.timeViewBottomConstaint.constant = 25;
    }
    else if ([MRCommon deviceHasFivePointFiveInchScreen])
    {
        self.drugViewBottomConstaint.constant = 80;
        self.companyViewBottomConstaint.constant =
        self.locationViewBottomConstaint.constant =
        self.dateViewBottomConstaint.constant =
        self.timeViewBottomConstaint.constant = 30;
    }
    
    [self updateViewConstraints];
    [self getNotificatcationsOnDemand];
    [self fillAppointmentData];
}

- (void)getNotificatcationsOnDemand
{
    if ([MRAppControl sharedHelper].notifications.count == 0)
    {
        [MRCommon showActivityIndicator:@"Loading..."];
        [[MRWebserviceHelper sharedWebServiceHelper] getMyNotifications:[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMdd"] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
         {
             if (status)
             {
                 [MRCommon stopActivityIndicator];
                 [MRAppControl sharedHelper].notifications = [responce objectForKey:kResponce];
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
                           if (status)
                           {
                               [MRAppControl sharedHelper].notifications = [responce objectForKey:kResponce];
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
}

- (void)fillAppointmentData
{
    NSDate *date = [MRCommon dateFromstring:[self.selectedAppointment objectForKey:@"startDate"] withDateFormate:@"YYYYMMddHHmmss"];
    self.timeLabel.text = [MRCommon stringFromDate:date withDateFormate:@"hh:mm a"];//[date shortTimeString];
    
    self.datelabel.text = [MRCommon stringFromDate:date withDateFormate:@"dd-MM-YYYY"];
    
    self.locationLabel.text = [self.selectedAppointment objectForKey:@"location"];
    
    self.companylabel.text =  [self.selectedAppointment objectForKey:@"companyname"];
    
    self.drugLabel.text =  [self.selectedAppointment objectForKey:@"title"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)rescheduleButtonAction:(id)sender
{
//    [MRCommon showAlert:kComingsoonMSG delegate:nil];
//    return;

    MPCallMedrepViewController *callMedrepDetails = [[MPCallMedrepViewController alloc] initWithNibName:@"MPCallMedrepViewController" bundle:nil];
    callMedrepDetails.isFromReschedule = YES;
    callMedrepDetails.selectedNotification = self.selectedAppointment;
    [self.navigationController pushViewController:callMedrepDetails animated:YES];
}
- (IBAction)productDetailsButtonAction:(id)sender
{
    MRNotificationInsiderViewController *prodcutDetails = [[MRNotificationInsiderViewController alloc] initWithNibName:@"MRNotificationInsiderViewController" bundle:nil];
    
    prodcutDetails.notificationDetails = [[MRAppControl sharedHelper] getNotificationByID:[[self.selectedAppointment objectForKey:@"notificationId"] integerValue]];
    [self.navigationController pushViewController:prodcutDetails animated:YES];
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

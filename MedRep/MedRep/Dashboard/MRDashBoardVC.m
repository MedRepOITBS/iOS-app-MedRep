//
//  MRDashBoardVC.m
//  MedRep
//
//  Created by MedRep Developer on 13/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRDashBoardVC.h"
#import "MRAppointmentCell.h"
#import "SWRevealViewController.h"
#import "MRAppointmentCell.h"
#import "MRNotificationsViewController.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRWebserviceHelper.h"
#import "MRAppControl.h"
#import "MPAppointmentViewController.h"
#import "MRSurveyListViewController.h"
#import "MRDoctorActivityScoreViewController.h"
#import "MRTransformViewController.h"
#import "MRDrugSearchViewController.h"
#import "AppDelegate.h"
#import "MRCustomTabBar.h"

@interface MRDashBoardVC () <UITableViewDataSource, UITableViewDelegate, SWRevealViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *titleView;

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UITableView *appointmentsTableView;
@property (weak, nonatomic) IBOutlet UIView *notificationsView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *optionsView;
@property (strong, nonatomic) NSArray *myAppointments;
@property (assign, nonatomic) NSInteger currentIndex;

@property (weak, nonatomic) IBOutlet UIImageView *newsImage;
@property (weak, nonatomic) IBOutlet UIImageView *searchImage;
@property (weak, nonatomic) IBOutlet UIImageView *marketingCampImage;

@property (weak, nonatomic) IBOutlet UIView *notificationsSuperView;
@property (weak, nonatomic) IBOutlet UIView *marketingCampaignSuperView;
@property (weak, nonatomic) IBOutlet UIView *surveysSuperView;
@property (weak, nonatomic) IBOutlet UIView *searchForDrugsSuperView;
@property (weak, nonatomic) IBOutlet UIView *activityScoreSuperView;
@property (weak, nonatomic) IBOutlet UIView *doctorPlusSuperView;

@property (weak, nonatomic) IBOutlet UILabel *notificationPendingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *surveysPendingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *doctorPlusPendingCountLabel;

@end

@implementation MRDashBoardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.marketingCampaignSuperView.alpha = 0.5;
    self.marketingCampaignSuperView.userInteractionEnabled = NO;
    self.marketingCampaignSuperView.alpha = 0.4f;
    
    SWRevealViewController *revealController = [self revealViewController];
    revealController.delegate = self;
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    self.currentIndex = 0;
    [self enableDisableLeftButton:NO];
    [self enableDisableRightButton:NO];
    [self setUpUI];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getPendingCounts];
    
    [self.titleView setBackgroundColor:[MRCommon colorFromHexString:kStatusBarColor]];
    [MRCommon applyNavigationBarStyling:self.navigationController];
    
    if ([APP_DELEGATE.launchScreen isEqualToString:@"Survey"]) {
        MRSurveyListViewController *surveyListViewController = [[MRSurveyListViewController alloc] initWithNibName:@"MRSurveyListViewController" bundle:nil];
        surveyListViewController.isFromMenu = NO;
        [self.navigationController pushViewController:surveyListViewController animated:NO];
        APP_DELEGATE.launchScreen = @"";
    }else if ([APP_DELEGATE.launchScreen isEqualToString:@"Notifications"]){
        MRNotificationsViewController *notifications = [[MRNotificationsViewController alloc] initWithNibName:@"MRNotificationsViewController" bundle:nil];
        [self.navigationController pushViewController:notifications animated:NO];
        APP_DELEGATE.launchScreen = @"";
    }else{
      [self getAppointmnets];
    }
}

- (void)enableDisableLeftButton:(BOOL)isEnable
{
    self.leftButton.enabled = isEnable;
    self.leftButton.alpha = isEnable ? 1.0 : 0.5;
    self.leftButton.userInteractionEnabled = isEnable;
  
}

- (void)enableDisableRightButton:(BOOL)isEnable
{
    self.rightButton.enabled = isEnable;
    self.rightButton.alpha = isEnable ? 1.0 : 0.5;
    self.rightButton.userInteractionEnabled = isEnable;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setUpUI
{
    NSDictionary *userData = [MRAppControl sharedHelper].userRegData;
    self.titleLabel.text = [NSString stringWithFormat:@"Welcome %@ %@", [userData objectForKey:KFirstName],[userData objectForKey:KLastName]];
    
    UITapGestureRecognizer *notificationsSuperViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(latestnotificationsButtonAction:)];
    [notificationsSuperViewTapRecognizer setNumberOfTapsRequired:1];
    [self.notificationsSuperView addGestureRecognizer:notificationsSuperViewTapRecognizer];
    
    UITapGestureRecognizer *marketingCampaignSuperViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(marketingCompaginsButtonAction:)];
    [marketingCampaignSuperViewTapRecognizer setNumberOfTapsRequired:1];
    [self.marketingCampaignSuperView addGestureRecognizer:marketingCampaignSuperViewTapRecognizer];
    
    UITapGestureRecognizer *surveysSuperViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(surveysButtonAction:)];
    [surveysSuperViewTapRecognizer setNumberOfTapsRequired:1];
    [self.surveysSuperView addGestureRecognizer:surveysSuperViewTapRecognizer];
    
    UITapGestureRecognizer *searchForDrugsSuperViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(searchButtonAction:)];
    [searchForDrugsSuperViewTapRecognizer setNumberOfTapsRequired:1];
    [self.searchForDrugsSuperView addGestureRecognizer:searchForDrugsSuperViewTapRecognizer];
    
    UITapGestureRecognizer *activityScoreSuperViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(activityScoreButtonAction:)];
    [activityScoreSuperViewTapRecognizer setNumberOfTapsRequired:1];
    [self.activityScoreSuperView addGestureRecognizer:activityScoreSuperViewTapRecognizer];
    
    UITapGestureRecognizer *doctorPlusSuperViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(newsButtonAction:)];
    [doctorPlusSuperViewTapRecognizer setNumberOfTapsRequired:1];
    [self.doctorPlusSuperView addGestureRecognizer:doctorPlusSuperViewTapRecognizer];
    
    [self.notificationPendingCountLabel.layer setMasksToBounds:YES];
    self.notificationPendingCountLabel.layer.cornerRadius = 8.0f;
    [self.notificationPendingCountLabel setHidden:YES];
    
    [self.surveysPendingCountLabel.layer setMasksToBounds:YES];
    self.surveysPendingCountLabel.layer.cornerRadius = 8.0f;
    [self.surveysPendingCountLabel setHidden:YES];
    
    [self.doctorPlusPendingCountLabel.layer setMasksToBounds:YES];
    self.doctorPlusPendingCountLabel.layer.cornerRadius = 8.0f;
    [self.doctorPlusPendingCountLabel setHidden:YES];
}

- (void)setPendingCountValuesInRespectiveLables:(NSDictionary*)data {
    NSInteger notificationsCount = 0;
    NSInteger surveysCount = 0;
    NSInteger dashboardCount = 0;
    
    if (data != nil) {
        id value = [data objectForCaseInsensitiveKey:@"notifications"];
        if (value != nil && [value isKindOfClass:[NSNumber class]]) {
            notificationsCount = ((NSNumber*)value).integerValue;
        }
        
        value = [data objectForCaseInsensitiveKey:@"surveys"];
        if (value != nil && [value isKindOfClass:[NSNumber class]]) {
            surveysCount = ((NSNumber*)value).integerValue;
        }
        
        value = [data objectForCaseInsensitiveKey:@"dashbaord"];
        if (value != nil && [value isKindOfClass:[NSNumber class]]) {
            dashboardCount = ((NSNumber*)value).integerValue;
        }
    }
    
    [MRAppControl sharedHelper].pendingNotificationCount = notificationsCount;
    [MRAppControl sharedHelper].pendingSurveysCount = surveysCount;
    [MRAppControl sharedHelper].pendingDashboardCount = dashboardCount;
    
    if (notificationsCount > 0) {
        [self.notificationPendingCountLabel setHidden:NO];
        [self.notificationPendingCountLabel setText:[NSString stringWithFormat:@"%ld", (long)notificationsCount]];
    } else {
        [self.notificationPendingCountLabel setHidden:YES];
    }
    
    if (surveysCount > 0) {
        [self.surveysPendingCountLabel setHidden:NO];
        [self.surveysPendingCountLabel setText:[NSString stringWithFormat:@"%ld", (long)surveysCount]];
    } else {
        [self.surveysPendingCountLabel setHidden:YES];
    }
    
    if (dashboardCount > 0) {
        [self.doctorPlusPendingCountLabel setHidden:NO];
        [self.doctorPlusPendingCountLabel setText:[NSString stringWithFormat:@"%ld", (long)dashboardCount]];
    } else {
        [self.doctorPlusPendingCountLabel setHidden:YES];
    }
}

- (void)getPendingCounts {
    NSDictionary *dict = @{@"resetDoctorPlusCount":[NSNumber numberWithBool:false],
                           @"resetNotificationCount":[NSNumber numberWithBool:false],
                           @"resetSurveyCount": [NSNumber numberWithBool:false]};
    [[MRWebserviceHelper sharedWebServiceHelper] getPendingCount:dict andHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             [self setPendingCountValuesInRespectiveLables:[responce objectForCaseInsensitiveKey:kResult]];
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getPendingCount:dict andHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       if (status)
                       {
                           [self setPendingCountValuesInRespectiveLables:[responce objectForCaseInsensitiveKey:kResult]];
                       }
                   }];
                  
              }];
         }
     }];
}

- (void)getAppointmnets
{
    [[MRWebserviceHelper sharedWebServiceHelper] getMyAppointments:[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMdd"] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             self.myAppointments = [responce objectForKey:kResponce];
             
             [[MRAppControl sharedHelper] setMyAppointmentDetails:[responce objectForKey:kResponce]];
             
             if (self.myAppointments.count == 0 || self.myAppointments.count == 1)
             {
                 [self enableDisableLeftButton:NO];
                 [self enableDisableRightButton:NO];
             }
             else{
                 [self enableDisableLeftButton:NO];
                 [self enableDisableRightButton:YES];
             }
             
             [self.appointmentsTableView reloadData];
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getMyAppointments:[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMdd"] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       if (status)
                       {
                           self.myAppointments = [responce objectForKey:kResponce];
                           
                           [[MRAppControl sharedHelper] setMyAppointmentDetails:[responce objectForKey:kResponce]];
                           
                           if (self.myAppointments.count == 0 || self.myAppointments.count == 1)
                           {
                               [self enableDisableLeftButton:NO];
                               [self enableDisableRightButton:NO];
                           }
                           else{
                               [self enableDisableLeftButton:NO];
                               [self enableDisableRightButton:YES];
                           }

                           [self.appointmentsTableView reloadData];
                       }
                   }];
                  
              }];
         }
         else
         {
             [self enableDisableLeftButton:NO];
             [self enableDisableRightButton:NO];
         }
     }];
}

- (IBAction)leftButtonAction:(id)sender
{
    --self.currentIndex;

    [self enableDisableLeftButton:(0 == self.currentIndex) ? NO : YES];
    
    
    [self.appointmentsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    [self enableDisableRightButton:YES];

}

- (IBAction)rightButtonAction:(id)sender
{
    [self enableDisableLeftButton:YES];
    
    ++self.currentIndex;
    
    [self.appointmentsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [self enableDisableRightButton:(self.myAppointments.count == self.currentIndex + 1) ? NO : YES];
    
}

- (IBAction)latestnotificationsButtonAction:(id)sender
{
    [self notificationsButtonAction:sender];
}

- (IBAction)notificationsButtonAction:(id)sender
{
    MRNotificationsViewController *notifications = [[MRNotificationsViewController alloc] initWithNibName:@"MRNotificationsViewController" bundle:nil];
    [self.navigationController pushViewController:notifications animated:YES];
}
- (IBAction)surveysButtonAction:(id)sender
{
    MRSurveyListViewController *surveyListViewController = [[MRSurveyListViewController alloc] initWithNibName:@"MRSurveyListViewController" bundle:nil];
    surveyListViewController.isFromMenu = NO;
    [self.navigationController pushViewController:surveyListViewController animated:YES];
}

- (IBAction)activityScoreButtonAction:(id)sender
{
    MRDoctorActivityScoreViewController *activityScoreViewController = [[MRDoctorActivityScoreViewController alloc] initWithNibName:@"MRDoctorActivityScoreViewController" bundle:nil];
    activityScoreViewController.isFromMenu = NO;
    [self.navigationController pushViewController:activityScoreViewController animated:YES];
}

- (IBAction)marketingCompaginsButtonAction:(id)sender
{
    //[MRCommon showAlert:kComingsoonMSG delegate:nil];
}

- (IBAction)searchButtonAction:(id)sender
{
    MRDrugSearchViewController *notiFicationViewController = [[MRDrugSearchViewController alloc] initWithNibName:@"MRDrugSearchViewController" bundle:nil];
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}

- (IBAction)newsButtonAction:(id)sender
{
    MRTransformViewController *notiFicationViewController = [[MRTransformViewController alloc] initWithNibName:@"MRTransformViewController" bundle:nil];
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myAppointments.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier                = @"MRAppointmentCell";
    MRAppointmentCell *appointmentCell     = (MRAppointmentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (appointmentCell == nil)
    {
        NSArray *nibViews                   = [[NSBundle mainBundle] loadNibNamed:@"MRAppointmentCell" owner:nil options:nil];
        appointmentCell                           = (MRAppointmentCell *)[nibViews lastObject];
        
    }
    
    [appointmentCell configureAppointmentCell:[self.myAppointments objectAtIndex:indexPath.row]];
    
    return appointmentCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"selected ==> %@",[self.myAppointments objectAtIndex:indexPath.row]);
    MPAppointmentViewController *appontVC =[[MPAppointmentViewController alloc] initWithNibName:@"MPAppointmentViewController" bundle:nil];
    appontVC.selectedAppointment = [self.myAppointments objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:appontVC animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)appointmentButtonAction:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMedRepMeetingsNotification object:nil];
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
@end

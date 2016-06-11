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

@interface MRDashBoardVC () <UITableViewDataSource, UITableViewDelegate, SWRevealViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UITableView *appointmentsTableView;
@property (weak, nonatomic) IBOutlet UIView *notificationsView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *optionsView;
@property (weak, nonatomic) IBOutlet UIButton *notificationsButton;
@property (weak, nonatomic) IBOutlet UIButton *surveysButton;
@property (weak, nonatomic) IBOutlet UIButton *activityScoreButton;
@property (weak, nonatomic) IBOutlet UIButton *marketingCompaginsButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *newsButon;
@property (strong, nonatomic) NSArray *myAppointments;
@property (assign, nonatomic) NSInteger currentIndex;

@property (weak, nonatomic) IBOutlet UIImageView *newsImage;
@property (weak, nonatomic) IBOutlet UIImageView *searchImage;
@property (weak, nonatomic) IBOutlet UIImageView *marketingCampImage;

@end

@implementation MRDashBoardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.marketingCompaginsButton.alpha = 0.5f;
    self.searchButton.alpha = 0.5f;
    self.newsButon.alpha = 0.5;
    
    self.marketingCompaginsButton.enabled = NO;
    self.searchButton.enabled = NO;
    self.newsButon.enabled = NO;
    
    self.newsImage.alpha =
    self.searchImage.alpha =
    self.marketingCampImage.alpha = 0.4f;
    
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
    [self getAppointmnets];
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
    self.appointmentsTableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
    
    if([MRCommon deviceHasThreePointFiveInchScreen])
    {
        [self.appointmentsTableView setFrame:CGRectMake(43 , 50, 234 , 50)];
    }
    else if([MRCommon deviceHasFourInchScreen])
    {
        [self.appointmentsTableView setFrame:CGRectMake(43 , 65, 234 , 50)];
    }
    else if([MRCommon deviceHasFourPointSevenInchScreen])
    {
        [self.appointmentsTableView setFrame:CGRectMake(52 , 70, 270 , 90)];

    }
    else if([MRCommon deviceHasFivePointFiveInchScreen])
    {
        [self.appointmentsTableView setFrame:CGRectMake(57 , 80, 300 , 90)];
    }

    
    NSDictionary *userData = [MRAppControl sharedHelper].userRegData;
    self.titleLabel.text = [NSString stringWithFormat:@"Welcome %@. %@ %@", [userData objectForKey:KTitle],[userData objectForKey:KFirstName],[userData objectForKey:KLastName]];
    self.appointmentsTableView.showsHorizontalScrollIndicator = NO;
    self.appointmentsTableView.showsVerticalScrollIndicator   = NO;
    self.appointmentsTableView.scrollEnabled = NO;
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
    //[MRCommon showAlert:kComingsoonMSG delegate:nil];
}

- (IBAction)newsButtonAction:(id)sender
{
   // [MRCommon showAlert:kComingsoonMSG delegate:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myAppointments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.appointmentsTableView.frame.size.width;
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

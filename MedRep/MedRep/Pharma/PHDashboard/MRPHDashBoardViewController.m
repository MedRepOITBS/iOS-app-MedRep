//
//  MRPHDashBoardViewController.m
//  MedRep
//
//  Created by MedRep Developer on 25/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRPHDashBoardViewController.h"
#import "SWRevealViewController.h"
#import "MRConstants.h"
#import "MRCommon.h"
#import "MRAppointmentCell.h"
#import "MRDocotrActivityScoreViewController.h"
#import "MRViewAppointmnetViewController.h"
#import "MRWebserviceHelper.h"
#import "MRAppControl.h"
#import "MRMedRepViewController.h"
#import "MRNewProductCompaignsViewController.h"
#import "MRMedRepListViewController.h"
#import "MRViewRepAppointmnetViewController.h"

@interface MRPHDashBoardViewController ()<SWRevealViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet UIView *optionView;
@property (weak, nonatomic) IBOutlet UIView *appointmentView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *notificationImage;

@property (weak, nonatomic) IBOutlet UIButton *trackProductButton;
@property (weak, nonatomic) IBOutlet UIButton *latestSurveysButton;
@property (weak, nonatomic) IBOutlet UIButton *doctorActivityButton;
@property (weak, nonatomic) IBOutlet UIButton *trackMedrepButton;

@property (weak, nonatomic) IBOutlet UITableView *appointmentTableview;
@property (weak, nonatomic) IBOutlet UIButton *appointmentButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) NSArray *myAppointments;
@property (assign, nonatomic) NSInteger currentIndex;
@property (weak, nonatomic) IBOutlet UIImageView *surveysImage;


@property (strong, nonatomic) IBOutlet UIView *navView;

@end

@implementation MRPHDashBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.latestSurveysButton.enabled = NO;
    self.latestSurveysButton.alpha = 0.5f;
    self.surveysImage.alpha = 0.5f;

     NSDictionary *userData = [MRAppControl sharedHelper].userRegData;
    self.userNameLabel.text = [NSString stringWithFormat:@"Welcome %@. %@ %@",[userData objectForKey:KTitle],[userData objectForKey:KFirstName],[userData objectForKey:KLastName]];
    
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
    [self enableDisableRightButton:YES];

    [self setUPTableView];

    // Do any additional setup after loading the view from its nib.
}

- (void)setUPTableView
{
    self.appointmentTableview.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
    self.appointmentTableview.scrollEnabled = NO;
    self.appointmentTableview.showsHorizontalScrollIndicator =
    self.appointmentTableview.showsVerticalScrollIndicator = YES;
    if ([MRCommon deviceHasThreePointFiveInchScreen])
    {
        self.appointmentTableview.frame = CGRectMake(40, 45, 240, 46);
    }
    else if ([MRCommon deviceHasFourInchScreen])
    {
        self.appointmentTableview.frame = CGRectMake(40, 45, 240, 65);
    }
    else if ([MRCommon deviceHasFourPointSevenInchScreen])
    {
        self.appointmentTableview.frame = CGRectMake(40, 57, 292, 80);
    }
    else if ([MRCommon deviceHasFivePointFiveInchScreen])
    {
        CGRect frame = self.appointmentTableview.frame;
        frame.origin.x = 40;
        frame.origin.y = 150;
        frame.size.width = 331;
        frame.size.height = 90;
        self.appointmentTableview.frame =  frame;
    }
    else if ([MRCommon isHD])
    {
        self.appointmentTableview.frame = CGRectMake(70, 64, 628, 210);
    }
    
    if ([MRAppControl sharedHelper].userType == 3) //pharma
    {
        [self callServiceCompletedUpcomingAppointment];
    }
    else if ([MRAppControl sharedHelper].userType == 4) //manager
    {
        [self callpendingAppointents];
    }

    
    [self.appointmentTableview reloadData];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myAppointments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.appointmentTableview.frame.size.width;
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
    [appointmentCell configureAppointmentCellForPharma:[self.myAppointments objectAtIndex:indexPath.row]];
    return appointmentCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict =[self.myAppointments objectAtIndex:indexPath.row];
    
    if ([MRAppControl sharedHelper].userType == 3) //pharma
    {
        MRViewRepAppointmnetViewController *appointList = [[MRViewRepAppointmnetViewController alloc] initWithNibName:@"MRViewRepAppointmnetViewController" bundle:nil];
        
        appointList.appointmnetDetails      = dict;
        appointList.isCompletedAppointmnet  = NO;
        appointList.isPendingAppointmnet    = NO;
        [self.navigationController pushViewController:appointList animated:YES];
    }
    else if ([MRAppControl sharedHelper].userType == 4) //manager
    {
        MRViewAppointmnetViewController *appointList = [[MRViewAppointmnetViewController alloc] init];
        appointList.appointmnetDetails      = dict;
        appointList.isCompletedAppointmnet  = NO;
        appointList.isPendingAppointmnet    = YES;
        [self.navigationController pushViewController:appointList animated:YES];

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

- (IBAction)trackProductButtonAction:(id)sender
{
    MRNewProductCompaignsViewController *prodcutCompaignsVC =[[MRNewProductCompaignsViewController alloc] initWithNibName:@"MRNewProductCompaignsViewController" bundle:nil];
    prodcutCompaignsVC.isFromMenu = NO;
    [self.navigationController pushViewController:prodcutCompaignsVC animated:YES];

}

- (IBAction)latestSurveysButtonAction:(id)sender
{
    //[MRCommon showAlert:kComingsoonMSG delegate:self];
}

- (IBAction)doctorActivityButtonAction:(id)sender
{
    MRDocotrActivityScoreViewController *prodcutCompaignsVC =[[MRDocotrActivityScoreViewController alloc] initWithNibName:@"MRDocotrActivityScoreViewController" bundle:nil];
    prodcutCompaignsVC.isFromMenu = NO;
    [self.navigationController pushViewController:prodcutCompaignsVC animated:YES];

}

- (IBAction)trackMedrepButtonAction:(id)sender
{
    if ([MRAppControl sharedHelper].userType == 3) //pharma
    {
        MRMedRepViewController *repViewController = [[MRMedRepViewController alloc] initWithNibName:@"MRMedRepViewController" bundle:nil];
        [self.navigationController pushViewController:repViewController animated:YES];
    }
    else if ([MRAppControl sharedHelper].userType == 4) //manager
    {
        MRMedRepListViewController *appointmentList = [[MRMedRepListViewController alloc] initWithNibName:@"MRMedRepListViewController" bundle:nil];
        [self.navigationController pushViewController:appointmentList animated:YES];
    }
}

- (IBAction)appointmentButtonAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMedRepMeetingsNotification object:nil];
}

- (IBAction)leftButtonAction:(id)sender
{
    --self.currentIndex;
    
    [self enableDisableLeftButton:(0 == self.currentIndex) ? NO : YES];
    
    
    [self.appointmentTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    [self enableDisableRightButton:YES];
}

- (IBAction)rightButtonAction:(id)sender
{
    [self enableDisableLeftButton:YES];
    
    ++self.currentIndex;
    
    [self.appointmentTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [self enableDisableRightButton:(self.myAppointments.count == self.currentIndex + 1) ? NO : YES];
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

- (void)callServiceCompletedUpcomingAppointment
{
    [MRCommon showActivityIndicator:@"Loading..."];
    
    [[MRWebserviceHelper sharedWebServiceHelper] getMyAppointmentForPharma:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            [MRCommon stopActivityIndicator];
            self.myAppointments = [self filterAppointmnetLis:[responce objectForKey:kResponce]];
            [[MRAppControl sharedHelper] setMyAppointmentDetails:[responce objectForKey:kResponce]];
            if (self.myAppointments.count == 0 || self.myAppointments.count == 1)
            {
                [self enableDisableLeftButton:NO];
                [self enableDisableRightButton:NO];
                
                if (self.myAppointments.count == 0)
                {
                    [self noUpComingAppointments];
                }
                else
                {
                    [self removeNoUpcomingAppointmentLabel];
                }
            }
            else
            {
                [self removeNoUpcomingAppointmentLabel];
            }
            
            [self.appointmentTableview reloadData];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getMyAppointmentForPharma:^(BOOL status, NSString *details, NSDictionary *responce)
                  {
                      if (status)
                      {
                          [MRCommon stopActivityIndicator];
                          self.myAppointments = [self filterAppointmnetLis:[responce objectForKey:kResponce]];
                          [[MRAppControl sharedHelper] setMyAppointmentDetails:[responce objectForKey:kResponce]];
                          
                          if (self.myAppointments.count == 0 || self.myAppointments.count == 1)
                          {
                              [self enableDisableLeftButton:NO];
                              [self enableDisableRightButton:NO];
                              
                              if (self.myAppointments.count == 0)
                              {
                                  [self noUpComingAppointments];
                              }
                              else
                              {
                                  [self removeNoUpcomingAppointmentLabel];
                              }
                          }
                          else
                          {
                              [self removeNoUpcomingAppointmentLabel];
                          }
                          
                          [self.appointmentTableview reloadData];
                      }
                  }];
                 
             }];
        }
        else
        {
            [self enableDisableLeftButton:NO];
            [self enableDisableRightButton:NO];
        }
        // NSLog(@"responce %@",responce);
    }];
}

- (void)callpendingAppointents
{
    [[MRWebserviceHelper sharedWebServiceHelper] getMyTeamPendingAppointments:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            self.myAppointments = [responce objectForKey:kResponce];
            
            [[MRAppControl sharedHelper] setMyAppointmentDetails:[responce objectForKey:kResponce]];
            
            if (self.myAppointments.count == 0 || self.myAppointments.count == 1)
            {
                if (self.myAppointments.count == 0)
                {
                    [self noPendingAppointments];
                }
                else
                {
                    [self removeNoUpcomingAppointmentLabel];
                }

                [self enableDisableLeftButton:NO];
                [self enableDisableRightButton:NO];
            }
            
            [self.appointmentTableview reloadData];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getMyTeamPendingAppointments:^(BOOL status, NSString *details, NSDictionary *responce)
                  {
                      if (status)
                      {
                          self.myAppointments = [responce objectForKey:kResponce];
                          
                          [[MRAppControl sharedHelper] setMyAppointmentDetails:[responce objectForKey:kResponce]];
                          
                          if (self.myAppointments.count == 0 || self.myAppointments.count == 1)
                          {
                              if (self.myAppointments.count == 0)
                              {
                                  [self noPendingAppointments];
                              }
                              else
                              {
                                  [self removeNoUpcomingAppointmentLabel];
                              }

                              [self enableDisableLeftButton:NO];
                              [self enableDisableRightButton:NO];
                          }
                          
                          [self.appointmentTableview reloadData];
                      }
                  }];
                 
             }];
        }
        else
        {
            [self enableDisableLeftButton:NO];
            [self enableDisableRightButton:NO];
        }
        // NSLog(@"responce %@",responce);
    }];
}
- (NSArray*)filterAppointmnetLis:(NSArray*)array
{
    NSArray *filteredArray          = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status == %@",@"Scheduled"]];
    return filteredArray;
}

- (void)noUpComingAppointments
{
    UILabel *lbl = [[UILabel alloc] initWithFrame:self.appointmentTableview.frame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.font = [UIFont systemFontOfSize:14.0];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.tag = 11223344;
    lbl.text = @"No Upcoming Appointmets Found.";
    [self.appointmentView addSubview:lbl];
   // CGRectMake(70, 64, 628, 210);
}

- (void)noPendingAppointments
{
    UILabel *lbl = [[UILabel alloc] initWithFrame:self.appointmentTableview.frame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.font = [UIFont systemFontOfSize:14.0];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.tag = 11223344;
    lbl.text = @"No Pending Appointmets Found.";
    [self.appointmentView addSubview:lbl];
    // CGRectMake(70, 64, 628, 210);
}

- (IBAction)latestNotificationButtonAction:(id)sender
{
    [self trackProductButtonAction:sender];
}

- (void)removeNoUpcomingAppointmentLabel
{
    if ([self.appointmentView viewWithTag:11223344] != nil)
    {
        [[self.appointmentView viewWithTag:11223344] removeFromSuperview];
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

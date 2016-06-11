//
//  MRProductCompaignsViewController.m
//  Gravity
//
//  Created by Apple on 26/09/15.
//  Copyright © 2015 Sprim. All rights reserved.
//

#import "MRMedRepViewController.h"
#import "SWRevealViewController.h"
#import "MRMedRepTableCell.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRNewProductCompaignsViewController.h"
#import "MRAppointmentListViewController.h"
#import "MRAppControl.h"
#import "MRMedRepListViewController.h"

#define kLogoImages [NSArray arrayWithObjects:@"upcoming_icon@2x.png", @"completed_icon@2x.png",  @"pending_icon@2x.png",nil]

#define kMLogoImages [NSArray arrayWithObjects:@"completed_icon@2x.png",@"upcoming_icon@2x.png",nil]

#define kTMLogoImages [NSArray arrayWithObjects:@"team@2x.png",@"pending_icon@2x.png",nil]


@interface MRMedRepViewController ()<UITableViewDataSource,MRMedRepTableCellDelegate,UITableViewDelegate>
{
    NSArray *dataSourceArray;
}

@property (weak, nonatomic) IBOutlet UIImageView *companyImage;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *pcTableView;

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation MRMedRepViewController


- (void)getMenuNavigationButtonWithController:(SWRevealViewController *)revealViewCont NavigationItem:(UINavigationItem *)navigationItem1
{
    SWRevealViewController *revealController = revealViewCont;
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
    
    self.title = @"MedRep";
    
    self.titleLabel.text = self.title;
    if ([MRAppControl sharedHelper].userType == 3)
    {
        dataSourceArray = @[@"Upcoming Appointments",@"Completed Appointments",@"Pending Appointments"];
    }
    else
    {
        if (self.isRepAppointments)
        {
            dataSourceArray = @[@"Completed Appointments",@"Upcoming Appointments"];
        }
        else
        {
            dataSourceArray = @[@"Team",@"Pending Appointments Requests"];
        }
    }
    
    self.companyImage.image = [[MRAppControl sharedHelper] getCompanyImage];
    
    [self getMenuNavigationButtonWithController:[self revealViewController] NavigationItem:self.navigationItem];

    // Do any additional setup after loading the view from its nib.
}

- (IBAction)backButttonAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDashboardNotificationFromRegistartionScren object:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Table View Data Source ---

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *productCelId = @"medrepCellIdentity";
    
    MRMedRepTableCell *medrepCell = [tableView dequeueReusableCellWithIdentifier:productCelId];
    
    if (medrepCell == nil)
    {
        NSArray *bundleCell = [[NSBundle mainBundle] loadNibNamed:@"MRMedRepTableCell" owner:nil options:nil];
        medrepCell = (MRMedRepTableCell *)[bundleCell lastObject];
        medrepCell.delegate = self;
    }
    
    medrepCell.cellTitleLabel.text = [dataSourceArray objectAtIndex:indexPath.row];
    medrepCell.imgView.image = [UIImage imageNamed:[MRAppControl sharedHelper].userType == 3 ? [kLogoImages objectAtIndex:indexPath.row] : (self.isRepAppointments) ? [kMLogoImages objectAtIndex:indexPath.row] : [kTMLogoImages objectAtIndex:indexPath.row]];
    
    return medrepCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([MRAppControl sharedHelper].userType == 3)
    {
        switch (indexPath.row) {
            case 0:
            {
                MRAppointmentListViewController *appointmentList = [[MRAppointmentListViewController alloc] initWithNibName:@"MRAppointmentListViewController" bundle:nil];
                appointmentList.appointnetType = 1;
                [self.navigationController pushViewController:appointmentList animated:YES];
            }
                break;
            case 1:
            {
                MRAppointmentListViewController *appointmentList = [[MRAppointmentListViewController alloc] initWithNibName:@"MRAppointmentListViewController" bundle:nil];
                appointmentList.appointnetType = 2;
                [self.navigationController pushViewController:appointmentList animated:YES];
            }
                break;
            case 2:
            {
                MRAppointmentListViewController *appointmentList = [[MRAppointmentListViewController alloc] initWithNibName:@"MRAppointmentListViewController" bundle:nil];
                appointmentList.appointnetType = 3;
                [self.navigationController pushViewController:appointmentList animated:YES];
                
            }
                break;
                
            default:
                break;
        }
        
    }
    else
    {
        if (self.showAppointmentsList)
        {
            MRAppointmentListViewController *appointmentList = [[MRAppointmentListViewController alloc] initWithNibName:@"MRAppointmentListViewController" bundle:nil];
            appointmentList.repId = self.repId;
            appointmentList.isPendingAppointmnet = NO;
            appointmentList.isCompletedAppointmnet = (indexPath.row == 0) ? YES : NO;
            [self.navigationController pushViewController:appointmentList animated:YES];
        }
        else
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    MRMedRepListViewController *appointmentList = [[MRMedRepListViewController alloc] initWithNibName:@"MRMedRepListViewController" bundle:nil];
                    [self.navigationController pushViewController:appointmentList animated:YES];
                }
                    break;
                case 1:
                {
                    MRAppointmentListViewController *appointmentList = [[MRAppointmentListViewController alloc] initWithNibName:@"MRAppointmentListViewController" bundle:nil];
                    appointmentList.appointnetType = 3;
                    appointmentList.isPendingAppointmnet = YES;
                    [self.navigationController pushViewController:appointmentList animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
        
    }
    
}

- (void)accessoryButtonDelegationAction:(MRMedRepTableCell *)tCell
{
//    NSString *kTitle = @"Doctor Appointment";
//    NSString *kDesc = @"Family Monthly Health Check up Appointment";
//    NSDate *kAppointDate = [NSDate date];
//    
//    [MRCommon syncEventInCalenderAlongWithEventTitle:kTitle withDescription:kDesc eventDate:kAppointDate];
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

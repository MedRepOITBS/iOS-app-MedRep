//
//  MRMedRepMeetingsViewController.m
//  MedRep
//
//  Created by MedRep Developer on 21/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRMedRepMeetingsViewController.h"
#import "MRMedrepMeetingsCell.h"
#import "MPAppointmentViewController.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "SWRevealViewController.h"


@interface MRMedRepMeetingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *medrepMeetingsTableView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIView *navView;

@end

@implementation MRMedRepMeetingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.listItems = [MRAppControl sharedHelper].myAppointments;
    
    if (self.listItems.count == 0)
    {
        [MRCommon showAlert:@"No Upcoming Appointments Scheduled" delegate:nil];
      //
    }
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonAction:(UIButton *)sender
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier                = @"MRMedrepMeetingsCell";
    MRMedrepMeetingsCell *appointmentCell     = (MRMedrepMeetingsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (appointmentCell == nil)
    {
        NSArray *nibViews                   = [[NSBundle mainBundle] loadNibNamed:@"MRMedrepMeetingsCell" owner:nil options:nil];
        appointmentCell                     = (MRMedrepMeetingsCell *)[nibViews lastObject];
        
    }
    
    [appointmentCell configureAppointmentCell:[self.listItems objectAtIndex:indexPath.row]];
    
    return appointmentCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MPAppointmentViewController *appontVC =[[MPAppointmentViewController alloc] initWithNibName:@"MPAppointmentViewController" bundle:nil];
    appontVC.selectedAppointment = [self.listItems objectAtIndex:indexPath.row];
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

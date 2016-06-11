//
//  MRDocotrActivityScoreViewController.m
//  
//
//  Created by MedRep Developer on 01/11/15.
//
//

#import "MRDocotrActivityScoreViewController.h"
#import "MRDoctorActivityScoreDetailsViewController.h"
#import "SWRevealViewController.h"
#import "MRConvertAppointmentCell.h"
#import "NSDate+Utilities.h"
#import "MRWebserviceHelper.h"
#import "MRAppControl.h"
#import "MRConstants.h"
#import "MRCommon.h"


@interface MRDocotrActivityScoreViewController ()<UITableViewDataSource,UITableViewDelegate, SWRevealViewControllerDelegate>
{
    NSArray *dataSourceArray;
    NSArray *timeArray;
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *pcTableView;
@property (retain, nonatomic) NSArray *convertAppointments;
@property (strong, nonatomic) IBOutlet UIView *navView;

@end

@implementation MRDocotrActivityScoreViewController

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
    [super viewDidLoad];
    
    dataSourceArray = @[@"Meeting With Dr.Anil Kumar",@"Catch up with Dr.Brain",@"Appointment with Neurologist"];
    
    timeArray = @[@"8 - 10am",@"11 - 12pm",@"1 - 2 pm"];
    
    [self getMenuNavigationButtonWithController:[self revealViewController] NavigationItem:self.navigationItem];
    [self callService];
    // Do any additional setup after loading the view from its nib.
}

- (void)callService
{
    [MRCommon showActivityIndicator:@"Loading..."];
    
    [[MRWebserviceHelper sharedWebServiceHelper] getMyCompanyDoctors:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             [MRCommon stopActivityIndicator];
             
             self.convertAppointments = [responce objectForKey:kResponce];
             if (self.convertAppointments.count > 0)
             {
                 [self.pcTableView reloadData];
             }
             else
             {
                 [MRCommon showAlert:@"No Appointments found." delegate:nil];
             }
             // NSLog(@"%@",self.notifications);
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getMyCompanyDoctors:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       [MRCommon stopActivityIndicator];
                       if (status)
                       {
                           self.convertAppointments = [responce objectForKey:kResponce];
                           if (self.convertAppointments.count > 0)
                           {
                               [self.pcTableView reloadData];
                           }
                           else
                           {
                               [MRCommon showAlert:@"No Appointments found." delegate:nil];
                           }
                       }
                   }];
              }];
         }
         else
         {
             [MRCommon stopActivityIndicator];
             [MRCommon showAlert:@"No Appointments found." delegate:nil];
         }
         
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.convertAppointments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *productCelId = @"productCellIdentity";
    
    MRConvertAppointmentCell *productCell = (MRConvertAppointmentCell*)[tableView dequeueReusableCellWithIdentifier:productCelId];
    
    if (productCell == nil)
    {
        NSArray *bundleCell = [[NSBundle mainBundle] loadNibNamed:@"MRConvertAppointmentCell" owner:nil options:nil];
        productCell = (MRConvertAppointmentCell *)[bundleCell lastObject];
    }
    NSDictionary *dict =[self.convertAppointments objectAtIndex:indexPath.row];
    productCell.profileImage.image = [UIImage imageNamed:@"profileIcon.png"];
    productCell.profileName.text = [NSString stringWithFormat:@"Dr. %@ %@",[dict objectForKey:@"firstName"],[dict objectForKey:@"lastName"]];
    productCell.appointmnetTime.text = @"";[self getAppointmnetDateTime:[dict objectForKey:@"startDate"]];
    productCell.timeIcon.hidden = YES;
    productCell.toplabelConstraint.constant = 25.0;
    [productCell updateConstraints];
    //[self getAppointmnetTime:[dict objectForKey:@"startDate"] withDurtaion:[dict objectForKey:@"duration"]];
    //productCell.locationLabel.text = [dict objectForKey:@"location"];
    [productCell loadProfileImageWithName:[dict objectForKey:@"doctorId"]];
    
    return productCell;
}

- (NSString*)getAppointmnetDateTime:(NSString*)dateString
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *date = [MRCommon dateFromstring:dateString withDateFormate:@"YYYYMMddHHmmss"];
    dateFormatter.dateFormat = @"MMM dd hh:mm a";
    NSString *strDate = [dateFormatter stringFromDate:date];
    
    
    
    return strDate;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict =[self.convertAppointments objectAtIndex:indexPath.row];
    MRDoctorActivityScoreDetailsViewController *doctorDetails = [[MRDoctorActivityScoreDetailsViewController alloc] initWithNibName:@"MRDoctorActivityScoreDetailsViewController" bundle:nil];
    doctorDetails.doctorID = [[dict objectForKey:@"doctorId"] integerValue];
    doctorDetails.doctorDetalsDictionary = [self.convertAppointments objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:doctorDetails animated:YES];
}

- (NSString*)getAppointmnetTime:(NSString*)dateString withDurtaion:(NSNumber*)durtaion
{
    NSDate *tempDate = [MRCommon dateFromstring:dateString withDateFormate:@"YYYYMMddHHmmss"];
    
    NSDate *tempEndDate = [tempDate dateByAddingMinutes:[durtaion integerValue]];
    
    if (tempDate == nil || tempEndDate == nil)
    {
        return @"00:00 - 00:00";
    }
    
    return [NSString stringWithFormat:@"%@ - %@",[tempDate shortTimeString], [tempEndDate shortTimeString]];
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

- (IBAction)sortByButtonAction:(id)sender
{
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

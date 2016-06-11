//
//  MRViewAppointmnetViewController.m
//  
//
//  Created by MedRep Developer on 04/11/15.
//
//

#import "MRViewAppointmnetViewController.h"
#import "MRDoctorDetailsTableViewCell.h"
#import "MRDoctorActivityScoreDetailsViewController.h"
#import "MRProductBrocherViewController.h"
#import "SWRevealViewController.h"
#import "MPNotificationAlertViewController.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "NSDate+Utilities.h"
#import "MRWebserviceHelper.h"

#define kDataSourceImgsArray   @[@"time-icon.png",@"PHlocations@2x.png",@"building-icon.png",@"drug-icon.png"]
#define kDataSourceHeadingsArray  @[@"Time :",@"Location :",@"Company Name :",@"Drug Requested :"]

@interface MRViewAppointmnetViewController ()<UITableViewDelegate, UITableViewDelegate, UIAlertViewDelegate>
{
     MPNotificationAlertViewController *viewController;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *therepaticLabel;
@property (weak, nonatomic) IBOutlet UITableView *deatilsTableview;
@property (weak, nonatomic) IBOutlet UILabel *AppointmnetheadingLbl;
@property (weak, nonatomic) IBOutlet UILabel *appointmnetDiscriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIView *navButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *appointmnetNotesHeightConstraint;

@end

@implementation MRViewAppointmnetViewController

- (void)getMenuNavigationButtonWithController:(SWRevealViewController *)revealViewCont NavigationItem:(UINavigationItem *)navigationItem1
{
    SWRevealViewController *revealController = revealViewCont;
    
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    revealButtonItem.tintColor = [UIColor blackColor];
    navigationItem1.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

/*
 {
 appointmentDesc = "This is the Final test before uploading to Playstore.. Hopefully :P
 \n";
 appointmentId = 36;
 companyId = 1;
 companyname = "SAIN Medicaments Pvt. Ltd.";
 createdOn = 1455026608000;
 doctorId = 137;
 doctorName = "Milan Hoogan";
 duration = 30;
 feedback = "The appointment went very well. Dr. Milan wants 10 samples and has asked to meet next month during the 1st week";
 location = "Yashoda ,Marred pally";
 notificationId = 38;
 pharmaRepId = "";
 pharmaRepName = "Rep Test Saints TEST";
 startDate = 20160210083052;
 status = Completed;
 therapeuticId = 11;
 therapeuticName = "Vitamins & Minerals";
 title = "Final Test 1";
 }
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getMenuNavigationButtonWithController:[self revealViewController] NavigationItem:self.navigationItem];

    [MRCommon showActivityIndicator:@""];
    [self loadProfileImage:[self.appointmnetDetails objectForKey:@"doctorId"]];

    self.titleLabel.text = @"Doctor Details";
    self.nameLabel.text = [NSString stringWithFormat:@"Dr. %@",[self.appointmnetDetails objectForKey:@"doctorName"]];
    self.therepaticLabel.text = [self.appointmnetDetails objectForKey:@"therapeuticName"];
    
    NSString *date , *month;
    date    = @"";
    month   = @"";
    NSString *startDate = [self.appointmnetDetails objectForKey:@"startDate"];
    if (startDate.length > 8)
    {
        month = [startDate substringWithRange:NSMakeRange(4, 2)];
        date = [startDate substringWithRange:NSMakeRange(6, 2)];
    }
    
    if (month.length > 0)
    {
        self.monthLabel.text = [kShotMonthsArray objectAtIndex:([month intValue] - 1)];
    }
    
    self.dayLabel.text = date;
    
    if (self.isCompletedAppointmnet == NO)
    {
        self.appointmnetDiscriptionLabel.hidden = YES;
        self.notesTextView.hidden = YES;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSDate *date = [MRCommon dateFromstring:[self.appointmnetDetails objectForKey:@"startDate"] withDateFormate:@"YYYYMMddHHmmss"];
        dateFormatter.dateFormat = @"hh:mm a";
        NSString *strDate = [dateFormatter stringFromDate:date];
        
        dateFormatter.dateFormat = @"dd-MM-YYYY";
         NSString *appointmentDate =[dateFormatter stringFromDate:date];
        self.appointmnetNotesHeightConstraint.constant = 50;

        self.AppointmnetheadingLbl.text = [NSString stringWithFormat:@"Appointment Scheduled on %@ at %@",appointmentDate,strDate];
    }
    else
    {
        self.appointmnetNotesHeightConstraint.constant = 30;
        self.appointmnetDiscriptionLabel.hidden = YES;
        self.appointmnetDiscriptionLabel.text = [self.appointmnetDetails objectForKey:@"feedback"];
        self.notesTextView.text = [self.appointmnetDetails objectForKey:@"feedback"];
        self.notesTextView.scrollsToTop = YES;
        [self.notesTextView setContentOffset:CGPointZero animated:NO];
        [self.notesTextView scrollRangeToVisible:NSMakeRange(0, 0)];//.scrollRangeToVisible(NSRange(location:0, length:0))
        //self.notesTextView sc
    }
    
    if (self.isPendingAppointmnet)
    {
        self.AppointmnetheadingLbl.hidden = YES;
        self.appointmnetDiscriptionLabel.hidden = YES;
        self.notesTextView.hidden = YES;

        if ([MRAppControl sharedHelper].userType == 3)
            self.acceptAppointmnetBtn.hidden = NO;
        else
            self.acceptAppointmnetBtn.hidden = YES;
    }
    else
    {
        self.acceptAppointmnetBtn.hidden = YES;
    }


    // Do any additional setup after loading the view from its nib.
}

- (void)loadProfileImage:(NSNumber*)doctorId
{
    [[MRWebserviceHelper sharedWebServiceHelper] getDoctorProfileForPharma:[NSString stringWithFormat:@"%lld",[doctorId longLongValue]] withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            self.nameLabel.text = [NSString stringWithFormat:@"Dr. %@ %@",[responce objectForKey:@"firstName"],[responce objectForKey:@"lastName"]];
            //self.profileImage.image = [MRCommon getImageFromBase64Data:[[responce objectForKey:KProfilePicture] objectForKey:@"data"]];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getDoctorProfileForPharma:[NSString stringWithFormat:@"%lld",[doctorId longLongValue]] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                  {
                      [MRCommon stopActivityIndicator];
                      if (status)
                      {
                          self.nameLabel.text = [NSString stringWithFormat:@"Dr. %@ %@",[responce objectForKey:@"firstName"],[responce objectForKey:@"lastName"]];
                          //self.profileImage.image = [MRCommon getImageFromBase64Data:[[responce objectForKey:KProfilePicture] objectForKey:@"data"]];
                      }
                  }];
             }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)doctorActivityScoreButtonAction:(id)sender
{
    MRDoctorActivityScoreDetailsViewController *doctorDetails = [[MRDoctorActivityScoreDetailsViewController alloc] initWithNibName:@"MRDoctorActivityScoreDetailsViewController" bundle:nil];
    doctorDetails.doctorID = [[self.appointmnetDetails objectForKey:@"doctorId"] integerValue];
    doctorDetails.doctorDetalsDictionary = self.appointmnetDetails;
    [self.navigationController pushViewController:doctorDetails animated:YES];
}

- (IBAction)viewProductBrocherButtonAction:(id)sender
{
    MRProductBrocherViewController *doctorDetails = [[MRProductBrocherViewController alloc] initWithNibName:@"MRProductBrocherViewController" bundle:nil];
    doctorDetails.notificationID = [[self.appointmnetDetails objectForKey:@"notificationId"] integerValue];
    [self.navigationController pushViewController:doctorDetails animated:YES];

}

#pragma mark Table View Data Source ---
#pragma mark Table View Data Source ---
- (CGFloat)getRowHeightForDevice
{
    if ([MRCommon isIPad])
    {
        return 80;//@"Default-Portrait@2x.png";
    }
    else if ([MRCommon isiPhone5])
    {
        return 44;
    }
    else if ([MRCommon deviceHasFivePointFiveInchScreen])
    {
        return 70;
    }
    else if ([MRCommon deviceHasFourPointSevenInchScreen])
    {
        return 60;
    }
    return 40;
}

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getRowHeightForDevice];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kDataSourceHeadingsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *doctorDetailsId = @"productCellIdentity";
    
    MRDoctorDetailsTableViewCell *doctorDetailsCell = [tableView dequeueReusableCellWithIdentifier:doctorDetailsId];
    
    if (doctorDetailsCell == nil)
    {
        NSArray *bundleCell = [[NSBundle mainBundle] loadNibNamed:@"MRDoctorDetailsTableViewCell" owner:nil options:nil];
        doctorDetailsCell = (MRDoctorDetailsTableViewCell *)[bundleCell lastObject];
    }
    
    doctorDetailsCell.cellHeaderLabel.text = [kDataSourceHeadingsArray objectAtIndex:indexPath.row];
    if (indexPath.row == 0)
    {
        doctorDetailsCell.cellDescLabel.hidden = YES;
        doctorDetailsCell.cellHeaderLabel.text = [NSString stringWithFormat:@"%@    %@",[kDataSourceHeadingsArray objectAtIndex:indexPath.row],[self getDetails:nil forRow:indexPath.row]];
    }
    else
    {
        doctorDetailsCell.cellDescLabel.hidden = NO;
        doctorDetailsCell.cellDescLabel.text = [self getDetails:nil forRow:indexPath.row];
    }
    doctorDetailsCell.cellImgView.image =  [UIImage imageNamed:[kDataSourceImgsArray objectAtIndex:indexPath.row]];
    
    return doctorDetailsCell;
}

- (NSString*)getDetails:(NSDictionary*)details forRow:(NSInteger)row
{
    switch (row) {
        case 0: //name@"firstName"
            //@"lastName"]
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSDate *date = [MRCommon dateFromstring:[self.appointmnetDetails objectForKey:@"startDate"] withDateFormate:@"YYYYMMddHHmmss"];
            dateFormatter.dateFormat = @"hh:mm a";
            NSString *strDate = [dateFormatter stringFromDate:date];
            return strDate;
        }
            break;
        case 1: // thrapatic
            return [self.appointmnetDetails objectForKey:@"location"];
            break;
        case 2:// emial
            return [self.appointmnetDetails objectForKey:@"companyname"];
            break;
        case 3:// mobile
            return [self.appointmnetDetails objectForKey:@"title"];
            break;
            
        default:
            break;
    }
    return @"";
}
- (IBAction)acceptAppointmentButtonAction:(id)sender
{
    
    viewController = [[MPNotificationAlertViewController alloc] initWithNibName:@"MPNotificationAlertViewController" bundle:nil];
    [self.view addSubview:viewController.view];
    [MRCommon addUpdateConstarintsTo:self.view withChildView:viewController.view];
    
    [viewController configureAlertWithAlertType:MRAlertTypeMessage withMessage:KAppointmentAcceptConfirmationMSG withTitle:@"Accept Appointment?" withOKButtonAction:^(MPNotificationAlertViewController *alertView)
     {
         alertView.view.alpha = 1.0f;
         [UIView animateWithDuration:0.4
                               delay:0.0
                             options: UIViewAnimationOptionCurveEaseInOut
                          animations:^{
                              alertView.view.alpha = 0.0f;
                          } completion:^(BOOL finished) {
                              
                              NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                              [dict setObject:[self.appointmnetDetails objectForKey:@"appointmentId"] forKey:@"appointmentId"];
                              [dict setObject:@"Accepted" forKey:@"status"];
                              
                              
                              [[MRWebserviceHelper sharedWebServiceHelper] acceptAppointments:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                               {
                                   if (status)
                                   {
                                       [MRCommon showAlert:@"Appointment accepted successfully." delegate:self withTag:123456789];
                                   }
                                   else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
                                   {
                                       [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
                                        {
                                            [MRCommon savetokens:responce];
                                            [[MRWebserviceHelper sharedWebServiceHelper] acceptAppointments:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                                             {
                                                 if (status)
                                                 {
                                                     [MRCommon showAlert:@"Appointment accepted successfully." delegate:self withTag:123456789];
                                                 }
                                             }];
                                        }];
                                   }
                               }];
                              
                              [alertView.view removeFromSuperview];
                              [alertView removeFromParentViewController];
                          }];
         
     } withCancelButtonAction:^(MPNotificationAlertViewController *alertView){
         alertView.view.alpha = 1.0f;
         [UIView animateWithDuration:0.4
                               delay:0.0
                             options: UIViewAnimationOptionCurveEaseInOut
                          animations:^{
                              alertView.view.alpha = 0.0f;
                          } completion:^(BOOL finished) {
                              [alertView.view removeFromSuperview];
                              [alertView removeFromParentViewController];
                          }];
     }];
    
    viewController.view.alpha = 0.0f;
    [UIView animateWithDuration:0.25f animations:^{
        viewController.view.alpha = 1.0f;
    }];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 123456789)
    {
        [self backButtonAction:nil];
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

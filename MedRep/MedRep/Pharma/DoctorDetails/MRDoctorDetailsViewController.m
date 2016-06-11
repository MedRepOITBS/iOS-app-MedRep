//
//  MRDoctorDetailsViewController.m
//  Gravity
//
//  Created by Apple on 26/09/15.
//  Copyright © 2015 Sprim. All rights reserved.
//

#import "MRDoctorDetailsViewController.h"
#import "SWRevealViewController.h"
#import "MRCompetitorAnalasysViewController.h"
#import "MRFeedBackResultViewController.h"
#import "MRWebserviceHelper.h"
#import "MRDoctorScoreViewController.h"
#import "MPNotificationAlertViewController.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"

#define kDataSourceImgsArray   @[@"PHdoctor.png",@"PHthera.png",@"PHmail.png",@"PHphone.png",@"PHlocations.png"]
#define kDataSourceHeadingsArray  @[@"Doctor Name :",@"Therapeutic Area :",@"Email Id :",@"Mobile No :"]

@interface MRDoctorDetailsViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    MPNotificationAlertViewController *viewController;
}
@property (weak, nonatomic) IBOutlet UIButton *presentActivityScoreButton;
@property (weak, nonatomic) IBOutlet UIButton *doctorCompititiveAnalasysButton;
@property (weak, nonatomic) IBOutlet UITableView *doctorDetails;

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIButton *feedBackButton;

@property (weak, nonatomic) IBOutlet UILabel *medrepNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *feedbackButtonBottomConstraint;
@property (nonatomic, retain) NSDictionary *doctorDetalsDictionlay;

@end

@implementation MRDoctorDetailsViewController

- (void)getMenuNavigationButtonWithController:(SWRevealViewController *)revealViewCont NavigationItem:(UINavigationItem *)navigationItem1
{
    SWRevealViewController *revealController = revealViewCont;
    
    
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
    
    self.title = @"Doctor Details ";
    
    [self setUpUI];

    [self getMenuNavigationButtonWithController:[self revealViewController] NavigationItem:self.navigationItem];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)callService
{
    [MRCommon showActivityIndicator:@"Loading..."];
    
    [[MRWebserviceHelper sharedWebServiceHelper] getDoctorProfileDetailsByID:[NSString stringWithFormat:@"%ld", self.doctorID] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             [MRCommon stopActivityIndicator];
             
             self.doctorDetalsDictionlay = responce;
             [self.doctorDetails reloadData];
//             if (self.convertAppointments.count > 0)
//             {
//                 [self.pcTableView reloadData];
//             }
//             else
//             {
//                 [MRCommon showAlert:@"No Appointments found." delegate:nil];
//             }
             // NSLog(@"%@",self.notifications);
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getDoctorProfileDetailsByID:[NSString stringWithFormat:@"%ld", self.doctorID] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       [MRCommon stopActivityIndicator];
                       if (status)
                       {
                           self.doctorDetalsDictionlay = responce ;
                           [self.doctorDetails reloadData];
//                           if (self.convertAppointments.count > 0)
//                           {
//                               [self.pcTableView reloadData];
//                           }
//                           else
//                           {
//                               [MRCommon showAlert:@"No Appointments found." delegate:nil];
//                           }
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

- (void)setUpUI
{
   // NSDictionary *userData = [MRAppControl sharedHelper].userRegData;
    
    NSRange range = NSMakeRange(0, [@"MedRep Name :" length]);
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"MedRep Name : %@", self.repname]];
    [string addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:16.0 ]}
                    range:range];

    self.medrepNameLabel.attributedText = string;
    if ([MRCommon deviceHasThreePointFiveInchScreen])
    {
        self.headerViewHeightConstraint.constant = 100;;
        self.tableViewBottomConstraint.constant =
        self.feedbackButtonBottomConstraint.constant = 6;
        [self.view updateConstraints];
    }
    [self callService];
}

- (IBAction)presentActivityScoreButtonAction:(id)sender
{
    MRDoctorScoreViewController *doctorDetails = [[MRDoctorScoreViewController alloc] initWithNibName:@"MRDoctorScoreViewController" bundle:nil];
    doctorDetails.doctorDetalsDictionlay = self.doctorDetalsDictionlay;
    doctorDetails.doctorID = self.doctorID;
    [self.navigationController pushViewController:doctorDetails animated:YES];
}

- (IBAction)doctorCompititiveAnalasysButtonAction:(id)sender
{
    [MRCommon showAlert:KPaidServiceMSG  delegate:nil];
    /*viewController = [[MPNotificationAlertViewController alloc] initWithNibName:@"MPNotificationAlertViewController" bundle:nil];
    [self.view addSubview:viewController.view];
    //    viewController.alertWidthConstraint.constant = 300;
    //    [viewController.view updateConstraints];
    
    [MRCommon addUpdateConstarintsTo:self.view withChildView:viewController.view];
    [viewController configureAlertWithAlertType:MRAlertTypeMessage withMessage:KPaidServiceMSG withTitle:@"Doctors Competitive Analysis" withOKButtonAction:^(MPNotificationAlertViewController *alertView)
     {
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
    }]; */

//    MRCompetitorAnalasysViewController *competitorAnalasys = [[MRCompetitorAnalasysViewController alloc] initWithNibName:@"MRCompetitorAnalasysViewController" bundle:nil];
//    [self.navigationController pushViewController:competitorAnalasys animated:YES];
}

- (IBAction)feedBackButtonAction:(id)sender
{
    MRFeedBackResultViewController *feedbackResult = [[MRFeedBackResultViewController alloc] initWithNibName:@"MRFeedBackResultViewController" bundle:nil];
    feedbackResult.notificationID = self.notificationID;
    feedbackResult.productName = self.productName;
    [self.navigationController pushViewController:feedbackResult animated:YES];
}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Data Source ---

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
    doctorDetailsCell.cellDescLabel.text = [self getDetails:nil forRow:indexPath.row];
    doctorDetailsCell.cellImgView.image =  [UIImage imageNamed:[kDataSourceImgsArray objectAtIndex:indexPath.row]];

    return doctorDetailsCell;
}

- (NSString*)getDetails:(NSDictionary*)details forRow:(NSInteger)row
{
    switch (row) {
        case 0: //name@"firstName"
            //@"lastName"]
            return self.doctorName;
            break;
        case 1: // thrapatic
            return [self.doctorDetalsDictionlay objectForKey:@"therapeuticName"];
            break;
        case 2:// emial
            return [self.doctorDetalsDictionlay objectForKey:@"emailId"];
            break;
        case 3:// mobile
            return [self.doctorDetalsDictionlay objectForKey:@"mobileNo"];
            break;
  
        default:
            break;
    }
    return @"";
}
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

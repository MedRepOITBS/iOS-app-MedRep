//
//  MRConvertAppointmentViewController.m
//  MedRep
//
//  Created by MedRep Developer on 27/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRConvertAppointmentViewController.h"
#import "SWRevealViewController.h"
#import "MRConvertAppointmentCell.h"
#import "MRDoctorDetailsViewController.h"
#import "NSDate+Utilities.h"
#import "MRWebserviceHelper.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"


@interface MRConvertAppointmentViewController ()<UITableViewDataSource,UITableViewDelegate, SWRevealViewControllerDelegate>
{
    NSArray *dataSourceArray;
    NSArray *timeArray;
}

@property (weak, nonatomic) IBOutlet UIImageView *companyImage;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *pcTableView;
@property (retain, nonatomic) NSArray *convertAppointments;


@property (strong, nonatomic) IBOutlet UIView *navView;

@end

@implementation MRConvertAppointmentViewController

- (void)getMenuNavigationButtonWithController:(SWRevealViewController *)revealViewCont NavigationItem:(UINavigationItem *)navigationItem1
{
    SWRevealViewController *revealController = revealViewCont;
    revealController.delegate = self;
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
    
    dataSourceArray = @[@"Meeting With Dr.Anil Kumar",@"Catch up with Dr.Brain",@"Appointment with Neurologist"];
    
    timeArray = @[@"8 - 10am",@"11 - 12pm",@"1 - 2 pm"];

    [self getMenuNavigationButtonWithController:[self revealViewController] NavigationItem:self.navigationItem];
    [self callService];
    // Do any additional setup after loading the view from its nib.
}

- (void)callService
{
    [MRCommon showActivityIndicator:@"Loading..."];
    
    [[MRWebserviceHelper sharedWebServiceHelper] getAppointmentsByNotificationIdForPharma:[NSString stringWithFormat:@"%ld", self.notificationID] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
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
                  [[MRWebserviceHelper sharedWebServiceHelper] getAppointmentsByNotificationIdForPharma:[NSString stringWithFormat:@"%ld", self.notificationID] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
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
    [self.navigationController popViewControllerAnimated:YES];
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
    productCell.profileName.text = [NSString stringWithFormat:@"Meeting With %@",[dict objectForKey:@"doctorName"]];
    productCell.appointmnetTime.text = [self getAppointmnetTime:[dict objectForKey:@"startDate"] withDurtaion:[dict objectForKey:@"duration"]];
    productCell.locationLabel.text = [dict objectForKey:@"location"];
    [productCell loadProfileImage:[dict objectForKey:@"doctorId"]];

    return productCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict =[self.convertAppointments objectAtIndex:indexPath.row];
    MRDoctorDetailsViewController *doctorDetails = [[MRDoctorDetailsViewController alloc] initWithNibName:@"MRDoctorDetailsViewController" bundle:nil];
    doctorDetails.doctorID = [[dict objectForKey:@"doctorId"] integerValue];
    doctorDetails.doctorName = [dict objectForKey:@"doctorName"];
    doctorDetails.repname = [dict objectForKey:@"pharmaRepName"];
    doctorDetails.notificationID = self.notificationID;
    doctorDetails.productName = self.productName;
    [self.navigationController pushViewController:doctorDetails animated:YES];
}

- (NSString*)getAppointmnetTime:(NSString*)dateString withDurtaion:(NSNumber*)durtaion
{
    NSDate *tempDate = [MRCommon dateFromstring:dateString withDateFormate:@"YYYYMMddHHmmss"];
    
    NSDate *tempEndDate = [tempDate dateByAddingMinutes:[durtaion integerValue]];
    
//    NSInteger hour = [tempDate hour];
//    
//    NSInteger min = [tempDate minute];
//    
//    NSInteger endhour = [tempEndDate hour];
//    
//    NSInteger endmin = [tempEndDate minute];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/*
 
 [{"appointmentId":3,"title":null,"appointmentDesc":"No Description","doctorId":4,"doctorName":"Kishore NG","pharmaRepId":null,"pharmaRepName":null,"notificationId":2,"startDate":"20151015005000","duration":30,"feedback":"Feedback","status":"Published","createdOn":null,"location":"Location1","companyId":null,"companyname":null,"therapeuticId":null,"therapeuticName":null},{"appointmentId":4,"title":"","appointmentDesc":"B-Complex with Mecobalamin & Zinc","doctorId":8,"doctorName":"satheesh kumar","pharmaRepId":null,"pharmaRepName":null,"notificationId":2,"startDate":"20151012121200","duration":30,"feedback":"Feedback","status":"Published","createdOn":null,"location":"TestLocation","companyId":null,"companyname":null,"therapeuticId":null,"therapeuticName":null},{"appointmentId":7,"title":null,"appointmentDesc":"No Description","doctorId":9,"doctorName":"ssreddy CH","pharmaRepId":null,"pharmaRepName":null,"notificationId":2,"startDate":"20151019101000","duration":30,"feedback":"Feedback","status":"Published","createdOn":null,"location":"Location1","companyId":null,"companyname":null,"therapeuticId":null,"therapeuticName":null},{"appointmentId":9,"title":"","appointmentDesc":"B-Complex with Mecobalamin & Zinc","doctorId":1,"doctorName":"Umar Ashraf","pharmaRepId":null,"pharmaRepName":null,"notificationId":2,"startDate":"20151010015720","duration":30,"feedback":"Feedback","status":"Published","createdOn":null,"location":"TestLocation","companyId":null,"companyname":null,"therapeuticId":null,"therapeuticName":null}]
 */
@end

//
//  MRConvertAppointmentViewController.m
//  MedRep
//
//  Created by MedRep Developer on 27/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRAppointmentListViewController.h"
#import "SWRevealViewController.h"
#import "MRAppointmentListCell.h"
#import "MRDoctorDetailsViewController.h"
#import "NSDate+Utilities.h"
#import "MRWebserviceHelper.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRViewAppointmnetViewController.h"
#import "MRViewRepAppointmnetViewController.h"


@interface MRAppointmentListViewController ()<UITableViewDataSource,UITableViewDelegate, SWRevealViewControllerDelegate>
{
}

@property (weak, nonatomic) IBOutlet UIImageView *companyImage;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *pcTableView;
@property (retain, nonatomic) NSArray *convertAppointments;


@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation MRAppointmentListViewController

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
    
    [self getMenuNavigationButtonWithController:[self revealViewController] NavigationItem:self.navigationItem];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([MRAppControl sharedHelper].userType == 3)
    {
        if (self.appointnetType == 1 || self.appointnetType == 2)
        {
            if (self.appointnetType == 1) {
                self.titleLabel.text = @"Upcoming Appointments";
                [self callServiceUpcomingAppointments];
            }
            else if (self.appointnetType == 2)
            {
                self.titleLabel.text = @"Completed Appointments";
                [self callServiceCompletedAppointments];

            }
            //[self callServiceCompletedUpcomingAppointment];
        }
        else  if (self.appointnetType == 3 )
        {
            self.titleLabel.text =  @"Pending Appointments";
            [self callServicePendingAppointment];
        }
    }
    else
    {
        if (self.appointnetType == 3 )
        {
            self.titleLabel.text =  @"Pending Appointments";
            [self callServiceTeamPendingAppointment];
        }
        else
        {
            if (self.isCompletedAppointmnet)
            {
                self.titleLabel.text = @"Completed Appointments";
            }
            else if (self.isCompletedAppointmnet == NO && self.isPendingAppointmnet == 0)
            {
                self.titleLabel.text = @"Upcoming Appointments";
            }

            [self callRepAppointmentsByID];
        }
        //        [[MRWebserviceHelper sharedWebServiceHelper] getAppointmentsByRep:[NSString stringWithFormat:@"%ld", (long)self.repId] withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        //
        //        }];
        
    }
}

- (void)callServicePendingAppointment
{
    [MRCommon showActivityIndicator:@"Loading..."];
    
    [[MRWebserviceHelper sharedWebServiceHelper] getMyPendingAppointmentForPharma:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            [MRCommon stopActivityIndicator];
            self.convertAppointments = [responce objectForKey:kResponce];
            if (self.convertAppointments.count == 0)
            {
                [MRCommon showAlert:@"No pending appointments found" delegate:nil];
            }
            [self.pcTableView reloadData];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getMyPendingAppointmentForPharma:^(BOOL status, NSString *details, NSDictionary *responce)
                  {
                      if (status)
                      {
                          [MRCommon stopActivityIndicator];
                          self.convertAppointments = [responce objectForKey:kResponce];
                          if (self.convertAppointments.count == 0)
                          {
                              [MRCommon showAlert:@"No pending appointments found" delegate:nil];
                          }
                          [self.pcTableView reloadData];
                      }
                  }];
                 
             }];
        }
        // NSLog(@"responce %@",responce);
    }];
}

- (void)callServiceTeamPendingAppointment
{
    [MRCommon showActivityIndicator:@"Loading..."];
    
    [[MRWebserviceHelper sharedWebServiceHelper] getMyTeamPendingAppointments:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            [MRCommon stopActivityIndicator];
            self.convertAppointments = [responce objectForKey:kResponce];
            if (self.convertAppointments.count == 0)
            {
                [MRCommon showAlert:@"No pending appointments found" delegate:nil];
            }
            [self.pcTableView reloadData];
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
                          [MRCommon stopActivityIndicator];
                          self.convertAppointments = [responce objectForKey:kResponce];
                          if (self.convertAppointments.count == 0)
                          {
                              [MRCommon showAlert:@"No pending appointments found" delegate:nil];
                          }
                          [self.pcTableView reloadData];
                      }
                  }];
                 
             }];
        }
        // NSLog(@"responce %@",responce);
    }];
}

- (void)callServiceCompletedUpcomingAppointment
{
    [MRCommon showActivityIndicator:@"Loading..."];
    
    [[MRWebserviceHelper sharedWebServiceHelper] getMyAppointmentForPharma:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            [MRCommon stopActivityIndicator];
            self.convertAppointments = [self filterAppointmnetLis:[responce objectForKey:kResponce]];
            if (self.convertAppointments.count == 0)
            {
                if (self.appointnetType == 1)
                {
                    [MRCommon showAlert:@"No upcoming appointments found" delegate:nil];
                }
                else
                [MRCommon showAlert:@"No completed appointments found" delegate:nil];
            }
            [self.pcTableView reloadData];
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
                          self.convertAppointments = [self filterAppointmnetLis:[responce objectForKey:kResponce]];
                          if (self.convertAppointments.count == 0)
                          {
                              if (self.appointnetType == 1)
                              {
                                  [MRCommon showAlert:@"No upcoming appointments found" delegate:nil];
                              }
                              else
                              [MRCommon showAlert:@"No completed appointments found" delegate:nil];
                          }
                          [self.pcTableView reloadData];
                      }
                  }];
                 
             }];
        }
        // NSLog(@"responce %@",responce);
    }];
}

- (void)callRepAppointmentsByID
{
    [MRCommon showActivityIndicator:@"Loading..."];
    
    [[MRWebserviceHelper sharedWebServiceHelper] getAppointmentsByRep:[NSString stringWithFormat:@"%ld", (long)self.repId] withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            [MRCommon stopActivityIndicator];
            self.convertAppointments =  [self filteredAppointmnets:[responce objectForKey:kResponce]];
            if (self.isCompletedAppointmnet)
            {
                if (self.convertAppointments.count == 0)
                    [MRCommon showAlert:@"No completed appointments found" delegate:nil];
            }
            else if (self.isCompletedAppointmnet == NO && self.isPendingAppointmnet == 0)
            {
                if (self.convertAppointments.count == 0)
                [MRCommon showAlert:@"No upcoming appointments found" delegate:nil];
            }
            [self.pcTableView reloadData];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getAppointmentsByRep:[NSString stringWithFormat:@"%ld", (long)self.repId] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                  {
                      if (status)
                      {
                          [MRCommon stopActivityIndicator];
                          self.convertAppointments = [self filteredAppointmnets:[responce objectForKey:kResponce]];
                          if (self.isCompletedAppointmnet)
                          {
                              if (self.convertAppointments.count == 0)
                              [MRCommon showAlert:@"No completed appointments found" delegate:nil];
                          }
                          else if (self.isCompletedAppointmnet == NO && self.isPendingAppointmnet == 0)
                          {
                              if (self.convertAppointments.count == 0)
                              [MRCommon showAlert:@"No upcoming appointments found" delegate:nil];
                          }
                          [self.pcTableView reloadData];
                      }
                  }];
                 
             }];
        }
        // NSLog(@"responce %@",responce);
    }];
}

- (NSArray*)filteredAppointmnets:(NSArray*)appointmnets
{
    NSArray *filteredArray          = [appointmnets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status == %@", self.isCompletedAppointmnet ? @"Completed" : @"Scheduled"]];
    return filteredArray.count > 0 ?  filteredArray : nil ;
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
    
    MRAppointmentListCell *productCell = (MRAppointmentListCell*)[tableView dequeueReusableCellWithIdentifier:productCelId];
    
    if (productCell == nil)
    {
        NSArray *bundleCell = [[NSBundle mainBundle] loadNibNamed:@"MRAppointmentListCell" owner:nil options:nil];
        productCell = (MRAppointmentListCell *)[bundleCell lastObject];
    }
    NSDictionary *dict =[self.convertAppointments objectAtIndex:indexPath.row];
    productCell.profileImage.image = [UIImage imageNamed:@"profileIcon.png"];
    productCell.profileName.text = [NSString stringWithFormat:@"Meeting With Dr %@",[dict objectForKey:@"doctorName"]];
    productCell.appointmnetTime.text = [self getAppointmnetDateTime:[dict objectForKey:@"startDate"]];
    productCell.locationLabel.text = @"";//[dict objectForKey:@"location"];
    [productCell loadProfileImage:[dict objectForKey:@"doctorId"]];
    return productCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([MRAppControl sharedHelper].userType == 3)
    {
        NSDictionary *dict =[self.convertAppointments objectAtIndex:indexPath.row];
        //    MRDoctorActivityScoreDetailsViewController *doctorDetails = [[MRDoctorActivityScoreDetailsViewController alloc] initWithNibName:@"MRDoctorActivityScoreDetailsViewController" bundle:nil];
        //    doctorDetails.doctorID = [[dict objectForKey:@"doctorId"] integerValue];
        //    doctorDetails.doctorDetalsDictionary = [self.convertAppointments objectAtIndex:indexPath.row];
        //    [self.navigationController pushViewController:doctorDetails animated:YES];
        
        switch (self.appointnetType)
        {
            case 1:
            {
                //MRViewRepAppointmnetViewController
                NSDictionary *dict =[self.convertAppointments objectAtIndex:indexPath.row];
//                MRViewAppointmnetViewController *appointList = [[MRViewAppointmnetViewController alloc] init];
                MRViewRepAppointmnetViewController *appointList = [[MRViewRepAppointmnetViewController alloc] initWithNibName:@"MRViewRepAppointmnetViewController" bundle:nil];

                appointList.appointmnetDetails      = dict;
                appointList.isCompletedAppointmnet  = NO;
                appointList.isPendingAppointmnet    = NO;
                [self.navigationController pushViewController:appointList animated:YES];
            }
                break;
            case 2:
            {
                MRViewAppointmnetViewController *appointList = [[MRViewAppointmnetViewController alloc] init];
                appointList.isCompletedAppointmnet  = YES;
                appointList.isPendingAppointmnet    = NO;
                appointList.appointmnetDetails = dict;
                [self.navigationController pushViewController:appointList animated:YES];
            }
                break;
            case 3:
            {
                NSDictionary *dict =[self.convertAppointments objectAtIndex:indexPath.row];
                MRViewAppointmnetViewController *appointList = [[MRViewAppointmnetViewController alloc] init];
                //MRViewRepAppointmnetViewController *appointList = [[MRViewRepAppointmnetViewController alloc] initWithNibName:@"MRViewRepAppointmnetViewController" bundle:nil];
                appointList.appointmnetDetails      = dict;
                appointList.isCompletedAppointmnet  = self.isCompletedAppointmnet;
                appointList.isPendingAppointmnet    = YES;
                [self.navigationController pushViewController:appointList animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        NSDictionary *dict =[self.convertAppointments objectAtIndex:indexPath.row];
        MRViewAppointmnetViewController *appointList = [[MRViewAppointmnetViewController alloc] init];
        appointList.appointmnetDetails      = dict;
        appointList.isCompletedAppointmnet  = self.isCompletedAppointmnet;
        appointList.isPendingAppointmnet    = self.isPendingAppointmnet;
        [self.navigationController pushViewController:appointList animated:YES];
    }
}

- (NSString*)getAppointmnetTime:(NSString*)dateString withDurtaion:(NSNumber*)durtaion
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *date = [MRCommon dateFromstring:dateString withDateFormate:@"YYYYMMddHHmmss"];
    dateFormatter.dateFormat = @"hh:mm a";
    NSString *strDate = [dateFormatter stringFromDate:date];

    
    NSDate *tempEndDate = [date dateByAddingMinutes:[durtaion integerValue]];
     NSString *endDate =  [dateFormatter stringFromDate:tempEndDate];
    
    return [NSString stringWithFormat:@"%@-%@",strDate, endDate];
}

- (NSString*)getAppointmnetDateTime:(NSString*)dateString
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *date = [MRCommon dateFromstring:dateString withDateFormate:@"YYYYMMddHHmmss"];
    dateFormatter.dateFormat = @"MMM dd hh:mm a";
    NSString *strDate = [dateFormatter stringFromDate:date];
    
    
    
    return strDate;
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

- (NSArray*)filterAppointmnetLis:(NSArray*)array
{
    NSArray *filteredArray          = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status == %@", (self.appointnetType == 1) ? @"Scheduled" : @"Completed"]];
    
    return filteredArray;
}

- (void)callServiceUpcomingAppointments
{
    [MRCommon showActivityIndicator:@"Loading..."];
    
    [[MRWebserviceHelper sharedWebServiceHelper] getMyUpcomingAppointment:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            [MRCommon stopActivityIndicator];
            self.convertAppointments = [responce objectForKey:kResponce];
            if (self.convertAppointments.count == 0)
            {
                if (self.appointnetType == 1)
                {
                    [MRCommon showAlert:@"No upcoming appointments found" delegate:nil];
                }
                else
                    [MRCommon showAlert:@"No completed appointments found" delegate:nil];
            }
            [self.pcTableView reloadData];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getMyUpcomingAppointment:^(BOOL status, NSString *details, NSDictionary *responce)
                  {
                      if (status)
                      {
                          [MRCommon stopActivityIndicator];
                          self.convertAppointments = [responce objectForKey:kResponce];
                          if (self.convertAppointments.count == 0)
                          {
                              if (self.appointnetType == 1)
                              {
                                  [MRCommon showAlert:@"No upcoming appointments found" delegate:nil];
                              }
                              else
                                  [MRCommon showAlert:@"No completed appointments found" delegate:nil];
                          }
                          [self.pcTableView reloadData];
                      }
                  }];
                 
             }];
        }
        // NSLog(@"responce %@",responce);
    }];
}


- (void)callServiceCompletedAppointments
{
    [MRCommon showActivityIndicator:@"Loading..."];
    
    [[MRWebserviceHelper sharedWebServiceHelper] getMyCompletedAppointment:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            [MRCommon stopActivityIndicator];
            self.convertAppointments = [responce objectForKey:kResponce];
            if (self.convertAppointments.count == 0)
            {
                if (self.appointnetType == 1)
                {
                    [MRCommon showAlert:@"No upcoming appointments found" delegate:nil];
                }
                else
                    [MRCommon showAlert:@"No completed appointments found" delegate:nil];
            }
            [self.pcTableView reloadData];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getMyCompletedAppointment:^(BOOL status, NSString *details, NSDictionary *responce)
                  {
                      if (status)
                      {
                          [MRCommon stopActivityIndicator];
                          self.convertAppointments = [responce objectForKey:kResponce];
                          if (self.convertAppointments.count == 0)
                          {
                              if (self.appointnetType == 1)
                              {
                                  [MRCommon showAlert:@"No upcoming appointments found" delegate:nil];
                              }
                              else
                                  [MRCommon showAlert:@"No completed appointments found" delegate:nil];
                          }
                          [self.pcTableView reloadData];
                      }
                  }];
                 
             }];
        }
        // NSLog(@"responce %@",responce);
    }];
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

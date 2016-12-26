//
//  MRPHSurveyDetailsViewController.m
//  MedRep
//
//  Created by MedRep Developer on 03/10/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRPHSurveyDetailsViewController.h"
#import "MRConstants.h"
#import "MRCommon.h"
#import "SWRevealViewController.h"
#import <PNChart/PNChart.h>
#import "MRPHSurveyStatistics+CoreDataClass.h"
#import "MRPHSurveyPendingList+CoreDataClass.h"
#import "MRPHSurveyDetailsPendingDoctorTableViewCell.h"

@interface MRPHSurveyDetailsViewController ()<SWRevealViewControllerDelegate,
                                              UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UIView *fullStatusView;
@property (weak, nonatomic) IBOutlet UIView *pendingStatusView;
@property (weak, nonatomic) IBOutlet UIView *answeredStatusView;

@property (nonatomic) PNCircleChart *fullStatusChart;
@property (nonatomic) PNCircleChart *pendingStatusChart;
@property (nonatomic) PNCircleChart *answeredStatusChart;

@property (nonatomic) MRPHSurveyStatistics *survey;

@property (weak, nonatomic) IBOutlet UITableView *doctorListTableView;

@property (nonatomic) NSArray *doctorList;

@end

@implementation MRPHSurveyDetailsViewController

- (void)getMenuNavigationButtonWithController
{
    self.navigationItem.title = @"Survey Details";
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButton:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
}

- (void)parseReceivedResponse:(NSArray*)response {
    
    if (self.fullStatusChart != nil) {
        [self.fullStatusChart removeFromSuperview];
    }
    
    if (self.pendingStatusChart != nil) {
        [self.pendingStatusChart removeFromSuperview];
    }
    
    if (self.answeredStatusChart != nil) {
        [self.answeredStatusChart removeFromSuperview];
    }
    
    [[MRDataManger sharedManager] removeAllObjects:kSurveyStatisticsPendingListEntity withPredicate:nil];
    
    id result = [MRWebserviceHelper parseNetworkResponse:NSClassFromString(kSurveyStatisticsPendingListEntity)
                                                 andData:response];
    
    [self.bgView setHidden:NO];
    
    NSArray *tempResult = (NSArray*)result;
    if (tempResult != nil && tempResult.count > 0) {
        self.doctorList = [[MRDataManger sharedManager] fetchObjectList:kSurveyStatisticsPendingListEntity
                                                          attributeName:@"doctorName"
                                                              sortOrder:SORT_ORDER_ASCENDING];
        
        self.fullStatusChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, self.fullStatusView.frame.size.width, 100.0)
                                                                    total:self.survey.totalSent
                                                                  current:self.survey.totalCompleted
                                                          clockwise:YES
                                      shadow:YES
                                                              shadowColor:[UIColor whiteColor]];
        [self.fullStatusChart setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.fullStatusChart.backgroundColor = [UIColor clearColor];
        [self.fullStatusChart setStrokeColor:PNGreen];
        
        [self.fullStatusChart strokeChart:^NSAttributedString *(float value) {
            
            NSString *completeString = [NSString stringWithFormat:@"%d\rSENT", self.survey.totalSent.integerValue];
            
            NSMutableAttributedString *sentString = [[NSMutableAttributedString alloc] initWithString:completeString];
            
            [sentString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16.0] range:NSMakeRange(completeString.length - 4, 4)];
            [sentString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(completeString.length - 4, 4)];
            
            [sentString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18.0] range:NSMakeRange(0, completeString.length - 4)];
            [sentString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, completeString.length - 4)];
            
            return sentString;
        }];
        [self.fullStatusView addSubview:self.fullStatusChart];
        
        // Pending
        self.pendingStatusChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, self.pendingStatusView.frame.size.width, 100.0)
                                                              total:self.survey.totalSent
                                                            current:self.survey.totalPending
                                                          clockwise:YES
                                                             shadow:YES
                                                        shadowColor:[UIColor lightGrayColor]];
        self.pendingStatusChart.backgroundColor = [UIColor clearColor];
        [self.pendingStatusChart setStrokeColor:PNGreen];
        [self.pendingStatusChart strokeChart:^NSAttributedString *(float value) {
            NSString *completeString = [NSString stringWithFormat:@"%d", self.survey.totalPending.integerValue];
            
            NSMutableAttributedString *sentString = [[NSMutableAttributedString alloc] initWithString:completeString];
            
            [sentString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18.0] range:NSMakeRange(0, completeString.length)];
            [sentString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, completeString.length)];
            
            return sentString;
        }];
        
        [self.pendingStatusView addSubview:self.pendingStatusChart];
        
        // Answered
        self.answeredStatusChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, self.answeredStatusView.frame.size.width, 100.0)
                                                              total:self.survey.totalSent
                                                            current:self.survey.totalCompleted
                                                          clockwise:YES
                                                             shadow:YES
                                                        shadowColor:[UIColor lightGrayColor]];
        self.answeredStatusChart.backgroundColor = [UIColor clearColor];
        [self.answeredStatusChart setStrokeColor:PNGreen];
        [self.answeredStatusChart strokeChart:^NSAttributedString *(float value) {
            NSString *completeString = [NSString stringWithFormat:@"%d", self.survey.totalCompleted.integerValue];
            
            NSMutableAttributedString *sentString = [[NSMutableAttributedString alloc] initWithString:completeString];
            
            [sentString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18.0] range:NSMakeRange(0, completeString.length)];
            [sentString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, completeString.length)];
            
            return sentString;

        }];
        
        [self.answeredStatusView addSubview:self.answeredStatusChart];
        [self.doctorListTableView setHidden:NO];
        [self.doctorListTableView reloadData];
    } else {
        self.doctorList = nil;
        [self.bgView setHidden:YES];
        [MRCommon showAlert:@"Unable to retrieve survey details" delegate:self withTag:1];
    }
}

- (void)downloadPendingDoctorsList {
    [[MRWebserviceHelper sharedWebServiceHelper] getPendingDoctorsListInSurvey:self.surveyId
                                                          andHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             [MRCommon stopActivityIndicator];
             [self parseReceivedResponse:[responce objectOrNilForKey:@"Responce"]];
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getPendingDoctorsListInSurvey:self.surveyId
                                                                        andHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       [MRCommon stopActivityIndicator];
                       if (status)
                       {
                           [self parseReceivedResponse:[responce objectOrNilForKey:@"Responce"]];
                       }
                   }];
              }];
         }
         else
         {
             [MRCommon stopActivityIndicator];
             [MRCommon showAlert:@"Unable to retrieve survey details" delegate:nil];
         }
     }];
}

- (void)parseSurveyStatisticsResponse:(NSDictionary*)response {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == %@", @"surveyId", self.surveyId];
    [[MRDataManger sharedManager] removeAllObjects:kSurveyStatisticsEntity withPredicate:predicate];
    
    id result = [MRWebserviceHelper parseNetworkResponse:NSClassFromString(kSurveyStatisticsEntity)
                                                 andData:@[response]];
    
    NSArray *tempResult = (NSArray*)result;
    if (tempResult != nil && tempResult.count > 0) {
        self.survey = (MRPHSurveyStatistics*)tempResult.firstObject;
    }
    
    [self downloadPendingDoctorsList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.bgView setHidden:YES];
    
    [self.doctorListTableView registerNib:[UINib nibWithNibName:@"MRPHSurveyDetailsPendingDoctorTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PendingDoctorList"];
    
    [self.doctorListTableView setHidden:YES];
    
    [MRCommon showActivityIndicator:@"Loading..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getSurveyStatistics:self.surveyId
                                                          andHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             [self parseSurveyStatisticsResponse:responce];
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getSurveyStatistics:self.surveyId
                                                                        andHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       if (status)
                       {
                           [self parseSurveyStatisticsResponse:responce];
                       }
                   }];
              }];
         }
         else
         {
             [MRCommon stopActivityIndicator];
             [MRCommon showAlert:@"No pending surveys found." delegate:nil];
         }
     }];
    
    [self getMenuNavigationButtonWithController];
      //]:[self revealViewController] NavigationItem:self.navigationItem];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = self.surveyName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    
    if (self.doctorList != nil && self.doctorList != nil) {
        count = self.doctorList.count;
    }
    
    return count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRPHSurveyDetailsPendingDoctorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PendingDoctorList"];
    
    if (cell == nil) {
        cell = [[MRPHSurveyDetailsPendingDoctorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PendingDoctorList"];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setData:[self.doctorList objectAtIndex:indexPath.row] andParentViewController:self];
    
    return cell;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        [self.navigationController popViewControllerAnimated:YES];
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

//
//  MRPHSurveyListViewController.m
//  MedRep
//
//  Created by MedRep Developer on 03/10/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRPHSurveyListViewController.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "SWRevealViewController.h"
#import "MRWebserviceHelper.h"
#import "MPNotificatinsTableViewCell.h"
#import "MRPHSurveyDetailsViewController.h"

@interface MRPHSurveyListViewController ()<UITableViewDataSource, UITableViewDelegate, SWRevealViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UITableView *surveysList;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic, retain) NSArray *surveysListArray;

@end

@implementation MRPHSurveyListViewController

- (void)getMenuNavigationButtonWithController:(SWRevealViewController *)revealViewCont NavigationItem:(UINavigationItem *)navigationItem1
{
    self.navigationItem.title = @"Surveys";
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [MRCommon showActivityIndicator:@"Loading..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getSurveysListByPharma:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             [MRCommon stopActivityIndicator];
             self.surveysListArray = [responce objectForKey:kResponce];
             if (self.surveysListArray.count == 0) {
                 [MRCommon showAlert:@"No pending surveys found." delegate:nil];
             }
             [self.surveysList reloadData];
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getSurveysListByPharma:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       [MRCommon stopActivityIndicator];
                       if (status)
                       {
                           self.surveysListArray = [responce objectForKey:kResponce];
                           [self.surveysList reloadData];
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
    [self getMenuNavigationButtonWithController:[self revealViewController] NavigationItem:self.navigationItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MRCommon applyNavigationBarStyling:self.navigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonAction:(id)sender
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.surveysListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier                = @"MRRegTableViewCell";
    MPNotificatinsTableViewCell *regCell    = (MPNotificatinsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (regCell == nil)
    {
        NSArray *nibViews                   = [[NSBundle mainBundle] loadNibNamed:@"MPNotificatinsTableViewCell" owner:nil options:nil];
        regCell                             = (MPNotificatinsTableViewCell *)[nibViews lastObject];
        
    }
    [regCell enableDownloadReportButton:NO];
    
    NSDictionary *survey              = [self.surveysListArray objectAtIndex:indexPath.row];
    [regCell setSurveyReport:[survey valueForKey:@"surveyId"]];
    
    regCell.notificationLetter.hidden       = NO;
    regCell.notificationLetter.backgroundColor = [MRCommon getColorForIndex:indexPath.row];
    regCell.notificationLetter.text            = [MRCommon getUpperCaseLetter:[survey objectForKey:@"surveyTitle"]];
    regCell.companyLogo.hidden              = YES;
    regCell.backgroundImage.image           = [UIImage imageNamed:@"transperent-bg.png"];
    regCell.companyLabel.hidden             =
    regCell.medicineLabel.hidden            = NO;
    regCell.companyLabel.text               = [survey objectForKey:@"surveyTitle"];
    regCell.medicineLabel.text              = [survey objectForKey:@"surveyDescription"];
    
    regCell.arrowImage.image                = [UIImage imageNamed:@"White-right-arrow@2x.png"];
    
    NSNumber *downloadStatus = [survey valueForKey:@"reportsAvailable"];
    if (downloadStatus != nil && downloadStatus.boolValue) {
        [regCell.downloadSurveyReportButton setImage:[UIImage imageNamed:@"transperent-bg"]
                                                      forState:UIControlStateNormal];
        [regCell.downloadSurveyReportButton setUserInteractionEnabled:NO];
    } else {
        [regCell.downloadSurveyReportButton setImage:[UIImage imageNamed:@"eye"]
                                            forState:UIControlStateNormal];
        [regCell.downloadSurveyReportButton setUserInteractionEnabled:YES];
    }
    
    [regCell.downloadSurveyReportButton addTarget:self
                                           action:@selector(downloadSurveyReportButtonClicked:)
                                 forControlEvents:UIControlEventTouchUpInside];
    
    return regCell;
}

- (void)downloadSurveyReportButtonClicked:(id)sender {
    
}

/*
 [{
 "surveyId": 2,
 "doctorId": 14,
 "doctorSurveyId": 2,
 "surveyTitle": "Demo Survey 2",
 "surveyUrl": "http://localhost:8090/surveys/list?2",
 "createdOn": null,
 "status": "NEW",
 "scheduledStart": "20150830",
 "scheduledFinish": "20150930",
 "companyId": 1,
 "therapeuticId": 1,
 "companyName": "Dummy Company",
 "therapeuticName": "Demo",
 "surveyDescription": "Demo Survey 2"
 }]
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MRPHSurveyDetailsViewController *notificationDetails = [[MRPHSurveyDetailsViewController alloc] initWithNibName:@"MRPHSurveyDetailsViewController" bundle:nil];
    
    NSDictionary *survey              = [self.surveysListArray objectAtIndex:indexPath.row];
    notificationDetails.surveyId = [survey objectOrNilForKey:@"surveyId"];
    notificationDetails.surveyURL = [survey objectOrNilForKey:@"surveyUrl"];
    notificationDetails.surveyName = [survey objectOrNilForKey:@"surveyTitle"];
    
    [self.navigationController pushViewController:notificationDetails animated:YES];
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

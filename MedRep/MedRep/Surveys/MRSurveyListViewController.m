//
//  MRSurveyListViewController.m
//  MedRep
//
//  Created by MedRep Developer on 03/10/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRSurveyListViewController.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "SWRevealViewController.h"
#import "MRWebserviceHelper.h"
#import "MPNotificatinsTableViewCell.h"
#import "MRSurveyDetailsViewController.h"

@interface MRSurveyListViewController ()<UITableViewDataSource, UITableViewDelegate, SWRevealViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UITableView *surveysList;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic, retain) NSArray *surveysListArray;

@end

@implementation MRSurveyListViewController
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
    // Do any additional setup after loading the view from its nib.
    [MRCommon showActivityIndicator:@"Loading..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getMyPendingSurveysDetails:^(BOOL status, NSString *details, NSDictionary *responce)
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
                  [[MRWebserviceHelper sharedWebServiceHelper] getMyPendingSurveysDetails:^(BOOL status, NSString *details, NSDictionary *responce)
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
    NSDictionary *survey              = [self.surveysListArray objectAtIndex:indexPath.row];
    
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
    return regCell;
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
    MRSurveyDetailsViewController *notificationDetails = [[MRSurveyDetailsViewController alloc] initWithNibName:@"MRSurveyDetailsViewController" bundle:nil];
    NSDictionary *survey              = [self.surveysListArray objectAtIndex:indexPath.row];
    NSString *str = [survey objectForKey:@"surveyUrl"];
    
    notificationDetails.surveyURL     = [str stringByReplacingOccurrencesOfString:@"http://medrep.in" withString:kBaseURL];
    notificationDetails.surveyName     = [survey objectForKey:@"surveyTitle"];

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

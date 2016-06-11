//
//  MRFeedBackResultViewController.m
//  MedRep
//
//  Created by MedRep Developer on 28/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRFeedBackResultViewController.h"
#import "MRFeedBackResultCell.h"
#import "SWRevealViewController.h"
#import "MRCommon.h"
#import "MRWebserviceHelper.h"

@interface MRFeedBackResultViewController ()<SWRevealViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *feedBackTable;
@property (nonatomic, retain) NSDictionary *feedbackResponse;
@end

@implementation MRFeedBackResultViewController

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
    
    /*
     "notificationId": 1,
     "notificationName": "BioSafe",
     "totalCount": "3",
     "ratingAverage": "4.3",
     "prescribeYes": "1.0",
     "prescribeNo": "2.0",
     "favoriteYes": "2.0",
     "favoriteNo": "1.0",
     "recomendYes": "0.0",
     "recomendNo": "3.0"
     */
    
    self.feedbackResponse = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"0", @"notificationId",
                             @"BioSafe", @"notificationName",
                             @"0", @"totalCount",
                             @"0", @"ratingAverage",
                             @"0", @"prescribeYes",
                             @"0", @"prescribeNo",
                             @"0", @"favoriteYes",
                             @"0", @"favoriteNo",
                             @"0", @"recomendYes",
                             @"0", @"recomendNo", nil];
    
    [self getFeedbackDetails];
    [self getMenuNavigationButtonWithController:[self revealViewController] NavigationItem:self.navigationItem];
    self.feedbackTitle.text = [NSString stringWithFormat:@"%@ Feedback Result",self.productName];
    // Do any additional setup after loading the view from its nib.
}

- (void)getFeedbackDetails
{
    [MRCommon showActivityIndicator:@"Loading..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getDoctorNotificationStatsById:[NSString stringWithFormat:@"%ld", self.notificationID] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
    {
         if (status)
         {
             [MRCommon stopActivityIndicator];
             self.feedbackResponse = responce;
             [self.feedBackTable reloadData];
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getDoctorNotificationStatsById:[NSString stringWithFormat:@"%ld", self.notificationID] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       [MRCommon stopActivityIndicator];
                       if (status)
                       {
                           self.feedbackResponse = responce;
                           [self.feedBackTable reloadData];
                       }
                   }];
              }];
         }
         else
         {
             [MRCommon stopActivityIndicator];
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
#pragma mark Table View Data Source ---

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *doctorDetailsId = @"feedBackResultCell";
    
    MRFeedBackResultCell *doctorDetailsCell = [tableView dequeueReusableCellWithIdentifier:doctorDetailsId];
    
    if (doctorDetailsCell == nil)
    {
        NSArray *bundleCell = [[NSBundle mainBundle] loadNibNamed:@"MRFeedBackResultCell" owner:nil options:nil];
        doctorDetailsCell = (MRFeedBackResultCell *)[bundleCell lastObject];
    }
    
    [doctorDetailsCell configureFeedbackCell:indexPath.row andFeedBack:self.feedbackResponse];
    
    return doctorDetailsCell;
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

- (void)updateTheUIBasedOnResponce:(NSDictionary*)responce
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

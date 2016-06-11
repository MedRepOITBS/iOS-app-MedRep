//
//  MRDoctorScoreViewController.m
//  Gravity
//
//  Created by Apple on 26/09/15.
//  Copyright © 2015 Sprim. All rights reserved.
//

#import "MRDoctorActivityScoreViewController.h"
#import "SWRevealViewController.h"
#import "MRWebserviceHelper.h"
#import "MRDoctorActivityScoreViewController.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "GraphView.h"
#import "GraphPoint.h"
#import "MRDRActivityTableViewCell.h"

@interface MRDoctorActivityScoreViewController ()
{
    NSArray *dataSourceHeadingsArray;
    NSArray *dataSourceImgsArray;
    GraphView *graphView;
}

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *detailsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *docotorDetailsHeightCostraint;
@property (weak, nonatomic) IBOutlet UIScrollView *graphScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *graphHolderView;
@property (nonatomic, retain) NSArray *activityDetals;
@property (weak, nonatomic) IBOutlet UILabel *totalScoreLabel;
@end

@implementation MRDoctorActivityScoreViewController

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
    
    self.title = @"Doctor Score ";
    
    dataSourceHeadingsArray= @[@"Doctor Name ",@"Therapeutic \nArea ",@"Email Id ",@"Mobile No ", @"Location(s) "];
    [self setUpUI];
    dataSourceImgsArray = @[@"PHdoctor.png",@"PHthera.png",@"PHmail.png",@"PHphone.png",@"PHlocations.png"];
    self.graphScrollView.contentSize = self.graphHolderView.frame.size;
    [self getMenuNavigationButtonWithController:[self revealViewController] NavigationItem:self.navigationItem];
    [self callService];
    // Do any additional setup after loading the view from its nib.
}

 -(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)setUpUI
{
    [self updateTotalScore:[NSNumber numberWithInteger:0]];
    if ([MRCommon deviceHasThreePointFiveInchScreen])
    {
        self.docotorDetailsHeightCostraint.constant = 210;
        [self.view updateConstraints];
    }
//    [self.graphScrollView scrollRectToVisible:CGRectMake(0, self.graphViewHeightConstraint.constant, self.view.frame.size.width, 100) animated:YES];
}

- (void)updateTotalScore:(NSNumber*)tScore
{
    //Total Score
    NSString *score = [NSString stringWithFormat:@"%ld", [tScore integerValue]];
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Total Score %@", score]];
    
//    NSRange range = NSMakeRange([string length], [string length]);
//
//    [string addAttributes:@{NSForegroundColorAttributeName : [UIColor blueColor]} range:range];
    
    NSRange range = NSMakeRange([@"Total Score " length], [score length]);
    
    [string addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:15.0 ]}
                    range:range];
    
    self.totalScoreLabel.attributedText = string;

}
- (void)callService
{
    [MRCommon showActivityIndicator:@"Loading..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getDoctorActivityScore:^(BOOL status, NSString *details, NSDictionary *responce)
     {
        
         /*
          [{"doctorId":4,"companyId":1,"companyName":"Demo Company","doctorName":"Umar Ashraf","totalScore":13,"activities":{"Appointment":5,"Survey":0,"Feedback":5,"Notification":3}},{"doctorId":4,"companyId":2,"companyName":"Demo Company","doctorName":"Umar Ashraf","totalScore":23,"activities":{"Appointment":5,"Survey":10,"Feedback":5,"Notification":3}},{"doctorId":4,"companyId":3,"companyName":"Demo Company","doctorName":"Umar Ashraf","totalScore":46,"activities":{"Appointment":10,"Survey":20,"Feedback":10,"Notification":6}}]
          */
         
         if (status)
         {
             [MRCommon stopActivityIndicator];
             self.activityDetals = [responce objectForKey:kResponce];
             if (self.activityDetals.count > 0) {
                 [self updateGraphView:[self.activityDetals objectAtIndex:0]];
             }
             [self.detailsTableView reloadData];
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getDoctorActivityScore:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       [MRCommon stopActivityIndicator];
                       if (status)
                       {
                           self.activityDetals = [responce objectForKey:kResponce];
                           if (self.activityDetals.count > 0) {
                               [self updateGraphView:[self.activityDetals objectAtIndex:0]];
                           }
                           [self.detailsTableView reloadData];
                       }
                   }];
              }];
         }
         else
         {
             [MRCommon stopActivityIndicator];
             [MRCommon showAlert:@"No Activity found." delegate:nil];
         }
         
     }];
}

- (void)updateGraphView:(NSDictionary *)dataDict
{
    NSDictionary *dict = [dataDict objectForKey:@"activities"];
    self.totalScoreLabel.text = [dataDict objectForKey:@"companyName"];
    NSMutableArray *pointArray = [[NSMutableArray alloc]init];
    GraphPoint *point = [[GraphPoint alloc] init];
    point.x = 0;
    point.y = [[dict objectForKey:@"Notification"] integerValue];
    point.barColor = kRGBCOLOR(48, 85, 108);
    [pointArray addObject:point];
    
    point = [[GraphPoint alloc] init];
    point.x = 20;
    point.y = [[dict objectForKey:@"Survey"] integerValue];
    point.barColor = kRGBCOLOR(93, 139, 166);
    [pointArray addObject:point];
    
    point = [[GraphPoint alloc] init];
    point.x = 60;
    point.y = [[dict objectForKey:@"Feedback"] integerValue];
    point.barColor = kRGBCOLOR(48, 85, 108);
    [pointArray addObject:point];

    point = [[GraphPoint alloc] init];
    point.x = 40;
    point.y = [[dict objectForKey:@"Appointment"] integerValue];
    point.barColor = kRGBCOLOR(67, 113, 140);
    [pointArray addObject:point];
    
    if ([self.graphHolderView viewWithTag:1234567890] == nil)
    {
        graphView = [[GraphView alloc] initWithFrame:self.graphHolderView.frame];
    }
    graphView.graphBackgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
    graphView.tag = 1234567890;
    graphView.graphPoints = pointArray;
    graphView.graphType = GRAPH_TYPE_BAR;
    graphView.showLegend = YES;
    graphView.axisLabelsY = [NSArray arrayWithObjects:@"10",@"20",@"30",@"40",@"50",@"60",@"70",@"80",@"90",@"100", nil];
    
    if ([self.graphHolderView viewWithTag:1234567890] == nil)
    {
        [self.graphHolderView addSubview:graphView];
        [MRCommon addUpdateConstarintsTo:self.graphHolderView withChildView:graphView];
    }
    [graphView setNeedsDisplay];
    [self.graphScrollView scrollRectToVisible:CGRectMake(0, 0, 100, 600) animated:NO];
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

- (IBAction)doctorCompAnalysisButtonAction:(id)sender {
}
#pragma mark Table View Data Source ---

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.activityDetals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *doctorScoreId = @"productCellIdentity";
    
    MRDRActivityTableViewCell *doctorScoreCell = [tableView dequeueReusableCellWithIdentifier:doctorScoreId];
    if (doctorScoreCell == nil)
    {
        NSArray *bundleCell = [[NSBundle mainBundle] loadNibNamed:@"MRDRActivityTableViewCell" owner:nil options:nil];
        doctorScoreCell = (MRDRActivityTableViewCell *)[bundleCell lastObject];
    }
    NSDictionary *data = [self.activityDetals objectAtIndex:indexPath.row];
    
    NSDictionary *comapnyDetails = [[MRAppControl sharedHelper] getCompanyDetailsByID:[[data objectForKey:@"companyId"] intValue]];

    doctorScoreCell.companyImageView.image = [MRCommon getImageFromBase64Data:[[comapnyDetails objectForKey:@"displayPicture"] objectForKey:@"data"]];
    doctorScoreCell.companyName.text = [data objectForKey:@"companyName"];
    doctorScoreCell.pointsLabel.text = [NSString stringWithFormat:@"%ld Pts",(long)[[data objectForKey:@"totalScore"] integerValue]];

    return doctorScoreCell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = [self.activityDetals objectAtIndex:indexPath.row];
    [self updateGraphView:data];
}

- (NSString*)getDetails:(NSDictionary*)details forRow:(NSInteger)row
{
    if (self.doctorDetalsDictionary.count > row)
    {
        switch (row) {
            case 0: //name@"firstName"
                //@"lastName"]
                return [NSString stringWithFormat:@"%@ %@",[self.doctorDetalsDictionary objectForKey:@"firstName"],[self.doctorDetalsDictionary objectForKey:@"lastName"]];
                break;
            case 1: // thrapatic
                return [self.doctorDetalsDictionary objectForKey:@"therapeuticName"];
                break;
            case 2:// emial
                return [self.doctorDetalsDictionary objectForKey:@"emailId"];
                break;
            case 3:// mobile
                return [self.doctorDetalsDictionary objectForKey:@"mobileNo"];
                break;
            case 4:// mobile
                return [self getLocation:[self.doctorDetalsDictionary objectForKey:@"locations"]];
                break;
                
            default:
                break;
        }
    }
    return @"";
}

- (NSString*)getLocation:(NSArray*)locationList
{
    if (locationList.count > 0)
    {
       return [[locationList objectAtIndex:0] objectForKey:@"address1"];
    }
    return @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

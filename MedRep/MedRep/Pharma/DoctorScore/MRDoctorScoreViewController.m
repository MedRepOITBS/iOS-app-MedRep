//
//  MRDoctorScoreViewController.m
//  Gravity
//
//  Created by Apple on 26/09/15.
//  Copyright © 2015 Sprim. All rights reserved.
//

#import "MRDoctorScoreViewController.h"
#import "SWRevealViewController.h"
#import "MRWebserviceHelper.h"
#import "MRDoctorScoreViewController.h"
#import "MPNotificationAlertViewController.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "GraphView.h"
#import "GraphPoint.h"
#import "WYPopoverController.h"
#import "MRListViewController.h"

@interface MRDoctorScoreViewController ()<MRDoctorScoreTableCellDeleagte,WYPopoverControllerDelegate,MRListViewControllerDelegate>
{
    NSArray *dataSourceHeadingsArray;
    NSArray *dataSourceImgsArray;
    GraphView *graphView;
    MPNotificationAlertViewController *viewController;
    
}

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *doctorCompAnalasysButton;
@property (weak, nonatomic) IBOutlet UITableView *detailsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *docotorDetailsHeightCostraint;
@property (weak, nonatomic) IBOutlet UIScrollView *graphScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *graphHolderView;
@property (nonatomic, retain) NSDictionary *activityDetals;
@property (weak, nonatomic) IBOutlet UILabel *totalScoreLabel;
@property (strong, nonatomic) WYPopoverController *myPopoverController;

@end

@implementation MRDoctorScoreViewController

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
    
    NSRange range = NSMakeRange([@"Total Score " length], [score length]);
    
    [string addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:15.0 ]}
                    range:range];
    
    self.totalScoreLabel.attributedText = string;

}
- (void)callService
{
    [MRCommon showActivityIndicator:@"Loading..."];
    
    [[MRWebserviceHelper sharedWebServiceHelper] getDoctorActivityScoreForPharma:[NSString stringWithFormat:@"%ld", self.doctorID] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             [MRCommon stopActivityIndicator];
             /*{"doctorId":18,"doctorName":"Milan Hoogan","totalScore":0,"activities":{"Survey":0,"Appointment":0,"Feedback":0,"Notification":0}}*/
             self.activityDetals = responce;
             [self updateGraphView];

         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getDoctorActivityScoreForPharma:[NSString stringWithFormat:@"%ld", self.doctorID] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       [MRCommon stopActivityIndicator];
                       if (status)
                       {
                           self.activityDetals = responce ;
                           [self updateGraphView];
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

- (void)updateGraphView
{
    NSDictionary *dict = [self.activityDetals objectForKey:@"activities"];
    [self updateTotalScore:[self.activityDetals objectForKey:@"totalScore"]];
    
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
    point.x = 40;
    point.y = [[dict objectForKey:@"Appointment"] integerValue];
    point.barColor = kRGBCOLOR(48, 85, 108);
    [pointArray addObject:point];

    point = [[GraphPoint alloc] init];
    point.x = 60;
    point.y = [[dict objectForKey:@"Feedback"] integerValue];
    point.barColor = kRGBCOLOR(67, 113, 140);
    [pointArray addObject:point];
    
    graphView = [[GraphView alloc] initWithFrame:self.graphHolderView.frame];
    graphView.graphPoints = pointArray;
    graphView.graphType = GRAPH_TYPE_BAR;
    graphView.showLegend = YES;
    graphView.axisLabelsY = [NSArray arrayWithObjects:@"10",@"20",@"30",@"40",@"50",@"60",@"70",@"80",@"90",@"100", nil];
    [self.graphHolderView addSubview:graphView];
    [MRCommon addUpdateConstarintsTo:self.graphHolderView withChildView:graphView];
    [self.graphScrollView scrollRectToVisible:CGRectMake(0, 0, 100, 600) animated:NO];
}
- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doctorCompAnalysisButtonAction:(id)sender
{
    [MRCommon showAlert:KPaidServiceMSG  delegate:nil];

   /*  viewController = [[MPNotificationAlertViewController alloc] initWithNibName:@"MPNotificationAlertViewController" bundle:nil];
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
    }];
    */
}
#pragma mark Table View Data Source ---

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([MRCommon deviceHasThreePointFiveInchScreen]) ? 30 : 36;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *doctorScoreId = @"productCellIdentity";

    MRDoctorScoreTableCell *doctorScoreCell = [tableView dequeueReusableCellWithIdentifier:doctorScoreId];
    if (doctorScoreCell == nil)
    {
        NSArray *bundleCell = [[NSBundle mainBundle] loadNibNamed:@"MRDoctorScoreTableCell" owner:nil options:nil];
        doctorScoreCell = (MRDoctorScoreTableCell *)[bundleCell lastObject];
    }
    
    doctorScoreCell.cellImgView.image = [UIImage imageNamed:[dataSourceImgsArray objectAtIndex:indexPath.row]];
    doctorScoreCell.cellDescLabel.text = [NSString stringWithFormat:@": %@",[self getDetails:nil forRow:indexPath.row]];
    doctorScoreCell.cellTitleLabel.text = [dataSourceHeadingsArray objectAtIndex:indexPath.row];
    doctorScoreCell.cellDelegate = self;
    if (indexPath.row == 4)
    {
        doctorScoreCell.locationButton.hidden = NO;
         doctorScoreCell.cellDescLabel.text = @":";
        doctorScoreCell.locationLabel.text = [self getDetails:nil forRow:indexPath.row];
    }
    else
    {
        doctorScoreCell.locationButton.hidden = YES;
    }

    return doctorScoreCell;
}

- (NSString*)getDetails:(NSDictionary*)details forRow:(NSInteger)row
{
    switch (row) {
        case 0: //name@"firstName"
            //@"lastName"]
            return [NSString stringWithFormat:@"%@ %@",[self.doctorDetalsDictionlay objectForKey:@"firstName"],[self.doctorDetalsDictionlay objectForKey:@"lastName"]];
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
        case 4:// mobile
            return [self getLocation:[self.doctorDetalsDictionlay objectForKey:@"locations"]];
            break;
   
        default:
            break;
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

- (void)doctorLocationButtonActiondelagate:(MRDoctorScoreTableCell*)scoreCell
{
    [self.view endEditing:YES];
    [self showPopoverInView:(UIButton*)scoreCell.locationButtonAction];
}

- (void)showPopoverInView:(UIButton*)button
{
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayView.tag = 2000;
    overlayView.backgroundColor = kRGBCOLORALPHA(0, 0, 0, 0.5);
    [self.view addSubview:overlayView];
    [MRCommon addUpdateConstarintsTo:self.view withChildView:overlayView];
    
    WYPopoverTheme *popOverTheme = [WYPopoverController defaultTheme];
    popOverTheme.outerStrokeColor = [UIColor lightGrayColor];
    [WYPopoverController setDefaultTheme:popOverTheme];
    
    
    MRListViewController *moreViewController = [[MRListViewController alloc] initWithNibName:@"MRListViewController" bundle:nil];
    
    moreViewController.modalInPopover = NO;
    moreViewController.delegate = self;
    moreViewController.listType = MRListVIewTypeAddress;
    moreViewController.listItems = [self.doctorDetalsDictionlay objectForKey:@"locations"];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    moreViewController.preferredContentSize = CGSizeMake(width, 200);
    
    UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController:moreViewController] ;
    contentViewController.navigationBar.hidden = YES;
    
    
    self.myPopoverController = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
    self.myPopoverController.delegate = self;
    self.myPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(0,2, 0, 2);
    self.myPopoverController.wantsDefaultContentAppearance = YES;
    [self.myPopoverController presentPopoverFromRect:button.bounds
                                              inView:button
                            permittedArrowDirections:WYPopoverArrowDirectionUp
                                            animated:YES
                                             options:WYPopoverAnimationOptionFadeWithScale];
    
}

#pragma mark - WYPopoverControllerDelegate

- (void)popoverControllerDidPresentPopover:(WYPopoverController *)controller
{
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    UIView *overlayView = [self.view viewWithTag:2000];
    [overlayView removeFromSuperview];
    
    self.myPopoverController.delegate = nil;
    self.myPopoverController = nil;
}

- (void)dismissPopoverController
{
    [self.myPopoverController dismissPopoverAnimated:YES completion:^{
        [self popoverControllerDidDismissPopover:self.myPopoverController];
    }];
}

- (void)selectedListItem:(id)listItem
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

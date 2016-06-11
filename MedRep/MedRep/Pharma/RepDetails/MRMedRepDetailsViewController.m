//
//  MRMedRepDetailsViewController.m
//  
//
//  Created by MedRep Developer on 03/11/15.
//
//

#import "MRMedRepDetailsViewController.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRDoctorScoreTableCell.h"
#import "SWRevealViewController.h"
#import "MRWebserviceHelper.h"
#import "MRAppointmentListViewController.h"
#import "MRMedRepViewController.h"
#import "WYPopoverController.h"
#import "MRListViewController.h"
#import "MRAppControl.h"

@interface MRMedRepDetailsViewController ()<UITableViewDataSource, UITableViewDelegate, MRDoctorScoreTableCellDeleagte,WYPopoverControllerDelegate,MRListViewControllerDelegate>
{
    NSArray *dataSourceHeadingsArray;
    NSArray *dataSourceImgsArray;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) WYPopoverController *myPopoverController;

@end

@implementation MRMedRepDetailsViewController

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

- (void)viewDidLoad
{
    [self getMenuNavigationButtonWithController:[self revealViewController] NavigationItem:self.navigationItem];
    dataSourceHeadingsArray= @[@"Employee ID ",@"Name ",@"Email Id ",@"Mobile No "];
    dataSourceImgsArray = @[@"PHdoctor.png",@"PHthera.png",@"PHmail.png",@"PHphone.png"];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2;
    self.profileImage.clipsToBounds = YES;
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",[self.doctorDetalsDictionlay objectForKey:@"firstName"],[self.doctorDetalsDictionlay objectForKey:@"lastName"]];
    
    [self getPharmarepDetails];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getPharmarepDetails
{
    [[MRWebserviceHelper sharedWebServiceHelper] getPharaRepProfile:[self.doctorDetalsDictionlay objectForKey:@"repId"] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             self.profileImage.image = [MRCommon getImageFromBase64Data:[[responce objectForKey:@"profilePicture"] objectForKey:@"data"]];
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [[MRWebserviceHelper sharedWebServiceHelper] getPharaRepProfile:[self.doctorDetalsDictionlay objectForKey:@"repId"] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       if (status)
                       {
                           self.profileImage.image = [MRCommon getImageFromBase64Data:[[responce objectForKey:@"profilePicture"] objectForKey:@"data"]];
                       }
                   }];
              }];
         }
     }];
}
#pragma mark Table View Data Source ---

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
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
    doctorScoreCell.locationButton.hidden = YES;
    doctorScoreCell.cellDelegate = self;
    return doctorScoreCell;
}

- (NSString*)getDetails:(NSDictionary*)details forRow:(NSInteger)row
{
    switch (row) {
        case 1: //name@"firstName"
            //@"lastName"]
            return [NSString stringWithFormat:@"%@ %@",[self.doctorDetalsDictionlay objectForKey:@"firstName"],[self.doctorDetalsDictionlay objectForKey:@"lastName"]];
            break;
        case 0: // thrapatic
            return [NSString stringWithFormat:@"%ld",(long)[[self.doctorDetalsDictionlay objectForKey:@"repId"] integerValue]];
            break;
        case 2:// emial
            return [self.doctorDetalsDictionlay objectForKey:@"emailId"];
            break;
        case 3:// mobile
            return [self.doctorDetalsDictionlay objectForKey:@"mobileNo"];
            break;
//        case 4:// mobile
//            return [self getLocation:[self.doctorDetalsDictionlay objectForKey:@"locations"]];
//            break;
            
        default:
            break;
    }
    return @"";
}

- (IBAction)viewAppointmentButtonAction:(id)sender
{    
//    MRAppointmentListViewController *appointmentList = [[MRAppointmentListViewController alloc] initWithNibName:@"MRAppointmentListViewController" bundle:nil];
//    appointmentList.repId = [[self.doctorDetalsDictionlay objectForKey:@"repId"] integerValue];
//    [self.navigationController pushViewController:appointmentList animated:YES];
    //[MRCommon showAlert:kComingsoonMSG delegate:nil];
    
    MRMedRepViewController *repViewController = [[MRMedRepViewController alloc] initWithNibName:@"MRMedRepViewController" bundle:nil];
    repViewController.isRepAppointments = YES;
    repViewController.showAppointmentsList = YES;
    repViewController.repId  = [[self.doctorDetalsDictionlay objectForKey:@"repId"] integerValue];;
    [self.navigationController pushViewController:repViewController animated:YES];

}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    moreViewController.listItems = [[MRAppControl sharedHelper].userRegData objectForKey:KRegistarionStageTwo];
    
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

@end

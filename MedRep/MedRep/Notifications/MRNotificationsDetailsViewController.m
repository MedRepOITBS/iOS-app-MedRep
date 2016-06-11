//
//  MRNotificationsDetailsViewController.m
//  MedRep
//
//  Created by MedRep Developer on 07/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRNotificationsDetailsViewController.h"
#import "MPNotificatinsTableViewCell.h"
#import "SWRevealViewController.h"
#import "MRNotificationInsiderViewController.h"
#import "MRListViewController.h"
#import "WYPopoverController.h"
#import "MRDatabaseHelper.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"

#define kImagesArray [NSArray arrayWithObjects:@"ndcompany3@2x.jpg",@"NDcompany4@2x.jpg", nil]

@interface MRNotificationsDetailsViewController () <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,WYPopoverControllerDelegate,MRListViewControllerDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLogo;
@property (weak, nonatomic) IBOutlet UITextField *detailsTextView;
@property (weak, nonatomic) IBOutlet UITableView *notificationDetailsTableView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *logoView;
@property (weak, nonatomic) IBOutlet UIImageView *companyLogoImage;
@property (weak, nonatomic) IBOutlet UIView *detailsInputView;
@property (strong, nonatomic) IBOutlet UIView *navView;
@property (strong, nonatomic) WYPopoverController *myPopoverController;
@property (weak, nonatomic) IBOutlet UIButton *therapeuticButton;
@end

@implementation MRNotificationsDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealController = [self revealViewController];
    revealController.delegate = self;
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    NSDictionary *comapnyDetails = [[MRAppControl sharedHelper] getCompanyDetailsByID:[[self.selectedNotification objectForKey:@"companyId"] intValue]];
    self.companyLogoImage.image =  [MRCommon getImageFromBase64Data:[[comapnyDetails objectForKey:@"displayPicture"] objectForKey:@"data"]];
    
    //self.notificationDetailsList = [self.selectedNotification objectForKey:@"notificationDetails"];
      self.titleLogo.text = [self.selectedNotification objectForKey:@"companyName"];
    self.titleLogo.hidden = YES;//[self.selectedNotification objectForKey:@"companyName"];

    [self loadNotificationDetails];
    
    // Do any additional setup after loading the view from its nib.
}


- (void)loadNotificationDetails
{
    self.notificationDetailsList = [[MRAppControl sharedHelper] getNotificationByCompanyID:[[self.selectedNotification objectForKey:@"companyId"] integerValue]];
    self.detailsTextView.text = [self.selectedNotification objectForKey:@"therapeuticName"];
    
    [self.notificationDetailsTableView reloadData];
    
    self.therapeuticNamesList = [self getNotificationTherapeuticAreas];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.notificationDetailsList = [self.selectedNotification objectForKey:@"notificationDetails"];
//    [self.notificationDetailsTableView reloadData];
//
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)therapeuticButtonAction:(UIButton *)sender
{
    [self showPopoverInView:sender];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
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
    return self.notificationDetailsList.count;
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
    NSDictionary *notification              = [self.notificationDetailsList objectAtIndex:indexPath.row];

    regCell.notificationLetter.hidden       = NO;
    regCell.notificationLetter.backgroundColor = [MRCommon getColorForIndex:indexPath.row];
    regCell.notificationLetter.text            = [MRCommon getUpperCaseLetter:[notification objectForKey:@"notificationName"]];
    regCell.companyLogo.hidden              = YES;
    regCell.backgroundImage.image           = [UIImage imageNamed:@"transperent-bg.png"];
    regCell.companyLabel.hidden             =
    regCell.medicineLabel.hidden            = NO;
    regCell.companyLabel.text               = [notification objectForKey:@"notificationName"];
    regCell.medicineLabel.text              = [notification objectForKey:@"notificationDesc"];
    
    regCell.arrowImage.image                = [UIImage imageNamed:@"White-right-arrow@2x.png"];
    return regCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MRNotificationInsiderViewController *notificationInsiderVc =[[MRNotificationInsiderViewController alloc] initWithNibName:@"MRNotificationInsiderViewController" bundle:nil];
    notificationInsiderVc.notificationDetails = [self.notificationDetailsList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:notificationInsiderVc animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    moreViewController.listType = MRListVIewTypeNotificationTherapetic;
    moreViewController.listItems = self.therapeuticNamesList;//[self getNotificationTherapeuticAreas];//[MRAppControl sharedHelper].therapeuticAreaDetails;
    
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

- (NSArray*)getNotificationTherapeuticAreas
{
    NSMutableArray *therapeutic = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.notificationDetailsList) {
        if (NO == [therapeutic containsObject:[dict objectForKey:@"therapeuticName"]]) {
            [therapeutic addObject:[dict objectForKey:@"therapeuticName"]];
        }
    }
    return therapeutic;
    
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
    NSDictionary *item = (NSDictionary*)listItem;
    [MRAppControl sharedHelper].selectedTherapeuticDetils = item;
    self.detailsTextView.text = [item objectForKey:@"therapeuticName"];
    
    self.notificationDetailsList = [[MRAppControl sharedHelper] getNotificationByTherapeuticName:[item objectForKey:@"therapeuticName"] withCompanyID:[[self.selectedNotification objectForKey:@"companyId"] intValue]];
    [self.notificationDetailsTableView reloadData];
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

@end

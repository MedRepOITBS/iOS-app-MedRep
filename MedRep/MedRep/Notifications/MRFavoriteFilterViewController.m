//
//  MRFavoriteFilterViewController.m
//  MedRep
//
//  Created by MedRep Developer on 10/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRFavoriteFilterViewController.h"
#import "SWRevealViewController.h"
#import "MRListViewController.h"
#import "WYPopoverController.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRAppControl.h"


@interface MRFavoriteFilterViewController ()<UITextFieldDelegate, WYPopoverControllerDelegate,MRListViewControllerDelegate, SWRevealViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *pharmaTextField;
@property (weak, nonatomic) IBOutlet UIButton *therapeuticButton;
@property (weak, nonatomic) IBOutlet UITextField *therapeuticTextField;
@property (strong, nonatomic) WYPopoverController *myPopoverController;

@property (nonatomic, assign) BOOL isFromCompany;

@property (strong, nonatomic) IBOutlet UIView *navView;
@end

@implementation MRFavoriteFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    SWRevealViewController *revealController = [self revealViewController];
    revealController.delegate = self;
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    self.therapeuticTextField.userInteractionEnabled = NO;
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(loadNotificationsOnFilter:withTherapiticName:)])
    {
        [self.delegate loadNotificationsOnFilter:@"" withTherapiticName:@""];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)therapeuticButtonAction:(id)sender
{
    [self.pharmaTextField resignFirstResponder];
    [self showPopoverInView:(UIButton*)sender];
}
- (IBAction)companyNameButtonAction:(id)sender
{
    [self.pharmaTextField resignFirstResponder];
    [self showCompanyDetailsPopoverInView:(UIButton*)sender];
}

- (IBAction)submitButtonAction:(id)sender
{
    //[MRCommon showAlert:kComingsoonMSG delegate:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(loadNotificationsOnFilter:withTherapiticName:)])
    {
        [self.delegate loadNotificationsOnFilter:self.pharmaTextField.text withTherapiticName:self.therapeuticTextField.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)showCompanyDetailsPopoverInView:(UIButton*)button
{
    self.isFromCompany = YES;
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
    moreViewController.listType = MRListVIewTypeCompanyList;
    moreViewController.listItems = [MRAppControl sharedHelper].companyDetails;
    
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

- (void)showPopoverInView:(UIButton*)button
{
    self.isFromCompany = NO;
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
    moreViewController.listType = MRListVIewTypeTherapetic;
    moreViewController.listItems = [MRAppControl sharedHelper].therapeuticAreaDetails;
    
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
    NSDictionary *item = (NSDictionary*)listItem;
    //[MRAppControl sharedHelper].selectedTherapeuticDetils = item;
    if (self.isFromCompany)
    {
        //[item objectForKey:@"companyId"];
        self.pharmaTextField.text = [item objectForKey:@"companyName"];
    }
    else
    {
        self.therapeuticTextField.text = [item objectForKey:@"therapeuticName"];
    }
}

- (IBAction)therapeuticAreaCloseButtonAction:(id)sender
{
   self.therapeuticTextField.text = @"";
}

- (IBAction)pharmaCompanyCloseButtonAction:(id)sender
{
   self.pharmaTextField.text = @"";
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

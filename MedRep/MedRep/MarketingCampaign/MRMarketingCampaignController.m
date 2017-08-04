//
//  MRServeViewController.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/20/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRMarketingCampaignController.h"
#import "SWRevealViewController.h"
#import "MRContactsViewController.h"
#import "MRGroupsListViewController.h"
#import "PendingContactsViewController.h"
#import "MRMyWallViewController.h"
#import "MRTransformViewController.h"
#import "MRCommon.h"
#import "MRCustomTabBar.h"
#import "MRAppConstants.h"
#import "MRConstants.h"

@interface MRMarketingCampaignController () <SWRevealViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (strong, nonatomic) UIView *tabBarView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;

@end

@implementation MRMarketingCampaignController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Marketing Campaign";
    //[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    SWRevealViewController *revealController = [self revealViewController];
    revealController.delegate = self;
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController
                                                                        action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    /*
    MRCustomTabBar *tabBarView = (MRCustomTabBar*)[MRCommon createTabBarView:self.view];
    [tabBarView setNavigationController:self.navigationController];
    [tabBarView setServeViewController:self];
    [tabBarView updateActiveViewController:self andTabIndex:DoctorPlusTabServe];
    
    self.tabBarView = (UIView*)tabBarView;
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.bgView
                                                                        attribute:NSLayoutAttributeBottomMargin
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0 constant:0];
    
    [self.view addConstraint:bottomConstraint];
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MRCommon applyNavigationBarStyling:self.navigationController];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)connectButtonTapped {
    MRContactsViewController* contactsViewCont = [[MRContactsViewController alloc] initWithNibName:@"MRContactsViewController" bundle:nil];
    MRGroupsListViewController* groupsListViewController = [[MRGroupsListViewController alloc] initWithNibName:@"MRGroupsListViewController" bundle:[NSBundle mainBundle]];
    contactsViewCont.groupsListViewController = groupsListViewController;
    
    [self.navigationController pushViewController:contactsViewCont animated:NO];
}

- (void)transformButtonTapped {
    MRTransformViewController *notiFicationViewController = [[MRTransformViewController alloc] initWithNibName:@"MRTransformViewController" bundle:nil];
    [self.navigationController pushViewController:notiFicationViewController animated:NO];
}

- (void)shareButtonTapped {
    MRMyWallViewController* contactsViewCont = [[MRMyWallViewController alloc] initWithNibName:@"MRMyWallViewController" bundle:nil];
    [self.navigationController pushViewController:contactsViewCont animated:NO];
}

@end

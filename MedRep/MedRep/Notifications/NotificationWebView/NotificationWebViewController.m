//
//  NotificationWebViewController.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/7/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "NotificationWebViewController.h"
#import "SWRevealViewController.h"
#import "MRAppControl.h"
#import "MRCommon.h"

@interface NotificationWebViewController () <SWRevealViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *companyLogoImage;
@property (weak, nonatomic) IBOutlet UIWebView *web;
@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *titleLogo;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *logoView;

@end

@implementation NotificationWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    SWRevealViewController *revealController = [self revealViewController];
    revealController.delegate = self;
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    NSDictionary *comapnyDetails = [[MRAppControl sharedHelper] getCompanyDetailsByID:[[self.selectedNotification objectForKey:@"companyId"] intValue]];
    self.companyLogoImage.image =  [MRCommon getImageFromBase64Data:[[comapnyDetails objectForKey:@"displayPicture"] objectForKey:@"data"]];
    
    self.navigationItem.title = _isFromTransform ? @"Details" : @"Notification Details";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    //self.notificationDetailsList = [self.selectedNotification objectForKey:@"notificationDetails"];
    self.titleLogo.text = [self.selectedNotification objectForKey:@"companyName"];
    self.titleLogo.hidden = YES;//[self.selectedNotification objectForKey:@"companyName"];
    
    [self loadNotificationDetails];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loadNotificationDetails
{
    self.notificationDetailsList = [[MRAppControl sharedHelper] getNotificationByCompanyID:[[self.selectedNotification objectForKey:@"companyId"] integerValue]];
    [_web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://medrep.in"]]];
}

- (void)backButtonAction
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

@end

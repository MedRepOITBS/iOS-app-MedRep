//
//  MRServeViewController.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/20/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRServeViewController.h"
#import "MRTabView.h"
#import "SWRevealViewController.h"
#import "MRContactsViewController.h"
#import "MRGroupsListViewController.h"
#import "PendingContactsViewController.h"
#import "MRShareViewController.h"
#import "MRTransformViewController.h"

@interface MRServeViewController () <MRTabViewDelegate, SWRevealViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *navView;

@end

@implementation MRServeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Serve";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
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

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"MRTabView" owner:self options:nil];
    MRTabView *tabView = (MRTabView *)[subviewArray objectAtIndex:0];
    tabView.delegate = self;
    tabView.serveView.backgroundColor = [UIColor colorWithRed:26/255.0 green:133/255.0 blue:213/255.0 alpha:1];
    [self.view addSubview:tabView];
    
    [tabView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:NSLayoutFormatAlignAllBottom metrics:nil views:@{@"view":tabView}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tabView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:tabView
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:50]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tabView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
}

- (void)connectButtonTapped {
    MRContactsViewController* contactsViewCont = [[MRContactsViewController alloc] initWithNibName:@"MRContactsViewController" bundle:nil];
    MRGroupsListViewController* groupsListViewController = [[MRGroupsListViewController alloc] initWithNibName:@"MRGroupsListViewController" bundle:[NSBundle mainBundle]];
    contactsViewCont.groupsListViewController = groupsListViewController;
    
    PendingContactsViewController *pendingViewController =[[PendingContactsViewController alloc] initWithNibName:@"PendingContactsViewController" bundle:[NSBundle mainBundle]];
    
    contactsViewCont.pendingContactsViewController = pendingViewController;
    [self.navigationController pushViewController:contactsViewCont animated:NO];
}

- (void)transformButtonTapped {
    MRTransformViewController *notiFicationViewController = [[MRTransformViewController alloc] initWithNibName:@"MRTransformViewController" bundle:nil];
    [self.navigationController pushViewController:notiFicationViewController animated:NO];
}

- (void)shareButtonTapped {
    MRShareViewController* contactsViewCont = [[MRShareViewController alloc] initWithNibName:@"MRShareViewController" bundle:nil];
    [self.navigationController pushViewController:contactsViewCont animated:NO];
}

@end

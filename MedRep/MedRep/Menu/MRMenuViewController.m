//
//  MRMenuViewController.m
//  MedRep
//
//  Created by MedRep Developer on 28/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRMenuViewController.h"
#import "SWRevealViewController.h"
#import "MRMenuTableViewCell.h"
#import "MRRegistationViewController.h"
#import "MRNotificationsViewController.h"
#import "MRMedRepMeetingsViewController.h"
#import "MRDatabaseHelper.h"
#import "MRAppControl.h"
#import "MRConstants.h"
#import "MRDashBoardVC.h"
#import "MRCommon.h"
#import "MRSurveyListViewController.h"
#import "MRProfileDetailsViewController.h"
#import "MRDoctorActivityScoreViewController.h"
#import "MRInviteViewController.h"
#import "MRTransformViewController.h"
#import "MRDrugSearchViewController.h"
#import "MRMarketingCampaignController.h"

#define kMenuList [NSArray arrayWithObjects:@"My Profile", @"Dashboard", @"Notifications", @"Surveys", @"Activities", @"Marketing Campaigns", @"MedRep Meeting", @"Discussion Forum", @"Search For Drugs", @"News & Updates", @"Invite Contacts",  @"Settings", @"Logout", nil]

#define kMenuListImages [NSArray arrayWithObjects:@"dashboard_menu@2x.png", @"Appointment", @"Survey", @"activity-score@2x.png", @"Advertising", @"meetings@2x.png", @"discussion-forum@2x.png", @"searc--for-drugs@2x.png", @"news@2x.png", @"Invite", @"setting@2x.png", @"logout@2x.png", nil]


@interface MRMenuViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *menuList;
@property (nonatomic, retain) NSDictionary *userData;
@end

@implementation MRMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userData = [MRAppControl sharedHelper].userRegData;
    if ([_menuList respondsToSelector:@selector(setSeparatorInset:)]) {
        [_menuList setSeparatorInset:UIEdgeInsetsZero];
        [_menuList setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        
    }

    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshMenu)
                                                 name:kNotificationRefreshMenu
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kMenuList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier                = @"MRMenuTableViewCell";
    MRMenuTableViewCell *regCell     = (MRMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (regCell == nil)
    {
        NSArray *nibViews                   = [[NSBundle mainBundle] loadNibNamed:@"MRMenuTableViewCell" owner:nil options:nil];
        regCell                           = (MRMenuTableViewCell *)[nibViews lastObject];
        
    }
    
    if (indexPath.row == 0)
    {
        regCell.cellIcon.clipsToBounds = YES;
        regCell.cellIcon.layer.cornerRadius = 15.0;
        regCell.cellIcon.layer.borderWidth = 1.0;
        regCell.cellIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    else
    {
        regCell.cellIcon.layer.cornerRadius = 0.0;
        regCell.cellIcon.layer.borderWidth =0.0;
        regCell.cellIcon.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    if ((indexPath.row == 0))
    {
        if ([self.userData objectForKey:KProfilePicture])
        {
            
            
            
            
            
            NSURL * imageURL = [NSURL URLWithString:[self.userData objectForKey:KProfilePicture]];
            

            UIImage *image;
            if (indexPath.row>0) {
                image = [UIImage imageNamed:[kMenuListImages objectAtIndex:indexPath.row -1]];
                if (image == nil) {
                    image = [UIImage imageNamed:@"profileIcon.png"];
                }else{
                    
                    regCell.cellIcon.image = image;
                    
                }
 
            
            }else {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(queue, ^{
                    NSData *data = [NSData dataWithContentsOfURL:imageURL];
                    UIImage *image = [UIImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (image!=nil) {
                            regCell.cellIcon.image = image;
                        }else{
                            regCell.cellIcon.image = [UIImage imageNamed:@"profileIcon.png"];
                        }
                        
             
                    });
                });
            }
            
            
            
            
            
            
            
        }
        else
        {
            regCell.cellIcon.image = [UIImage imageNamed:@"profileIcon.png"];
        }
    }
    else
    {
        regCell.cellIcon.image = [UIImage imageNamed:[kMenuListImages objectAtIndex:indexPath.row -1]];
    }
    
    regCell.menuTitle.text = [kMenuList objectAtIndex:indexPath.row];
    
    if (indexPath.row ==7 || indexPath.row ==11) {
        regCell.menuTitle.alpha = 0.5f;
    }
    else {
        regCell.menuTitle.alpha = 1.0f;
    }
    
    return regCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWRevealViewController *revealController = self.revealViewController;
    UINavigationController *frontNavigationController = (id)revealController.frontViewController;
    NSInteger row = indexPath.row;
    
    switch (row)
    {
        case 0:
        {
            if (![frontNavigationController.topViewController isKindOfClass:[MRRegistationViewController class]])
            {
//                MRRegistationViewController *regViewController = [[MRRegistationViewController alloc] initWithNibName:@"MRRegistationViewController" bundle:nil];
//                regViewController.isFromSinUp = NO;
                
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ProfileStoryboard" bundle:nil];
                MRProfileDetailsViewController *profViewController = [sb instantiateInitialViewController];
                
//                MRProfileDetailsViewController *profViewController = [[MRProfileDetailsViewController alloc] initWithNibName:@"AddExperienceTableViewController" bundle:nil];
                profViewController.isFromSinUp = NO;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:profViewController];
                [revealController pushFrontViewController:navigationController animated:YES];
            }
            else
            {
                [revealController revealToggle:self];
            }
        }
            break;
        case 1:
        {
            if (![frontNavigationController.topViewController isKindOfClass:[MRDashBoardVC class]])
            {
                MRDashBoardVC *dashboardViewCont = [[MRDashBoardVC alloc] initWithNibName:@"MRDashBoardVC" bundle:nil];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dashboardViewCont];
                [revealController pushFrontViewController:navigationController animated:YES];
            }
            else
            {
                [revealController revealToggle:self];
            }
        }
            break;
        case 2:
        {
            if (![frontNavigationController.topViewController isKindOfClass:[MRNotificationsViewController class]])
            {
                MRNotificationsViewController *notifications = [[MRNotificationsViewController alloc] initWithNibName:@"MRNotificationsViewController" bundle:nil];
                notifications.isFromMenu = YES;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:notifications];
                [revealController pushFrontViewController:navigationController animated:YES];
            }
            else
            {
                [revealController revealToggle:self];
            }
        }
            break;
        case 3:
        {
            if (![frontNavigationController.topViewController isKindOfClass:[MRSurveyListViewController class]])
            {
                MRSurveyListViewController *surveyListViewController = [[MRSurveyListViewController alloc] initWithNibName:@"MRSurveyListViewController" bundle:nil];
                surveyListViewController.isFromMenu = YES;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:surveyListViewController];
                [revealController pushFrontViewController:navigationController animated:YES];
            }
            else
            {
                [revealController revealToggle:self];
            }
        }
            break;
        case 4:
        {
           // [MRCommon showAlert:kComingsoonMSG delegate:nil];
            
            if ( ![frontNavigationController.topViewController isKindOfClass:[MRDoctorActivityScoreViewController class]] )
            {
                MRDoctorActivityScoreViewController *activityScoreViewController = [[MRDoctorActivityScoreViewController alloc] initWithNibName:@"MRDoctorActivityScoreViewController" bundle:nil];
                activityScoreViewController.isFromMenu = YES;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:activityScoreViewController];
                [revealController pushFrontViewController:navigationController animated:YES];
            }
            else
            {
                [revealController revealToggle:self];
            }
        }
            break;
        case 5:
        {
            if ( ![frontNavigationController.topViewController isKindOfClass:[MRMarketingCampaignController class]] )
            {
                MRMarketingCampaignController *marketingCampignViewController = [[MRMarketingCampaignController alloc] initWithNibName:@"MRMarketingCampaignController" bundle:nil];
                
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:marketingCampignViewController];
                [revealController pushFrontViewController:navigationController animated:YES];
            }
            else
            {
                [revealController revealToggle:self];
            }
        }
            break;
        case 6:
        {
            if ( ![frontNavigationController.topViewController isKindOfClass:[MRMedRepMeetingsViewController class]] )
            {
                MRMedRepMeetingsViewController *medrepMeetings = [[MRMedRepMeetingsViewController alloc] initWithNibName:@"MRMedRepMeetingsViewController" bundle:nil];
                medrepMeetings.isFromMenu = YES;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:medrepMeetings];
                [revealController pushFrontViewController:navigationController animated:YES];
            }
            else
            {
                [revealController revealToggle:self];
            }
        }
            break;
        case 7:
        {
            //[MRCommon showAlert:kComingsoonMSG delegate:nil];
        }
            break;
        case 8:
        {
            // Search For Drugs
            if ( ![frontNavigationController.topViewController isKindOfClass:[MRDrugSearchViewController class]] )
            {
                MRDrugSearchViewController *drugSearchViewController =
                [[MRDrugSearchViewController alloc] initWithNibName:@"MRDrugSearchViewController" bundle:nil];
                
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:drugSearchViewController];
                [revealController pushFrontViewController:navigationController animated:YES];
            }
            else
            {
                [revealController revealToggle:self];
            }
        }
            break;
        case 9:
        {
            // Transform Page -> News & Updates
            if ( ![frontNavigationController.topViewController isKindOfClass:[MRTransformViewController class]] )
            {
                MRTransformViewController *transformViewController =
                                [[MRTransformViewController alloc] initWithNibName:@"MRTransformViewController" bundle:nil];
                
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:transformViewController];
                [revealController pushFrontViewController:navigationController animated:YES];
            }
            else
            {
                [revealController revealToggle:self];
            }
        }
            break;
        case 10:
        {
            if (![frontNavigationController.topViewController isKindOfClass:[MRInviteViewController class]])
            {
                
                /*
                MRInviteViewController *notifications = [[MRInviteViewController alloc] initWithNibName:@"MRInviteViewController" bundle:nil];
                notifications.isFromMenu = YES;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:notifications];
                [revealController pushFrontViewController:navigationController animated:YES];
           */
                [MRAppControl invokeInviteContact:self];

            } else {
                [revealController revealToggle:self];
            }
        }
            break;
        case 11:
        {
            //[MRCommon showAlert:kComingsoonMSG delegate:nil];
        }
            break;
        case 12:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(loadLoginView)]) {
                [MRCommon removedTokens];
                [MRDatabaseHelper cleanDatabaseOnLogout];
                [self.delegate loadLoginView];
            }
        }
            break;
     
        default:
            break;
    }
}

- (void)loadDashboard
{
    SWRevealViewController *revealController = self.revealViewController;

    MRDashBoardVC *dashboardViewCont = [[MRDashBoardVC alloc] initWithNibName:@"MRDashBoardVC" bundle:nil];
    
    UINavigationController *dashboardNavCont = [[UINavigationController alloc] initWithRootViewController:dashboardViewCont];
    [revealController pushFrontViewController:dashboardNavCont animated:YES];
}

- (void)loadAppointmentList
{
    SWRevealViewController *revealController = self.revealViewController;

    MRMedRepMeetingsViewController *medrepMeetings = [[MRMedRepMeetingsViewController alloc] initWithNibName:@"MRMedRepMeetingsViewController" bundle:nil];
     medrepMeetings.isFromMenu = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:medrepMeetings];
    [revealController pushFrontViewController:navigationController animated:YES];

}

- (void)refreshMenu {
    [self.menuList reloadData];
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

//
//  MRPharmaMenuViewController.m
//  MedRep
//
//  Created by MedRep Developer on 27/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRPharmaMenuViewController.h"
#import "SWRevealViewController.h"
#import "MRPharmaMenuCell.h"
#import "MRRegistationViewController.h"
#import "MRAppControl.h"
#import "MRConstants.h"
#import "MRCommon.h"
#import "MRPHDashBoardViewController.h"
#import "MRSurveyListViewController.h"
#import "MRDatabaseHelper.h"
#import "MRMedRepViewController.h"
#import "MRDocotrActivityScoreViewController.h"
#import "MRNewProductCompaignsViewController.h"
#import "MRProfileDetailsViewController.h"

#define kMenuList [NSArray arrayWithObjects:@"My Profile", @"Dashboard", @"Product Campaigns", @"Doctor Activity Score", @"Surveys", @"MedRep", @"Other Marketing Campaigns", @"Drug Sales", @"Prescription Activites", @"News & Updates", @"Settings & Preferences", @"Logout", nil]

#define kMenuListImages [NSArray arrayWithObjects:@"dashboard_menu@2x.png", @"PHproductcampaigns@2x.png", @"activity-score@2x.png", @"surveys@2x.png", @"PHmedrep@2x.png", @"marketing@2x.png", @"PHdrugsales@2x.png", @"PHprescription@2x.png", @"news@2x.png", @"setting@2x.png", @"logout@2x.png", nil]

@interface MRPharmaMenuViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *menuList;
@property (nonatomic, retain) NSDictionary *userData;

@end

@implementation MRPharmaMenuViewController

- (void)viewDidLoad {
    
    self.userData = [MRAppControl sharedHelper].userRegData;
    if ([_menuList respondsToSelector:@selector(setSeparatorInset:)]) {
        [_menuList setSeparatorInset:UIEdgeInsetsZero];
        [_menuList setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        
    }

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    NSString *CellIdentifier                = @"MRPharmaMenuCell";
    MRPharmaMenuCell *regCell     = (MRPharmaMenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (regCell == nil)
    {
        NSArray *nibViews                   = [[NSBundle mainBundle] loadNibNamed:@"MRPharmaMenuCell" owner:nil options:nil];
        regCell                           = (MRPharmaMenuCell *)[nibViews lastObject];
        
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
            regCell.cellIcon.image = (indexPath.row > 0) ? [UIImage imageNamed:[kMenuListImages objectAtIndex:indexPath.row -1]] : [MRCommon getImageFromBase64Data:[self.userData objectForKey:KProfilePicture]];
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
    
    if (indexPath.row == 4 || indexPath.row == 6 || indexPath.row ==7 || indexPath.row ==8 || indexPath.row ==9 || indexPath.row ==10) {
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
                MRProfileDetailsViewController *profViewController = [[MRProfileDetailsViewController alloc] initWithNibName:@"MRProfileDetailsViewController" bundle:nil];
                profViewController.isFromSinUp = NO;
                
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:profViewController];
                navigationController.navigationBarHidden = YES;
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
            if (![frontNavigationController.topViewController isKindOfClass:[MRPHDashBoardViewController class]])
            {
                MRPHDashBoardViewController *dashboardViewCont = [[MRPHDashBoardViewController alloc] initWithNibName:[MRCommon nibNameForDevice:@"MRPHDashBoardViewController"] bundle:nil];
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
            if (![frontNavigationController.topViewController isKindOfClass:[MRNewProductCompaignsViewController class]])
            {
                MRNewProductCompaignsViewController *prodcutCompaignsVC =[[MRNewProductCompaignsViewController alloc] initWithNibName:@"MRNewProductCompaignsViewController" bundle:nil];
                prodcutCompaignsVC.isFromMenu = YES;

//                MRProductCompaignsViewController *prodcutCompaignsVC =[[MRProductCompaignsViewController alloc] initWithNibName:@"MRProductCompaignsViewController" bundle:nil];
//                prodcutCompaignsVC.isFromMenu = YES;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:prodcutCompaignsVC];
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
            if (![frontNavigationController.topViewController isKindOfClass:[MRDocotrActivityScoreViewController class]])
            {
                MRDocotrActivityScoreViewController *prodcutCompaignsVC =[[MRDocotrActivityScoreViewController alloc] initWithNibName:@"MRDocotrActivityScoreViewController" bundle:nil];
                prodcutCompaignsVC.isFromMenu = YES;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:prodcutCompaignsVC];
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
            //[MRCommon showAlert:kComingsoonMSG delegate:nil];
        }
            break;
        case 5:
        {
            if (![frontNavigationController.topViewController isKindOfClass:[MRMedRepViewController class]])
            {
                MRMedRepViewController *repViewController = [[MRMedRepViewController alloc] initWithNibName:@"MRMedRepViewController" bundle:nil];
                repViewController.isRepAppointments = NO;
                repViewController.showAppointmentsList = NO;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:repViewController];
                [revealController pushFrontViewController:navigationController animated:YES];
            }
            else
            {
                [revealController revealToggle:self];
            }

            //[MRCommon showAlert:kComingsoonMSG delegate:nil];
        }
            break;
        case 6:
        {
            //[MRCommon showAlert:kComingsoonMSG delegate:nil];
        }
            break;
        case 7:
        {
            //[MRCommon showAlert:kComingsoonMSG delegate:nil];
        }
            break;
        case 8:
        {
           // [MRCommon showAlert:kComingsoonMSG delegate:nil];
        }
            break;
        case 9:
        {
            //[MRCommon showAlert:kComingsoonMSG delegate:nil];
        }
            break;
        case 10:
        {
            //[MRCommon showAlert:kComingsoonMSG delegate:nil];
        }
            break;
        case 11:
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

- (void)showPharmaDashboard
{
    SWRevealViewController *revealController = self.revealViewController;
    
    MRPHDashBoardViewController *dashboardViewCont = [[MRPHDashBoardViewController alloc] initWithNibName:[MRCommon nibNameForDevice:@"MRPHDashBoardViewController"] bundle:nil];
    
    UINavigationController *dashboardNavCont = [[UINavigationController alloc] initWithRootViewController:dashboardViewCont];
    [revealController pushFrontViewController:dashboardNavCont animated:YES];
}

- (void)loadAppointmentList
{
    SWRevealViewController *revealController = self.revealViewController;
    
    MRMedRepViewController *repViewController = [[MRMedRepViewController alloc] initWithNibName:@"MRMedRepViewController" bundle:nil];
    repViewController.isRepAppointments = NO;
    repViewController.showAppointmentsList = NO;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:repViewController];
    [revealController pushFrontViewController:navigationController animated:YES];
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

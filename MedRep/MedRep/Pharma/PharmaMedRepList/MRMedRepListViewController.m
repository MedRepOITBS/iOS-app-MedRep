//
//  MRProductCompaignsViewController.m
//  Gravity
//
//  Created by Apple on 26/09/15.
//  Copyright © 2015 Sprim. All rights reserved.
//

#import "MRMedRepListViewController.h"
#import "SWRevealViewController.h"
#import "MRMedRepListTableCell.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRNewProductCompaignsViewController.h"
#import "MRWebserviceHelper.h"
#import "MRMedRepDetailsViewController.h"
#import "MRAppControl.h"


@interface MRMedRepListViewController ()<UITableViewDataSource,MRMedRepListTableCellDelegate,UITableViewDelegate>
{
   
}

@property (weak, nonatomic) IBOutlet UIImageView *companyImage;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *pcTableView;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (strong, nonatomic) IBOutlet UIView *navView;
@property (retain, nonatomic)  NSArray *dataSourceArray;
@end

@implementation MRMedRepListViewController


- (void)getMenuNavigationButtonWithController:(SWRevealViewController *)revealViewCont NavigationItem:(UINavigationItem *)navigationItem1
{
    SWRevealViewController *revealController = revealViewCont;
    //[NSArray arrayWithObjects:@"pcselect@2x.png",@"pcfedback@2x.png",@"pcplus@2x.png",nil];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.companyImage.image = [[MRAppControl sharedHelper] getCompanyImage];

    
    revealButtonItem.tintColor = [UIColor blackColor];
    navigationItem1.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.title = @"ProductCompaignsView";
    
//    dataSourceArray = @[@"Track New Product Notifications",@"Doctor Feedback",@"See all product Notifications"];
//    
    
    [self getMenuNavigationButtonWithController:[self revealViewController] NavigationItem:self.navigationItem];
    [self callServiceCompletedUpcomingAppointment];
    // Do any additional setup after loading the view from its nib.
}

- (void)callServiceCompletedUpcomingAppointment
{
    [MRCommon showActivityIndicator:@"Loading..."];
    
    [[MRWebserviceHelper sharedWebServiceHelper] getMyteam:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            [MRCommon stopActivityIndicator];
            self.dataSourceArray = [responce objectForKey:kResponce];
            [self.pcTableView reloadData];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getMyteam:^(BOOL status, NSString *details, NSDictionary *responce)
                  {
                      if (status)
                      {
                          [MRCommon stopActivityIndicator];
                          self.dataSourceArray = [responce objectForKey:kResponce];
                          [self.pcTableView reloadData];
                      }
                  }];
                 
             }];
        }
        // NSLog(@"responce %@",responce);
    }];
}
- (IBAction)backButttonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Table View Data Source ---

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *medrepCellId = @"medrepCellListIdentity";
    
    MRMedRepListTableCell *medrepCell = [tableView dequeueReusableCellWithIdentifier:medrepCellId];
    
    if (medrepCell == nil)
    {
        NSArray *bundleCell = [[NSBundle mainBundle] loadNibNamed:@"MRMedRepListTableCell" owner:nil options:nil];
        medrepCell = (MRMedRepListTableCell *)[bundleCell lastObject];
        medrepCell.delegate = self;
    }
    NSDictionary *dict = [self.dataSourceArray objectAtIndex:indexPath.row];
    medrepCell.cellTitleLabel.text = [NSString stringWithFormat:@"%@ %@", [dict objectForKey:@"firstName"],[dict objectForKey:@"lastName"]];
    
    return medrepCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if (indexPath.row == 0)
    {
        MRMedRepDetailsViewController *repDeatils = [[MRMedRepDetailsViewController alloc] initWithNibName:@"MRMedRepDetailsViewController" bundle:nil];
        repDeatils.doctorDetalsDictionlay = [self.dataSourceArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:repDeatils animated:YES];
    }
}

- (void)accessoryButtonDelegationAction:(MRMedRepListTableCell *)tCell
{
//    NSString *kTitle = @"Doctor Appointment";
//    NSString *kDesc = @"Family Monthly Health Check up Appointment";
//    NSDate *kAppointDate = [NSDate date];
//    
//    [MRCommon syncEventInCalenderAlongWithEventTitle:kTitle withDescription:kDesc eventDate:kAppointDate];
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

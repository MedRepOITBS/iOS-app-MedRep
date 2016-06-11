//
//  MRCompetitorAnalasysViewController.m
//  MedRep
//
//  Created by MedRep Developer on 28/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRCompetitorAnalasysViewController.h"
#import "MRDoctorScoreViewController.h"
#import "SWRevealViewController.h"
#import "MRCompetitorAnalasysCell.h"

@interface MRCompetitorAnalasysViewController ()<UITableViewDataSource,UITableViewDelegate, SWRevealViewControllerDelegate>
{
    NSArray *dataSourceArray;
    NSArray *timeArray;
}

@property (weak, nonatomic) IBOutlet UIImageView *companyImage;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *pcTableView;

@property (strong, nonatomic) IBOutlet UIView *navView;
@end

@implementation MRCompetitorAnalasysViewController

- (void)getMenuNavigationButtonWithController:(SWRevealViewController *)revealViewCont NavigationItem:(UINavigationItem *)navigationItem1
{
    SWRevealViewController *revealController = revealViewCont;
    revealController.delegate = self;
    //[NSArray arrayWithObjects:@"pcselect@2x.png",@"pcfedback@2x.png",@"pcplus@2x.png",nil];
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
    
    dataSourceArray = @[@"Competitor 1",@"Competitor 2",@"Competitor 3"];
    
    timeArray = @[@"230",@"130",@"58"];
    
    [self getMenuNavigationButtonWithController:[self revealViewController] NavigationItem:self.navigationItem];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *productCelId = @"productCellIdentity";
    
    MRCompetitorAnalasysCell *productCell = (MRCompetitorAnalasysCell*)[tableView dequeueReusableCellWithIdentifier:productCelId];
    
    if (productCell == nil)
    {
        NSArray *bundleCell = [[NSBundle mainBundle] loadNibNamed:@"MRCompetitorAnalasysCell" owner:nil options:nil];
        productCell = (MRCompetitorAnalasysCell *)[bundleCell lastObject];
    }
    productCell.competitorName.text = [dataSourceArray objectAtIndex:indexPath.row];
    productCell.competitorScore.text = [timeArray objectAtIndex:indexPath.row];
    
    return productCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MRDoctorScoreViewController *doctorDetails = [[MRDoctorScoreViewController alloc] initWithNibName:@"MRDoctorScoreViewController" bundle:nil];
    [self.navigationController pushViewController:doctorDetails animated:YES];

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

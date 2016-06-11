//
//  MRRegistrationRoleViewController.m
//  MedRep
//
//  Created by MedRep Developer on 28/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRRegistrationRoleViewController.h"
#import "MRRegistrationRoleCellTableViewCell.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MROTPViewController.h"
#import "MRConstants.h"
#import "MRWebserviceHelper.h"

#define kRoleName   [NSArray arrayWithObjects: @"Head of Sales & Marketing", @"Category / Therapeutic\n Area Manager", @"Area Manager", @"Medical Representative", nil]

@interface MRRegistrationRoleViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UITableView *registrationTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) NSMutableDictionary *userDeatils;


@end

@implementation MRRegistrationRoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userDeatils = [[MRAppControl sharedHelper] userRegData];
    [self setUPView];

    self.registrationTable.contentInset = UIEdgeInsetsMake(-30, 0, 0, -20);
    
    

    // Do any additional setup after loading the view from its nib.
}

-(void)setUPView
{
    if ([MRCommon deviceHasFourInchScreen])
    {
        self.bottomConstraint.constant = 30;
    }
    else if ([MRCommon deviceHasFourPointSevenInchScreen])
    {
        self.bottomConstraint.constant = 50;
    }
    else if ([MRCommon deviceHasFivePointFiveInchScreen])
    {
        self.bottomConstraint.constant = 50;
    }
    
}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextButtonAction:(id)sender
{
    MROTPViewController *otpViewController = [[MROTPViewController alloc] initWithNibName:@"MROTPViewController" bundle:nil];
    otpViewController.isFromSinUp = self.isFromSinUp;
    [self.navigationController pushViewController:otpViewController animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kRoleName.count;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier                = @"MRRegistrationRoleCellTableViewCell";
    MRRegistrationRoleCellTableViewCell *regCell     = (MRRegistrationRoleCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (regCell == nil)
    {
        NSArray *nibViews                   = [[NSBundle mainBundle] loadNibNamed:@"MRRegistrationRoleCellTableViewCell" owner:nil options:nil];
        regCell                           = (MRRegistrationRoleCellTableViewCell *)[nibViews lastObject];
        
    }
    
    regCell.roleText.text = [kRoleName objectAtIndex:indexPath.row];
    
    return regCell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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

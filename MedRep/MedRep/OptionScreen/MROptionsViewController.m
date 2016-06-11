//
//  MROptionsViewController.m
//  MedRep
//
//  Created by MedRep Developer on 16/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MROptionsViewController.h"
#import "MRRegistationViewController.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRRegistationTwoViewController.h"

@interface MROptionsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *patientButton;
@property (weak, nonatomic) IBOutlet UIButton *pharmacyButton;
@property (weak, nonatomic) IBOutlet UIButton *companyButton;
@property (weak, nonatomic) IBOutlet UIButton *doctorButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@end

@implementation MROptionsViewController

- (void)viewDidLoad {
    [MRAppControl sharedHelper].userType = 2;
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)nextButtonAction:(id)sender
{
    MRRegistationViewController *regViewController = [[MRRegistationViewController alloc] initWithNibName:@"MRRegistationViewController" bundle:nil];
    regViewController.isFromSinUp = YES;
    [self.navigationController pushViewController:regViewController animated:YES];
    
//    MRRegistationTwoViewController *regTwoViewController = [[MRRegistationTwoViewController alloc] initWithNibName:@"MRRegistationTwoViewController" bundle:nil];
//    regTwoViewController.isFromSinUp = YES;
//    regTwoViewController.isFromEditing = NO;
//    regTwoViewController.registrationStage = 1;
//    [self.navigationController pushViewController:regTwoViewController animated:YES];

}

- (IBAction)doctorButtonAction:(id)sender {
    [self resetButtonStatus];
    [[MRAppControl sharedHelper].userRegData setObject:@"" forKey:KDoctorRegID];
    [MRAppControl sharedHelper].userType = 2;
    NSString *btnName = @"radioSelection@2x.png";
    [self.doctorButton setBackgroundImage:[UIImage imageNamed:btnName] forState:UIControlStateNormal];
}

- (IBAction)companyButtonAction:(id)sender {
    [MRCommon showAlert:kCompanyAccessMSG delegate:self];
//    [self resetButtonStatus];
//    [MRAppControl sharedHelper].userType = 2;
//    NSString *btnName = @"radioSelection@2x.png";
//    [self.companyButton setBackgroundImage:[UIImage imageNamed:btnName] forState:UIControlStateNormal];
}

- (IBAction)pharmacyButtonAction:(id)sender
{
    //[MRCommon showAlert:kComingsoonMSG delegate:self];
//    return;
//    [self resetButtonStatus];
//    [[MRAppControl sharedHelper].userRegData setObject:[NSNumber numberWithInteger:0] forKey:KDoctorRegID];
//
//    [MRAppControl sharedHelper].userType = 3;
//    NSString *btnName = @"radioSelection@2x.png";
//    [self.pharmacyButton setBackgroundImage:[UIImage imageNamed:btnName] forState:UIControlStateNormal];
}

- (IBAction)patientButtonAction:(id)sender
{
   // [MRCommon showAlert:kComingsoonMSG delegate:self];
//    [self resetButtonStatus];
//    [MRAppControl sharedHelper].userType = 4;
//    NSString *btnName = @"radioSelection@2x.png";
//    [self.patientButton setBackgroundImage:[UIImage imageNamed:btnName] forState:UIControlStateNormal];
}


- (void)resetButtonStatus
{
    NSString *btnName = @"radioUnSelection@2x.png";
    [self.doctorButton setBackgroundImage:[UIImage imageNamed:btnName] forState:UIControlStateNormal];
    [self.patientButton setBackgroundImage:[UIImage imageNamed:btnName] forState:UIControlStateNormal];
    [self.pharmacyButton setBackgroundImage:[UIImage imageNamed:btnName] forState:UIControlStateNormal];
    [self.companyButton setBackgroundImage:[UIImage imageNamed:btnName] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

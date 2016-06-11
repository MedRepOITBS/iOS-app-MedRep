//
//  MRLoginViewController.m
//  MedRep
//
//  Created by MedRep Developer on 16/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRLoginViewController.h"
#import "MRWelcomeViewController.h"
#import "MRAppControl.h"
#import "MRWebserviceHelper.h"
#import "MRConstants.h"
#import "MRCommon.h"
#import "MROTPVerifiedViewController.h"
#import "MRForgotPasswordViewController.h"

@interface MRLoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *loginInputView;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxtField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewButtonConstraint; //145 , 300
@property (weak, nonatomic) IBOutlet UIButton *homeButton;

@end

@implementation MRLoginViewController

- (void)viewDidLoad
{
//    self.emailTextField.text   = @"sateeshoruganti@gmail.com";
//    self.passwordTxtField.text = @"medrep";

//    ravish.jha2@dummy.com
//    password
    
//    self.emailTextField.text      = @"ravish.jha2@dummy.com";
//    self.passwordTxtField.text    = @"password";

//    self.emailTextField.text      = @"rajesh.rallabandi008@gmail.com";
//    self.passwordTxtField.text    = @"passpwrd12345";
    
//    self.emailTextField.text      = @"sam@gmail.com";
//    self.passwordTxtField.text    = @"rest";
    
//      self.emailTextField.text      = @"rep2@dummy.com";
//      self.passwordTxtField.text    = @"password";
//
   
//    self.emailTextField.text      = @"rajesh.mca008@gmail.com";
//    self.passwordTxtField.text    = @"password";
    
//    self.emailTextField.text      = @"milan.hoogan@gmail.com";
//    self.passwordTxtField.text    = @"qqqq";

//    self.emailTextField.text      = @"Rep1@sain.com";
//    self.passwordTxtField.text    = @"password";
    
//    self.emailTextField.text      = @"Manager@sain.com";
//    self.passwordTxtField.text    = @"manager";

//    self.emailTextField.text      = @"ssreddy013@gmail.com";
//    self.passwordTxtField.text    = @"test";
    
//    self.emailTextField.text      = @"Rep@erfolg.com";
//    self.passwordTxtField.text    = @"password";
    
//    self.emailTextField.text      = @"Manager@erfolg.com";
//    self.passwordTxtField.text    = @"manager";


    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signinButtonAction:(id)sender
{
    if ([self validateFields])
    {
        [MRCommon showActivityIndicator:@"Processing..."];
        [[MRWebserviceHelper sharedWebServiceHelper] userLogin:self.emailTextField.text andPasword:self.passwordTxtField.text withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
            if (status)
            {
                [MRCommon setLoginEmail:self.emailTextField.text];
                [MRCommon savetokens:responce];
                [[MRWebserviceHelper sharedWebServiceHelper] getMyRole:^(BOOL status, NSString *details, NSDictionary *responce) {
                    
                    if (status)
                    {
                        [MRCommon stopActivityIndicator];

                        [MRAppControl sharedHelper].userType = [[responce objectForKey:@"roleId"] integerValue];
                        [MRCommon setUserType:[MRAppControl sharedHelper].userType];
                        
                        if ([[responce objectForKeyedSubscript:@"status"] isEqualToString:@"Not Verified"])
                        {
                            MROTPVerifiedViewController *otpViewController = [[MROTPVerifiedViewController alloc] initWithNibName:@"MROTPVerifiedViewController" bundle:nil];
                            otpViewController.isFromSinUp = NO;
                            [self.navigationController pushViewController:otpViewController animated:YES];

                        }
                        else
                        {
                            if ([MRAppControl sharedHelper].userType == 1 || [MRAppControl sharedHelper].userType == 2)
                            {
                                [[MRWebserviceHelper sharedWebServiceHelper] getDoctorProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
                                 {
                                     [MRCommon stopActivityIndicator];
                                     if (status)
                                     {
                                         [[MRAppControl sharedHelper] setUserDetails:responce];
                                         [[MRAppControl sharedHelper] loadDashboardScreen];
                                     }
                                 }];
                            }
                            else if ([MRAppControl sharedHelper].userType == 3 || [MRAppControl sharedHelper].userType == 4)
                            {
                                [[MRWebserviceHelper sharedWebServiceHelper] getPharmaProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
                                 {
                                     [MRCommon stopActivityIndicator];
                                     if (status)
                                     {
                                         [[MRAppControl sharedHelper] setUserDetails:responce];
                                         [[MRAppControl sharedHelper] loadDashboardScreen];
                                     }
                                 }];
                                
                            }
                        }
                    }
                    else
                    {
                        [MRCommon stopActivityIndicator];
                        NSArray *erros =  [details componentsSeparatedByString:@"-"];
                        if (erros.count > 0)
                            [MRCommon showAlert:[erros lastObject] delegate:nil];
                    }
                }];
            }
            else if (NO == [MRCommon isStringEmpty:details])
            {
                [MRCommon stopActivityIndicator];
                NSArray *erros =  [details componentsSeparatedByString:@"-"];
                if (erros.count > 0)
                [MRCommon showAlert:[erros lastObject] delegate:nil];
            }
        }];
    }

//    MRWelcomeViewController *welcomeViewController = [[MRWelcomeViewController alloc] initWithNibName:@"MRWelcomeViewController" bundle:nil];
//    welcomeViewController.delegate = [MRAppControl sharedHelper];
//    [self.navigationController pushViewController:welcomeViewController animated:YES];
}

- (BOOL)validateFields
{
    BOOL isValid = YES;
    
    if ([MRCommon isStringEmpty:self.emailTextField.text])
    {
        [MRCommon showAlert:@"E-Mail ID should not be empty." delegate:nil];
        isValid = NO;
    }
    else if ([MRCommon isStringEmpty:self.passwordTxtField.text])
    {
        [MRCommon showAlert:@"Password should not be empty." delegate:nil];
        isValid = NO;
    }
    
    return isValid;
}
- (IBAction)forgotPaswordButtonAction:(id)sender
{
    MRForgotPasswordViewController *forgotPassword = [[MRForgotPasswordViewController alloc] initWithNibName:@"MRForgotPasswordViewController" bundle:nil];
    [self.navigationController pushViewController:forgotPassword animated:YES];
}

- (IBAction)homeButtonAction:(id)sender
{
    [[MRAppControl sharedHelper] applyFadeAnimation];
    if (self.isFromHome)
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
    else
    {
        [[MRAppControl sharedHelper] loadHomeScreen];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self showHideFiltersView:self.inputViewButtonConstraint withAdjustableValue:250];

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self showHideFiltersView:self.inputViewButtonConstraint withAdjustableValue:145];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showHideFiltersView:(NSLayoutConstraint*)adjustableConstraint
        withAdjustableValue:(CGFloat)value
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.8f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    adjustableConstraint.constant = value;
    [self updateViewConstraints];
    [UIView commitAnimations];
}

@end

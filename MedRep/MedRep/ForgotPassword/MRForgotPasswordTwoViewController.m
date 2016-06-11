//
//  MRForgotPasswordTwoViewController.m
//  
//
//  Created by MedRep Developer on 12/12/15.
//
//

#import "MRForgotPasswordTwoViewController.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRWebserviceHelper.h"

@interface MRForgotPasswordTwoViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topAdjustment;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *otpTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *resendOTPButton;

@end

@implementation MRForgotPasswordTwoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitButtonAction:(id)sender
{
    if ([self validateData])
    {
        [MRCommon showActivityIndicator:@"Sending..."];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:self.emailText forKey:@"userName"];
        [dict setObject:self.otpTextField.text forKey:@"otp"];
        [dict setObject:self.passwordTextField.text  forKey:@"newPassword"];
        [dict setObject:self.confirmPasswordTextField.text  forKey:@"confirmPassword"];
        [dict setObject:@"SMS"  forKey:@"verificationType"];
        
        [[MRWebserviceHelper sharedWebServiceHelper] sendForgotPassword:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce)      {
            [MRCommon stopActivityIndicator];
            if (status)
            {
                [MRCommon showAlert:@"Your password has been update successfully." delegate:self withTag:1234];
            }
        }];
    }
}

- (BOOL)validateData
{
     BOOL isSuccess = YES;
    
    if ([MRCommon isStringEmpty:self.passwordTextField.text])
    {
        [MRCommon showAlert:@"New Password should not be empty." delegate:nil];
        isSuccess = NO;
        return isSuccess;
    }
    
    if ([MRCommon isStringEmpty:self.confirmPasswordTextField.text])
    {
        [MRCommon showAlert:@"Confirm Password should not be empty." delegate:nil];
        isSuccess = NO;
        return isSuccess;
    }
    
    if ([MRCommon isStringEmpty:self.otpTextField.text])
    {
        [MRCommon showAlert:@"OTP should not be empty." delegate:nil];
        isSuccess = NO;
        return isSuccess;
    }
    
    return isSuccess;
}

- (IBAction)resendOTPButtonAction:(id)sender
{
    [MRCommon showActivityIndicator:@"Sending..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getRecreateOTP:self.emailText withComplitionHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         [MRCommon stopActivityIndicator];
         if (status)
         {
             //self.otpString = [responce objectForKey:@"otp"];
           [MRCommon showAlert:@"OTP has been sent to your registered Email / Mobile number" delegate:nil];
         }
     }];
}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1234)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
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

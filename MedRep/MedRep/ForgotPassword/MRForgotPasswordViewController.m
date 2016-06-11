//
//  MRForgotPasswordViewController.m
//  
//
//  Created by MedRep Developer on 12/12/15.
//
//

#import "MRForgotPasswordViewController.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRWebserviceHelper.h"
#import "MRForgotPasswordTwoViewController.h"

@interface MRForgotPasswordViewController ()<UITextFieldDelegate>

@end

@implementation MRForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextButtonAction:(id)sender
{
    if (![MRCommon validateEmailWithString:self.emailTextField.text])
    {
        [MRCommon showAlert:@"Provide a valid email." delegate:nil];
    }
    else
    {
        [MRCommon showActivityIndicator:@"Sending..."];
        [[MRWebserviceHelper sharedWebServiceHelper] getRecreateOTP:self.emailTextField.text withComplitionHandler:^(BOOL status, NSString *details, NSDictionary *responce)
         {
             [MRCommon stopActivityIndicator];
             if (status)
             {
                 
                 MRForgotPasswordTwoViewController *forgotStageTwo = [[MRForgotPasswordTwoViewController alloc] initWithNibName:@"MRForgotPasswordTwoViewController" bundle:nil];
                 forgotStageTwo.emailText = self.emailTextField.text;
                 [self.navigationController pushViewController:forgotStageTwo animated:NO];
                 //self.otpString = [responce objectForKey:@"otp"];
//                 [MRCommon showAlert:[NSString stringWithFormat:@"OTP sent to %@",[MRCommon getUserPhoneNumber]] delegate:nil];
             }
         }];
    }

}

- (IBAction)homeButtonAction:(id)sender
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

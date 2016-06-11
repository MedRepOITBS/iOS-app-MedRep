//
//  MROTPVerifiedViewController.m
//  MedRep
//
//  Created by MedRep Developer on 03/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MROTPVerifiedViewController.h"
#import "MROTPViewController.h"
#import "MRWelcomeViewController.h"
#import "MRWebserviceHelper.h"
#import "MRCommon.h"
#import "MRAppControl.h"

@interface MROTPVerifiedViewController ()<UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *otpTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitButtonBottomConstraint;
@property (nonatomic, retain) NSString *otpString;
@property (weak, nonatomic) IBOutlet UILabel *otpverifiedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *otpTicmarkImage;

@end

@implementation MROTPVerifiedViewController

- (void)viewDidLoad {
    
    self.otpTicmarkImage.hidden = YES;
    self.otpverifiedLabel.hidden = YES;
    
    if (self.isFromSinUp)
    {
        [MRCommon showAlert:[NSString stringWithFormat:@"OTP sent to %@",[MRCommon getUserPhoneNumber]] delegate:nil];
    }
    else
    {
        [MRCommon showAlert:[NSString stringWithFormat:@"Verify your mobile number"] delegate:nil];
    }
    
    
//    [[MRWebserviceHelper sharedWebServiceHelper] getNewSMSOTP:[MRCommon getUserPhoneNumber] withComplitionHandler:^(BOOL status, NSString *details, NSDictionary *responce){
//        if (status)
//        {
//            /*
//             {"id":null,"otp":"77478","type":"MOBILE","verificationId":"9247204720","securityId":null,"status":"WAITING"}
//             */
//            // NSLog(@"%@", responce);
//            if (status)
//            {
//                self.otpString = [responce objectForKey:@"otp"];
//                [MRCommon showAlert:[NSString stringWithFormat:@"OTP sent to %@",[MRCommon getUserPhoneNumber]] delegate:nil];
//                //self.otpTextField.text = [responce objectForKey:@"otp"];
//            }
//        }
//    }];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitButtonAction:(id)sender
{
    [self.otpTextField resignFirstResponder];
    
    if (self.otpTextField.text.length < 6)
    {
        [MRCommon showAlert:@"OTP must be six digits." delegate:nil];
    }
    else
    {
        [MRCommon showActivityIndicator:@"Sending..."];
        [[MRWebserviceHelper sharedWebServiceHelper] verifyMobileNumber:[MRCommon getUserPhoneNumber] withOTP:self.otpTextField.text withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
            [MRCommon stopActivityIndicator];
            if (status)
            {
                self.otpTicmarkImage.hidden = NO;
                self.otpverifiedLabel.hidden = NO;
                
                self.otpTextField.text = @"";
                [MRCommon showAlert:@"OTP successfully verified." delegate:self withTag:1234];
            }
            else
            {
                //[MRCommon showAlert:@"OTP verification failed." delegate:nil];
            }
            
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.otpString isEqualToString:self.otpTextField.text])
    {
        self.otpTicmarkImage.hidden = NO;
        self.otpverifiedLabel.hidden = NO;
    }
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self showHideFiltersView:self.submitButtonBottomConstraint withAdjustableValue:210];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self showHideFiltersView:self.submitButtonBottomConstraint withAdjustableValue:80];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([MRCommon isStringEmpty:string]) return YES;
    
    if(textField.text.length == 6) return NO;

    unichar lastCharacter = [string characterAtIndex:0];
    if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:lastCharacter]) return YES;
    
    return NO;
}

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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1234) {
        MRWelcomeViewController *welcomeViewController = [[MRWelcomeViewController alloc] initWithNibName:@"MRWelcomeViewController" bundle:nil];
        welcomeViewController.delegate = [MRAppControl sharedHelper];
        welcomeViewController.isFromSinUp = self.isFromSinUp;
        [self.navigationController pushViewController:welcomeViewController animated:YES];
    }
}
- (IBAction)generateOTPButtonAction:(id)sender
{
    [MRCommon showActivityIndicator:@"Sending..."];
        [[MRWebserviceHelper sharedWebServiceHelper] getRecreateOTP:[MRCommon getLoginEmail] withComplitionHandler:^(BOOL status, NSString *details, NSDictionary *responce)
    {
        [MRCommon stopActivityIndicator];
                if (status)
                {
                    //self.otpString = [responce objectForKey:@"otp"];
                    [MRCommon showAlert:[NSString stringWithFormat:@"OTP sent to %@",[MRCommon getUserPhoneNumber]] delegate:nil];
                }
        }];
}
- (IBAction)homeButtonAction:(id)sender {
    
    if (self.isFromSinUp)
    {
        [[MRAppControl sharedHelper] applyFadeAnimation];
        [[MRAppControl sharedHelper] loadLoginView];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end

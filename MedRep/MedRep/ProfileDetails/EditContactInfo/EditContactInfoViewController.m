//
//  EditContactInfoViewController.m
//  MedRep
//
//  Created by Vamsi Katragadda on 8/26/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "EditContactInfoViewController.h"
#import "ContactInfo.h"
#import "MRDatabaseHelper.h"
#import "MRCommon.h"

@interface EditContactInfoViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic) NSString *currentText;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *mobileNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *alternateEmailTextField;

@property (nonatomic) UITextField *activeTextField;


@end

@implementation EditContactInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title  = @"Edit Contact Info";
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"]
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(backButtonTapped:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"DONE"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(doneButtonTapped:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [self setUpData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#define kOFFSET_FOR_KEYBOARD 80.0

-(void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height + 5;
    
    CGPoint referenceFrame = self.activeTextField.frame.origin;
    referenceFrame.y += 64;
    
    if (!CGRectContainsPoint(aRect, referenceFrame) ) {
        CGPoint scrollPoint = CGPointMake(0.0, (self.activeTextField.frame.origin.y + 50)-kbSize.height);
        if (scrollPoint.y > 0) {
            [self.scrollView setContentOffset:scrollPoint animated:YES];
        }
    }
}

-(void)keyboardWillHide:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonTapped:(id)sender {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    NSString *value = self.alternateEmailTextField.text;
    if (value != nil && value.length > 0) {
        [dictionary setObject:value forKey:@"alternateEmailId"];
    }
    
    value = self.emailTextField.text;
    if (value != nil && value.length > 0) {
        [dictionary setObject:value forKey:@"emailId"];
    }
    
    value = self.mobileNumberTextField.text;
    if (value != nil && value.length > 0) {
        [dictionary setObject:value forKey:@"mobileNo"];
    }
    
    value = self.phoneNumberTextField.text;
    if (value != nil && value.length > 0) {
        [dictionary setObject:value forKey:@"phoneNo"];
    }
    
    [MRDatabaseHelper editContactInfo:dictionary
                        andHandler:^(id result) {
                            if ([result caseInsensitiveCompare:@"success"] == NSOrderedSame) {
                                
                                [self.navigationController popViewControllerAnimated:YES];
                                [MRCommon showAlert:@"Contact Info updated successfully !!!"
                                           delegate:self
                                            withTag:500];
                            }else{
                                [MRCommon showAlert:@"Failed to update contact info" delegate:nil];
                            }
                        }];
}

- (void)setUpData {
    
    if (self.contactInfo != nil) {
        if (self.contactInfo.phoneNo != nil && self.contactInfo.phoneNo.length > 0) {
            self.phoneNumberTextField.text = self.contactInfo.phoneNo;
        }
        
        if (self.contactInfo.mobileNo != nil && self.contactInfo.mobileNo.length > 0) {
            self.mobileNumberTextField.text = self.contactInfo.mobileNo;
        }
        
        if (self.contactInfo.email != nil && self.contactInfo.email.length > 0) {
            self.emailTextField.text = self.contactInfo.email;
        }
        
        if (self.contactInfo.alternateEmail != nil && self.contactInfo.alternateEmail.length > 0) {
            self.alternateEmailTextField.text = self.contactInfo.alternateEmail;
        }
    }
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(closeOnKeyboardPressed:)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneOnKeyboardPressed:)],
                           nil];
    [numberToolbar sizeToFit];
    self.phoneNumberTextField.inputAccessoryView = numberToolbar;
    self.mobileNumberTextField.inputAccessoryView = numberToolbar;
    self.emailTextField.inputAccessoryView = numberToolbar;
    self.alternateEmailTextField.inputAccessoryView = numberToolbar;
}

- (void)closeOnKeyboardPressed:(id)sender {
    self.activeTextField.text = self.currentText;
    [self.activeTextField resignFirstResponder];
}

- (void)doneOnKeyboardPressed:(id)sender {
    [self.activeTextField resignFirstResponder];
}

#pragma mark - UITextField Delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
    self.currentText = textField.text;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeTextField = nil;
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 500) {
        [MRCommon showActivityIndicator:@"Loading..."];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshProfile
                                                            object:nil];
    }
    //code for opening settings app in iOS 8
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

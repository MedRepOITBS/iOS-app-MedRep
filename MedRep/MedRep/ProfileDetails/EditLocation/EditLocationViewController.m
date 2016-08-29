//
//  EditLocationViewController.m
//  MedRep
//
//  Created by Vamsi Katragadda on 8/25/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "EditLocationViewController.h"
#import "MRDatabaseHelper.h"
#import "MRCommon.h"
#import "AddressInfo.h"
#import "ContactInfo.h"


@interface EditLocationViewController () <UITextFieldDelegate>

@property (nonatomic) NSString *currentText;

@property (weak, nonatomic) IBOutlet UITextField *addressLine1;
@property (weak, nonatomic) IBOutlet UITextField *addressLine2;
@property (weak, nonatomic) IBOutlet UITextField *city;
@property (weak, nonatomic) IBOutlet UITextField *state;
@property (weak, nonatomic) IBOutlet UITextField *country;
@property (weak, nonatomic) IBOutlet UITextField *zipCode;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic) UITextField *activeTextField;

@end

@implementation EditLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title  = @"Edit Location";
    
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
//    if (self.contactInfo != nil) {
//        if (self.contactInfo.alternateEmail != nil && self.contactInfo.alternateEmail.length > 0) {
//            [dictionary setObject:self.contactInfo.alternateEmail forKey:@"alternateEmailId"];
//        }
//        
//        if (self.contactInfo.email != nil && self.contactInfo.email.length > 0) {
//            [dictionary setObject:self.contactInfo.email forKey:@"emailId"];
//        }
//        
//        if (self.contactInfo.mobileNo != nil && self.contactInfo.mobileNo.length > 0) {
//            [dictionary setObject:self.contactInfo.mobileNo forKey:@"mobileNo"];
//        }
//        
//        if (self.contactInfo.phoneNo != nil && self.contactInfo.phoneNo.length > 0) {
//            [dictionary setObject:self.contactInfo.phoneNo forKey:@"phoneNo"];
//        }
//    }
    
    NSMutableDictionary *locationDictionary = [NSMutableDictionary new];
    NSString *value = self.addressLine1.text;
    if (value != nil && value.length > 0) {
        [locationDictionary setObject:value forKey:@"address1"];
    }
    
    value = self.addressLine2.text;
    if (value != nil && value.length > 0) {
        [locationDictionary setObject:value forKey:@"address2"];
    }
    
    value = self.city.text;
    if (value != nil && value.length > 0) {
        [locationDictionary setObject:value forKey:@"city"];
    }
    
    value = self.country.text;
    if (value != nil && value.length > 0) {
        [locationDictionary setObject:value forKey:@"country"];
    }
    
    value = self.state.text;
    if (value != nil && value.length > 0) {
        [locationDictionary setObject:value forKey:@"state"];
    }
    
    value = self.zipCode.text;
    if (value != nil && value.length > 0) {
        [locationDictionary setObject:value forKey:@"zipcode"];
    }
    
    if (self.addressObject != nil && self.addressObject.locationId != nil) {
        [locationDictionary setObject:[NSNumber numberWithLong:self.addressObject.locationId.longValue]
                               forKey:@"locationId"];
    }
    
    NSArray *locationsArray = @[locationDictionary];
    
    [dictionary setObject:locationDictionary forKey:@"location"];

    [MRDatabaseHelper editLocation:locationsArray
                        andHandler:^(id result) {
        if ([result caseInsensitiveCompare:@"success"] == NSOrderedSame) {
            
            [MRCommon showAlert:@"Location updated successfully !!!" delegate:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshProfile
                                                                object:nil];
        }else{
            [MRCommon showAlert:@"Failed to update location" delegate:nil];
        }
    }];
}

- (void)setUpData {
    
    if (_addressObject!=nil) {
        _addressLine1.text = _addressObject.address1;
        _addressLine2.text = _addressObject.address2;
        _city.text = _addressObject.city;
        _state.text = _addressObject.state;
        _zipCode.text = _addressObject.zipcode;
        _country.text = _addressObject.country;
    }
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(closeOnKeyboardPressed:)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneOnKeyboardPressed:)],
                           nil];
    [numberToolbar sizeToFit];
    _addressLine1.inputAccessoryView = numberToolbar;
    _addressLine2.inputAccessoryView = numberToolbar;
    _city.inputAccessoryView = numberToolbar;
    _state.inputAccessoryView = numberToolbar;
    _zipCode.inputAccessoryView = numberToolbar;
    _country.inputAccessoryView = numberToolbar;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

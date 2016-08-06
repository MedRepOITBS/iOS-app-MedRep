//
//  MROTPViewController.m
//  MedRep
//
//  Created by MedRep Developer on 16/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MROTPViewController.h"
#import "MRWelcomeViewController.h"
#import "MROTPVerifiedViewController.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRWebserviceHelper.h"
#import "MRConstants.h"
#import "MRListViewController.h"
#import "WYPopoverController.h"
#import "KLCPopup.h"
#import "TutorialView.h"

@interface MROTPViewController ()<UITextFieldDelegate, UIAlertViewDelegate,WYPopoverControllerDelegate,MRListViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UITextField *desiredPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;
@property (strong, nonatomic) WYPopoverController *myPopoverController;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tickMarkTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tickMarkBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *therapeuticButton;
@property (weak, nonatomic) IBOutlet UIButton *yearRegButton;
@property (weak, nonatomic) IBOutlet UIButton *stateCouncilButton;
@property (strong,nonatomic) KLCPopup *tutorialViewKLCPopView;
@property (strong,nonatomic) TutorialView *tutorialView;
@end

@implementation MROTPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.therapeuticButton.layer.borderWidth = 1.0;
    self.therapeuticButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.yearRegButton.layer.borderWidth = 1.0;
    self.yearRegButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.stateCouncilButton.layer.borderWidth = 1.0;
    self.stateCouncilButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    if ([MRCommon deviceHasThreePointFiveInchScreen])
    {
        self.inputViewBottomConstraint.constant = 20;
        self.passwordBottomConstraint.constant = 160;
        [self updateViewConstraints];
    }
}
- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setupTutorialView{
    
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"TutorialView" owner:self options:nil];
    
    _tutorialView = (TutorialView *)[arr objectAtIndex:0];
    _tutorialView.layer.cornerRadius = 10;
    _tutorialViewKLCPopView = [KLCPopup popupWithContentView:self.tutorialView];
    [_tutorialViewKLCPopView showWithLayout:KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutCenter)];
}
-(IBAction)whyThisBtnTapped:(id)sender{
    [self setupTutorialView];
    
}


- (IBAction)submitButtonAction:(id)sender
{
    if ([self.therapeuticButton.titleLabel.text isEqualToString:@"Select Therapeutic Area"])
    {
        [MRCommon showAlert:@"Select Therapeutic Area" delegate:nil];
        return;
    }
    
    if ([self.yearRegButton.titleLabel.text isEqualToString:@"Year of Registration"])
    {
        [MRCommon showAlert:@"Year of Registration" delegate:nil];
        return;
    }
    
    if ([self.stateCouncilButton.titleLabel.text isEqualToString:@"State Medical Council"])
    {
        [MRCommon showAlert:@"State Medical Council" delegate:nil];
        return;
    }
    
    if (![MRCommon isStringEmpty:self.desiredPasswordTextField.text] && ![MRCommon isStringEmpty:self.repeatPasswordTextField.text])
    {
        if (![self.desiredPasswordTextField.text isEqualToString:self.repeatPasswordTextField.text])
        {
            [MRCommon showAlert:@"Password should be same." delegate:nil];
        }
        else
        {
            [[MRAppControl sharedHelper].userRegData setObject:self.desiredPasswordTextField.text forKey:KPassword];
            [MRCommon showActivityIndicator:@"Sending..."];
            if ([MRAppControl sharedHelper].userType == 2)
            {
                if (self.isFromSinUp)
                {
                    [self doctorRegistration];
                }
                else
                {
                    [self updateDoctorRegistration];
                }
            }
            else if ([MRAppControl sharedHelper].userType == 3)
            {
                if (self.isFromSinUp)
                {
                  [self pharmaRegistration];
                }
                else
                {
                    [self updatePharmaRegistration];
                }
            }
            
        }
    }
    else
    {
        [MRCommon showAlert:@"Password should not be empty." delegate:nil];
    }
}

- (void)doctorRegistration
{
    [[MRWebserviceHelper sharedWebServiceHelper] sendSignUp:[MRAppControl sharedHelper].userRegData withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         [MRCommon stopActivityIndicator];
         if (status)
         {
             [MRCommon setLoginEmail:[[[MRAppControl sharedHelper].userRegData objectForKey:KEmail] objectAtIndex:0]];
             [MRCommon setUserPhoneNumber:[[[MRAppControl sharedHelper].userRegData objectForKey:KMobileNumber] objectAtIndex:0]];
             [MRCommon showAlert:@"Registration Successful, Please Verify Mobile number" delegate:self withTag:1234];
//             MROTPVerifiedViewController *homeViewController = [[MROTPVerifiedViewController alloc] initWithNibName:@"MROTPVerifiedViewController" bundle:nil];
//             [self.navigationController pushViewController:homeViewController animated:YES];
         }
     }];
}

- (void)pharmaRegistration
{
    [[MRWebserviceHelper sharedWebServiceHelper] sendPharmaRepSignUp:[MRAppControl sharedHelper].userRegData withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         [MRCommon stopActivityIndicator];
         if (status)
         {
             [MRCommon setLoginEmail:[[[MRAppControl sharedHelper].userRegData objectForKey:KEmail] objectAtIndex:0]];
             [MRCommon setUserPhoneNumber:[[[MRAppControl sharedHelper].userRegData objectForKey:KMobileNumber] objectAtIndex:0]];
             [MRCommon showAlert:@"Registration Successful, Please Verify Mobile number" delegate:self withTag:1234];

//             MROTPVerifiedViewController *homeViewController = [[MROTPVerifiedViewController alloc] initWithNibName:@"MROTPVerifiedViewController" bundle:nil];
//             [self.navigationController pushViewController:homeViewController animated:YES];
         }
     }];
}

- (void)updateDoctorRegistration
{
    
    [MRCommon showActivityIndicator:@"Sending..."];
    [[MRWebserviceHelper sharedWebServiceHelper] updateMyDetails:[MRAppControl sharedHelper].userRegData withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             [MRCommon stopActivityIndicator];
             [MRCommon showAlert:@"Profile updated successfully" delegate:self withTag:6789];
             //[[NSNotificationCenter defaultCenter] postNotificationName:kDashboardNotificationFromRegistartionScren object:nil];
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] updateMyDetails:[MRAppControl sharedHelper].userRegData withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       if (status)
                       {
                           [MRCommon stopActivityIndicator];
                           [MRCommon showAlert:@"Profile updated successfully" delegate:self withTag:6789];
                           //[[NSNotificationCenter defaultCenter] postNotificationName:kDashboardNotificationFromRegistartionScren object:nil];
                       }
                   }];
              }];
         }
         else
         {
             [MRCommon stopActivityIndicator];
             [[NSNotificationCenter defaultCenter] postNotificationName:kDashboardNotificationFromRegistartionScren object:nil];
         }
     }];
}

- (void)updatePharmaRegistration
{
    [MRCommon showActivityIndicator:@"Loading..."];
    [[MRWebserviceHelper sharedWebServiceHelper] updateMyPharmaDetails:[MRAppControl sharedHelper].userRegData withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            [MRCommon stopActivityIndicator];
            [MRCommon showAlert:@"Profile updated successfully" delegate:self withTag:6789];
           // [[NSNotificationCenter defaultCenter] postNotificationName:kDashboardNotificationFromRegistartionScren object:nil];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] updateMyPharmaDetails:[MRAppControl sharedHelper].userRegData withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     if (status)
                     {
                         [MRCommon stopActivityIndicator];
                         [MRCommon showAlert:@"Profile updated successfully" delegate:self withTag:6789];
                        // [[NSNotificationCenter defaultCenter] postNotificationName:kDashboardNotificationFromRegistartionScren object:nil];
                     }
                 }];
             }];
        }
        else
        {
            [MRCommon stopActivityIndicator];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDashboardNotificationFromRegistartionScren object:nil];
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self showHideFiltersView:self.inputViewBottomConstraint withAdjustableValue:170];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self showHideFiltersView:self.inputViewBottomConstraint withAdjustableValue:20];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1234)
    {
        MROTPVerifiedViewController *otpViewController = [[MROTPVerifiedViewController alloc] initWithNibName:@"MROTPVerifiedViewController" bundle:nil];
        otpViewController.isFromSinUp = YES;
        [self.navigationController pushViewController:otpViewController animated:YES];
    }
    else if (alertView.tag == 6789)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDashboardNotificationFromRegistartionScren object:nil];
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

- (void)showHideFiltersView:(NSLayoutConstraint*)adjustableConstraint
        withAdjustableValue:(CGFloat)value
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.8f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    adjustableConstraint.constant = value;
    self.passwordBottomConstraint.constant = value + 140;
    [self updateViewConstraints];
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *) yearsOfRegistration {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    int year = [[formatter stringFromDate:[NSDate date]] intValue];
    
    NSMutableArray *arr = [NSMutableArray array];
    
    for (int i= 0; i < 50 ; i++) {
        [arr addObject:[NSString stringWithFormat:@"%d",year--]];
    }
    return [NSArray arrayWithArray:arr];
}

-(NSDictionary *) stateMedicalCouncilList {
    return @{@"AND" : @"Andhra Pradesh Medical Council",
               @"TSMC" : @"Tripura State Medical Council",
               @"ARU" : @"Arunachal Pradesh Medical Council",
               @"ASS" : @"Assam Medical Council",
               @"BHO" : @"Bhopal Medical Council",
               @"BIH" : @"Bihar Medical Council",
               @"BOM" : @"Bombay Medical Council",
               @"CHG" : @"Chandigarh Medical Council",
               @"CHA" : @"Chattisgarh Medical Council",
               @"DEL" : @"Delhi Medical Council",
               @"DCI" : @"Dental Council of India",
               @"GOA" : @"Goa Medical Council",
               @"GUJ" : @"Gujarat Medical Council",
               @"HAR" : @"Haryana Dental &amp; Medical Councils",
               @"HIM" : @"Himanchal  Pradesh Medical Council",
               @"HYD" : @"Hyderabad Medical Council",
               @"JAM" : @"Jammu &amp; Kashmir Medical Council",
               @"JHA" : @"Jharkhand Medical Council",
               @"KAR" : @"Karnataka Medical Council",
               @"KER" : @"Kerala Medical Council",
               @"MAD" : @"Madhya Pradesh Medical Council",
               @"MRS" : @"Madras Medical Council",
               @"MAC" : @"Mahakoshal Medical Council",
               @"MAH" : @"Maharashtra Medical Council",
               @"MAN" : @"Manipur Medical Council",
               @"MCI" : @"Medical Council of India",
               @"MYS" : @"Mysore Medical Council",
               @"NMC" : @"Nagaland Medical Council",
               @"ORI" : @"Orissa Council of Medical Registration",
               @"OTH" : @"Others",
               @"PUN" : @"Punjab Medical Council",
               @"RAJ" : @"Rajasthan Medical Council",
               @"SIK" : @"Sikkim Medical Council",
               @"TAM" : @"Tamil Nadu Medical Council",
               @"TEL" : @"Telangana State Medical Council",
               @"TC" : @"Travancore-Cochin Medical Council, Trivandrum",
               @"TRI" : @"Tripura State Medical Council ",
               @"UP" : @"Uttar Pradesh Medical Council",
               @"UTT" : @"Uttarakhand Medical Council",
               @"VID" : @"Vidharba Medical Council",
               @"WES" : @"West Bengal Medical Council"};
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)selectTherapeuitcAraeaButtonActin:(id)sender
{
    [self showPopoverInView:sender];
}

- (IBAction)selectYearRegButtonActin:(id)sender
{
    [self showPopoverInView:sender];
}

- (IBAction)selectStateCouncilButtonActin:(id)sender
{
    [self showPopoverInView:sender];
}

- (void)showPopoverInView:(UIButton*)button
{
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayView.tag = 2000;
    overlayView.backgroundColor = kRGBCOLORALPHA(0, 0, 0, 0.5);
    [self.view addSubview:overlayView];
    [MRCommon addUpdateConstarintsTo:self.view withChildView:overlayView];
    
    WYPopoverTheme *popOverTheme = [WYPopoverController defaultTheme];
    popOverTheme.outerStrokeColor = [UIColor lightGrayColor];
    [WYPopoverController setDefaultTheme:popOverTheme];
    
    MRListViewController *moreViewController = [[MRListViewController alloc] initWithNibName:@"MRListViewController" bundle:nil];
    
    moreViewController.modalInPopover = NO;
    moreViewController.delegate = self;
    
    if (button.tag == 1) {
        moreViewController.listType = MRListVIewTypeRegYear;
        moreViewController.listItems = [self yearsOfRegistration];
    }else if(button.tag == 2){
        moreViewController.listType = MRListVIewTypeStateCouncil;
        moreViewController.listItems = [[[self stateMedicalCouncilList] allValues]  sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }else if (button.tag == 3){
        moreViewController.listType = MRListVIewTypeTherapetic;
        moreViewController.listItems = [MRAppControl sharedHelper].therapeuticAreaDetails;
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    moreViewController.preferredContentSize = CGSizeMake(width, 200);
    
    UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController:moreViewController] ;
    contentViewController.navigationBar.hidden = YES;
    
    self.myPopoverController = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
    self.myPopoverController.delegate = self;
    self.myPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(0,2, 0, 2);
    self.myPopoverController.wantsDefaultContentAppearance = YES;
    [self.myPopoverController presentPopoverFromRect:button.bounds
                                              inView:button
                            permittedArrowDirections:WYPopoverArrowDirectionUp
                                            animated:YES
                                             options:WYPopoverAnimationOptionFadeWithScale];
    
}
#pragma mark - WYPopoverControllerDelegate

- (void)popoverControllerDidPresentPopover:(WYPopoverController *)controller
{
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    UIView *overlayView = [self.view viewWithTag:2000];
    [overlayView removeFromSuperview];
    
    self.myPopoverController.delegate = nil;
    self.myPopoverController = nil;
}

- (void)dismissPopoverController
{
    [self.myPopoverController dismissPopoverAnimated:YES completion:^{
        [self popoverControllerDidDismissPopover:self.myPopoverController];
    }];
}

- (void)selectedListItem:(id)listItem
{
    NSDictionary *item = (NSDictionary*)listItem;
    
    if ([item objectForKey:@"therapeuticId"]) {
        [self.therapeuticButton setTitle:[item objectForKey:@"therapeuticName"] forState:UIControlStateNormal];
        [[MRAppControl sharedHelper].userRegData setObject:[item objectForKey:@"therapeuticId"] forKey:@"therapeuticId"];
        //[myTherapeuticDict objectForKey:@"therapeuticId"];
    }
    
    if ([item objectForKey:@"yearReg"]) {
        [self.yearRegButton setTitle:[item objectForKey:@"yearReg"] forState:UIControlStateNormal];
        [[MRAppControl sharedHelper].userRegData setObject:[item objectForKey:@"yearReg"] forKey:@"registrationYear"];
    }
    
    if ([item objectForKey:@"stateCouncil"]) {
        [self.stateCouncilButton setTitle:[item objectForKey:@"stateCouncil"] forState:UIControlStateNormal];
        [[MRAppControl sharedHelper].userRegData setObject:[item objectForKey:@"stateCouncil"] forKey:@"stateMedCouncil"];
    }
}



- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height+50;
        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}



@end

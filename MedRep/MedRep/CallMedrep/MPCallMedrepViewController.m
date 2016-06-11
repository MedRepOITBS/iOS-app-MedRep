//
//  MPCallMedrepViewController.m
//  MedRep
//
//  Created by MedRep Developer on 10/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MPCallMedrepViewController.h"
#import "SWRevealViewController.h"
#import "UILabel+WhiteUIDatePickerLabels.h"
#import "MPNotificationAlertViewController.h"
#import "MRWebserviceHelper.h"
#import "MRListViewController.h"
#import "WYPopoverController.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRLocationManager.h"


@interface MPCallMedrepViewController ()<WYPopoverControllerDelegate,MRListViewControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate, SWRevealViewControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationViewBottomConstarint;//0 Phone 5, 0 iPhone 6, 30  iPhone 6+
@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *drugTitle;
@property (weak, nonatomic) IBOutlet UILabel *drugSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *TherapeuticTitle;
@property (weak, nonatomic) IBOutlet UILabel *TherapeuticSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *companyTitle;
@property (weak, nonatomic) IBOutlet UILabel *companySubTitle;

@property (weak, nonatomic) IBOutlet UIDatePicker *cellRepDatePicker;
@property (weak, nonatomic) IBOutlet UIButton *scheduleButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *companyBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *companyTopConstarint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *therapeticTopConstraint;
@property (strong, nonatomic) WYPopoverController *myPopoverController;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UITextField *otherLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *durationTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;

@end

@implementation MPCallMedrepViewController

- (void)viewDidLoad {
    [self setUPView];
    SWRevealViewController *revealController = [self revealViewController];
    revealController.delegate = self;
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [super viewDidLoad];
    
   
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self.scheduleButton setTitle:self.isFromReschedule ? @"RESCHEDULE" : @"SCHEDULE" forState:UIControlStateNormal];
    self.otherLocationTextField.userInteractionEnabled = NO;
    if (self.isFromReschedule)
    {
        self.drugSubTitle.text = [self.selectedNotification objectForKey:@"title"];
        self.TherapeuticSubTitle.text = [self.selectedNotification objectForKey:@"therapeuticName"];
        self.companySubTitle.text = [self.selectedNotification objectForKey:@"companyname"];
        self.cellRepDatePicker.date = [MRCommon dateFromstring:[self.selectedNotification objectForKey:@"startDate"] withDateFormate:@"YYYYMMddHHmmss"];
        self.locationTextField.text = [self.selectedNotification objectForKey:@"location"];
        self.otherLocationTextField.text =  [self.selectedNotification objectForKey:@"location"];
        self.durationTextField.text = [NSString stringWithFormat:@"%ld",[[self.selectedNotification objectForKey:@"duration"] integerValue]];

    }
    else
    {
        self.drugSubTitle.text = [self.notificationDetails objectForKey:@"notificationName"];
        self.TherapeuticSubTitle.text = [self.selectedNotification objectForKey:@"therapeuticName"];
        self.companySubTitle.text = [self.selectedNotification objectForKey:@"companyName"];
        NSArray *items = [[MRAppControl sharedHelper].userRegData objectForKey:KRegistarionStageTwo];
        NSDictionary *item = [items objectAtIndex:0];
         self.locationTextField.text = [NSString stringWithFormat:@"%@,%@,%@",[item objectForKey:KAddressOne],[item objectForKey:KAdresstwo],[item objectForKey:KCity]];
         self.otherLocationTextField.text = [NSString stringWithFormat:@"%@,%@,%@",[item objectForKey:KAddressOne],[item objectForKey:KAdresstwo],[item objectForKey:KCity]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUPView
{
    [self.locationButton setTitle:@" " forState:UIControlStateNormal];
    self.locationTextField.text = @" ";
   // [NSString stringWithFormat:@"%@,%@",[item objectForKey:@"AddressOne"],[item objectForKey:@"Adresstwo"]]

    if ([MRCommon deviceHasFourInchScreen])
    {
    }
    else if ([MRCommon deviceHasFourPointSevenInchScreen])
    {
        self.companyBottomConstraint.constant = 50.0;
        self.companyTopConstarint.constant =
        self.therapeticTopConstraint.constant = 15;
        
    }
    else if ([MRCommon deviceHasFivePointFiveInchScreen])
    {
        self.companyBottomConstraint.constant = 75.0;

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
- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)locationDropDownButtonAction:(id)sender
{
    [self.view endEditing:YES];
    [self showPopoverInView:(UIButton*)sender];
}

- (IBAction)cellRepDatePickerAction:(UIDatePicker *)sender
{
    
}

- (IBAction)scheduleButtonAction:(id)sender
{
    [self createAppointment];
}

- (void)createAppointment
{
    if ([self.cellRepDatePicker.date compare:[NSDate date]] == NSOrderedAscending || [self.cellRepDatePicker.date compare:[NSDate date]] == NSOrderedSame )
         {
             [MRCommon showAlert:@"Select future time" delegate:nil];
             return;
    }
    NSMutableDictionary *appointmentDetails = [[NSMutableDictionary alloc] init];
    
    if (!self.isFromReschedule)
    {
        [appointmentDetails setObject:[self.selectedNotification objectForKey:@"notificationName"] forKey:@"notificationName"];
        [appointmentDetails setObject:[self.selectedNotification objectForKey:@"notificationDesc"] forKey:@"notificationDesc"];
        [appointmentDetails setObject:[self.selectedNotification objectForKey:@"notificationId"] forKey:@"notificationId"];
        [appointmentDetails setObject:[MRCommon stringFromDate:self.cellRepDatePicker.date withDateFormate:@"YYYYMMddHHmmss"] forKey:@"startDate"];
        
       // [MRCommon stringFromDate:self.cellRepDatePicker.date withDateFormate:@"YYYYMMddHHmmss"];
        
        NSString *duration = @"30"; //([MRCommon isStringEmpty:self.durationTextField.text]) ? @"30" : self.durationTextField.text;
        [appointmentDetails setObject:duration forKey:@"duration"];
         [appointmentDetails setObject:@"Pending" forKey:@"status"]; //
        NSString *location = (![MRCommon isStringEmpty:self.otherLocationTextField.text]) ? self.otherLocationTextField.text : (![MRCommon isStringEmpty:self.locationTextField.text]) ? self.locationTextField.text : @"";
        
        [appointmentDetails setObject:location forKey:@"location"];
    }
    else
    {
        
        
        [appointmentDetails setObject:[self.selectedNotification objectForKey:@"title"] forKey:@"title"];
        
        NSString *location = (![MRCommon isStringEmpty:self.locationTextField.text]) ? self.locationTextField.text : (![MRCommon isStringEmpty:self.otherLocationTextField.text]) ? self.otherLocationTextField.text : [appointmentDetails objectForKey:@"location"];
        
        [appointmentDetails setObject:location forKey:@"location"];
        
        [appointmentDetails setObject:@"Update" forKey:@"status"];
        
        [appointmentDetails setObject:[self.selectedNotification objectForKey:@"notificationId"] forKey:@"notificationId"];
       // [appointmentDetails setObject:[self.selectedNotification objectForKey:@"doctorId"] forKey:@"doctorId"];
        [appointmentDetails setObject:[self.selectedNotification objectForKey:@"appointmentDesc"] forKey:@"appointmentDesc"];
        [appointmentDetails setObject:[self.selectedNotification objectForKey:@"appointmentId"] forKey:@"appointmentId"];
        //[appointmentDetails setObject:[self.selectedNotification objectForKey:@"feedback"] forKey:@"feedback"];
        
        [appointmentDetails setObject:[MRCommon stringFromDate:self.cellRepDatePicker.date withDateFormate:@"YYYYMMddHHmmss"]  forKey:@"startDate"];
        
        NSString *duration = ([MRCommon isStringEmpty:self.durationTextField.text]) ? [appointmentDetails objectForKey:@"duration"] : self.durationTextField.text;
        
        [appointmentDetails setObject:duration forKey:@"duration"];
    }
    
    
    [[MRWebserviceHelper sharedWebServiceHelper] createNewAppointment:appointmentDetails
                                                         isFromUpdate:!self.isFromReschedule
                                                          withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            [self showConformationAlert];

           // [self moveBackOnEventSync];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] createNewAppointment:appointmentDetails
                                                                      isFromUpdate:YES
                                                                       withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     if (status)
                     {
                         [self showConformationAlert];
                     }
                 }];
             }];
        }
    }];
}

- (void)showConformationAlert
{
    viewController = [[MPNotificationAlertViewController alloc] initWithNibName:@"MPNotificationAlertViewController" bundle:nil];
    [self.view addSubview:viewController.view];
    
    [MRCommon addUpdateConstarintsTo:self.view withChildView:viewController.view];
    [viewController configureAlertWithAlertType:MRAlertTypeMessage withMessage:KScheduleConfirmationMSG withTitle:@"SCHEDULE" withOKButtonAction:^(MPNotificationAlertViewController *alertView)
     {
         [self moveBackOnEventSync];
         alertView.view.alpha = 1.0f;
         [UIView animateWithDuration:0.4
                               delay:0.0
                             options: UIViewAnimationOptionCurveEaseInOut
                          animations:^{
                              alertView.view.alpha = 0.0f;
                          } completion:^(BOOL finished) {
                              [alertView.view removeFromSuperview];
                              [alertView removeFromParentViewController];
                          }];
         
     } withCancelButtonAction:^(MPNotificationAlertViewController *alertView){
         alertView.view.alpha = 1.0f;
         [UIView animateWithDuration:0.4
                               delay:0.0
                             options: UIViewAnimationOptionCurveEaseInOut
                          animations:^{
                              alertView.view.alpha = 0.0f;
                          } completion:^(BOOL finished) {
                              [alertView.view removeFromSuperview];
                              [alertView removeFromParentViewController];
                              [self.navigationController popViewControllerAnimated:YES];
                          }];
     }];
    
    viewController.view.alpha = 0.0f;
    [UIView animateWithDuration:0.25f animations:^{
        viewController.view.alpha = 1.0f;
    }];
}

- (void)moveBackOnEventSync
{
    [MRCommon syncEventInCalenderAlongWithEventTitle:[self.selectedNotification objectForKey:@"notificationName"]
                                     withDescription:[self.selectedNotification objectForKey:@"location"]
                                        withDuration:[[self.selectedNotification objectForKey:@"duration"] integerValue]
                                           eventDate:self.cellRepDatePicker.date
                                         withHandler:^{
                                            [MRCommon showAlert:@"Appointment added successfully." delegate:self withTag:1234];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1234)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    moreViewController.listType = MRListVIewTypeAddress;
    moreViewController.isFromCallMedrep = YES;
    moreViewController.listItems = [[MRAppControl sharedHelper].userRegData objectForKey:KRegistarionStageTwo];
    
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
    if ([listItem isKindOfClass:[NSString class]])
    {
        if ([listItem isEqualToString:@"Current Location"])
        {
            [self addLocationInSection];
        }
    }
    else
    {
        NSDictionary *item = (NSDictionary*)listItem;
        self.locationTextField.text = [NSString stringWithFormat:@"%@,%@, %@",[item objectForKey:KAddressOne],[item objectForKey:KAdresstwo],[item objectForKey:KCity]];
        self.otherLocationTextField.text = [NSString stringWithFormat:@"%@,%@, %@",[item objectForKey:KAddressOne],[item objectForKey:KAdresstwo],[item objectForKey:KCity]];
    }

    //[self.locationButton setTitle:[NSString stringWithFormat:@"%@,%@",[item objectForKey:@"AddressOne"],[item objectForKey:@"Adresstwo"]] forState:UIControlStateNormal];
}

- (void)addLocationInSection
{
    NSMutableDictionary *sectDict = [[NSMutableDictionary alloc] init];
    [MRCommon showActivityIndicator:@""];
    [[MRLocationManager sharedManager] getCurrentLocation:^(CLLocation *location)
     {
         CLGeocoder *geocoder = [[CLGeocoder alloc] init];
         
         [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
             [MRCommon stopActivityIndicator];
             //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
             if (error == nil && [placemarks count] > 0) {
                 CLPlacemark *placemark = [placemarks lastObject];
                 
                 if (placemark.name) {
                     [sectDict setObject:placemark.name forKey:KAddressOne];
                 } else {
                     [sectDict setObject:@"" forKey:KAddressOne];
                 }
                 
                 if (placemark.subLocality) {
                     [sectDict setObject:placemark.subLocality forKey:KAdresstwo];
                 } else {
                     [sectDict setObject:@"" forKey:KAdresstwo];
                 }
                 
                 if (placemark.postalCode) {
                     [sectDict setObject:placemark.postalCode forKey:KZIPCode];
                 } else {
                     [sectDict setObject:@"" forKey:KZIPCode];
                 }
                 
                 if (placemark.administrativeArea) {
                     [sectDict setObject:placemark.administrativeArea forKey:KState];
                 } else {
                     [sectDict setObject:@"" forKey:KState];
                 }
                 
                 if (placemark.subAdministrativeArea) {
                     [sectDict setObject:placemark.subAdministrativeArea forKey:KCity];
                 } else {
                     [sectDict setObject:@"" forKey:KCity];
                 }
                  self.otherLocationTextField.text = [NSString stringWithFormat:@"%@,%@,%@",[sectDict objectForKey:KAddressOne],[sectDict objectForKey:KAdresstwo],[sectDict objectForKey:KCity]];
             } else {
                 NSLog(@"%@", error.debugDescription);
                 [MRCommon showAlert:error.description delegate:nil];
             }
         } ];
     }];
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self showHideFiltersView:nil withAdjustableValue:-25];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self showHideFiltersView:nil withAdjustableValue:64];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 100) {
        if([MRCommon isStringEmpty:string]) return YES;
        unichar lastCharacter = [string characterAtIndex:0];
        
        if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:lastCharacter])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

- (void)showHideFiltersView:(NSLayoutConstraint*)adjustableConstraint
        withAdjustableValue:(CGFloat)value
{
    if ([MRCommon deviceHasFourInchScreen] || [MRCommon deviceHasThreePointFiveInchScreen])
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        CGRect myFrame = self.view.frame;
        myFrame.origin.y = value;
        self.view.frame = myFrame;
        [self updateViewConstraints];
        [UIView commitAnimations];
    }
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

@end

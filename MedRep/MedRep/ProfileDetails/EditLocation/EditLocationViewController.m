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
#import "MRRegTableViewCell.h"
#import "MRRegHeaderView.h"
#import "MRLocationManager.h"
#import "MRConstants.h"
#import "MRRegHeaderView.h"

@import GooglePlaces;
@import GoogleMaps;

#define kHeaderView     [NSArray arrayWithObjects:@"ADDITIONAL ADDRESS", nil]

#define kPlaceHolders   [NSArray arrayWithObjects:@"ADDRESS LINE 1", @"ADDRESS LINE 2", @"STATE", @"CITY", @"ZIP CODE", nil]

#define kDocCellTypes [NSArray arrayWithObjects:[NSNumber numberWithInt:MRCellTypeNumeric],[NSNumber numberWithInt:MRCellTypeAlphabets], [NSNumber numberWithInt:MRCellTypeAlphabets], [NSNumber numberWithInt:MRCellTypeNumeric], [NSNumber numberWithInt:MRCellTypeNumeric], nil]

@interface EditLocationViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate,MRRegTableViewCellDelagte>

@property (nonatomic) NSString *currentText;

@property (nonatomic) NSMutableDictionary *locationDictionary;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic) UITextField *activeTextField;
@property (weak, nonatomic) IBOutlet UITableView *regTableView;

@property (weak, nonatomic) IBOutlet UIView *addressViewHeader;
@property (weak, nonatomic) IBOutlet UIButton *hospitalButton;
@property (weak, nonatomic) IBOutlet UIButton *privateClinicButton;

@property (assign, nonatomic) NSInteger numberOfSections;
@property (assign, nonatomic) NSInteger numberOfSectionsTwoTypes;
@property (assign, nonatomic) BOOL isKeyboardUp;
@property (strong, nonatomic) NSMutableDictionary *userDeatils;
@property (assign, nonatomic) NSInteger selectedUserType;
@property (strong,nonatomic)  GMSPlacesClient *placesClient;
@property (nonatomic) BOOL isLocationUpdateGet;

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
    
    self.locationDictionary = [NSMutableDictionary new];
    
    _placesClient = [GMSPlacesClient sharedClient];
    
    if (self.addressObject == nil) {
        [self getCurrentLocation];
    }
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
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
//    self.scrollView.contentInset = contentInsets;
//    self.scrollView.scrollIndicatorInsets = contentInsets;
//    
//    // If active text field is hidden by keyboard, scroll it so it's visible
//    // Your application might not need or want this behavior.
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= kbSize.height + 5;
//    
//    CGPoint referenceFrame = self.activeTextField.frame.origin;
//    referenceFrame.y += 64;
//    
//    if (!CGRectContainsPoint(aRect, referenceFrame) ) {
//        CGPoint scrollPoint = CGPointMake(0.0, (self.activeTextField.frame.origin.y + 50)-kbSize.height);
//        if (scrollPoint.y > 0) {
//            [self.scrollView setContentOffset:scrollPoint animated:YES];
//        }
//    }
}

-(void)keyboardWillHide:(NSNotification*)aNotification {
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//    self.scrollView.contentInset = contentInsets;
//    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonTapped:(id)sender
{
    if ([self validateData]) {
        NSString *value = self.addressObject.address1;
        if (value != nil && value.length > 0) {
            [self.locationDictionary setObject:value forKey:@"address1"];
        }
        
        value = self.addressObject.address2;
        if (value != nil && value.length > 0) {
            [self.locationDictionary setObject:value forKey:@"address2"];
        }
        
        value = self.addressObject.city;
        if (value != nil && value.length > 0) {
            [self.locationDictionary setObject:value forKey:@"city"];
        }
        
        value = self.addressObject.country;
        if (value != nil && value.length > 0) {
            [self.locationDictionary setObject:value forKey:@"country"];
        } else {
            [self.locationDictionary setObject:@"India" forKey:@"country"];
        }
        
        value = self.self.addressObject.state;
        if (value != nil && value.length > 0) {
            [self.locationDictionary setObject:value forKey:@"state"];
        }
        
        value = self.addressObject.zipcode;
        if (value != nil && value.length > 0) {
            [self.locationDictionary setObject:value forKey:@"zipcode"];
        }
        
        if (self.addressObject != nil && self.addressObject.locationId != nil) {
            [self.locationDictionary setObject:[NSNumber numberWithLong:self.addressObject.locationId.longValue]
                                   forKey:@"locationId"];
        }
        
        [MRDatabaseHelper editLocation:@[self.locationDictionary]
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
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pickALocationClicked:(id)sender {
    [self getCurrentLocation];
}

-(void)getCurrentLocation {
    [MRCommon showActivityIndicator:@""];
    
    [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *placeLikelihoodList, NSError *error){
        if (error != nil) {
            [MRCommon stopActivityIndicator];
            
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
        if (placeLikelihoodList != nil) {
            GMSPlace *place = [[[placeLikelihoodList likelihoods] firstObject] place];
            if (place != nil) {
                NSLog(@"%@",place.name);
                NSLog(@"%@",[[place.formattedAddress componentsSeparatedByString:@", "]
                             componentsJoinedByString:@"\n"]);
                
                [[GMSGeocoder geocoder] reverseGeocodeCoordinate:place.coordinate completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
                    NSLog(@"reverse geocoding results:");
                    GMSAddress* addressObj =  [response results].firstObject;
                    if (_isLocationUpdateGet) {
                        
                        [MRCommon stopActivityIndicator];
                        return;
                    }
                    
                    [MRCommon stopActivityIndicator];
                    
                    NSString *entityName = NSStringFromClass(AddressInfo.class);
                    
                    MRDataManger *dbManager = [MRDataManger sharedManager];
                    NSManagedObjectContext *context = [dbManager getNewPrivateManagedObjectContext];
                    
                    NSEntityDescription *entityDescription = [[[dbManager managedObjectModel] entitiesByName] objectForKey:entityName];
                    self.addressObject = (AddressInfo*)[[MRManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
                    
                    self.addressObject.address1 = @"";
                    
                    if (place.name != nil && place.name.length > 0) {
                        self.addressObject.address1 = place.name;
                    }
                    
                    self.addressObject.address2 = @"";
                    
                    if (addressObj.subLocality != nil && addressObj.subLocality.length > 0) {
                        self.addressObject.address2 = addressObj.subLocality;
                    }
                    
                    self.addressObject.zipcode = @"";
                    if (addressObj.postalCode != nil && addressObj.postalCode.length > 0) {
                        self.addressObject.zipcode = addressObj.postalCode;
                    }
                    
                    self.addressObject.state = @"";
                    if (addressObj.administrativeArea != nil && addressObj.administrativeArea.length > 0) {
                        self.addressObject.state = addressObj.administrativeArea;
                    }
                    
                    self.addressObject.city = @"";
                    if (addressObj.locality != nil && addressObj.locality.length > 0) {
                        self.addressObject.city = addressObj.locality;
                    }
                    
                    [self.regTableView reloadData];
                    
                }];
            }
        }
    }];
}

-(void)isLocationUpdateDone{
    
    _isLocationUpdateGet = YES;
    [MRCommon stopActivityIndicator];
    
}

- (void)addLocationInSection:(NSInteger)section
{
    NSMutableDictionary *sectDict = [NSMutableDictionary new];
    
    [MRCommon showActivityIndicator:@""];
    [[MRLocationManager sharedManager] getCurrentLocation:^(CLLocation *location)
     {
         CLGeocoder *geocoder = [[CLGeocoder alloc] init];
         
         [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
             [MRCommon stopActivityIndicator];
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
                 
                 [self.regTableView reloadData];
                 
             } else {
                 NSLog(@"%@", error.debugDescription);
                 [self showLocationErrorAlert];
             }
         } ];
     }];
    
}

-(void)showLocationErrorAlert{
    UIAlertView* curr2=[[UIAlertView alloc] initWithTitle:@"MedRep Location Services Disabled" message:@"Please enable your device Location Service to locate your location address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Settings", nil];
    curr2.tag=121;
    [curr2 show];
}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex:%ld",(long)buttonIndex);
    if (alertView.tag == 121) {
        if (buttonIndex == 0) {
            
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    
    if (alertView.tag == 6789 )
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    //code for opening settings app in iOS 8
}

- (IBAction)privateButtonAction:(id)sender
{
    [self.view endEditing:YES];
    self.addressObject.type = @"Home";
    [self.privateClinicButton setBackgroundImage:[UIImage imageNamed:@"privateHospital_selection@2x.png"] forState:UIControlStateNormal];
    [self.hospitalButton setBackgroundImage:[UIImage imageNamed:@"hospital@2x.png"] forState:UIControlStateNormal];
    [self.regTableView reloadData];
    
}

- (IBAction)hospitalButtonAction:(id)sender
{
    [self.view endEditing:YES];
    self.addressObject.type = @"Hospital";
    [self.privateClinicButton setBackgroundImage:[UIImage imageNamed:@"privateHospital.png"] forState:UIControlStateNormal];
    [self.hospitalButton setBackgroundImage:[UIImage imageNamed:@"hospital_selection.png"] forState:UIControlStateNormal];
    [self.regTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier                = @"MRRegTableViewCell";
    MRRegTableViewCell *regCell     = (MRRegTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (regCell == nil)
    {
        NSArray *nibViews                   = [[NSBundle mainBundle] loadNibNamed:@"MRRegTableViewCell" owner:nil options:nil];
        regCell                           = (MRRegTableViewCell *)[nibViews lastObject];
    }
    
    regCell.delegate                   = self;
    regCell.isUserPesronalDetails      = NO;
    regCell.regType = [MRAppControl sharedHelper].userType; // 1 for doc , 3 for pharma
    
    regCell = [self configureCellForDoctor:regCell atIndexPath:indexPath];
    
    return regCell;
}

- (MRRegTableViewCell*)configureCellForDoctor:(MRRegTableViewCell*)regCell atIndexPath:(NSIndexPath *)indexPath
{
    regCell.inputTextField.placeholder =  (indexPath.row == 3) ? [kPlaceHolders objectAtIndex:indexPath.row + 1] : [kPlaceHolders objectAtIndex:indexPath.row];
    regCell.rowNumber                  = indexPath.row;
    regCell.sectionNumber              = indexPath.section;
    
    regCell.cellType = MRCellTypeNone;
    
    if (indexPath.row == 0) {
        NSString *value = @"";
        
        if (self.addressObject.address1 != nil && self.addressObject.address1.length > 0) {
            value = self.addressObject.address1;
        }
        regCell.inputTextField.text = value;
        [regCell configureSingleInput:YES];
    } else if (indexPath.row == 1) {
        NSString *value = @"";
        
        if (self.addressObject.address2 != nil && self.addressObject.address2.length > 0) {
            value = self.addressObject.address2;
        }
        regCell.inputTextField.text = value;
        [regCell configureSingleInput:YES];
    } else if (indexPath.row == 2) {
        [regCell configureSingleInput:NO];
        regCell.mTwoTextField.placeholder = [kPlaceHolders objectAtIndex:indexPath.row + 1];
        regCell.mOneTextFiled.placeholder = [kPlaceHolders objectAtIndex:indexPath.row];
        
        NSString *value = @"";
        
        if (self.addressObject.state != nil && self.addressObject.state.length > 0) {
            value = self.addressObject.state;
        }
        regCell.mOneTextFiled.text = value;
        
        value = @"";
        
        if (self.addressObject.city != nil && self.addressObject.city.length > 0) {
            value = self.addressObject.city;
        }
        regCell.mTwoTextField.text = value;
    } else if (indexPath.row == 3) {
        regCell.inputTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        regCell.cellType = MRCellTypeNumeric;
        
        NSString *value = @"";
        
        if (self.addressObject.zipcode != nil && self.addressObject.address1.length > 0) {
            value = self.addressObject.zipcode;
        }
        regCell.inputTextField.text = value;
        
        [regCell configureSingleInput:YES];
    } else {
        regCell.cellType = MRCellTypeNone;
    }
    return regCell;
}

- (void)setDataForCell:(MRRegTableViewCell*)cell
{
    switch (cell.rowNumber)
    {
        case 0:
            self.addressObject.address1 = cell.inputTextField.text;
            break;
            
        case 1:
            self.addressObject.address2 = cell.inputTextField.text;
            break;
            
        case 3:
            self.addressObject.zipcode = cell.inputTextField.text;
            break;
            
        default:
            break;
    }
}

- (void)mOneButtonActionDelegate:(MRRegTableViewCell*)cell
{
    self.addressObject.state = cell.mOneTextFiled.text;
    [self  showHideFiltersView:cell withAdjustableValue:NO];
}

- (void)mTwoButtonActionDelegate:(MRRegTableViewCell*)cell
{
    self.addressObject.city = cell.mTwoTextField.text;
    [self  showHideFiltersView:cell withAdjustableValue:NO];
}

- (void)areaWorkLocationButtonActionDelegate:(MRRegTableViewCell*)cell
{
    
}
- (void)inputTextFieldBeginEditingDelegate:(MRRegTableViewCell*)cell
{
    [self  showHideFiltersView:cell withAdjustableValue:YES];
}

- (void)inputTextFieldEndEditingDelegate:(MRRegTableViewCell*)cell
{
    [self setDataForCell:cell];
    [self  showHideFiltersView:cell withAdjustableValue:NO];
}

- (void)showHideFiltersView:(MRRegTableViewCell*)cell
        withAdjustableValue:(BOOL)isBeginEditing
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
    [self.regTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:cell.rowNumber inSection:cell.sectionNumber] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    [self updateViewConstraints];
    [UIView commitAnimations];
}

//Header View Delegates
- (BOOL)validateData
{
    BOOL isSuccess = YES;
    
    NSArray *regDetails = [self.userDeatils objectForKey:KRegistarionStageTwo];
    
    for (NSDictionary *dict in  regDetails)
    {
        if ([[dict objectForKey:KType] intValue] == 1)
        {
            if ([MRCommon isStringEmpty:[dict objectForKey:KAddressOne]])
            {
                [MRCommon showAlert:@"Address line 1 should not be empty." delegate:nil];
                isSuccess = NO;
                break;
                
            }
            if ([MRCommon isStringEmpty:[dict objectForKey:KCity]])
            {
                [MRCommon showAlert:@"City should not be empty." delegate:nil];
                isSuccess = NO;
                break;
            }
            if ([MRCommon isStringEmpty:[dict objectForKey:KState]])
            {
                [MRCommon showAlert:@"State should not be empty." delegate:nil];
                isSuccess = NO;
                break;
            }
            
            if ([MRCommon isStringEmpty:[dict objectForKey:KZIPCode]])
            {
                [MRCommon showAlert:@"Zipcode should not be empty." delegate:nil];
                isSuccess = NO;
                break;
            }
        }
        else
        {
            if (![MRCommon isStringEmpty:[dict objectForKey:KZIPCode]] || ![MRCommon isStringEmpty:[dict objectForKey:KCity]] || ![MRCommon isStringEmpty:[dict objectForKey:KAddressOne]] || ![MRCommon isStringEmpty:[dict objectForKey:KAdresstwo]] )
            {
                if ([MRCommon isStringEmpty:[dict objectForKey:KAddressOne]])
                {
                    [MRCommon showAlert:@"Address line 1 should not be empty." delegate:nil];
                    isSuccess = NO;
                    break;
                    
                }
                if ([MRCommon isStringEmpty:[dict objectForKey:KCity]])
                {
                    [MRCommon showAlert:@"City should not be empty." delegate:nil];
                    isSuccess = NO;
                    break;
                }
                if ([MRCommon isStringEmpty:[dict objectForKey:KState]])
                {
                    [MRCommon showAlert:@"State should not be empty." delegate:nil];
                    isSuccess = NO;
                    break;
                }
                
                if ([MRCommon isStringEmpty:[dict objectForKey:KZIPCode]])
                {
                    [MRCommon showAlert:@"Zipcode should not be empty." delegate:nil];
                    isSuccess = NO;
                    break;
                }
            }
        }
    }
    
    return isSuccess;
}

@end

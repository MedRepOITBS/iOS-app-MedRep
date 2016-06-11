//
//  MRRegistationTwoViewController.m
//  MedRep
//
//  Created by MedRep Developer on 27/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRRegistationTwoViewController.h"
#import "MROTPVerifiedViewController.h"
#import "MRRegistrationRoleViewController.h"
#import "MROTPViewController.h"
#import "MRWebserviceHelper.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRLocationManager.h"

#define kHeaderView     [NSArray arrayWithObjects:@"ADDITIONAL ADDRESS", nil]
#define kPlaceHolders   [NSArray arrayWithObjects:@"ADDRESS LINE 1", @"ADDRESS LINE 2", @"STATE", @"CITY", @"ZIP CODE", nil]
#define kPharmaPlaceHolders   [NSArray arrayWithObjects:@"Reporting Manager Name", @"Reporting Manager Email ID", @"Reporting Manager Mobile Number", nil]


#define kDocCellTypes [NSArray arrayWithObjects:[NSNumber numberWithInt:MRCellTypeNumeric],[NSNumber numberWithInt:MRCellTypeAlphabets], [NSNumber numberWithInt:MRCellTypeAlphabets], [NSNumber numberWithInt:MRCellTypeNumeric], [NSNumber numberWithInt:MRCellTypeNumeric], nil]



@interface MRRegistationTwoViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topClinicViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewTopConstarint;
@property (strong, nonatomic) NSMutableArray *sectionsArray;
@property (strong, nonatomic) NSMutableArray *addressTwosectionsArray;

@property (assign, nonatomic) NSInteger numberOfSections;
@property (assign, nonatomic) NSInteger numberOfSectionsTwoTypes;
@property (assign, nonatomic) BOOL isKeyboardUp;
@property (strong, nonatomic) NSMutableDictionary *userDeatils;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextButtonBottomSpace;
@property (assign, nonatomic) NSInteger selectedUserType;
@property (assign, nonatomic) NSInteger selectedAddressType;

@end

@implementation MRRegistationTwoViewController

- (void)viewDidLoad {
    
    [MRAppControl sharedHelper].addressType = 1;
    self.selectedAddressType = 1;
    self.selectedUserType = [MRAppControl sharedHelper].userType;
    self.userDeatils = [[MRAppControl sharedHelper] userRegData];
    self.regTableView.contentInset = UIEdgeInsetsMake(-30, 0, 0, -20);
    [self setUPView];

    if (!self.isFromSinUp)
    {
        [self.nextButton setTitle:@"UPDATE" forState:UIControlStateNormal];
    }

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)addLocationInSection:(NSInteger)section
{
    NSMutableDictionary *sectDict = [self getDataByAddressType:[NSIndexPath indexPathForRow:0 inSection:section]];
    [MRCommon showActivityIndicator:@""];
    [[MRLocationManager sharedManager] getCurrentLocation:^(CLLocation *location)
     {
         CLGeocoder *geocoder = [[CLGeocoder alloc] init];
         
         [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
             //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
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
                 [MRCommon showAlert:error.description delegate:nil];
             }
         } ];
     }];

}

-(void)setUPView
{
    //if (self.selectedAddressType == 1)
    {
        self.numberOfSections = [self getAddressCountByType:1] + 1;//(!self.isFromSinUp) ? [self getAddressCountByType:1] + 1 : 2 ;
        self.sectionsArray = [[NSMutableArray alloc] init];
        for (int i = 0 ; i < self.numberOfSections; i++)
        {
            MRRegHeaderView *headerView = [MRRegHeaderView regHeaderView];
            
            if (self.numberOfSections == 3 && i == 0)
            {
                headerView.addLabel.text = [NSString stringWithFormat:@"ADDRESS 2"];
                headerView.section = 1;
                headerView.backgroundColor = [UIColor clearColor];
                headerView.delegate = self;
                headerView.pickLocationButton.hidden = NO;
                headerView.pickLocationImage.hidden = NO;
                headerView.addIconImage.image = [UIImage imageNamed:@"minus.png"];
            }
            else
            {
                headerView.addLabel.text = [kHeaderView firstObject];
                headerView.section = 0;
                headerView.backgroundColor = [UIColor clearColor];
                headerView.delegate = self;
                headerView.pickLocationButton.hidden = NO;
                headerView.pickLocationImage.hidden = NO;
            }

            [self.sectionsArray addObject:headerView];
        }
    }
    //else if (self.selectedAddressType == 1)
    {
        self.numberOfSectionsTwoTypes = [self getAddressCountByType:1] + 1;//(!self.isFromSinUp) ? [self getAddressCountByType:2] + 1 : 2 ;
        self.addressTwosectionsArray = [[NSMutableArray alloc] init];
        for (int i = 0 ; i < self.numberOfSectionsTwoTypes; i++)
        {
            MRRegHeaderView *headerView = [MRRegHeaderView regHeaderView];
            if (self.numberOfSectionsTwoTypes == 3 && i == 0)
            {
                headerView.addLabel.text = [NSString stringWithFormat:@"ADDRESS 2"];
                headerView.section = 1;
                headerView.backgroundColor = [UIColor clearColor];
                headerView.delegate = self;
                headerView.pickLocationButton.hidden = NO;
                headerView.pickLocationImage.hidden = NO;
                headerView.addIconImage.image = [UIImage imageNamed:@"minus.png"];
            }
            else
            {
                headerView.addLabel.text = [kHeaderView firstObject];
                headerView.section = 0;
                headerView.backgroundColor = [UIColor clearColor];
                headerView.delegate = self;
                headerView.pickLocationButton.hidden = NO;
                headerView.pickLocationImage.hidden = NO;
            }
            [self.addressTwosectionsArray addObject:headerView];
        }
    }
    
    [self updateViewsToDefaultConstarints];
}

- (void)updateViewsToDefaultConstarints
{
    if ([MRAppControl sharedHelper].userType == 3 || [MRAppControl sharedHelper].userType == 4)
    {
        self.addressViewHeader.hidden = YES;
        self.tableviewTopConstarint.constant = 215 - 90;
    }
    
    if ([MRCommon deviceHasFourInchScreen])
    {
        self.nextButtonBottomSpace.constant = 30;
    }
    else if ([MRCommon deviceHasFourPointSevenInchScreen])
    {
        self.nextButtonBottomSpace.constant = 50;
    }
    else if ([MRCommon deviceHasFivePointFiveInchScreen])
    {
        self.nextButtonBottomSpace.constant = 50;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)privateButtonAction:(id)sender
{
    [self.view endEditing:YES];
    [MRAppControl sharedHelper].addressType = 2;
    self.selectedAddressType = 2;
    [self.privateClinicButton setBackgroundImage:[UIImage imageNamed:@"privateHospital_selection@2x.png"] forState:UIControlStateNormal];
    [self.hospitalButton setBackgroundImage:[UIImage imageNamed:@"hospital@2x.png"] forState:UIControlStateNormal];
    [self.regTableView reloadData];

}

- (IBAction)hospitalButtonAction:(id)sender
{
    [self.view endEditing:YES];
    [MRAppControl sharedHelper].addressType = 1;
    self.selectedAddressType = 1;
    [self.privateClinicButton setBackgroundImage:[UIImage imageNamed:@"privateHospital.png"] forState:UIControlStateNormal];
    [self.hospitalButton setBackgroundImage:[UIImage imageNamed:@"hospital_selection.png"] forState:UIControlStateNormal];
    [self.regTableView reloadData];
}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextButtonAction:(id)sender
{
    if ([self validateData] == NO)   return;
    
    if (self.isFromSinUp)
    {
        if (([MRAppControl sharedHelper].userType == 1 || [MRAppControl sharedHelper].userType == 2) || ([MRAppControl sharedHelper].userType == 3 && self.registrationStage == 2))
        {
            MROTPViewController *otpViewController = [[MROTPViewController alloc] initWithNibName:@"MROTPViewController" bundle:nil];
            otpViewController.isFromSinUp = self.isFromSinUp;
            [self.navigationController pushViewController:otpViewController animated:YES];
        }
        else if ([MRAppControl sharedHelper].userType == 3 && self.registrationStage == 1)
        {
            MRRegistationTwoViewController *regTwoViewController = [[MRRegistationTwoViewController alloc] initWithNibName:@"MRRegistationTwoViewController" bundle:nil];
            regTwoViewController.isFromSinUp = self.isFromSinUp;
            regTwoViewController.registrationStage = 2;
            [self.navigationController pushViewController:regTwoViewController animated:YES];
        }
    }
    else
    {
        if ([MRAppControl sharedHelper].userType == 1 || [MRAppControl sharedHelper].userType == 2)
        {
            [self updateDoctorRegistration];
        }
        else if ([MRAppControl sharedHelper].userType == 3 || [MRAppControl sharedHelper].userType == 4)
        {
            [self updatePharmaRegistration];
        }
    }

//    else if ([MRAppControl sharedHelper].userType == 1)
//    {
//        MROTPViewController *otpViewController = [[MROTPViewController alloc] initWithNibName:@"MROTPViewController" bundle:nil];
//        otpViewController.isFromSinUp = self.isFromSinUp;
//        [self.navigationController pushViewController:otpViewController animated:YES];
//    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.selectedAddressType == 1)
    {
        return ((1 == self.selectedUserType || 2 == self.selectedUserType) && self.registrationStage == 1) ? self.numberOfSections : 1;

    }
    else
    {
        return ((1 == self.selectedUserType || 2 == self.selectedUserType)  && self.registrationStage == 1) ? self.numberOfSectionsTwoTypes : 1;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //if (self.selectedAddressType == 1)
    {
        return ((1 == self.selectedUserType || 2 == self.selectedUserType) || ((self.selectedUserType == 3 || self.selectedUserType == 4 ) && self.registrationStage == 1)) ? (section != 0) ? 40.0 : 0.0 : 0.0;
    }
//    else
//    {
//        return ((1 == self.selectedUserType || 2 == self.selectedUserType) || ((self.selectedUserType == 3 || self.selectedUserType == 4 ) && self.registrationStage == 1)) ? (section != 0) ? 40.0 : 0.0 : 0.0;
//    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (self.selectedAddressType == 1)
    {
        return  ((1 == self.selectedUserType || 2 == self.selectedUserType) || ((self.selectedUserType == 3 || self.selectedUserType == 4 ) && self.registrationStage == 1)) ? (section != 0) ? [self.sectionsArray objectAtIndex:section-1] : nil : nil;
    }
    else
    {
        return  ((1 == self.selectedUserType || 2 == self.selectedUserType) && self.registrationStage == 1) ? (section != 0) ? [self.addressTwosectionsArray objectAtIndex:section-1] : nil : nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.selectedAddressType == 1)
    {
        return  ((1 == self.selectedUserType || 2 == self.selectedUserType) || ((self.selectedUserType == 3 || self.selectedUserType == 4 ) && self.registrationStage == 1)) ? (section == self.numberOfSections - 1) ? 0 : 4 : 3;
    }
    else
    {
        return  ((1 == self.selectedUserType || 2 == self.selectedUserType) || ((self.selectedUserType == 3 || self.selectedUserType == 4 ) && self.registrationStage == 1)) ? (section == self.numberOfSectionsTwoTypes - 1) ? 0 : 4 : 3;
    }
    
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
    
    if ((1 == self.selectedUserType || 2 == self.selectedUserType))
    {
        regCell = [self configureCellForDoctor:regCell atIndexPath:indexPath];
    }
    else  if (3 == self.selectedUserType || 4 == self.selectedUserType)
    {
        if (2 == self.registrationStage)
        {
            regCell = [self configureCellForPharmarep:regCell atIndexPath:indexPath];
        }
        else if (1 == self.registrationStage)
        {
            regCell = [self configureCellForDoctor:regCell atIndexPath:indexPath]; 
        }
    }

    return regCell;
}


- (MRRegTableViewCell*)configureCellForDoctor:(MRRegTableViewCell*)regCell atIndexPath:(NSIndexPath *)indexPath
{
    regCell.inputTextField.placeholder =  (indexPath.row == 3) ? [kPlaceHolders objectAtIndex:indexPath.row + 1] : [kPlaceHolders objectAtIndex:indexPath.row];
    regCell.rowNumber                  = indexPath.row;
    regCell.sectionNumber              = indexPath.section;
    
    NSString *celltext = [self getDataForCell:indexPath];
    
    if (![MRCommon isStringEmpty:celltext]) {
        regCell.inputTextField.text = celltext;
    }
    
    if (indexPath.row == 2)
    {
        [regCell configureSingleInput:NO];
        NSArray *strObjs = [celltext componentsSeparatedByString:@"-"];
        regCell.mTwoTextField.placeholder = [kPlaceHolders objectAtIndex:indexPath.row + 1];
        regCell.mOneTextFiled.placeholder = [kPlaceHolders objectAtIndex:indexPath.row];
        
        if (strObjs.count > 0 && ![MRCommon isStringEmpty:[strObjs objectAtIndex:0]]) {
            regCell.mOneTextFiled.text = [strObjs objectAtIndex:0];
        }
        
        if (strObjs.count > 1 &&  ![MRCommon isStringEmpty:[strObjs objectAtIndex:1]]) {
            regCell.mTwoTextField.text = [strObjs objectAtIndex:1];
        }
    }
    else
    {
        [regCell configureSingleInput:YES];
    }
    
    if (indexPath.row == 3)
    {
        regCell.inputTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        regCell.cellType = MRCellTypeNumeric;
    }
    else
    {
        regCell.cellType = MRCellTypeNone;
    }
    return regCell;
}

- (MRRegTableViewCell*)configureCellForPharmarep:(MRRegTableViewCell*)regCell atIndexPath:(NSIndexPath *)indexPath
{
    regCell.inputTextField.placeholder =   [kPharmaPlaceHolders objectAtIndex:indexPath.row];
    regCell.rowNumber                  = indexPath.row;
    regCell.sectionNumber              = indexPath.section;
    
    NSString *celltext = [self getPharamaDataForCell:indexPath];
    
    if (![MRCommon isStringEmpty:celltext]) {
        regCell.inputTextField.text = celltext;
    }
    
    [regCell configureSingleInput:YES];
    
    if (indexPath.row == 2)
    {
        regCell.inputTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        regCell.cellType = MRCellTypeNumeric;
    }
    else if (indexPath.row == 1)
    {
        regCell.inputTextField.keyboardType = UIKeyboardTypeEmailAddress;
        regCell.cellType = MRCellTypeNone;
    }
    else
    {
        regCell.inputTextField.keyboardType = UIKeyboardTypeAlphabet;
        regCell.cellType = MRCellTypeNone;
    }
    
    return regCell;
}

- (NSString*)getDataForCell:(NSIndexPath*)path
{
    NSDictionary *sectDict = [self getDataByAddressType:path];
    
    if (([[sectDict objectForKey:KType] intValue] == 1 || [[sectDict objectForKey:KType] isEqualToString:@""])&& self.selectedAddressType == 1)
    {
        switch (path.row)
        {
            case 0:
                return [sectDict objectForKey:KAddressOne];
                break;
                
            case 1:
                return [sectDict objectForKey:KAdresstwo];
                break;
                
            case 2:
                return [NSString stringWithFormat:@"%@-%@",[sectDict objectForKey:KState],[sectDict objectForKey:KCity]];
                break;
            case 3:
                return [sectDict objectForKey:KZIPCode];
                break;
            default:
                break;
        }
    }
    else
    {
        switch (path.row)
        {
            case 0:
                return [sectDict objectForKey:KAddressOne];
                break;
                
            case 1:
                return [sectDict objectForKey:KAdresstwo];
                break;
                
            case 2:
                return (sectDict) ? [NSString stringWithFormat:@"%@-%@",[sectDict objectForKey:KState],[sectDict objectForKey:KCity]] : @"";
                break;
            case 3:
                return [sectDict objectForKey:KZIPCode];
                break;
            default:
                break;
        }
    }
    return @"";
}



- (NSMutableDictionary*)getDataByAddressType:(NSIndexPath*)path
{
    NSArray *sectDict = [self.userDeatils objectForKey:KRegistarionStageTwo];
    
    NSMutableArray * dataOne = [[NSMutableArray alloc] init];
    for(NSMutableDictionary *dict in sectDict)
    {
        if ([[dict objectForKey:KType] intValue] == self.selectedAddressType  && (self.selectedUserType == 3 || self.selectedUserType == 1  || self.selectedUserType == 2))
        {
             [dataOne addObject:dict];
        }
        else if ((self.selectedAddressType == 1 && [[dict objectForKey:KType] isEqualToString:@""]) && (self.selectedUserType == 3 || self.selectedUserType == 1  || self.selectedUserType == 2))
        {
            [dataOne addObject:dict];
        }
        else  if ((self.selectedUserType == 3  || self.selectedUserType == 4))
        {
            [dataOne addObject:dict];
        }
        
    }

    return (dataOne.count > 0 && dataOne.count > path.section) ? [dataOne objectAtIndex:path.section] : nil;
}


- (NSInteger)getAddressCountByType:(NSInteger)addressType
{
    NSArray *sectDict = [self.userDeatils objectForKey:KRegistarionStageTwo];
    
    NSMutableArray * dataOne = [[NSMutableArray alloc] init];
    for(NSMutableDictionary *dict in sectDict)
    {
        if ([[dict objectForKey:KType] intValue] == addressType  && (self.selectedUserType == 3 || self.selectedUserType == 1  || self.selectedUserType == 2))
        {
            [dataOne addObject:dict];
        }
        else if ((addressType == 1 && [[dict objectForKey:KType] isEqualToString:@""]) && (self.selectedUserType == 3 || self.selectedUserType == 1  || self.selectedUserType == 2))
        {
            [dataOne addObject:dict];
        }
        else  if ((self.selectedUserType == 3  || self.selectedUserType == 4))
        {
            [dataOne addObject:dict];
        }
        
    }
    
    return dataOne.count;
}

- (NSString*)getPharamaDataForCell:(NSIndexPath*)path
{
    switch (path.row)
    {
        case 0:
            return [self.userDeatils objectForKey:kManagerName];
            break;
            
        case 1:
            return [self.userDeatils objectForKey:kManagerEmail];
            break;
            
        case 2:
            return [self.userDeatils objectForKey:kManagerMobileNumber];
            break;
        default:
            break;
    }
    return @"";
}


- (void)setDataForCell:(MRRegTableViewCell*)cell
{
    NSMutableDictionary *sectDict = [self getDataByAddressType:[NSIndexPath indexPathForRow:cell.rowNumber inSection:cell.sectionNumber]];
   // if (cell.sectionNumber == 0)
    
    if ([[sectDict objectForKey:@"type"] intValue] == 1 && self.selectedAddressType == 1)
    {
        {
            [sectDict setObject:@"1" forKey:KType];
            switch (cell.rowNumber)
            {
                case 0:
                    [sectDict setObject:cell.inputTextField.text forKey:KAddressOne];
                    break;
                    
                case 1:
                    [sectDict setObject:cell.inputTextField.text forKey:KAdresstwo];
                    break;
                case 3:
                    [sectDict setObject:cell.inputTextField.text forKey:KZIPCode];
                    break;
                default:
                    break;
            }
        }
    }
    else
    {
        {
            [sectDict setObject:@"2" forKey:KType];

            switch (cell.rowNumber)
            {
                case 0:
                    [sectDict setObject:cell.inputTextField.text forKey:KAddressOne];
                    break;
                    
                case 1:
                    [sectDict setObject:cell.inputTextField.text forKey:KAdresstwo];
                    break;
                case 3:
                    [sectDict setObject:cell.inputTextField.text forKey:KZIPCode];
                    break;
                default:
                    break;
            }
        }
    }

}

- (void)setDataForPharmaCell:(MRRegTableViewCell*)cell
{
    switch (cell.rowNumber)
    {
        case 0:
            [[[MRAppControl sharedHelper] userRegData] setObject:cell.inputTextField.text forKey:kManagerName];
            break;
            
        case 1:
            [[[MRAppControl sharedHelper] userRegData] setObject:cell.inputTextField.text forKey:kManagerEmail];
            break;
            
        case 2:
            [[[MRAppControl sharedHelper] userRegData] setObject:cell.inputTextField.text forKey:kManagerMobileNumber];
            break;
            
        default:
            break;
    }
}

- (void)mOneButtonActionDelegate:(MRRegTableViewCell*)cell
{
     NSMutableDictionary *sectDict = [self getDataByAddressType:[NSIndexPath indexPathForRow:cell.rowNumber inSection:cell.sectionNumber]];
    if ([[sectDict objectForKey:@"type"] intValue] == 1 && self.selectedAddressType == 1)
    {
        [sectDict setObject:cell.mOneTextFiled.text forKey:KState];
    }
    else
    {
        [sectDict setObject:cell.mOneTextFiled.text forKey:KState];
    }
    [self  showHideFiltersView:cell withAdjustableValue:NO];
}

- (void)mTwoButtonActionDelegate:(MRRegTableViewCell*)cell
{
     NSMutableDictionary *sectDict = [self getDataByAddressType:[NSIndexPath indexPathForRow:cell.rowNumber inSection:cell.sectionNumber]];
    if ([[sectDict objectForKey:@"type"] intValue] == 1 && self.selectedAddressType == 1)
    {
        [sectDict setObject:cell.mTwoTextField.text forKey:KCity];
    }
    else
    {
        [sectDict setObject:cell.mTwoTextField.text forKey:KCity];
    }
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
    if ((1 == self.selectedUserType || 2 == self.selectedUserType) || (self.selectedUserType == 3 && self.registrationStage == 1) || (self.selectedUserType == 4 && self.registrationStage == 1))
    {
        [self setDataForCell:cell];
    }
    else if ((self.selectedUserType == 3 && self.registrationStage == 2) || (self.selectedUserType == 4 && self.registrationStage == 2))
    {
        [self setDataForPharmaCell:cell];
    }
    [self  showHideFiltersView:cell withAdjustableValue:NO];
}

- (void)showHideFiltersView:(MRRegTableViewCell*)cell
        withAdjustableValue:(BOOL)isBeginEditing
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.isKeyboardUp = isBeginEditing;
    
    if ([MRCommon deviceHasThreePointFiveInchScreen])
    {
        if ([MRAppControl sharedHelper].userType == 3 && self.registrationStage == 2)
        {
            self.tableviewTopConstarint.constant = 115;
        }
        else if ((1 == self.selectedUserType || 2 == self.selectedUserType))
        {
            self.tableviewTopConstarint.constant = (!isBeginEditing) ? 215 : 185;
            self.topClinicViewConstraint.constant = (!isBeginEditing) ? 120 : 90;
        }
    }
    
    self.regTableView.contentInset = (isBeginEditing) ? UIEdgeInsetsMake(-30, 0, 180, -20) : UIEdgeInsetsMake(-30, 0, 0, -20) ;
    if (!isBeginEditing)
    {
        [self updateViewsToDefaultConstarints];
    }
    
    [self.regTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:cell.rowNumber inSection:cell.sectionNumber] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    [self updateViewConstraints];
    [UIView commitAnimations];
}

//Header View Delegates
- (void)addButtonClicked:(NSInteger)addType
{
    if (self.isKeyboardUp)
    {
        [self.view endEditing:YES];
        return;
    }

    if (addType == 0)
    {
        if (self.selectedAddressType == 1)
        {
            if (self.numberOfSections <= 2)
            {
                MRRegHeaderView *headerView = [MRRegHeaderView regHeaderView];
                headerView.addLabel.text = [NSString stringWithFormat:@"ADDRESS 2"];
                headerView.section = self.numberOfSections - 1;
                headerView.backgroundColor = [UIColor clearColor];
                headerView.delegate = self;
                headerView.addIconImage.image = [UIImage imageNamed:@"minus.png"];
                headerView.pickLocationButton.hidden = NO;
                headerView.pickLocationImage.hidden = NO;
                [self.sectionsArray insertObject:headerView atIndex:self.numberOfSections - 2];
                
                NSMutableArray *array = [self.userDeatils objectForKey:KRegistarionStageTwo];
                if ([self getAddressCountByType:1] < 2) {
                    [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@" ",KAddressOne, @" ",KAdresstwo, @" ",KZIPCode, @" ",KState, @" ",KCity, [NSString stringWithFormat:@"%ld", (long)self.selectedAddressType],KType, nil]];
                }
                
                self.numberOfSections++;
            }
        }
        else
        {
            if (self.numberOfSectionsTwoTypes <= 2)
            {
                MRRegHeaderView *headerView = [MRRegHeaderView regHeaderView];
                headerView.addLabel.text = [NSString stringWithFormat:@"ADDRESS 2"];
                headerView.section = self.numberOfSectionsTwoTypes - 1;
                headerView.backgroundColor = [UIColor clearColor];
                headerView.delegate = self;
                headerView.addIconImage.image = [UIImage imageNamed:@"minus.png"];
                headerView.pickLocationButton.hidden = NO;
                headerView.pickLocationImage.hidden = NO;
                [self.addressTwosectionsArray insertObject:headerView atIndex:self.numberOfSectionsTwoTypes - 2];
                
                NSMutableArray *array = [self.userDeatils objectForKey:KRegistarionStageTwo];
                if ([self getAddressCountByType:2] < 2) {
                    [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@" ",KAddressOne, @" ",KAdresstwo, @" ",KZIPCode, @" ",KState, @" ",KCity, [NSString stringWithFormat:@"%ld", self.selectedAddressType],KType, nil]];
                }
                
                self.numberOfSectionsTwoTypes++;
            }
        }
    }
    else
    {
        if (self.selectedAddressType == 1)
        {
            [self.sectionsArray removeObjectAtIndex:self.numberOfSections - 3];
            self.numberOfSections--;

            NSMutableArray *array = [self.userDeatils objectForKey:KRegistarionStageTwo];
            NSMutableDictionary *data = [self getDataByAddressType:[NSIndexPath indexPathForRow:0 inSection:self.numberOfSections - 1]];
            NSInteger index = [array indexOfObject:data];
            [array removeObjectAtIndex:index];
        }
        else
        {            
            [self.addressTwosectionsArray removeObjectAtIndex:self.numberOfSectionsTwoTypes - 3];
            self.numberOfSectionsTwoTypes--;
            
            NSMutableArray *array = [self.userDeatils objectForKey:KRegistarionStageTwo];
            NSMutableDictionary *data = [self getDataByAddressType:[NSIndexPath indexPathForRow:0 inSection:self.numberOfSectionsTwoTypes - 1]];
            NSInteger index = [array indexOfObject:data];
            [array removeObjectAtIndex:index];
        }
    }
    
    [self.regTableView reloadData];
  //  NSLog(@"Header View Delegates");
}

- (void)pickLocationButtonActionDelegate:(MRRegHeaderView*)section
{
    [self addLocationInSection:(self.selectedAddressType == 1) ? [self.sectionsArray indexOfObject:section] : [self.addressTwosectionsArray indexOfObject:section]];
}
- (BOOL)validateData
{
    BOOL isSuccess = YES;
    if ((1 == self.selectedUserType || 2 == self.selectedUserType) || (self.selectedUserType == 3 && self.registrationStage == 1)) {
        
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
                //            if ([MRCommon isStringEmpty:[dict objectForKey:KAdresstwo]])
                //            {
                //                [MRCommon showAlert:@"Address line 2 should not be empty." delegate:nil];
                //                isSuccess = NO;
                //                break;
                //            }
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
//                else
//                {
////                    if ([[dict objectForKey:KZIPCode] length] != 6)
////                    {
////                        [MRCommon showAlert:@"Provide a valid Zipcode." delegate:nil];
////                        isSuccess = NO;
////                        break;
////                    }
//                    
//                }
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
//                    else
////                    {
//////                        if ([[dict objectForKey:KZIPCode] length] != 6)
//////                        {
//////                            [MRCommon showAlert:@"Provide a valid Zipcode." delegate:nil];
//////                            isSuccess = NO;
//////                            break;
//////                        }
////                        
////                    }
                }
            }
        }
    }
    else if (self.selectedUserType == 3 && self.registrationStage == 2)
    {
        if (![MRCommon isStringEmpty:[[[MRAppControl sharedHelper] userRegData] objectForKey:kManagerEmail]])
        {
            if (![MRCommon validateEmailWithString:[[[MRAppControl sharedHelper] userRegData] objectForKey:kManagerEmail]])
            {
                [MRCommon showAlert:@"Provide a valid email." delegate:nil];
                isSuccess = NO;
                return isSuccess;
            }
        }

//        if ([MRCommon isStringEmpty:[[[MRAppControl sharedHelper] userRegData] objectForKey:kManagerName]])
//        {
//            [MRCommon showAlert:@"Reporting Manager Name should not be empty." delegate:nil];
//            isSuccess = NO;
//            return isSuccess;
//        }
//        else if (![MRCommon validateEmailWithString:[[[MRAppControl sharedHelper] userRegData] objectForKey:kManagerEmail]])
//        {
//            [MRCommon showAlert:@"Provide a valid email." delegate:nil];
//            isSuccess = NO;
//            return isSuccess;
//        }
//        else if ([MRCommon isStringEmpty:[[[MRAppControl sharedHelper] userRegData] objectForKey:kManagerMobileNumber]])
//        {
//            [MRCommon showAlert:@"Reporting Manager Mobile number should not be empty." delegate:nil];
//            isSuccess = NO;
//            return isSuccess;
//        }
//        else if ([[[[MRAppControl sharedHelper] userRegData] objectForKey:kManagerMobileNumber] length] != 10)
//        {
//            [MRCommon showAlert:@"Provide a valid Mobilenumber." delegate:nil];
//            isSuccess = NO;
//            return isSuccess;
//        }
    }

    return isSuccess;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 6789 )
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

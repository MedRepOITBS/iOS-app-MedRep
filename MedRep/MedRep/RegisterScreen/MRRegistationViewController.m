//
//  MRRegistationViewController.m
//  MedRep
//
//  Created by MedRep Developer on 16/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRRegistationViewController.h"
#import "MRRegistationTwoViewController.h"
#import "MRListViewController.h"
#import "WYPopoverController.h"
#import "MRAddressView.h"
#import "MRCommon.h"
#import "MRAppControl.h"
#import "MRConstants.h"
#import "MRWebserviceHelper.h"
#import "MRLocationManager.h"

#define kHeaderView     [NSArray arrayWithObjects:@"ADD MOBILE NUMBER",@"ALTERNATIVE EMAIL ADDRESS", nil]
#define kPlaceHolders   [NSArray arrayWithObjects:@"DOCTOR REGISTRATION ID", @"FIRST NAME", @"LAST NAME", @"MOBILE NUMBER", @"MOBILE NUMBER", nil]

//@"PRIMARY MOBILE NUMBER"

#define kCompanyID      @"COMPANY ID"

#define kDocCellTypes [NSArray arrayWithObjects:[NSNumber numberWithInt:MRCellTypeNumeric],[NSNumber numberWithInt:MRCellTypeAlphabets], [NSNumber numberWithInt:MRCellTypeAlphabets], [NSNumber numberWithInt:MRCellTypeNumeric], [NSNumber numberWithInt:MRCellTypeNumeric], nil]


typedef void(^selectedComapany)(NSString *companyName);



@interface MRRegistationViewController ()<UITableViewDelegate, UITableViewDataSource,WYPopoverControllerDelegate,MRListViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UITableView *registrationTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) NSMutableArray *sectionsArray;
@property (assign, nonatomic) NSInteger sectionOneRows;
@property (assign, nonatomic) NSInteger sectionsTwoRows;
@property (assign, nonatomic) BOOL isKeyboardUp;
@property (strong, nonatomic) NSMutableDictionary *userDeatils;
@property (assign, nonatomic) NSInteger selectedUserType;
@property (strong, nonatomic) WYPopoverController *myPopoverController;
@property (nonatomic, strong) selectedComapany userSelectedCompany;
@end

@implementation MRRegistationViewController

- (void)viewDidLoad {
    
    self.userDeatils = [[MRAppControl sharedHelper] userRegData];
    self.selectedUserType = [MRAppControl sharedHelper].userType;
    [self setUPView];
    
    if (!self.isFromSinUp)
    {
        [self.nextButton setTitle:@"UPDATE" forState:UIControlStateNormal];
    }
    
    [super viewDidLoad];
    
    self.registrationTable.contentInset = UIEdgeInsetsMake(-30, 0, 0, -20);
    // Do any additional setup after loading the view from its nib.
}

-(void)setUPView
{
    if (!self.isFromSinUp)
    {
        self.sectionsTwoRows = [self getEmailCount:[self.userDeatils objectForKey:KEmail]];
        self.sectionOneRows  = 3 + [self getMobileNumberCount:[self.userDeatils objectForKey:KMobileNumber]];
        self.sectionsArray = [[NSMutableArray alloc] init];
        int i = 0;
        
        for (NSString *title in kHeaderView)
        {
            MRRegHeaderView *headerView = [MRRegHeaderView regHeaderView];
            headerView.addLabel.text = title;
            headerView.backgroundColor = [UIColor clearColor];
            headerView.section = ++i;
            headerView.delegate = self;
            headerView.pickLocationImageWidthConstraint.constant = 0;
            headerView.pickLocationButtonWidthConstraint.constant = 0;
            [headerView updateConstraints];
            [self.sectionsArray addObject:headerView];
        }
        
            if (self.sectionOneRows == 5)
            {
                [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:0] addLabel] setText:@"REMOVE"];
                [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:0] addIconImage] setImage:[UIImage imageNamed:@"minus.png"]];
            }
            else
            {
                [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:0] addLabel] setText:@"ADD MOBILE NUMBER"];
                [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:0] addIconImage] setImage:[UIImage imageNamed:@"addicon.png"]];
            }
        
            if (self.sectionsTwoRows == 2)
            {
                [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:1] addLabel] setText:@"REMOVE"];
                [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:1] addIconImage] setImage:[UIImage imageNamed:@"minus.png"]];
                
            }
            else
            {
                [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:1] addLabel] setText:@"ALTERNATIVE EMAIL ADDRESS"];
                [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:1] addIconImage] setImage:[UIImage imageNamed:@"addicon.png"]];
            }

    }
    else
    {
        self.sectionsTwoRows = 1;
        self.sectionOneRows  = 4;
        self.sectionsArray = [[NSMutableArray alloc] init];
        int i = 0;
        
        for (NSString *title in kHeaderView)
        {
            MRRegHeaderView *headerView = [MRRegHeaderView regHeaderView];
            headerView.addLabel.text = title;
            headerView.backgroundColor = [UIColor clearColor];
            headerView.section = ++i;
            headerView.delegate = self;
            headerView.pickLocationImageWidthConstraint.constant = 0;
            headerView.pickLocationButtonWidthConstraint.constant = 0;
            [headerView updateConstraints];
            [self.sectionsArray addObject:headerView];
        }
    }
    
    if ([MRCommon deviceHasFourInchScreen])
    {
        self.bottomConstraint.constant = 30;
    }
    else if ([MRCommon deviceHasFourPointSevenInchScreen])
    {
        self.bottomConstraint.constant = 50;
    }
    else if ([MRCommon deviceHasFivePointFiveInchScreen])
    {
        self.bottomConstraint.constant = 50;
    }
}

- (NSInteger)getEmailCount:(NSArray*)emaileNumbers
{
    NSInteger count = 0;
    for (NSString *email in emaileNumbers)
    {
        if (![MRCommon isStringEmpty:email]) {
            ++count;
        }
    }
    return count;
}

- (NSInteger)getMobileNumberCount:(NSArray*)mobileNumbers
{
    NSInteger count = 0;
    for (NSString *mobile in mobileNumbers)
    {
        if (![MRCommon isStringEmpty:mobile]) {
            ++count;
        }
    }
    return count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 2:
            return 40.0;
            break;
        case 1:
            return 40.0;
            break;
        default:
            return 0.0;
            break;
    }

    return 0.0;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 2:
            return [self.sectionsArray objectAtIndex:section -1];
            break;
        case 1:
            return [self.sectionsArray objectAtIndex:section -1];
            break;
        default:
            return nil;
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 2:
            return self.selectedUserType == 3 ? 1 : 0;
            break;
        case 1:
            return self.sectionsTwoRows;
            break;
        case 0:
            return self.sectionOneRows;
            break;
    }
    return 0;
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
    
    regCell.delegate = self;
    regCell.rowNumber = indexPath.row;
    regCell.isUserPesronalDetails = YES;
    regCell.regType = 1; // 1 for doc , 2 for pharma
    regCell.sectionNumber = indexPath.section;
    regCell.inputTextField.placeholder = (indexPath.section == 0) ?  (kPlaceHolders.count > indexPath.row) ? [kPlaceHolders objectAtIndex:indexPath.row] : [kPlaceHolders lastObject] : @"E-MAIL ADDRESS";
    
    regCell.cellType = (indexPath.section == 0) ?  (kDocCellTypes.count > indexPath.row) ? [[kDocCellTypes objectAtIndex:indexPath.row] intValue] : [[kDocCellTypes lastObject] intValue] : MRCellTypeNone;

    NSString *celltext = [self getDataForCell:indexPath];
    
    if (![MRCommon isStringEmpty:celltext]) {
        regCell.inputTextField.text = celltext;
    }
    
    [regCell configureSingleInput:YES];

    if (indexPath.row == 0 && indexPath.section == 0 && ([MRAppControl sharedHelper].userType == 3 || [MRAppControl sharedHelper].userType == 4))
    {        
        regCell.areaLocationTextField.keyboardType = UIKeyboardTypeAlphabet;
        regCell.areaLocationTextField.placeholder = @"Select Your Company";
        
        if (![MRCommon isStringEmpty:celltext]) {
            regCell.areaLocationTextField.text = celltext;
        }
        
        if (!self.isFromSinUp) {
            regCell.dropDownImage.hidden = YES;
        }
        
        regCell.cellType = MRCellTypeNone;
        [regCell configureAreaInput:YES];
    }

    if (indexPath.section == 0 && (indexPath.row >= 3 || indexPath.row == 0)) {
        regCell.inputTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    else if (indexPath.section == 1)
    {
        regCell.inputTextField.keyboardType = UIKeyboardTypeEmailAddress;
        regCell.cellType = MRCellTypeNone;
    }
    else if (indexPath.section == 2)
    {
        
        regCell.inputTextField.keyboardType = UIKeyboardTypeAlphabet;
        regCell.inputTextField.placeholder = @"Areas Covered";
        
        if (![MRCommon isStringEmpty:celltext]) {
            regCell.inputTextField.text = celltext;
        }
        
        regCell.cellType = MRCellTypeAlphabets;

//        regCell.areaLocationTextField.keyboardType = UIKeyboardTypeAlphabet;
//        regCell.areaLocationTextField.placeholder = @"Areas Covered";
//        
//        if (![MRCommon isStringEmpty:celltext]) {
//            regCell.areaLocationTextField.text = celltext;
//        }
//        
//        regCell.cellType = MRCellTypeNone;
//        [regCell configureAreaInput:YES];
    }
    
    if (self.isFromEditing)
    {
        if (((indexPath.row == 0 || indexPath.row == 3)  && indexPath.section == 0 ) || (indexPath.row == 0 && indexPath.section == 1))
        {
            regCell.userInteractionEnabled = NO;
        }
        else
        {
            regCell.userInteractionEnabled = YES;
        }
    }
    else
    {
        regCell.userInteractionEnabled = YES;
    }
    return regCell;
}

- (NSString*)getDataForCell:(NSIndexPath*)path
{
    if (path.section == 0)
    {
        switch (path.row)
        {
            case 0:
            {
                if ([MRAppControl sharedHelper].userType == 3 || [MRAppControl sharedHelper].userType == 4)
                {
                   // [self.userDeatils setObject:[item objectForKey:@"companyId"] forKey:KDoctorRegID];
                    NSDictionary *comapany = [[MRAppControl sharedHelper] getCompanyDetailsByID:[[self.userDeatils objectForKey:KDoctorRegID] integerValue]];
                    return [comapany objectForKey:@"companyName"]; // company name from id
                }
                else
                {
                    return [self.userDeatils objectForKey:KDoctorRegID];
                }
            }
                break;
                
            case 1:
                return [self.userDeatils objectForKey:KFirstName];
                break;
            case 2:
                return [self.userDeatils objectForKey:KLastName];
                break;
            case 3:
            {
                if ([[[self.userDeatils objectForKey:KMobileNumber] objectAtIndex:0] isEqual:[NSNull null]]) {
                    return @"";
                } else {
                    return [[self.userDeatils objectForKey:KMobileNumber] objectAtIndex:0];
                }
                break;
 
            }
            case 4:
            {
                if ([[[self.userDeatils objectForKey:KMobileNumber] objectAtIndex:1] isEqual:[NSNull null]]) {
                    return @"";
                } else {
                    return [[self.userDeatils objectForKey:KMobileNumber] objectAtIndex:1];
                }
            }
                break;
                
            default:
                break;
        }
    }
    else if (path.section == 1)
    {
        switch (path.row)
        {
            case 0:
                return [[self.userDeatils objectForKey:KEmail] objectAtIndex:0];
                break;
                
            case 1:
                return [[self.userDeatils objectForKey:KEmail] objectAtIndex:1];
                break;
            default:
                break;
        }
    }
    else if (path.section == 2)
    {
        return [self.userDeatils objectForKey:KAreasCovered];
    }
    return @"";
}

- (IBAction)backButtonAction:(id)sender {
    if (self.isFromSinUp)
    {
        [[MRAppControl sharedHelper] resetUserData];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
       // [[MRAppControl sharedHelper] loadDashboardScreen];
    }
}

//    if (self.isFromSinUp)
//{
//    [[MRAppControl sharedHelper] resetUserData];
//}


- (IBAction)nextButtonAction:(id)sender
{
    if (self.isFromSinUp)
    {
        if ([self validateData])
        {
            MRRegistationTwoViewController *regTwoViewController = [[MRRegistationTwoViewController alloc] initWithNibName:@"MRRegistationTwoViewController" bundle:nil];
            regTwoViewController.isFromSinUp = self.isFromSinUp;
            regTwoViewController.isFromEditing = NO;
            regTwoViewController.registrationStage = 1;
            [self.navigationController pushViewController:regTwoViewController animated:YES];
        }
    }
    else
    {
        if ([MRAppControl sharedHelper].userType == 1 || [MRAppControl sharedHelper].userType == 2)
        {
            if ([self validateData])
            {
                [self updateDoctorRegistration];
            }
        }
        else if ([MRAppControl sharedHelper].userType == 3 || [MRAppControl sharedHelper].userType == 4)
        {
            if ([self validateData])
            {
                [self updatePharmaRegistration];
            }
        }
    }
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

- (void)mOneButtonActionDelegate:(MRRegTableViewCell*)cell
{
}

- (void)mTwoButtonActionDelegate:(MRRegTableViewCell*)cell
{
    
}

- (void)areaWorkLocationButtonActionDelegate:(MRRegTableViewCell*)cell;
{
    [self setDataForCell:cell];
    [self.view endEditing:YES];
    //[self  showHideFiltersView:cell withAdjustableValue:NO];
}

- (void)showCompanyList:(MRRegTableViewCell*)cell forCompanyName:(void (^)(NSString *companyName))seletecName
{
    self.userSelectedCompany = seletecName;
    [self showPopoverInView:cell.areaWorkLocation];
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

- (void)setDataForCell:(MRRegTableViewCell*)cell
{
    if (cell.sectionNumber == 0)
    {
        switch (cell.rowNumber)
        {
            case 0:
            {
                if ([MRAppControl sharedHelper].userType == 3)
                {
                    [self.userDeatils setObject:cell.inputTextField.text forKey:KDoctorRegID]; /// set company id from name
                }
                else
                {
                    [self.userDeatils setObject:cell.inputTextField.text forKey:KDoctorRegID];
                }
            }
                break;
                
            case 1:
                 [self.userDeatils setObject:cell.inputTextField.text forKey:KFirstName];
                break;
            case 2:
                 [self.userDeatils setObject:cell.inputTextField.text forKey:KLastName];
                break;
                
            case 3:
            {
                NSMutableArray *array = [self.userDeatils objectForKey:KMobileNumber];
                [array replaceObjectAtIndex:0 withObject:cell.inputTextField.text];
            }
                break;
                
            case 4:
            {
                NSMutableArray *array = [self.userDeatils objectForKey:KMobileNumber];
                [array replaceObjectAtIndex:1 withObject:cell.inputTextField.text];
            }
                break;
                
            case 5:
            {
                NSMutableArray *array = [self.userDeatils objectForKey:KMobileNumber];
                [array replaceObjectAtIndex:2 withObject:cell.inputTextField.text];
            }
                break;
            default:
                break;
        }
    }
    else if (cell.sectionNumber == 1)
    {
        switch (cell.rowNumber)
        {
            case 0:
            {
                NSMutableArray *array = [self.userDeatils objectForKey:KEmail];
                [array replaceObjectAtIndex:0 withObject:cell.inputTextField.text];
            }
                break;
                
            case 1:
            {
                NSMutableArray *array = [self.userDeatils objectForKey:KEmail];
                [array replaceObjectAtIndex:1 withObject:cell.inputTextField.text];
            }
                break;
            default:
                break;
        }
    }
    else if (cell.sectionNumber == 2)
    {
//         [self.userDeatils setObject:cell.areaLocationTextField.text forKey:KAreasCovered];
        [self.userDeatils setObject:cell.inputTextField.text forKey:KAreasCovered];

    }
}

- (void)removeDataForCell:(MRRegTableViewCell*)cell
{
    if (cell.sectionNumber == 0)
    {
        switch (cell.rowNumber)
        {
            case 0:
            {
                if ([MRAppControl sharedHelper].userType == 3)
                {
                    [self.userDeatils setObject:cell.inputTextField.text forKey:KDoctorRegID]; /// set company id from name
                }
                else
                {
                }
            }
                break;
                
            case 1:
                break;
            case 2:
                break;
                
            case 3:
            {
            }
                break;
                
            case 4:
            {
                NSMutableArray *array = [self.userDeatils objectForKey:KMobileNumber];
                [array replaceObjectAtIndex:1 withObject:cell.inputTextField.text];
            }
                break;
                
            case 5:
            {
                NSMutableArray *array = [self.userDeatils objectForKey:KMobileNumber];
                [array removeObjectAtIndex:1];
            }
                break;
            default:
                break;
        }
    }
    else if (cell.sectionNumber == 1)
    {
        switch (cell.rowNumber)
        {
            case 0:
            {
                NSMutableArray *array = [self.userDeatils objectForKey:KEmail];
                [array replaceObjectAtIndex:0 withObject:cell.inputTextField.text];
            }
                break;
                
            case 1:
            {
                NSMutableArray *array = [self.userDeatils objectForKey:KEmail];
                [array removeObjectAtIndex:1];
            }
                break;
            default:
                break;
        }
    }
    else if (cell.sectionNumber == 2)
    {
        //         [self.userDeatils setObject:cell.areaLocationTextField.text forKey:KAreasCovered];
        [self.userDeatils setObject:cell.inputTextField.text forKey:KAreasCovered];
        
    }
}

- (BOOL)validateData
{
    BOOL isSuccess = YES;
    if ([MRAppControl sharedHelper].userType == 1)
    {
        if ([MRCommon isStringEmpty:[self.userDeatils objectForKey:KDoctorRegID]])
        {
            [MRCommon showAlert:@"Doctor registration ID should not be empty." delegate:nil];
            isSuccess = NO;
            return isSuccess;
        }
    }
    else if ([MRAppControl sharedHelper].userType == 3)
    {
        if ([[self.userDeatils objectForKey:KDoctorRegID] integerValue] == 0 )
        {
            [MRCommon showAlert:@"COMPANY ID should not be empty." delegate:nil];
            isSuccess = NO;
            return isSuccess;
        }

    }
    
    if ([MRCommon isStringEmpty:[self.userDeatils objectForKey:KFirstName]])
    {
        [MRCommon showAlert:@"First name should not be empty." delegate:nil];
        isSuccess = NO;
        return isSuccess;
    }
    
    if ([MRCommon isStringEmpty:[self.userDeatils objectForKey:KLastName]])
    {
        [MRCommon showAlert:@"Last name should not be empty." delegate:nil];
        isSuccess = NO;
        return isSuccess;
    }
    
    if ([MRCommon isStringEmpty:[[self.userDeatils objectForKey:KMobileNumber] objectAtIndex:0]])
    {
        [MRCommon showAlert:@"Mobile number should not be empty." delegate:nil];
        isSuccess = NO;
        return isSuccess;
    }
    else
    {
        if ([[[self.userDeatils objectForKey:KMobileNumber] objectAtIndex:0] length] != 10)
        {
            [MRCommon showAlert:@"Provide a valid Mobilenumber." delegate:nil];
            isSuccess = NO;
            return isSuccess;
        }
    }
    
    if ([MRCommon isStringEmpty:[[self.userDeatils objectForKey:KMobileNumber] objectAtIndex:1]] && self.sectionOneRows == 5)
    {
        [MRCommon showAlert:@"Mobile number should not be empty." delegate:nil];
        isSuccess = NO;
        return isSuccess;
    }
    else if(self.sectionOneRows == 5)
    {
        if ([[[self.userDeatils objectForKey:KMobileNumber] objectAtIndex:1] length] != 10)
        {
            [MRCommon showAlert:@"Provide a valid alternate Mobilenumber." delegate:nil];
            isSuccess = NO;
            return isSuccess;
        }
    }
    
    if (![MRCommon validateEmailWithString:[[self.userDeatils objectForKey:KEmail] objectAtIndex:0]])
    {
        [MRCommon showAlert:@"Provide a valid email." delegate:nil];
        isSuccess = NO;
        return isSuccess;
    }
    
    if (![MRCommon validateEmailWithString:[[self.userDeatils objectForKey:KEmail] objectAtIndex:1]] && self.sectionsTwoRows == 2)
    {
        [MRCommon showAlert:@"Provide a valid alternate email." delegate:nil];
        isSuccess = NO;
        return isSuccess;
    }


    return isSuccess;
}

- (void)showHideFiltersView:(MRRegTableViewCell*)cell
        withAdjustableValue:(BOOL)isBeginEditing
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.isKeyboardUp = isBeginEditing;
    self.registrationTable.contentInset = (isBeginEditing) ? UIEdgeInsetsMake(-30, 0, 180, -20): UIEdgeInsetsMake(-30, 0, 0, -20) ;
    [self.registrationTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:cell.rowNumber inSection:cell.sectionNumber] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
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
    
    if (addType == 1)
    {
        if (self.sectionOneRows <= 4)
        {
            self.sectionOneRows++ ;
            [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:0] addLabel] setText:@"REMOVE"];
            [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:0] addIconImage] setImage:[UIImage imageNamed:@"minus.png"]];
        }
        else
        {
            self.sectionOneRows--;
            [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:0] addLabel] setText:@"ADD MOBILE NUMBER"];
            [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:0] addIconImage] setImage:[UIImage imageNamed:@"addicon.png"]];
            NSMutableArray *array = [self.userDeatils objectForKey:KMobileNumber];
            [array replaceObjectAtIndex:1 withObject:@""];

        }
    }
    else
    {
        if (self.sectionsTwoRows <= 1)
        {
            self.sectionsTwoRows++;
            [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:1] addLabel] setText:@"REMOVE"];
            [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:1] addIconImage] setImage:[UIImage imageNamed:@"minus.png"]];

        }
        else
        {
             self.sectionsTwoRows--;
            [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:1] addLabel] setText:@"ALTERNATIVE EMAIL ADDRESS"];
            [[(MRRegHeaderView*)[self.sectionsArray objectAtIndex:1] addIconImage] setImage:[UIImage imageNamed:@"addicon.png"]];
            
            NSMutableArray *array = [self.userDeatils objectForKey:KEmail];
            [array replaceObjectAtIndex:1 withObject:@""];

        }
    }
    
    [self.registrationTable reloadData];
}

- (void)pickLocationButtonActionDelegate:(MRRegHeaderView *)section
{
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
    moreViewController.listType = MRListVIewTypeCompanyList;
    moreViewController.listItems = [MRAppControl sharedHelper].companyDetails;
    
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
    [self.userDeatils setObject:[item objectForKey:@"companyId"] forKey:KDoctorRegID];
    self.userSelectedCompany([item objectForKey:@"companyName"]);
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 6789 )
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end

//
//  AddEducationTableViewController.m
//  MedRep
//
//  Created by Namit Nayak on 7/14/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "AddEducationViewController.h"
#import "CommonEducationTableViewCell.h"
#import "EducationDateTimeTableViewCell.h"
#import "NSString+Date.h"
#import "MRDatabaseHelper.h"
#import "NTMonthYearPicker.h"
#import "MRConstants.h"
#import "EducationalQualifications.h"

@interface AddEducationViewController () <EducationDateTimeTableViewCellDelegate, CommonEducationTableViewCellDelegate,NTMonthYearPickerViewDelegate>
@property (nonatomic,strong) UITextField *currentSelectedTextField;
@property (nonatomic,strong) NSString *fromYYYY;
@property (nonatomic,strong) NSString *toYYYY;
@property (nonatomic,strong) NSString *degree;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *speciality;
@property (nonatomic,strong) NSString *institute;
@property (nonatomic,strong) NTMonthYearPicker *picker;



@end

@implementation AddEducationViewController


-(void)setupPicker{
    CGRect pickerFrame = [UIScreen mainScreen].applicationFrame;
    pickerFrame.origin.y = pickerFrame.size.height - 350;
    _picker = [[NTMonthYearPicker alloc] initWithFrame:pickerFrame];
    [_picker setPickerDelegate:self];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    // Set mode to month + year
    // This is optional; default is month + year
    _picker.datePickerMode = NTMonthYearPickerModeMonthAndYear;
    
    // Set minimum date to January 2000
    // This is optional; default is no min date
    [comps setDay:1];
    [comps setMonth:1];
    [comps setYear:1990];
    _picker.minimumDate = [cal dateFromComponents:comps];
    
    // Set maximum date to next month
    // This is optional; default is no max date
    [comps setDay:0];
    [comps setMonth:0];
    [comps setYear:0];
    _picker.maximumDate = [cal dateByAddingComponents:comps toDate:[NSDate date] options:0];
    
    // Set initial date to last month
    // This is optional; default is current month/year
    [comps setDay:0];
    [comps setMonth:0];
    [comps setYear:0];
    _picker.date = [cal dateByAddingComponents:comps toDate:[NSDate date] options:0];
    _picker.hidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
   
    self.navigationItem.title  = @"Add Education Details";

//    [self initCustomDatePicker:self.customYearPicker withOption:NSCustomDatePickerOptionYear andOrder:NSCustomDatePickerOrderMonthDayAndYear];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"]  style:UIBarButtonItemStyleDone target:self action:@selector(backButtonTapped:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setupPicker];
    [self updateLabel];
    [self setUpdata];
}
-(void)setUpdata{
    
    
    UIBarButtonItem *revealButtonItem;
    
    if (_educationQualObj!=nil) {
        revealButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"UPDATE" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
        self.navigationItem.rightBarButtonItem = revealButtonItem;
        
        _degree = _educationQualObj.degree;
        _institute = _educationQualObj.collegeName;
        _speciality = _educationQualObj.course;
        _type = [_educationQualObj.aggregate stringValue];
        _fromYYYY = [[_educationQualObj.yearOfPassout componentsSeparatedByString:@"-"] objectAtIndex:0];
        _toYYYY = [[_educationQualObj.yearOfPassout componentsSeparatedByString:@"-"] objectAtIndex:1];
        
        
    }else{
        revealButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
        self.navigationItem.rightBarButtonItem = revealButtonItem;
    }
    
}
- (void)updateLabel {
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *stringFromDate;
    
    
    [formatter setDateFormat:@"YYYY"];
    stringFromDate = [formatter stringFromDate:_picker.date];
    if (_currentSelectedTextField.tag == 1200) {
        _fromYYYY = stringFromDate;
    }
    else if(_currentSelectedTextField.tag == 1201) {
        
        if([stringFromDate integerValue] < [_fromYYYY integerValue]){
            [MRCommon showAlert:@"From Year Cannot be smaller then To Year. Please change the year accordingly." delegate:nil];
            return ;
            
        }
        _toYYYY = stringFromDate;
        
    }
    
    
    
    NSLog(@"%@",stringFromDate);
    _currentSelectedTextField.text = stringFromDate;
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    //    CGSize pickerSize = _picker.frame.size;
    //    CGFloat temp = [UIScreen mainScreen].applicationFrame.size.width;
    //
    //    CGRect pickerFrame = CGRectMake( 0, [[UIScreen mainScreen] bounds].size.height - (pickerSize.height+50), temp, pickerSize.height );
    //    [_picker updateFrame:pickerFrame];
    
    _picker.backgroundColor = [UIColor lightTextColor];
    [self.view addSubview:_picker];
}
-(void)doneButtonTapped:(id)sender{
    if (![self isValidationSuccess]) {
        return;
    }
    
       NSDictionary * workExpDict;
    
    
    if ([_fromScreen isEqualToString:@"UPDATE"]) {
        
        workExpDict = [[NSDictionary alloc] initWithObjectsAndKeys:_degree,@"degree",_institute,@"collegeName",[NSString stringWithFormat:@"%@ - %@",_fromYYYY,_toYYYY],@"yearOfPassout",_speciality,@"course",_type,@"aggregate",_educationQualObj.id,@"id", nil];
        [MRDatabaseHelper updateEducationQualification:workExpDict withEducationQualificationID:_educationQualObj.id andHandler:^(id result) {
            
            if ([result isEqualToString:@"TRUE"]) {
                
                [MRCommon showAlert:@"Education Qualification Updated Successfully." delegate:nil];
                
                [self.navigationController popViewControllerAnimated:YES];
            }else{
            [MRCommon showAlert:@"Due to server error not able to update education details. Please try again later." delegate:nil];
                
            }
            
        }];
        
    }else{
        
        workExpDict = [[NSDictionary alloc] initWithObjectsAndKeys:_degree,@"degree",_institute,@"collegeName",[NSString stringWithFormat:@"%@ - %@",_fromYYYY,_toYYYY],@"yearOfPassout",_speciality,@"course",_type,@"aggregate", nil];
        [MRDatabaseHelper addEducationQualification:workExpDict andHandler:^(id result) {
         
            if ([result isEqualToString:@"TRUE"]) {
                
                [MRCommon showAlert:@"Education Qualification Added Successfully." delegate:nil];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];

    }
    
  
}
-(BOOL)isValidationSuccess{
    NSString *errorMsg;
    BOOL isValidationPassed = YES;
    if ([_type isEqualToString:@""] || _type == nil) {
        isValidationPassed = NO;
        errorMsg = @"Please enter the Aggregate Percentage";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        return isValidationPassed;
    }else if([_degree isEqualToString:@""] || _degree == nil){
        
        isValidationPassed = NO;
        errorMsg = @"Please enter the Degree.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        return isValidationPassed;
    }else if([_institute isEqualToString:@""] || _institute == nil){
        
        isValidationPassed = NO;
        errorMsg = @"Please enter the Institution.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        return isValidationPassed;
    }
    
    else if([_speciality isEqualToString:@""] || _speciality == nil){
        
        isValidationPassed = NO;
        errorMsg = @"Please enter the speciality";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        return isValidationPassed;
    }else if([_fromYYYY isEqualToString:@""] || _fromYYYY == nil){
        errorMsg = @"Please enter the starting year";
        isValidationPassed = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        return isValidationPassed;
    }else if([_toYYYY isEqualToString:@""] || _toYYYY == nil){
        errorMsg = @"Please enter the ending year";
        isValidationPassed = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        return isValidationPassed;
        
        
    }else if([_toYYYY integerValue] < [_fromYYYY integerValue]){
        [MRCommon showAlert:@"From Year Cannot be smaller then To Year. Please change the year accordingly." delegate:nil];
        return NO;
        
    }
       return isValidationPassed;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)backButtonTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 2;
    
    if (section == 0) {
        rowCount = 4;
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        EducationDateTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EducationDateTimeTableViewCell" forIndexPath:indexPath];
        cell.delegate = self;
        if (indexPath.row == 0) {
            [cell.mandatoryItemIcon setHidden:YES];
            cell.textLabel.text = _fromYYYY;
        } else {
            cell.textLabel.text = _toYYYY;
            [cell.itemLabel setText:@"TO"];
            cell.itemLabelWidthConstraint.constant = 25.0;
        }
        return cell;
    } else {
        CommonEducationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommonEducationTableViewCell" forIndexPath:indexPath];
        
        switch (indexPath.row) {
            case 0:
            {
             
                NSString *buttonTitle =@"AGGREGATE";
                CGSize stringSize = [buttonTitle sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
               
                cell.titleWidthConstraint.constant =  ceil(stringSize.width);
                cell.titleEducationLbl.text = buttonTitle;
                cell.inputTextField.placeholder = @"Aggregate Percentage ";
                cell.inputTextField.tag = 800;

                cell.inputTextField.text = _type;
                cell.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
                cell.hintLabel.hidden = YES;
                
            }
                break;
            case  1:
            {
                NSString *buttonTitle =@"DEGREE";
                CGSize stringSize = [buttonTitle sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
                
                cell.titleWidthConstraint.constant =  ceil(stringSize.width);
                
                cell.inputTextField.text = _degree;

                cell.titleEducationLbl.text = buttonTitle;
                cell.inputTextField.placeholder = @"For eg. MBBS, MD, DGO, FRCS etc.";
                cell.hintLabel.hidden = NO;
                cell.inputTextField.tag = 801;
                
            }
                break;
            case  2:
            {
                NSString *buttonTitle =@"SPECIALITY";
                CGSize stringSize = [buttonTitle sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
                
                cell.titleWidthConstraint.constant =  ceil(stringSize.width);
                
                cell.inputTextField.text = _speciality;

                cell.titleEducationLbl.text = buttonTitle;
                cell.inputTextField.placeholder = @"speciality";
                cell.hintLabel.hidden = YES;
                cell.inputTextField.tag = 802;
                
            }
                break;
            case  3:
            {
                
                NSString *buttonTitle =@"INSTITUTE";
                CGSize stringSize = [buttonTitle sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
                
                cell.titleWidthConstraint.constant =  ceil(stringSize.width);
                
                cell.inputTextField.text = _institute;

                cell.titleEducationLbl.text = buttonTitle;
                cell.inputTextField.placeholder = @"institute";
                cell.hintLabel.hidden = YES;
                cell.inputTextField.tag = 803;
                
            }
                break;
                
            default:
                break;
        }
        cell.delegate = self;
        return cell;
    }
    return nil;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    self.picker.hidden = YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)viewWillAppear:(BOOL)animated {
  }

- (void)viewWillDisappear:(BOOL)animated {
    
}
#pragma mark - keyboard movements



-(void)EducationDateTimeTableViewCellDelegateForTextFieldClicked:(EducationDateTimeTableViewCell *)cell withTextField:(UITextField *)textField{
    
    [_currentSelectedTextField resignFirstResponder];
    
    [UIView animateWithDuration:0.5 animations:^{
//        CGRect f = self.view.frame;
//        f.origin.y = -150+50;
      self.topConstraint.constant = -150+50;
        [self.tableView updateConstraintsIfNeeded];
    }];

    _currentSelectedTextField = textField;
    self.picker.hidden = NO;
    
}
-(void)CommonEducationTableViewCellDelegateForTextFieldDidBeginEditing:(CommonEducationTableViewCell *)cell withTextField:(UITextField *)textField{
    [self cancelDateSelection];
    
    if(textField.tag == 803){
        [UIView animateWithDuration:0.5 animations:^{
            self.topConstraint.constant = -100;
            [self.tableView updateConstraintsIfNeeded];
        }];
       
    }
    _currentSelectedTextField = textField;
}

-(void)CommonEducationTableViewCellDelegateForTextFieldDidEndEditing:(CommonEducationTableViewCell *)cell withTextField:(UITextField *)textField{
    NSString *trimmedString = [textField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    if (textField.tag == 800) {
        
        _type = trimmedString;
    }else if(textField.tag == 801){
        _degree = trimmedString;
    }
    else if(textField.tag == 802){
        _speciality = trimmedString;
    }else if(textField.tag == 803){
        [UIView animateWithDuration:0.5 animations:^{
            self.topConstraint.constant = 0;
            [self.tableView updateConstraintsIfNeeded];
        }];
        _institute = trimmedString;
    }
}

- (void)didSelectDate {
    [UIView animateWithDuration:0.5 animations:^{
        self.topConstraint.constant = 0;
        [self.tableView updateConstraintsIfNeeded];
    }];
    
    [_picker setHidden:YES];
    [self updateLabel];
}

- (void)cancelDateSelection {
    [UIView animateWithDuration:0.5 animations:^{
        self.topConstraint.constant = 0;
        [self.tableView updateConstraintsIfNeeded];
    }];
    [_picker setHidden:YES];
}

@end

//
//  AddExperienceTableViewController.m
//  MedRep
//
//  Created by Namit Nayak on 7/14/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "AddExperienceTableViewController.h"
#import "CommonTableViewCell.h"
#import "ExperienceSummaryTableViewCell.h"
#import "ExperienceDateTimeTableViewCell.h"
#import "UICustomDatePicker.h"
#import "NSString+Date.h"
#import "MRDatabaseHelper.h"
#import "NTMonthYearPicker.h"
#import "MRConstants.h"
#import "MRWorkExperience.h"
#import "MRCommon.h"
#import "NSDate+Utilities.h"
@interface AddExperienceTableViewController () <ExperienceDateTimeTableViewCellDelegate,CommonTableViewCellDelegate, ExperienceSummaryTableViewCellDelegate, NTMonthYearPickerViewDelegate>

//@property (nonatomic, weak) IBOutlet UICustomDatePicker *customDatePicker;
@property (nonatomic,strong) NSString * designation;
@property (nonatomic,strong) NSString *organisation;
@property (nonatomic,strong) NSString *location;
@property (nonatomic,strong) NSString *fromMM;
@property (nonatomic,strong) NSString *toMM;
@property (nonatomic,strong) NSString *fromYYYY;
@property (nonatomic,strong) NSString *toYYYY;
@property (nonatomic) BOOL isCurrentChecked;
@property (nonatomic,strong) NSString *summaryText;
@property (nonatomic,strong) NSDate *fromDate;
@property (nonatomic,strong)NSDate *toDate;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) UITextField *currentSelectedTextField;
@property (nonatomic,strong) NTMonthYearPicker *picker;

@end

@implementation AddExperienceTableViewController

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
    NSString *title = @"Add Experience";
    if (self.workExperience != nil) {
        title = @"Edit Experience";
    }
    
    self.navigationItem.title  = title;
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"]  style:UIBarButtonItemStyleDone target:self action:@selector(backButtonTapped:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setupPicker];
    [self updateLabel];
    [self setupData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideDatePicker) name:@"HIDE_DATE_PICKER" object:nil];
}

-(void)hideDatePicker{
    
    [_picker setHidden:YES];

}

-(void)setupData{
    UIBarButtonItem *revealButtonItem;
    if (_workExperience !=nil) {
        
        _designation = _workExperience.designation;
        _organisation = _workExperience.hospital;
        _location = _workExperience.location;
        _fromMM = _workExperience.fromDate;
        _toMM = _workExperience.toDate;
        _isCurrentChecked = [_workExperience.currentJob boolValue];
        _summaryText = _workExperience.summary;
       
        if (![_fromMM isEqualToString:@""]) {
            
            NSArray *fromArrDate = [_fromMM componentsSeparatedByString:@" "];
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            NSCalendar *cal = [NSCalendar currentCalendar];
            [comps setDay:1];
            [comps setMonth:[MRCommon getMonthIndexForShortName:[fromArrDate objectAtIndex:0]]];
            NSString *year = [fromArrDate objectAtIndex:1];
            
            [comps setYear:year.intValue];
            _fromDate = [cal dateFromComponents:comps];
        }
        
        if (![_toMM isEqualToString:@""]) {
            
            NSArray *fromArrDate = [_toMM componentsSeparatedByString:@" "];
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            NSCalendar *cal = [NSCalendar currentCalendar];
            [comps setDay:1];
            [comps setMonth:[MRCommon getMonthIndexForShortName:[fromArrDate objectAtIndex:0]]];
            NSString *year = [fromArrDate objectAtIndex:1];
            
            [comps setYear:year.intValue];
            _toDate = [cal dateFromComponents:comps];
        }
        [self.tableView reloadData];
        revealButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"UPDATE" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
    }else{
        revealButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
    }
    self.navigationItem.rightBarButtonItem = revealButtonItem;

}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
//    CGSize pickerSize = _picker.frame.size;
//    CGFloat temp = [UIScreen mainScreen].applicationFrame.size.width;
//    
//    CGRect pickerFrame = CGRectMake( 0, [[UIScreen mainScreen] bounds].size.height - (pickerSize.height+50), temp, pickerSize.height );
//    [_picker updateFrame:pickerFrame];
    
    _picker.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:_picker];
}


- (void)updateModeSelector {
    
}

- (void)updateLabel {
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *stringFromDate;
    
    
    [formatter setDateFormat:@"MMM YYYY"];
    stringFromDate = [formatter stringFromDate:_picker.date];
    if (_currentSelectedTextField.tag == 500) {
        _fromMM = stringFromDate;
        _fromDate = _picker.date;
    }
    else if(_currentSelectedTextField.tag == 502) {
       
        _toMM = stringFromDate;
        
        if([_fromDate isLaterThanDate:_picker.date]){
            
            [MRCommon showAlert:@"From Date should be smaller then To Date." delegate:nil];
            return;
        }
        _toDate = _picker.date;
    }
    
    
    
    NSLog(@"%@",stringFromDate);
    _currentSelectedTextField.text = stringFromDate;
}

- (void)didSelectDate {
    
    [_picker setHidden:YES];
    [self updateLabel];
}

- (void)cancelDateSelection {
    [_picker setHidden:YES];
}

-(void)doneButtonTapped:(id)sender{
    if (![self isValidationSuccess]) {
        return;
    }
    
    if (_isCurrentChecked) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *stringFromDate;
        [formatter setDateFormat:@"yyyy"];
        _toYYYY = [formatter stringFromDate:[NSDate date]];
        
        [formatter  setDateFormat:@"MMM"];
        _toMM = [formatter stringFromDate:[NSDate date]];
        
        _toMM = [NSString stringWithFormat:@"%@ %@",_toMM,_toYYYY];
        
    }
    NSDictionary * workExpDict ;
    

    
    
    if ([_fromScreen isEqualToString:@"UPDATE"]) {
      workExpDict  = [[NSDictionary alloc] initWithObjectsAndKeys:_designation,@"designation",_organisation,@"hospital",[NSString stringWithFormat:@"%@",_fromMM],@"fromDate",[NSString stringWithFormat:@"%@",_toMM],@"toDate",_location,@"location",_workExperience.id, @"id",[NSNumber numberWithBool:_isCurrentChecked],@"currentJob",_summaryText,@"summary", nil];
        [MRDatabaseHelper updateWorkExperience:workExpDict withWorkExperienceID:_workExperience.id andHandler:^(id result) {
            if ([result isEqualToString:@"TRUE"]) {
                
                [MRCommon showAlert:@"Work Experience Updated Successfully." delegate:nil];
                
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [MRCommon showAlert:@"Due to server error not able to update Work Experience. Please try again later." delegate:nil];

            }
 
        }];
    }else{
          workExpDict  = [[NSDictionary alloc] initWithObjectsAndKeys:_designation,@"designation",_organisation,@"hospital",[NSString stringWithFormat:@"%@",_fromMM],@"fromDate",[NSString stringWithFormat:@"%@",_toMM],@"toDate",_location,@"location",[NSNumber numberWithBool:_isCurrentChecked],@"currentJob",_summaryText,@"summary", nil];
        [MRDatabaseHelper addWorkExperience:workExpDict andHandler:^(id result) {
            if ([result isEqualToString:@"TRUE"]) {
                
                [MRCommon showAlert:@"Work Experience Add Successfully." delegate:nil];

                        [self.navigationController popViewControllerAnimated:YES];
                    }
        } ];
    }
//  BOOL ys =  [MRDatabaseHelper  addWorkExperience:workExpDict];
//    if (ys) {
////        [self.navigationController popViewControllerAnimated:YES];
//        
//    }
}
-(BOOL)isValidationSuccess{
    NSString *errorMsg;
    BOOL isValidationPassed = YES;
    if ([_designation isEqualToString:@""] || _designation == nil) {
        isValidationPassed = NO;
        errorMsg = @"Please enter the designation";

        
        
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            
        return isValidationPassed;
    }else if([_location isEqualToString:@""] || _location == nil){
        
        isValidationPassed = NO;
        errorMsg = @"Please enter the location , city name.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        return isValidationPassed;
    }else if([_organisation isEqualToString:@""] || _organisation == nil){

        isValidationPassed = NO;
            errorMsg = @"Please enter the organisation";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        return isValidationPassed;
    }else if([_fromMM isEqualToString:@""] || _fromMM == nil){
        errorMsg = @"Please enter the starting month";
        isValidationPassed = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        return isValidationPassed;
        
    
    }
    else if(!_isCurrentChecked)
    {
         if([_fromDate isLaterThanDate:_toDate]){
            
            [MRCommon showAlert:@"From Date should be smaller then To Date." delegate:nil];
            return NO;
        }
         if([_toMM isEqualToString:@""] || _toMM == nil){
                    errorMsg = @"Please enter the end month";
            isValidationPassed = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            
            return isValidationPassed;
            
        }
    }
    
    
    return isValidationPassed;
}

-(void)backButtonTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 0;
    
    if (indexPath.row ==0 || indexPath.row == 1|| indexPath.row == 2) {
        height = 72;
    } else if(indexPath.row == 3 ){
        height = 146;
        
        if (self.workExperience != nil && self.workExperience.currentJob != nil &&
            self.isCurrentChecked == 1) {
            height -= 55;
        }
    } else {
        CGRect applicatonFrame = [[UIScreen mainScreen] applicationFrame];
        height = applicatonFrame.size.height - ((72 * 3) + 146 + 44);
        //124;
    }
    return height;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 5;
}

-(CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    switch (indexPath.row) {
        case 0: case 1: case 2:{
            CommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommonTableViewCell" forIndexPath:indexPath];
            if (indexPath.row == 0) {
                cell.title.text = @"DESIGNATION";
                cell.inputTextField.placeholder = @"Designation";
                [cell setTextData:_designation];
                
                cell.inputTextField.tag = 101;
            } else if(indexPath.row == 1){
                
                NSString *buttonTitle =@"ORGANISATION";
                CGSize stringSize = [buttonTitle sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
//                CGFloat width  = [self widthOfString:@"ORGANISATION" withFont:<#(NSFont *)#>]
                cell.title.text = buttonTitle;
                [cell setTextData:_organisation];
                cell.titleWidthConstraint.constant =  ceil(stringSize.width);
                cell.inputTextField.placeholder = @"Organisation";
                cell.inputTextField.tag = 102;
            } else{
                
                NSString *buttonTitle =@"Location";
                CGSize stringSize = [buttonTitle sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
                cell.title.text = buttonTitle;
                [cell setTextData:_location];
                cell.titleWidthConstraint.constant =  ceil(stringSize.width);

                cell.inputTextField.placeholder = @"City Name";
                cell.inputTextField.tag = 110;
            }
            cell.delegate = self;
            return cell;
            

        }
                        break;
        case 3:{
            ExperienceDateTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExperienceDateTimeTableViewCell" forIndexPath:indexPath];
            cell.delegate = self;
            cell.isChecked = _isCurrentChecked;
            [cell setCurrentCheckBox:_isCurrentChecked];
            cell.toMMTextField.text = _toMM;
            cell.fromTextField.text = _fromMM;
            return cell;
        }
            break;
        case 4:{
            ExperienceSummaryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExperienceSummaryTableViewCell" forIndexPath:indexPath];
            // Configure the cell...
            [cell setSummaryTextData:self.summaryText andParentView:tableView];
            cell.delegate = self;
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}

-(void)ExperienceSummaryTableViewCellDelegateForTextViewDidEndEditing:(ExperienceSummaryTableViewCell *)cell
                                                         withTextView:(UITextView *)textView {
    NSString *trimmedString = [textView.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    
    _summaryText = trimmedString;
    
}
-(void)CommonTableViewCellDelegateForTextFieldDidEndEditing:(CommonTableViewCell *)cell withTextField:(UITextField *)textField{
    NSString *trimmedString = [textField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    if (textField.tag == 101) {
    
        _designation = trimmedString;
    }else if(textField.tag == 102){
        _organisation = trimmedString;
    }
    else if(textField.tag == 110){
        _location = trimmedString;
    }
}

-(void)ExperienceDateTimeTableViewCellDelegateForTextFieldClicked:(ExperienceDateTimeTableViewCell *)cell withTextField:(UITextField *)textField{

    _currentSelectedTextField = textField;
//        self.customDatePicker.hidden = NO;
    _picker.hidden = NO;
    
    if (textField.tag == 502) {
        if (_toDate != nil) {
            [_picker setDate:_toDate];
        } else {
            [_picker setDate:[NSDate date]];
        }
        
        if (_fromMM != nil && _fromMM.length > 0) {
            [_picker setMinimumDate:_fromDate];
            [_picker setMaximumDate:[NSDate date]];
        }
    } else {
        if (_toMM != nil && _toMM.length > 0) {
            [_picker setMaximumDate:_toDate];
            
            if (_fromDate != nil) {
                [_picker setDate:_fromDate];
            } else {
                [_picker setDate:_toDate];
            }
        } else {
            if (_fromDate != nil) {
                [_picker setDate:_fromDate];
            }
        }
    }
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


-(void)getCurrentCheckButtonVal:(BOOL)isCurrentCheck{
    _isCurrentChecked = isCurrentCheck;
    [self.tableView reloadData];
}
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
//    self.customDatePicker.hidden = YES;
    _picker.hidden = YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (IBAction)didCustomDatePickerValueChanged:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *stringFromDate;
   
    [formatter setDateFormat:@"MMM YYYY"];
    stringFromDate = [formatter stringFromDate:[(UICustomDatePicker *)sender currentDate]];
    if (_currentSelectedTextField.tag == 500) {
        _fromMM = stringFromDate;
    }
    else if(_currentSelectedTextField.tag == 502) {
        _toMM = stringFromDate;
        
    }
    
    NSLog(@"%@",stringFromDate);
    _currentSelectedTextField.text = stringFromDate;
}

@end

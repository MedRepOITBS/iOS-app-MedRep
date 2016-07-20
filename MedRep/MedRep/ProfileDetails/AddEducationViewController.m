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
#import "UICustomDatePicker.h"
#import "NSString+Date.h"
#import "MRDatabaseHelper.h"
@interface AddEducationViewController () <EducationDateTimeTableViewCellDelegate, CommonEducationTableViewCellDelegate>
@property (nonatomic, weak) IBOutlet UICustomDatePicker *customYearPicker;
@property (nonatomic,strong) UITextField *currentSelectedTextField;
@property (nonatomic,strong) NSString *fromYYYY;
@property (nonatomic,strong) NSString *toYYYY;
@property (nonatomic,strong) NSString *degree;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *speciality;
@property (nonatomic,strong) NSString *institute;



@end

@implementation AddEducationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.rightBarButtonItem = revealButtonItem;
    self.navigationItem.title  = @"Add Education Details";

    self.customYearPicker.hidden = YES;
    [self initCustomDatePicker:self.customYearPicker withOption:NSCustomDatePickerOptionYear andOrder:NSCustomDatePickerOrderMonthDayAndYear];
//    [self initCustomDatePicker:self.customYearPicker withOption:NSCustomDatePickerOptionYear andOrder:NSCustomDatePickerOrderMonthDayAndYear];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"]  style:UIBarButtonItemStyleDone target:self action:@selector(backButtonTapped:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



-(void)doneButtonTapped:(id)sender{
    if (![self isValidationSuccess]) {
        return;
    }
    
    
    
        

    NSDictionary * workExpDict = [[NSDictionary alloc] initWithObjectsAndKeys:_degree,@"degree",_institute,@"collegeName",[NSString stringWithFormat:@"%@ %@",_fromYYYY,_toYYYY],@"yearOfPassout",_speciality,@"course",_type,@"aggregate", nil];
    
    BOOL ys =  [MRDatabaseHelper  addEducationQualification:workExpDict];
    if (ys) {
        [self.navigationController popViewControllerAnimated:YES];
        
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



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.row ==4) {
        return 124;
    }
    return 84;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    switch (indexPath.row) {
        case 4:
        {
            
            EducationDateTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EducationDateTimeTableViewCell" forIndexPath:indexPath];
            cell.delegate = self;
            
            return cell;
        }
            break;

        
        default:
        {
            CommonEducationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommonEducationTableViewCell" forIndexPath:indexPath];
            
            switch (indexPath.row) {
                case 0:
                {
                    cell.titleEducationLbl.text = @"AGGREGATE";
                    cell.inputTextField.placeholder = @"Aggregate Percentage ";
                    cell.inputTextField.tag = 800;
                    cell.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
                    cell.hintLabel.hidden = YES;
                    
                }
                    break;
                case  1:
                {
                    cell.titleEducationLbl.text = @"DEGREE";
                    cell.inputTextField.placeholder = @"Degree";
                    cell.hintLabel.hidden = NO;
                    cell.inputTextField.tag = 801;
                    
                }
                    break;
                case  2:
                {
                    cell.titleEducationLbl.text = @"SPECIALITY";
                    cell.inputTextField.placeholder = @"speciality";
                    cell.hintLabel.hidden = YES;
                    cell.inputTextField.tag = 802;
                    
                }
                    break;
                case  3:
                {
                    cell.titleEducationLbl.text = @"INSTITUTE";
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
            break;
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
    self.customYearPicker.hidden = YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) initCustomDatePicker:(UICustomDatePicker *) picker withOption:(NSUInteger) option andOrder:(NSUInteger) order {
    picker.minDate = [[NSString stringWithFormat:@"06/Jan/1986"] dateValueForFormatString:@"dd/MMM/yyyy"];
    picker.maxDate = [[NSString stringWithFormat:@"06/Dec/2027"] dateValueForFormatString:@"dd/MMM/yyyy"];
    picker.currentDate = [NSDate date];
    picker.order = order;
    picker.option = option;
}
-(void)EducationDateTimeTableViewCellDelegateForTextFieldClicked:(EducationDateTimeTableViewCell *)cell withTextField:(UITextField *)textField{
    _currentSelectedTextField = textField;
    self.customYearPicker.hidden = NO;
    
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
        _institute = trimmedString;
    }

}

- (IBAction)didCustomDatePickerValueChanged:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *stringFromDate;
    [formatter setDateFormat:@"yyyy"];
    stringFromDate = [formatter stringFromDate:[(UICustomDatePicker *)sender currentDate]];

           if(_currentSelectedTextField.tag == 1200)
        {
            _fromYYYY = stringFromDate;
        }else if(_currentSelectedTextField.tag == 1201)
        {
            _toYYYY = stringFromDate;
        }
    
    
    
    NSLog(@"%@",stringFromDate);
    _currentSelectedTextField.text = stringFromDate;
}
@end
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


@interface AddExperienceTableViewController () <ExperienceDateTimeTableViewCellDelegate>
@property (nonatomic, weak) IBOutlet UICustomDatePicker *customDatePicker;
@property (nonatomic, weak) IBOutlet UICustomDatePicker *customYearPicker;

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) UITextField *currentSelectedTextField;
@end

@implementation AddExperienceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.rightBarButtonItem = revealButtonItem;
    self.customDatePicker.hidden = YES;
    self.customYearPicker.hidden = YES;

      [self initCustomDatePicker:self.customDatePicker withOption:NSCustomDatePickerOptionMediumMonth andOrder:NSCustomDatePickerOrderMonthDayAndYear];
  [self initCustomDatePicker:self.customYearPicker withOption:NSCustomDatePickerOptionYear andOrder:NSCustomDatePickerOrderMonthDayAndYear];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"]  style:UIBarButtonItemStyleDone target:self action:@selector(backButtonTapped:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)doneButtonTapped:(id)sender{
    
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
    
    if (indexPath.row ==0 || indexPath.row == 1) {
        return 72;
    }else if(indexPath.row == 2 ){
        return 146;
    }
    return 124;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    switch (indexPath.row) {
        case 0: case 1:{
            CommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommonTableViewCell" forIndexPath:indexPath];
            if (indexPath.row == 0) {
                cell.title.text = @"DESIGNATION";
                cell.inputTextField.placeholder = @"Designation";
            }else{
                cell.title.text = @"ORGANISATION";
                cell.inputTextField.placeholder = @"Organisation";
                
            }
            
            return cell;
            

        }
                        break;
        case 2:{
            ExperienceDateTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExperienceDateTimeTableViewCell" forIndexPath:indexPath];
            cell.delegate = self;
            return cell;
        }
            break;
        case 3:{
            ExperienceSummaryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExperienceSummaryTableViewCell" forIndexPath:indexPath];
            // Configure the cell...
            
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}

-(void)ExperienceDateTimeTableViewCellDelegateForTextFieldClicked:(ExperienceDateTimeTableViewCell *)cell withTextField:(UITextField *)textField{

    _currentSelectedTextField = textField;
    if ([textField.placeholder isEqualToString:@"MMM"]) {
        self.customDatePicker.hidden = NO;
        self.customYearPicker.hidden = YES;
        

        
    }else {
        self.customDatePicker.hidden = YES;
        self.customYearPicker.hidden = NO;
        

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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) initCustomDatePicker:(UICustomDatePicker *) picker withOption:(NSUInteger) option andOrder:(NSUInteger) order {
    picker.minDate = [[NSString stringWithFormat:@"06/Jan/1900"] dateValueForFormatString:@"dd/MMM/yyyy"];
    picker.maxDate = [[NSString stringWithFormat:@"06/Dec/2300"] dateValueForFormatString:@"dd/MMM/yyyy"];
    picker.currentDate = [NSDate date];
    picker.order = order;
    picker.option = option;
}


- (IBAction)didCustomDatePickerValueChanged:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (((UICustomDatePicker *)sender).tag == 120) {
        [formatter setDateFormat:@"yyyy"];
    }else {
        
        [formatter setDateFormat:@"MMM"];
    }
    NSString *stringFromDate = [formatter stringFromDate:[(UICustomDatePicker *)sender currentDate]];
    NSLog(@"%@",stringFromDate);
    _currentSelectedTextField.text = stringFromDate;
}
@end

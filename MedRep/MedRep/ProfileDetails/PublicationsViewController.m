//
//  PublicationsViewController.m
//  MedRep
//
//  Created by Namit Nayak on 7/19/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "PublicationsViewController.h"
#import "UICustomDatePicker.h"
#import "NSString+Date.h"
#import "MRDatabaseHelper.h"
@interface PublicationsViewController ()
@property (nonatomic, weak) IBOutlet UICustomDatePicker *customYearPicker;
@end

@implementation PublicationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title  = @"Add Publications Details";
    self.customYearPicker.hidden = YES;
[self initCustomDatePicker:self.customYearPicker withOption:NSCustomDatePickerOptionYear andOrder:NSCustomDatePickerOrderMonthDayAndYear];
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.rightBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"]  style:UIBarButtonItemStyleDone target:self action:@selector(backButtonTapped:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)backButtonTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)doneButtonTapped:(id)sender{
    NSString *publicationArticleText = [self.publicationArticleTextField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    
    NSString *publicationsText = [self.pulbicationsTextField.text stringByTrimmingCharactersInSet:
                                        [NSCharacterSet whitespaceCharacterSet]];
    NSString *yearText = [self.yearTextField.text stringByTrimmingCharactersInSet:
                                        [NSCharacterSet whitespaceCharacterSet]];

    if ((publicationsText!=nil && [publicationsText isEqualToString:@""])|| (publicationArticleText!=nil && [publicationArticleText isEqualToString:@""])||(yearText!=nil && [yearText isEqualToString:@""])) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter the all mandatory fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return;
    }
  
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:publicationArticleText,@"articleName",publicationsText,@"publication",yearText,@"year", nil];
    BOOL YS = [MRDatabaseHelper addPublications:dict];
    if (YS) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSLog(@"textfield %@",textField.text);
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (textField.tag == 202) {
        self.customYearPicker.hidden = NO;
        return NO;
    }
    return YES;
}

- (void) initCustomDatePicker:(UICustomDatePicker *) picker withOption:(NSUInteger) option andOrder:(NSUInteger) order {
    picker.minDate = [[NSString stringWithFormat:@"06/Jan/1986"] dateValueForFormatString:@"dd/MMM/yyyy"];
    picker.maxDate = [[NSString stringWithFormat:@"06/Dec/2027"] dateValueForFormatString:@"dd/MMM/yyyy"];
    picker.currentDate = [NSDate date];
    picker.order = order;
    picker.option = option;
}
- (IBAction)didCustomDatePickerValueChanged:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *stringFromDate;
    [formatter setDateFormat:@"yyyy"];
    stringFromDate = [formatter stringFromDate:[(UICustomDatePicker *)sender currentDate]];
    
//    if(_currentSelectedTextField.tag == 1200)
//    {
//        _fromYYYY = stringFromDate;
//    }else if(_currentSelectedTextField.tag == 1201)
//    {
//        _toYYYY = stringFromDate;
//    }
//    
//    
//    
    NSLog(@"%@",stringFromDate);
    _yearTextField.text = stringFromDate;
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

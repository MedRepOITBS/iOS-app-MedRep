//
//  PublicationsViewController.m
//  MedRep
//
//  Created by Namit Nayak on 7/19/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "PublicationsViewController.h"
#import "MRPublicationsDetailsViewController.h"
#import "NTMonthYearPicker.h"
#import "MRConstants.h"
#import "MRDatabaseHelper.h"
#import "MRCommon.h"
#import "MRPublications.h"

@interface PublicationsViewController () <NTMonthYearPickerViewDelegate>

@property (nonatomic,strong) NTMonthYearPicker *picker;
@property (weak, nonatomic) IBOutlet UIButton *goToDetailsButton;

@end

@implementation PublicationsViewController


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


- (void)updateLabel {
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *stringFromDate;
    
    
    [formatter setDateFormat:@"MMM YYYY"];
    stringFromDate = [formatter stringFromDate:_picker.date];
    
    NSLog(@"%@",stringFromDate);
    _yearTextField.text = stringFromDate;
}
- (void)didSelectDate {
    [_picker setHidden:YES];
    [self updateLabel];
}

- (void)cancelDateSelection {
    [_picker setHidden:YES];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.publications != nil) {
        self.navigationItem.title  = @"Edit Publications";
    } else {
        self.navigationItem.title  = @"Add Publications";
    }
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"]  style:UIBarButtonItemStyleDone target:self action:@selector(backButtonTapped:)];
    [self setupPicker];
    [self updateLabel];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    [self setupData];
}



-(void)setupData{
    UIBarButtonItem *revealButtonItem;
    if (_publications!=nil) {
        self.publicationArticleTextField.text  = _publications.articleName;
        self.pulbicationsTextField.text = _publications.publication;
        self.yearTextField.text = _publications.year;
        self.urlTextField.text = _publications.url;
        revealButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"UPDATE" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
        
        if (_publications.url != nil && _publications.url.length > 0) {
            [self.goToDetailsButton setHidden:NO];
        } else {
            [self.goToDetailsButton setHidden:YES];
        }
    }else{
        revealButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
        [self.goToDetailsButton setHidden:YES];
    }
    self.navigationItem.rightBarButtonItem = revealButtonItem;
    
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
    NSString *publicationURLString = @"";
    publicationURLString = _urlTextField.text;
  
    NSDictionary *dict;
    if ([_fromScreen isEqualToString:@"UPDATE"]) {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:publicationArticleText,@"articleName",publicationsText,@"publication",publicationURLString,@"url",yearText,@"year",_publications.id,@"id", nil];
        [MRDatabaseHelper updatePublication:dict withPublicationID:_publications.id andHandler:^(id result) {
            NSString* YS = (NSString *)result;
            if([YS isEqualToString:@"TRUE"]){
                [MRCommon showAlert:@"Publication Update Successfully" delegate:nil];
                
                [self.navigationController popViewControllerAnimated:YES];
                
                
            }else{
                [MRCommon showAlert:@"Due to server error not able to update publications details. Please try again later." delegate:nil];
            }
        }];

    }else{
        
        dict = [NSDictionary dictionaryWithObjectsAndKeys:publicationArticleText,@"articleName",publicationsText,@"publication",publicationURLString,@"url",yearText,@"year", nil];
        [MRDatabaseHelper addPublications:dict andHandler:^(id result) {
            NSString* YS = (NSString *)result;
            if([YS isEqualToString:@"TRUE"]){
                [MRCommon showAlert:@"Publication Added Successfully" delegate:nil];
                
                [self.navigationController popViewControllerAnimated:YES];
                
                
            }else{
                [MRCommon showAlert:@"Due to server error not able to update publications details. Please try again later." delegate:nil];
            }
        }];
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
        self.picker.hidden = NO;
        return NO;
    }
    return YES;
}

- (IBAction)goToDetailsTapped:(id)sender {
    MRPublicationsDetailsViewController *detailsView = [MRPublicationsDetailsViewController new];
    [detailsView setPublication:_publications];
    [self.navigationController pushViewController:detailsView  animated:YES];
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

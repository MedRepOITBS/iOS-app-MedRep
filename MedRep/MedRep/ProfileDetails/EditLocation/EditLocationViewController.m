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
@interface EditLocationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *addressLine1;
@property (weak, nonatomic) IBOutlet UITextField *addressLine2;
@property (weak, nonatomic) IBOutlet UITextField *city;
@property (weak, nonatomic) IBOutlet UITextField *state;
@property (weak, nonatomic) IBOutlet UITextField *country;
@property (weak, nonatomic) IBOutlet UITextField *zipCode;
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
    [self setUpData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backButtonTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doneButtonTapped:(id)sender{
    NSString *interestArticle = @"";
//    [self.interestAreaLabel.text stringByTrimmingCharactersInSet:
//                                 [NSCharacterSet whitespaceCharacterSet]];
//    
//    
//    if ((interestArticle!=nil && [interestArticle isEqualToString:@""] )|| [interestArticle isEqualToString:@"Select Therapeutic Area"]) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select the Therapeutic Area." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alertView show];
//        return;
//    }
    
    [MRDatabaseHelper addInterestArea:[NSArray arrayWithObjects:interestArticle, nil] andHandler:^(id result) {
        if ([result isEqualToString:@"TRUE"]) {
            
            [MRCommon showAlert:@"Therapeutic Area Added Successfully." delegate:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [MRCommon showAlert:@"Due to server error not able to update Therapeutic Area. Please try again later." delegate:nil];
            
        }
        
    }];
}
-(void)setUpData{
    
    if (_addressObject!=nil) {
        _addressLine1.text = _addressObject.address1;
        _addressLine2.text = _addressObject.address2;
        _city.text = _addressObject.city;
        _state.text = _addressObject.state;
        _zipCode.text = _addressObject.zipcode;
        _country.text = _addressObject.country;
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

@end

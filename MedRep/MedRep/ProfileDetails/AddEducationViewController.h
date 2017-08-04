//
//  AddEducationTableViewController.h
//  MedRep
//
//  Created by Namit Nayak on 7/14/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  EducationalQualifications;

@interface AddEducationViewController : UIViewController <UITableViewDelegate , UITableViewDataSource>

@property (nonatomic,strong) NSString *fromScreen;
@property (nonatomic,strong) EducationalQualifications *educationQualObj;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic)IBOutlet NSLayoutConstraint *topConstraint;
- (IBAction)didCustomDatePickerValueChanged:(id)sender;

@end

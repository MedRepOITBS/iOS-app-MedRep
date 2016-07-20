//
//  AddEducationTableViewController.h
//  MedRep
//
//  Created by Namit Nayak on 7/14/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddEducationViewController : UIViewController <UITableViewDelegate , UITableViewDataSource>

@property (nonatomic,weak) IBOutlet UITableView *tableView;
- (IBAction)didCustomDatePickerValueChanged:(id)sender;
@end

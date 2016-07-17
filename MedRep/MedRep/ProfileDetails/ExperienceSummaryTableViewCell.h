//
//  ExperienceSummaryTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ExperienceSummaryTableViewCellDelegate;

@interface ExperienceSummaryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *summaryTextField;
@property (nonatomic,weak) id<ExperienceSummaryTableViewCellDelegate> delegate;

@end

@protocol ExperienceSummaryTableViewCellDelegate <NSObject>
@optional

-(void)ExperienceSummaryTableViewCellDelegateForTextFieldDidEndEditing:(ExperienceSummaryTableViewCell *)cell withTextField:(UITextField *)textField;

@end

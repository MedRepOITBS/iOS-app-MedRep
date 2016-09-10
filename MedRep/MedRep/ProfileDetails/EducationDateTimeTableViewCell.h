//
//  EducationDateTimeTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/17/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EducationDateTimeTableViewCellDelegate;

@interface EducationDateTimeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mandatoryItemIcon;

@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemLabelWidthConstraint;

@property (weak, nonatomic) IBOutlet UITextField *dateLabel;

@property (nonatomic,weak) id<EducationDateTimeTableViewCellDelegate> delegate;

@end

@protocol EducationDateTimeTableViewCellDelegate <NSObject>
@optional

-(void)EducationDateTimeTableViewCellDelegateForTextFieldClicked:(EducationDateTimeTableViewCell *)cell withTextField:(UITextField *)textField;
-(void)getCurrentCheckButtonVal:(BOOL)isCurrentCheck;
@end

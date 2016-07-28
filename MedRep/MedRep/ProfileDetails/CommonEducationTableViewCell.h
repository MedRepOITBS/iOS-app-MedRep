//
//  CommonEducationTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/17/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CommonEducationTableViewCellDelegate;

@interface CommonEducationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleEducationLbl;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (nonatomic,weak) id<CommonEducationTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWidthConstraint;

@end
@protocol CommonEducationTableViewCellDelegate <NSObject>

@optional

-(void)CommonEducationTableViewCellDelegateForTextFieldDidEndEditing:(CommonEducationTableViewCell *)cell withTextField:(UITextField *)textField;

@end
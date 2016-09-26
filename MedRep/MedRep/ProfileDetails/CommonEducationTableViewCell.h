//
//  CommonEducationTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/17/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CommonEducationTableViewCellDelegate;

@interface CommonEducationTableViewCell : UITableViewCell<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleEducationLbl;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (nonatomic,weak) id<CommonEducationTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWidthConstraint;

@end
@protocol CommonEducationTableViewCellDelegate <NSObject>

@optional
-(void)CommonEducationTableViewCellDelegateForTextFieldDidBeginEditing:(CommonEducationTableViewCell *)cell withTextField:(UITextField *)textField;


-(void)CommonEducationTableViewCellDelegateForTextFieldDidEndEditing:(CommonEducationTableViewCell *)cell withTextField:(UITextField *)textField;

@optional
-(BOOL)CommonEducationTableViewCellDelegateForTextFieldShouldChangeCharacetersInRange:(CommonEducationTableViewCell *)cell withTextField:(UITextField *)textField
                                                                                range:(NSRange)range
                                                                    replacementString:(NSString *)string;

@end

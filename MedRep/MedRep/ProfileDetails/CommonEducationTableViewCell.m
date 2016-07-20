//
//  CommonEducationTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 7/17/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "CommonEducationTableViewCell.h"

@implementation CommonEducationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSLog(@"textfield %@",textField.text);
    if ([self.delegate respondsToSelector:@selector(CommonEducationTableViewCellDelegateForTextFieldDidEndEditing:withTextField:)]) {
        [self.delegate CommonEducationTableViewCellDelegateForTextFieldDidEndEditing:self withTextField:textField];
    }
    
//    -(void)CommonEducationTableViewCellDelegateForTextFieldDidEndEditing:(CommonEducationTableViewCell *)cell withTextField:(UITextField *)textField;
}
@end

//
//  CommonTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "CommonTableViewCell.h"

@implementation CommonTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSLog(@"textfield %@",textField.text);
    if ([self.delegate respondsToSelector:@selector(CommonTableViewCellDelegateForTextFieldDidEndEditing:withTextField:)]) {
        [self.delegate CommonTableViewCellDelegateForTextFieldDidEndEditing:self withTextField:textField];
    }
}
@end

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
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.superview.frame.size.width, 50)];
        numberToolbar.barStyle = UIBarStyleDefault;
        numberToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(closeOnKeyboardPressed:)],
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                               [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneOnKeyboardPressed:)],
                               nil];
        [numberToolbar sizeToFit];
        self.inputTextField.inputAccessoryView = numberToolbar;
    
    // Initialization code
}
- (void)closeOnKeyboardPressed:(id)sender {
    self.inputTextField.text = self.text;
    [self.inputTextField resignFirstResponder];
}

- (void)doneOnKeyboardPressed:(id)sender {
    [self.inputTextField resignFirstResponder];
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

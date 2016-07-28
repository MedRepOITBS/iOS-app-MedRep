//
//  CommonTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "CommonTableViewCell.h"

@interface CommonTableViewCell ()

@property (nonatomic, strong) NSString *text;

@end

@implementation CommonTableViewCell

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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTextData:(NSString*)text {
    self.text = text;
    [self.inputTextField setText:text];
}

- (void)closeOnKeyboardPressed:(id)sender {
    self.inputTextField.text = self.text;
    [self.inputTextField resignFirstResponder];
}

- (void)doneOnKeyboardPressed:(id)sender {
    [self.inputTextField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self doneWithEditing:textField];
}

- (void)doneWithEditing:(UITextField*)textField {

    NSLog(@"textfield %@",textField.text);
    
    self.text = textField.text;
    
    if ([self.delegate respondsToSelector:@selector(CommonTableViewCellDelegateForTextFieldDidEndEditing:withTextField:)]) {
        [self.delegate CommonTableViewCellDelegateForTextFieldDidEndEditing:self withTextField:textField];
    }
}

@end

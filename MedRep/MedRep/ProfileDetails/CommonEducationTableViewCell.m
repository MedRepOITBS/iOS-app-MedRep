//
//  CommonEducationTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 7/17/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "CommonEducationTableViewCell.h"

@interface CommonEducationTableViewCell ()

@property (nonatomic) NSString *previousString;

@end

@implementation CommonEducationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.previousString = @"";
    
        // Initialization code
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.superview.frame.size.width, 50)];
        numberToolbar.barStyle = UIBarStyleDefault;
    [numberToolbar setBackgroundColor:[UIColor darkTextColor]];
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
    self.inputTextField.text = self.previousString;
    [self.inputTextField resignFirstResponder];
}

- (void)doneOnKeyboardPressed:(id)sender {
    [self.inputTextField resignFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.previousString = textField.text;
    
    if ([self.delegate respondsToSelector:@selector(CommonEducationTableViewCellDelegateForTextFieldDidBeginEditing:withTextField:)]) {
        [self.delegate CommonEducationTableViewCellDelegateForTextFieldDidBeginEditing:self withTextField:textField];
    }
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
   
    NSLog(@"textfield %@",textField.text);
    if ([self.delegate respondsToSelector:@selector(CommonEducationTableViewCellDelegateForTextFieldDidEndEditing:withTextField:)]) {
        [self.delegate CommonEducationTableViewCellDelegateForTextFieldDidEndEditing:self withTextField:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL status = YES;
    
    if ([string caseInsensitiveCompare:@""] == NSOrderedSame) {
        status = YES;
    } else {
        NSString *currentText = textField.text;
        NSInteger length = 0;
        if (currentText != nil) {
            length = currentText.length;
        }
        
        if (string != nil) {
            length += string.length;
        }
        
        if (currentText != nil) {
            NSString *newString =
                [currentText stringByReplacingCharactersInRange:range withString:string];
            
            NSArray *subStrings = [newString componentsSeparatedByString:@"."];
            if (subStrings.count > 0) {
                if (subStrings.count > 2) {
                    status = NO;
                } else {
                    NSString *firstString = subStrings[0];
                    if (firstString != nil && firstString.length > 2) {
                        status = NO;
                    }
                    
                    if (subStrings.count == 2) {
                        NSString *secondString = subStrings[1];
                        if (secondString != nil && secondString.length > 2) {
                            status = NO;
                        }
                    }
                }
            }
        }
    }
    
    return status;
}

@end

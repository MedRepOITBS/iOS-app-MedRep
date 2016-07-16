//
//  ExperienceDateTimeTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "ExperienceDateTimeTableViewCell.h"


@implementation ExperienceDateTimeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if ([self.delegate respondsToSelector:@selector(ExperienceDateTimeTableViewCellDelegateForTextFieldClicked:withTextField:)]) {
        [self.delegate ExperienceDateTimeTableViewCellDelegateForTextFieldClicked:self withTextField:textField];
    }
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if ([self.delegate respondsToSelector:@selector(ExperienceDateTimeTableViewCellDelegateForTextFieldClicked:withTextField:)]) {
        [self.delegate ExperienceDateTimeTableViewCellDelegateForTextFieldClicked:self withTextField:textField];
    }
    return NO;
}

/// return NO to disallow editing.

- (IBAction)currentBtnPressed:(id)sender {
}
@end

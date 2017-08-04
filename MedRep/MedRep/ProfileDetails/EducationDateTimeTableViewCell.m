//
//  EducationDateTimeTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 7/17/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "EducationDateTimeTableViewCell.h"

@implementation EducationDateTimeTableViewCell

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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
   
    if ([self.delegate respondsToSelector:@selector(EducationDateTimeTableViewCellDelegateForTextFieldClicked:withTextField:)]) {
        [self.delegate EducationDateTimeTableViewCellDelegateForTextFieldClicked:self withTextField:textField];
    }
    //EducationDateTimeTableViewCellDelegateForTextFieldClicked:(EducationDateTimeTableViewCell *)cell withTextField:(UITextField *)textField;
    
    return NO;
}

@end

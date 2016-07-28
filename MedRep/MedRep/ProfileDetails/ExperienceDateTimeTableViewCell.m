//
//  ExperienceDateTimeTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "ExperienceDateTimeTableViewCell.h"

@interface ExperienceDateTimeTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *fromDateFieldDropDown;

@end


@implementation ExperienceDateTimeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _isChecked = NO;
    // Initialization code
    [self bringSubviewToFront:self.fromDateFieldDropDown];
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
    if (!_isChecked) {
        [self.checkCurrentBtn setImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
        _isChecked = YES;
        _toView.hidden = YES;
    }else{
        _isChecked = NO;
        _toView.hidden = NO;
        [self.checkCurrentBtn setImage:[UIImage imageNamed:@"unselected.png"] forState:UIControlStateNormal];
    }
    
    if ([self.delegate respondsToSelector:@selector(getCurrentCheckButtonVal:)]) {
        [self.delegate getCurrentCheckButtonVal:_isChecked];
    }
    
}

@end

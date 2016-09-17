//
//  ExpericeFillUpTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "ExpericeFillUpTableViewCell.h"
#import "MRCommon.h"

@interface ExpericeFillUpTableViewCell () <UIAlertViewDelegate>

@end

@implementation ExpericeFillUpTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)deleteBtnTapped:(id)sender{
    [MRCommon showConformationOKNoAlert:NSLocalizedString(kDeleteProfileDetailsAlertMessage, "")
                               delegate:self withTag:11];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 11) {
        if (buttonIndex == 1) {
            if ([self.delegate respondsToSelector:@selector(ExpericeFillUpTableViewCellDelegateForButtonPressed:withButtonType:)]) {
                [self.delegate ExpericeFillUpTableViewCellDelegateForButtonPressed:self withButtonType:@"ExperienceDetail"];
            }
        }
    }
}

@end

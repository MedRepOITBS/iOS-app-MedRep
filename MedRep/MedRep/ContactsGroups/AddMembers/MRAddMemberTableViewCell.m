//
//  MRAddMemberTableViewCell.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/16/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRAddMemberTableViewCell.h"

@implementation MRAddMemberTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)checkMarkClicked:(id)sender {
    if ([sender isSelected]) {
        [sender setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        [sender setSelected:NO];
    } else {
        [sender setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        [sender setSelected:YES];
    }
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(selectedMemberAtIndex:)])
    {
        [self.cellDelegate selectedMemberAtIndex:((UIButton *)sender).tag];
    }
}

@end

//
//  AddMemberTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 8/6/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "AddMemberTableViewCell.h"

@implementation AddMemberTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)rejectAction:(id)sender {
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(rejectAction:)])
    {
        [self.cellDelegate rejectAction:((UIButton *)sender).tag];
    }
}

- (IBAction)acceptAction:(id)sender {
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(acceptAction:)])
    {
        [self.cellDelegate acceptAction:((UIButton *)sender).tag];
    }
}
@end

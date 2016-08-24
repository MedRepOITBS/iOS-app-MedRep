//
//  basicInfoTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "basicInfoTableViewCell.h"

@implementation basicInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)deleteBtnTapped:(id)sender{
    if ([self.delegate respondsToSelector:@selector(basicInfoTableViewCellDelegateForButtonPressed:withButtonType:)]) {
        [self.delegate basicInfoTableViewCellDelegateForButtonPressed:self withButtonType:@"ExperienceDetail"];
    }
    
}
@end

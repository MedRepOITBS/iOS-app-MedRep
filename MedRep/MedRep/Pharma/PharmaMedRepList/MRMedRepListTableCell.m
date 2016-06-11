//
//  MRProductTableCell.m
//  Gravity
//
//  Created by Apple on 26/09/15.
//  Copyright © 2015 Sprim. All rights reserved.
//

#import "MRMedRepListTableCell.h"

@implementation MRMedRepListTableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)accessoryButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(accessoryButtonDelegationAction:)])
    {
        [self.delegate accessoryButtonDelegationAction:self];
    }
}

@end

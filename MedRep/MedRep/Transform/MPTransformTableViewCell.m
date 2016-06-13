//
//  MPTransformTableViewCell.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MPTransformTableViewCell.h"

@implementation MPTransformTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.img.layer setBorderWidth:1.0];
    [self.img.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

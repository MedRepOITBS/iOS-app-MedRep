//
//  MRDoctorScoreTableCell.m
//  Gravity
//
//  Created by Apple on 26/09/15.
//  Copyright © 2015 Sprim. All rights reserved.
//

#import "MRDoctorScoreTableCell.h"

@implementation MRDoctorScoreTableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)doctorLocationButtonAction:(id)sender
{
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(doctorLocationButtonActiondelagate:)])
    {
        [self.cellDelegate doctorLocationButtonActiondelagate:self];
    }
}
@end

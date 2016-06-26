//
//  MRContactWithinGroupCollectionViewCell.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRContactWithinGroupCollectionViewCell.h"

@implementation MRContactWithinGroupCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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

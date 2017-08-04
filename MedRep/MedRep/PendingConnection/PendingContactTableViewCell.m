//
//  PendingContactTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 6/9/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "PendingContactTableViewCell.h"

@interface PendingContactTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *rejectButton;

@end

@implementation PendingContactTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.rejectButton.layer.cornerRadius = self.rejectButton.bounds.size.width / 2.0;
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

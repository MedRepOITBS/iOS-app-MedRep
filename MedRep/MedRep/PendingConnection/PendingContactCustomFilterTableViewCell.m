//
//  PendingContactTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 6/9/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "PendingContactCustomFilterTableViewCell.h"
@interface PendingContactCustomFilterTableViewCell(){
    BOOL isBtnChecked;
    
}
@end
@implementation PendingContactCustomFilterTableViewCell

-(IBAction)checkButtonTapped:(id)sender{
    if (!isBtnChecked) {
        isBtnChecked = YES;
        [self.checkImage setImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
                [self.checkImage setImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateHighlighted];
    }else {
        isBtnChecked = NO;
        [self.checkImage setImage:[UIImage imageNamed:@"uncheck.png"] forState:UIControlStateNormal];
        [self.checkImage setImage:[UIImage imageNamed:@"uncheck.png"] forState:UIControlStateHighlighted];
    }
    
}

-(BOOL)isButtonChecked{
    return isBtnChecked;
}

- (void)awakeFromNib {
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

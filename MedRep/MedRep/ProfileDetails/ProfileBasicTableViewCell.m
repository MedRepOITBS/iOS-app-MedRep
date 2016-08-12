//
//  ProfileBasicTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "ProfileBasicTableViewCell.h"

@implementation ProfileBasicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.profileimageView.layer.cornerRadius = self.profileimageView.frame.size.width / 2;
    self.profileimageView.clipsToBounds = YES;
    self.profileimageView.layer.borderWidth = 3.0f;
    self.profileimageView.layer.borderColor = [UIColor grayColor].CGColor;
}
-(IBAction)imageButtonTapped:(id)sender{
    if ([self.delegate respondsToSelector:@selector(ProfileBasicTableViewCellDelegateForButtonPressed:withButtonType:)]) {
        [self.delegate ProfileBasicTableViewCellDelegateForButtonPressed:self withButtonType:@"ProfilePicButton"];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  MPNotificatinsTableViewCell.m
//  MedRep
//
//  Created by MedRep Developer on 07/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MPNotificatinsTableViewCell.h"

@implementation MPNotificatinsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.notificationLetter.layer.cornerRadius = 30;
    self.notificationLetter.layer.borderWidth = 2.0;
    self.notificationLetter.layer.borderColor = [UIColor whiteColor].CGColor;
    self.notificationLetter.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCompanyNotifcationcell:(NSIndexPath*)indexpath
{
    self.companyLogo.hidden =
    self.arrowImage.hidden = YES;
    
    self.cellImageLeftConstarint.constant =
    self.cellImageRightConstaint.constant = 0;
    self.cellimageTopConstarint.constant = 2;
    self.topSeparator.hidden = NO;
    
    self.companyLabel.textColor =
    self.medicineLabel.textColor = [UIColor whiteColor];
    self.notificationLetterBottomConstratint.constant = 20;
    self.notificationLetterLeadingConstratint.constant = 20;

    [self updateConstraints];
//    if (indexpath.row == 0)
//    {
//        self.indicationNewLabel.hidden = NO;
//    }
//    else
//    {
//        self.indicationNewLabel.hidden = YES;
//    }
}

@end

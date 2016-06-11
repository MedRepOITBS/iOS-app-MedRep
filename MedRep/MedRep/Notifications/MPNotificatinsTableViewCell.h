//
//  MPNotificatinsTableViewCell.h
//  MedRep
//
//  Created by MedRep Developer on 07/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPNotificatinsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *companyLogo;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImage;
@property (weak, nonatomic) IBOutlet UILabel *medicineLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellimageTopConstarint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellImageLeftConstarint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellImageRightConstaint;
@property (weak, nonatomic) IBOutlet UILabel *indicationNewLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *indicatorNewXCoordinate;
@property (weak, nonatomic) IBOutlet UILabel *topSeparator;
@property (weak, nonatomic) IBOutlet UILabel *notificationLetter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationLetterBottomConstratint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationLetterLeadingConstratint;

- (void)configureCompanyNotifcationcell:(NSIndexPath*)indexpath;
@end

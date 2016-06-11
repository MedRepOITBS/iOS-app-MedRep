//
//  MRConvertAppointmentCell.h
//  MedRep
//
//  Created by MedRep Developer on 27/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRConvertAppointmentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *appointmnetTime;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *timeIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toplabelConstraint;

- (void)loadProfileImage:(NSNumber*)doctorId;
- (void)loadProfileImageWithName:(NSNumber*)doctorId;
@end

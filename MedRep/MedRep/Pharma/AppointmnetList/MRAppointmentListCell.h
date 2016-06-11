//
//  MRAppointmentListCell.h
//  MedRep
//
//  Created by MedRep Developer on 27/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRAppointmentListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *appointmnetTime;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

- (void)loadProfileImage:(NSNumber*)doctorId;

@end

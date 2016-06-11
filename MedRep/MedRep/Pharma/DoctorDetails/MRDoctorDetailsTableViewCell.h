//
//  MRDoctorDetailsTableViewCell.h
//  Gravity
//
//  Created by Apple on 26/09/15.
//  Copyright © 2015 Sprim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRDoctorDetailsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellImgView;
@property (weak, nonatomic) IBOutlet UILabel *cellHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellDescLabel;

- (void)loadProfileImage:(NSNumber*)doctorId;

@end

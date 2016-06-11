//
//  MRDoctorDetailsTableViewCell.m
//  Gravity
//
//  Created by Apple on 26/09/15.
//  Copyright © 2015 Sprim. All rights reserved.
//

#import "MRDoctorDetailsTableViewCell.h"
#import "MRWebserviceHelper.h"
#import "MRCommon.h"
#import "MRConstants.h"

@implementation MRDoctorDetailsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadProfileImage:(NSNumber*)doctorId
{
    [[MRWebserviceHelper sharedWebServiceHelper] getDoctorProfileForPharma:[NSString stringWithFormat:@"%lld",[doctorId longLongValue]] withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            if ([[responce objectForKey:KProfilePicture] isKindOfClass:[NSDictionary class]])
            {
                
                self.cellImgView.image = [MRCommon getImageFromBase64Data:[[responce objectForKey:KProfilePicture] objectForKey:@"data"]];
            }
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getDoctorProfileForPharma:[NSString stringWithFormat:@"%lld",[doctorId longLongValue]] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                  {
                      [MRCommon stopActivityIndicator];
                      if (status)
                      {
                          if ([[responce objectForKey:KProfilePicture] isKindOfClass:[NSDictionary class]])
                          {
                              
                              self.cellImgView.image = [MRCommon getImageFromBase64Data:[[responce objectForKey:KProfilePicture] objectForKey:@"data"]];
                          }
                      }
                  }];
             }];
        }
    }];
}

@end

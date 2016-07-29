//
//  MRAppointmentListCell.m
//  MedRep
//
//  Created by MedRep Developer on 27/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRAppointmentListCell.h"
#import "MRWebserviceHelper.h"
#import "MRCommon.h"
#import "MRConstants.h"

@implementation MRAppointmentListCell

- (void)awakeFromNib {
    // Initialization code
    
    self.profileImage.layer.cornerRadius = 15/2;
    self.profileImage.clipsToBounds = YES;
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
            self.profileName.text = [NSString stringWithFormat:@"Meeting With Dr %@ %@",[responce objectForKey:@"firstName"],[responce objectForKey:@"lastName"]];
            if ([[responce objectForKey:KProfilePicture] isKindOfClass:[NSDictionary class]])
            {
                
                NSDictionary *temp = [responce objectForKey:@"profilePicture"];

                
                NSURL * imageURL = [NSURL URLWithString:[temp objectForKey:KProfilePicture]];
                
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(queue, ^{
                    NSData *data = [NSData dataWithContentsOfURL:imageURL];
                    UIImage *image = [UIImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.profileImage.image = image;
                    });  
                });
                
       
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
                          self.profileName.text = [NSString stringWithFormat:@"Meeting With DR %@ %@",[responce objectForKey:@"firstName"],[responce objectForKey:@"lastName"]];
                          if ([[responce objectForKey:KProfilePicture] isKindOfClass:[NSDictionary class]])
                          {
                              NSDictionary *temp = [responce objectForKey:@"profilePicture"];
                              
                              
                              NSURL * imageURL = [NSURL URLWithString:[temp objectForKey:KProfilePicture]];
                              
                              
                              dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                              dispatch_async(queue, ^{
                                  NSData *data = [NSData dataWithContentsOfURL:imageURL];
                                  UIImage *image = [UIImage imageWithData:data];
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      self.profileImage.image = image;
                                  });  
                              });
                              
                             
                        
                          }
                      }
                  }];
             }];
        }
    }];
}

@end

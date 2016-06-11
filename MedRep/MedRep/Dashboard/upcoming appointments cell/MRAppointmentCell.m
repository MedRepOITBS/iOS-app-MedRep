//
//  MRAppointmentCell.m
//  MedRep
//
//  Created by MedRep Developer on 13/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRAppointmentCell.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "MRWebserviceHelper.h"

@implementation MRAppointmentCell

- (void)awakeFromNib {
    
    self.transform = CGAffineTransformMakeRotation(M_PI * 0.5);

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureAppointmentCell:(NSDictionary*)appointment
{
    //[self loadProfileImage:[appointment objectForKey:@"doctorId"]];
    self.appointmentName.text = [appointment objectForKey:@"companyname"];
    self.appointmentDescription.text = [appointment objectForKey:@"title"];
   // self.appointmentName.text = [appointment objectForKey:@"companyname"];
    [self getDateandMonth:[appointment objectForKey:@"startDate"]];
}

- (void)configureAppointmentCellForPharma:(NSDictionary*)appointment
{
    [self loadProfileImage:[appointment objectForKey:@"doctorId"]];
    self.appointmentDescription.text = [appointment objectForKey:@"title"];
    //self.appointmentName.text = [appointment objectForKey:@"doctorName"];
    [self getDateandMonth:[appointment objectForKey:@"startDate"]];
}

- (void)getDateandMonth:(NSString*)startDate
{
    //startDate = @"20150917103000";
    NSString *date , *month;
    
    month = nil;
    date  = @"";
    
    if(startDate.length > 4)
    month = [startDate substringWithRange:NSMakeRange(4, 2)];
    
    if(startDate.length > 6)
    date = [startDate substringWithRange:NSMakeRange(6, 2)];
    
    self.appointmentMonth.text = (month != nil) ? [kShotMonthsArray objectAtIndex:([month intValue] - 1)] : @"";
    self.appointmnetDate.text = date;
}

- (void)loadProfileImage:(NSNumber*)doctorId
{
    [[MRWebserviceHelper sharedWebServiceHelper] getDoctorProfileForPharma:[NSString stringWithFormat:@"%lld",[doctorId longLongValue]] withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            self.appointmentName.text = [NSString stringWithFormat:@"Dr. %@ %@",[responce objectForKey:@"firstName"],[responce objectForKey:@"lastName"]];
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
                          self.appointmentName.text = [NSString stringWithFormat:@"Dr. %@ %@",[responce objectForKey:@"firstName"],[responce objectForKey:@"lastName"]];
                      }
                  }];
             }];
        }
    }];
}

@end

/*
 appointmentDesc = " 1 Test Description";
 appointmentId = 1;
 companyId = 2;
 companyname = RanBaxy;
 createdOn = 1441434188000;
 doctorId = 14;
 doctorName = "Rajesh Kumar";
 duration = 30;
 feedback = Feedback;
 location = "";
 notificationId = 3;
 pharmaRepId = "";
 pharmaRepName = "";
 startDate = 20160620000000;
 status = Updated;
 therapeuticId = 1;
 therapeuticName = Demo;
 title = "Mr.";
 */

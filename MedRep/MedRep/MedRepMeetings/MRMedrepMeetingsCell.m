//
//  MRMedrepMeetingsCell.m
//  MedRep
//
//  Created by MedRep Developer on 21/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRMedrepMeetingsCell.h"
#import "MRCommon.h"
#import "MRConstants.h"

@implementation MRMedrepMeetingsCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)configureAppointmentCell:(NSDictionary*)appointment
{
    self.appointmentDescription.text = [appointment objectForKey:@"appointmentDesc"];
    self.appointmentName.text = [appointment objectForKey:@"companyname"];
    [self getDateandMonth:[appointment objectForKey:@"startDate"]];
}

- (void)getDateandMonth:(NSString*)startDate
{
    //startDate = @"20150917103000";
    NSString *date , *month;
    
    month = [startDate substringWithRange:NSMakeRange(4, 2)];
    date = [startDate substringWithRange:NSMakeRange(6, 2)];
    
    self.appointmentMonth.text = [kShotMonthsArray objectAtIndex:([month intValue] - 1)];
    self.appointmnetDate.text = date;
}

@end

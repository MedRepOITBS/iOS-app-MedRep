//
//  MRMedrepMeetingsCell.h
//  MedRep
//
//  Created by MedRep Developer on 21/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRMedrepMeetingsCell : UITableViewCell
{
    
}

@property (weak, nonatomic) IBOutlet UILabel *appointmentDescription;
@property (weak, nonatomic) IBOutlet UILabel *appointmentName;
@property (weak, nonatomic) IBOutlet UILabel *appointmnetDate;
@property (weak, nonatomic) IBOutlet UILabel *appointmentMonth;

- (void)configureAppointmentCell:(NSDictionary*)appointment;

@end

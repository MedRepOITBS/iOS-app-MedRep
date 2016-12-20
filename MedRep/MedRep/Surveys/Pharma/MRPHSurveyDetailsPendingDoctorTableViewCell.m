//
//  MRPHSurveyDetailsPendingDoctorTableViewCell.m
//  MedRep
//
//  Created by Vamsi Katragadda on 12/19/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRPHSurveyDetailsPendingDoctorTableViewCell.h"
#import "MRPHSurveyPendingList+CoreDataClass.h"
#import "MRWebserviceHelper.h"
#import "MRCommon.h"
#import "MRPHSurveyDetailsViewController.h"

@interface MRPHSurveyDetailsPendingDoctorTableViewCell () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UILabel *doctorName;

@property (nonatomic) MRPHSurveyPendingList *doctorDetail;

@property (nonatomic) MRPHSurveyDetailsViewController *parentViewController;

@end

@implementation MRPHSurveyDetailsPendingDoctorTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(MRPHSurveyPendingList*)doctorDetails
andParentViewController:(MRPHSurveyDetailsViewController*)viewController {
    
    self.doctorDetail = doctorDetails;
    self.parentViewController = viewController;
    
    if (doctorDetails != nil) {
        [self.doctorName setText:doctorDetails.doctorName];
        
        if (doctorDetails.reminder_sent.boolValue) {
            [self.statusButton setUserInteractionEnabled:NO];
            [self.statusButton setTitle:@"Reminder Sent" forState:UIControlStateNormal];
        } else {
            [self.statusButton setUserInteractionEnabled:YES];
            [self.statusButton setTitle:@"Remind" forState:UIControlStateNormal];
        }
    }
}

- (IBAction)remindMeButtonPressed:(id)sender {
    [MRCommon showActivityIndicator:@"Sending..."];
    
    [[MRWebserviceHelper sharedWebServiceHelper] sendReminderToDoctorForSurvey:self.doctorDetail.surveyId.longValue doctorId:self.doctorDetail.doctorId.longValue andHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             [MRCommon stopActivityIndicator];
             [self parseRemindResponse:responce];
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] sendReminderToDoctorForSurvey:self.doctorDetail.surveyId.longValue doctorId:self.doctorDetail.doctorId.longValue andHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       [MRCommon stopActivityIndicator];
                       [self parseRemindResponse:responce];
                   }];
              }];
         }
         else
         {
             [MRCommon stopActivityIndicator];
             [MRCommon showAlert:@"Reminder cannot be sent" delegate:nil];
         }
     }];
}

- (void)parseRemindResponse:(NSDictionary*)response {
    NSString *status = [response objectOrNilForKey:@"status"];
    if (status != nil && status.length > 0 && [status caseInsensitiveCompare:@"success"] == NSOrderedSame) {
        NSString *message = [response objectOrNilForKey:@"message"];
        if (message == nil || message.length == 0) {
            message = @"Reminder is sent to the doctor";
        }
        [MRCommon showAlert:message delegate:self];
    } else {
        [MRCommon showAlert:@"Failed to send reminder !!!" delegate:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.parentViewController downloadPendingDoctorsList];
}

@end

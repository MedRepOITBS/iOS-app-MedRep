//
//  MPNotificatinsTableViewCell.m
//  MedRep
//
//  Created by MedRep Developer on 07/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MPNotificatinsTableViewCell.h"
#import "MRCommon.h"
#import "MRWebserviceHelper.h"

@interface MPNotificatinsTableViewCell () <UIAlertViewDelegate>

@property (assign, nonatomic) NSInteger surveyId;

@end

@implementation MPNotificatinsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.notificationLetter.layer.cornerRadius = 30;
    self.notificationLetter.layer.borderWidth = 2.0;
    self.notificationLetter.layer.borderColor = [UIColor whiteColor].CGColor;
    self.notificationLetter.clipsToBounds = YES;
    
    [self.downloadSurveyReportButton setHidden:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCompanyNotifcationcell:(NSIndexPath*)indexpath
{
    self.companyLogo.hidden =
    self.arrowImage.hidden = YES;
    
    self.cellImageLeftConstarint.constant =
    self.cellImageRightConstaint.constant = 0;
    self.cellimageTopConstarint.constant = 2;
    self.topSeparator.hidden = NO;
    
    self.companyLabel.textColor =
    self.medicineLabel.textColor = [UIColor whiteColor];
    self.notificationLetterBottomConstratint.constant = 20;
    self.notificationLetterLeadingConstratint.constant = 20;

    [self updateConstraints];
//    if (indexpath.row == 0)
//    {
//        self.indicationNewLabel.hidden = NO;
//    }
//    else
//    {
//        self.indicationNewLabel.hidden = YES;
//    }
}

- (void)enableDownloadReportButton:(BOOL)hidden {
    [self.downloadSurveyReportButton setHidden:hidden];
    
    if (hidden) {
        [self.downloadSurveyReportButton setImage:[UIImage imageNamed:@"disabeDownloadIcon"]
                                         forState:UIControlStateNormal];
    } else {
        [self.downloadSurveyReportButton setImage:[UIImage imageNamed:@"downloadIcon"]
                                         forState:UIControlStateNormal];
    }
}

- (void)removeDownloadReportAction {
    [self.downloadSurveyReportButton removeTarget:self action:@selector(downloadReportButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)downloadReportButtonAction:(id)sender {
    [MRCommon showConformationOKNoAlert:@"Do you want to request a Report for this Survey?"
                               delegate:self withTag:999];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 999 && buttonIndex == 1) {
        [MRCommon showActivityIndicator:@"Sending..."];
        
        [[MRWebserviceHelper sharedWebServiceHelper] getSurveyReports:self.surveyId withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
            if (status)
            {
                [MRCommon stopActivityIndicator];
                [MRCommon showAlert:[responce objectOrNilForKey:@"result"] delegate:nil];
            }
            else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
            {
                [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
                 {
                     [MRCommon stopActivityIndicator];
                     [MRCommon savetokens:responce];
                     [[MRWebserviceHelper sharedWebServiceHelper] getSurveyReports:0 withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                         if (status)
                         {
                             [MRCommon stopActivityIndicator];
                             [MRCommon showAlert:@"Your request has been submitted. You will receive the report as soon as the Survey has been completed" delegate:nil];
                         }
                     }];
                 }];
            }
            else
            {
                [MRCommon stopActivityIndicator];
            }
        }];
    }
}

- (void)setSurveyReport:(NSNumber*)surveyId {
    if (surveyId != nil) {
        self.surveyId = surveyId.longValue;
    }
}

@end

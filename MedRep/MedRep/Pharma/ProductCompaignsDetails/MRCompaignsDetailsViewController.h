//
//  MRCompaignsDetailsViewController.h
//  MedRep
//
//  Created by MedRep Developer on 28/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRCompaignsDetailsViewController : UIViewController

@property (retain, nonatomic) NSString *titleText;
@property (assign, nonatomic) NSInteger notificationID;
@property (weak, nonatomic) IBOutlet UILabel *convertedAppointmentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *sentAppointmentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewedAppointmentCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkFeedbackButton;

- (void)updateTitleLabel;
- (IBAction)checkFeedbackButtonAction:(id)sender;

@end

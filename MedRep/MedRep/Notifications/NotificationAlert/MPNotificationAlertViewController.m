//
//  MPNotificationAlertViewController.m
//  MedRep
//
//  Created by MedRep Developer on 10/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MPNotificationAlertViewController.h"
#import "MRCommon.h"
#import "MRConstants.h"

@interface MPNotificationAlertViewController ()
@property (weak, nonatomic) IBOutlet UIView *feedbackAlert;
@property (weak, nonatomic) IBOutlet UIView *messageAlert;
@property (weak, nonatomic) IBOutlet UIView *optionsAlert;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *feedbackAlertTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *feedbackAlertBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *yesButtonOne;
@property (weak, nonatomic) IBOutlet UIButton *noButtonOne;
@property (weak, nonatomic) IBOutlet UIButton *yesButtonTwo;
@property (weak, nonatomic) IBOutlet UIButton *noButtonTwo;
@property (weak, nonatomic) IBOutlet UIButton *rateButtonOne;
@property (weak, nonatomic) IBOutlet UIButton *rateButtonTwo;
@property (weak, nonatomic) IBOutlet UIButton *rateButtonThree;
@property (weak, nonatomic) IBOutlet UIButton *rateButtonFour;
@property (weak, nonatomic) IBOutlet UIButton *rateButtonFive;
@property (weak, nonatomic) IBOutlet UIButton *optionsCloseButton;


@property (weak, nonatomic) IBOutlet UILabel *messageAlertMessageText;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UILabel *optionsAlertTitle;
@property (weak, nonatomic) IBOutlet UIButton *optionAlertCancelButton;

@property (weak, nonatomic) IBOutlet UIButton *optionAlertOkButton;
@property (weak, nonatomic) IBOutlet UIButton *dayButton;
@property (weak, nonatomic) IBOutlet UIButton *weekButton;
@property (weak, nonatomic) IBOutlet UIButton *monthButton;

@property (nonatomic, strong) alertCompletionHandler okComplitionHandler;
@property (nonatomic, strong) alertCompletionHandler cancelComplitionHandler;

@end

@implementation MPNotificationAlertViewController

- (void)viewDidLoad {
    self.dayButton.selected = YES;
    self.locatlNotificationType = 1;
    self.yesButtonOne.selected = NO;
    self.yesButtonTwo.selected = NO;
    
    if ([MRCommon deviceHasThreePointFiveInchScreen])
    {
        self.feedbackAlertBottomConstraint.constant = 30;
        self.feedbackAlertTopConstraint.constant = 30;
        [self updateViewConstraints];
    }
    else if ([MRCommon deviceHasFourInchScreen])
    {
        self.feedbackAlertBottomConstraint.constant = 50;
        self.feedbackAlertTopConstraint.constant = 50;
        [self updateViewConstraints];
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureAlertWithAlertType:(MRAlertType)alertType
                        withMessage:(NSString*)message
                          withTitle:(NSString*)title
                 withOKButtonAction:(alertCompletionHandler)okResponceHandler
             withCancelButtonAction:(alertCompletionHandler)cancelResponceHandler
{
    switch (alertType)
    {
        case MRAlertTypeMessage:
        {
            self.messageAlertMessageText.text = message;
            self.messageAlertTitle.text = title;
            _messageAlert.hidden    = NO;
            _optionsAlert.hidden    = YES;
            _feedbackAlert.hidden   = YES;
        }
            break;
        case MRAlertTypeFeedBack:
        {
            _messageAlert.hidden    = YES;
            _optionsAlert.hidden    = YES;
            _feedbackAlert.hidden   = NO;
            self.patiantRecomended = YES;
            self.doctorRecomended = YES;
            self.rating = 0.0;
        }
            break;
        case MRAlertTypeOptions:
        {
            _messageAlert.hidden    = YES;
            _optionsAlert.hidden    = NO;
            _feedbackAlert.hidden   = YES;
        }
            break;
        case MRAlertTypeNone:
        {
            _messageAlert.hidden    = NO;
            _optionsAlert.hidden    = YES;
            _feedbackAlert.hidden   = YES;
        }
            break;
   
        default:
            break;
    }
   
    self.okComplitionHandler = okResponceHandler;
    self.cancelComplitionHandler = cancelResponceHandler;
}


- (IBAction)submitButtonAction:(id)sender
{
    if ((self.yesButtonOne.selected == YES || self.noButtonOne.selected == YES) && (self.yesButtonTwo.selected == YES || self.noButtonTwo.selected == YES))
    {
        self.okComplitionHandler(self);
    }
    else
    {
        [MRCommon showAlert:@"Please provide feedback." delegate:nil];
    }
}

- (IBAction)yesButtonOneAction:(id)sender
{
    self.yesButtonOne.selected = YES;
    self.noButtonOne.selected = NO;
    self.patiantRecomended = YES;
}

- (IBAction)noButtonOneAction:(id)sender
{
    self.yesButtonOne.selected = NO;
    self.noButtonOne.selected = YES;
    self.patiantRecomended = NO;
}

- (IBAction)yesButtonTwoAction:(id)sender
{
    self.yesButtonTwo.selected = YES;
    self.noButtonTwo.selected = NO;
    self.doctorRecomended = YES;

}

- (IBAction)noButtonTwoAction:(id)sender
{
    self.yesButtonTwo.selected = NO;
    self.noButtonTwo.selected = YES;
    self.doctorRecomended = NO;
}

- (IBAction)rateButtonAction:(UIButton *)sender
{
    UIButton *button = (UIButton*)sender;
    [self unselectImage];
    switch (button.tag)
    {
        case 100:
        {
            //star.png
            if (self.rateButtonOne.selected == NO) {
                self.rateButtonOne.selected = YES;
                [self.rateButtonOne setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
                self.rating = 1.0;
            }
            else
            {
                self.rateButtonOne.selected = NO;
                [self.rateButtonOne setImage:[UIImage imageNamed:@"starunselected.png"] forState:UIControlStateNormal];
            }
        }
            break;
        case 101:
        {
             self.rateButtonOne.selected = NO;
            [self.rateButtonOne setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.rateButtonTwo setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            self.rating = 2.0;

        }
            break;
        case 102:
        {
             self.rateButtonOne.selected = NO;
            [self.rateButtonOne setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.rateButtonTwo setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.rateButtonThree setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            self.rating = 3.0;

        }
            break;
        case 103:
        {
             self.rateButtonOne.selected = NO;
            [self.rateButtonOne setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.rateButtonTwo setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.rateButtonThree setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.rateButtonFour setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            self.rating = 4.0;

        }
            break;
        case 104:
        {
             self.rateButtonOne.selected = NO;
            [self.rateButtonOne setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.rateButtonTwo setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.rateButtonThree setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.rateButtonFour setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.rateButtonFive setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            self.rating = 5.0;

        }
            break;
   
        default:
            break;
    }
}

- (void)unselectImage
{
    [self.rateButtonOne setImage:[UIImage imageNamed:@"starunselected.png"] forState:UIControlStateNormal];
    [self.rateButtonTwo setImage:[UIImage imageNamed:@"starunselected.png"] forState:UIControlStateNormal];
    [self.rateButtonThree setImage:[UIImage imageNamed:@"starunselected.png"] forState:UIControlStateNormal];
    [self.rateButtonFour setImage:[UIImage imageNamed:@"starunselected.png"] forState:UIControlStateNormal];
    [self.rateButtonFive setImage:[UIImage imageNamed:@"starunselected.png"] forState:UIControlStateNormal];

}
- (IBAction)optionsCloseButtonAction:(id)sender
{
    self.cancelComplitionHandler(self);
}
- (IBAction)okButtonAction:(id)sender
{
    self.okComplitionHandler(self);
}
- (IBAction)cancelButtonAction:(id)sender
{
    self.cancelComplitionHandler(self);
}
- (IBAction)optionAlertCancelButtonAction:(id)sender
{
    self.cancelComplitionHandler(self);
}
- (IBAction)optionAlertOkButtonAction:(id)sender
{
    self.okComplitionHandler(self);
}

- (IBAction)remindMeButtonAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 1000:
        {
            self.dayButton.selected = YES;
            self.monthButton.selected = NO;
            self.weekButton.selected = NO;
            self.locatlNotificationType = 1;
        }
            break;
        case 1001:
        {
            self.dayButton.selected = NO;
            self.monthButton.selected = NO;
            self.weekButton.selected = YES;
            self.locatlNotificationType = 2;
        }
            break;
        case 1002:
        {
            self.dayButton.selected = NO;
            self.monthButton.selected = YES;
            self.weekButton.selected = NO;
            self.locatlNotificationType = 3;
        }
            break;
   
        default:
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

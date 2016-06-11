//
//  MPNotificationAlertViewController.h
//  MedRep
//
//  Created by MedRep Developer on 10/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    MRAlertTypeNone = 0,
    MRAlertTypeMessage,
    MRAlertTypeOptions,
    MRAlertTypeFeedBack
} MRAlertType;

@class MPNotificationAlertViewController;

typedef void(^alertCompletionHandler)(MPNotificationAlertViewController* alertView);

@interface MPNotificationAlertViewController : UIViewController
{
    
}

@property (weak, nonatomic) IBOutlet UILabel *messageAlertTitle;
@property (assign, nonatomic) CGFloat rating;
@property (assign, nonatomic) BOOL patiantRecomended;
@property (assign, nonatomic) BOOL doctorRecomended;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertWidthConstraint;

@property (assign, nonatomic) NSInteger locatlNotificationType;
- (void)configureAlertWithAlertType:(MRAlertType)alertType
                        withMessage:(NSString*)message
                          withTitle:(NSString*)title
                 withOKButtonAction:(alertCompletionHandler)okResponceHandler
             withCancelButtonAction:(alertCompletionHandler)cancelResponceHandler;

@end




//
//  MPCallMedrepViewController.h
//  MedRep
//
//  Created by MedRep Developer on 10/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MPNotificationAlertViewController;
@interface MPCallMedrepViewController : UIViewController
{
     MPNotificationAlertViewController *viewController;
}

@property (nonatomic, assign) BOOL isFromReschedule;
@property (nonatomic, retain) NSDictionary *notificationDetails;
@property (nonatomic, retain) NSDictionary *selectedNotification;
@end

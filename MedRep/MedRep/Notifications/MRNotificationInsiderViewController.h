//
//  MRNotificationInsiderViewController.h
//  MedRep
//
//  Created by MedRep Developer on 09/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPNotificationAlertViewController;
@class MRNotifications;

@interface MRNotificationInsiderViewController : UIViewController
{
    MPNotificationAlertViewController *viewController;
}

@property (nonatomic, retain) NSNumber *notificationId;
@property (nonatomic, assign) BOOL isFullScreen;

@end

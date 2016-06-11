//
//  MRNotificationInsiderViewController.h
//  MedRep
//
//  Created by MedRep Developer on 09/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPNotificationAlertViewController;

@interface MRPharmaNotificationDetailsViewController : UIViewController
{
    MPNotificationAlertViewController *viewController;
}
@property (nonatomic, assign) BOOL isFullScreenShown;
@property (nonatomic, retain) NSDictionary *notificationDetails;
@property (nonatomic, retain) NSDictionary *selectedNotification;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageConstarintViewConstaint;
@property (weak, nonatomic) IBOutlet UIView *fullscreenView;
@end

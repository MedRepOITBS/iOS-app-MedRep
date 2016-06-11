//
//  NotificationWebViewController.h
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/7/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationWebViewController : UIViewController

@property (nonatomic, retain) NSDictionary *selectedNotification;
@property (strong, nonatomic) NSString *urlLink;
@property (nonatomic, retain) NSArray *notificationDetailsList;
@property (nonatomic, assign) BOOL isFromTransform;

@end

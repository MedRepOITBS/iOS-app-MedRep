//
//  MRNotificationsDetailsViewController.h
//  MedRep
//
//  Created by MedRep Developer on 07/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRNotificationsDetailsViewController : UIViewController

@property (nonatomic, retain) NSDictionary *selectedNotification;
@property (nonatomic, retain) NSArray *notificationDetailsList;
@property (nonatomic, retain) NSArray *therapeuticNamesList;

@end

//
//  NotificationUUIDViewController.h
//  MedRep
//
//  Created by Vamsi Katragadda on 6/12/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationUUIDViewController : UIViewController

@property (atomic) UIWindow *appWindow;
@property (atomic) NSString *token;

- (void)refreshScreen;

@end

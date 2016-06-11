//
//  MRConvertAppointmentViewController.h
//  MedRep
//
//  Created by MedRep Developer on 27/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRAppointmentListViewController : UIViewController

@property (assign, nonatomic) NSInteger notificationID;
@property (assign, nonatomic) NSInteger appointnetType;
@property (assign, nonatomic) NSInteger repId;
@property (assign, nonatomic) BOOL isCompletedAppointmnet;
@property (assign, nonatomic) BOOL isPendingAppointmnet;
@end

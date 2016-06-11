//
//  MRDoctorDetailsViewController.h
//  Gravity
//
//  Created by Apple on 26/09/15.
//  Copyright © 2015 Sprim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRDoctorDetailsTableViewCell.h"

@interface MRDoctorDetailsViewController : UIViewController

@property (retain, nonatomic) NSString *doctorName;
@property (assign, nonatomic) NSInteger doctorID;
@property (assign, nonatomic) NSInteger notificationID;
@property (retain, nonatomic) NSString *repname;
@property (retain, nonatomic) NSString *productName;


@end

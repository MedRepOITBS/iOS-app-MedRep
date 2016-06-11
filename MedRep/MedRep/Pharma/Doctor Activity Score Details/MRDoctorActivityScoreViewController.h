//
//  MRDoctorScoreViewController.h
//  Gravity
//
//  Created by Apple on 26/09/15.
//  Copyright © 2015 Sprim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRDoctorActivityScoreViewController : UIViewController

@property (nonatomic, retain) NSDictionary *doctorDetalsDictionary;
@property (assign, nonatomic) NSInteger doctorID;
@property (nonatomic, assign) BOOL isFromMenu;

@end

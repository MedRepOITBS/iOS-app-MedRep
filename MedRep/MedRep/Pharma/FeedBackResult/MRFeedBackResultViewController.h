//
//  MRFeedBackResultViewController.h
//  MedRep
//
//  Created by MedRep Developer on 28/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRFeedBackResultViewController : UIViewController

@property (assign, nonatomic) NSInteger notificationID;
@property (weak, nonatomic) IBOutlet UILabel *feedbackTitle;
@property (retain, nonatomic) NSString *productName;

@end

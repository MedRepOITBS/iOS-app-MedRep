//
//  MRWelcomeViewController.h
//  MedRep
//
//  Created by MedRep Developer on 27/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRWelcomeViewControllerDelegate <NSObject>

- (void)loadDashboardScreenOnLogin;

@end

@interface MRWelcomeViewController : UIViewController

@property (nonatomic, assign) id<MRWelcomeViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL isFromSinUp;

@end

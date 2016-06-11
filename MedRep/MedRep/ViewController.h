//
//  ViewController.h
//  MedRep
//
//  Created by MedRep Developer on 09/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ViewControllerDelegate <NSObject>

- (void)removeSplashViewOnAnimationEnd;

@end

@interface ViewController : UIViewController<ViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *spImage;
@property (assign, nonatomic) id <ViewControllerDelegate> delegate;

@end


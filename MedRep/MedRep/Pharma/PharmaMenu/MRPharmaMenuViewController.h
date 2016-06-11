//
//  MRPharmaMenuViewController.h
//  MedRep
//
//  Created by MedRep Developer on 27/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRPharmaMenuViewControllerDelegate <NSObject>

- (void)loadLoginView;

@end

@interface MRPharmaMenuViewController : UIViewController

@property (nonatomic, assign) id<MRPharmaMenuViewControllerDelegate> delegate;

@end

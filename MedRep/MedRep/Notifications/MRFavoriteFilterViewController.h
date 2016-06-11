//
//  MRFavoriteFilterViewController.h
//  MedRep
//
//  Created by MedRep Developer on 10/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRFavoriteFilterViewControllerDelegate <NSObject>

- (void)loadNotificationsOnFilter:(NSString*)companyName
               withTherapiticName:(NSString*)therapeuticName;

@end

@interface MRFavoriteFilterViewController : UIViewController

@property (nonatomic, assign) id <MRFavoriteFilterViewControllerDelegate> delegate;

@end

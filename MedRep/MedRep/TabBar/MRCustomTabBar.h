//
//  MRCustomTabBar.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/1/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRTransformViewController;
@class MRContactsViewController;
@class MRMyWallViewController;
@class MRServeViewController;

@interface MRCustomTabBar : UIView

@property (nonatomic, weak) UINavigationController *navigationController;

@property (nonatomic) MRTransformViewController *transformViewController;
@property (nonatomic) MRContactsViewController *contactsViewController;
@property (nonatomic) MRMyWallViewController *shareViewController;
@property (nonatomic) MRServeViewController *serveViewController;

- (void)updateActiveViewController:(UIViewController*)viewController andTabIndex:(NSInteger)tabIndex;

@end

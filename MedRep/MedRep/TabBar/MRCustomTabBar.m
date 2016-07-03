//
//  MRCustomTabBar.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/1/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRCustomTabBar.h"

#import "MRCommon.h"
#import "MRTransformViewController.h"
#import "MRContactsViewController.h"
#import "MRShareViewController.h"
#import "MRServeViewController.h"

@interface MRCustomTabBar () {
    
    __weak IBOutlet UIView *connectView;
    __weak IBOutlet UIView *transformView;
    __weak IBOutlet UIView *shareView;
    __weak IBOutlet UIView *serveView;
}

@property (nonatomic, weak) UIViewController *activeViewController;

@end

@implementation MRCustomTabBar

- (void)updateActiveViewController:(UIViewController*)viewController andTabIndex:(NSInteger)tabIndex {
    self.activeViewController = viewController;
    [self updateTabBarColors:tabIndex];
}

- (IBAction)connectButtonTapped:(id)sender {
    if (self.contactsViewController == nil || self.activeViewController != self.contactsViewController) {
        if (self.contactsViewController == nil) {
            self.contactsViewController = [[MRContactsViewController alloc] initWithNibName:@"MRContactsViewController" bundle:nil];
        }
        
        [self.navigationController pushViewController:self.contactsViewController animated:true];
    }
}

- (IBAction)transformButtonTapped:(id)sender {
    if (self.transformViewController == nil ||self.activeViewController != self.transformViewController) {
        if (self.transformViewController == nil) {
            self.transformViewController = [[MRTransformViewController alloc] initWithNibName:@"MRTransformViewController" bundle:nil];
        }
        [self.navigationController pushViewController:self.transformViewController animated:true];
    }
}

- (IBAction)shareButtonTapped:(id)sender {
    if (self.shareViewController == nil || self.activeViewController != self.shareViewController) {
        if (self.shareViewController == nil) {
            self.shareViewController = [[MRShareViewController alloc] initWithNibName:@"MRShareViewController" bundle:nil];
        }
        [self.navigationController pushViewController:self.shareViewController animated:true];
    }
}

- (IBAction)serveButtonTapped:(id)sender {
    if (self.serveViewController == nil || self.activeViewController != self.serveViewController) {
        if (self.serveViewController == nil) {
            self.serveViewController = [[MRServeViewController alloc] initWithNibName:@"MRServeViewController" bundle:nil];
        }
        [self.navigationController pushViewController:self.serveViewController animated:true];
    }
}

- (void)updateTabBarColors:(NSInteger)currentTabIndex {
    
    UIView *currentView = [self getView:currentTabIndex];
    
    if (currentView != nil) {
        [currentView setBackgroundColor:[MRCommon colorFromHexString:@"#2BF6C0"]];
    }
    
    for (NSInteger index = 0; index < 4; index++) {
        UIView *otherView = [self getView:index];
        if (otherView != nil && otherView != currentView) {
            [otherView setBackgroundColor:[MRCommon colorFromHexString:@"#20B18A"]];
        }
    }
}

- (UIView*)getView:(NSInteger)index {
    UIView *currentView = nil;
    switch (index) {
        case 0:
            currentView = connectView;
            break;
            
        case 1:
            currentView = transformView;
            break;
            
        case 2:
            currentView = shareView;
            break;
            
        case 3:
            currentView = serveView;
            break;
            
        default:
            break;
    }
    
    return currentView;
}

@end

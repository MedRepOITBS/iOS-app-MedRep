//
//  MRAppControl.h
//  MedRep
//
//  Created by MedRep Developer on 10/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@class Reachability;

@class ViewController;

@interface MRAppControl : NSObject
{
    Reachability           *internetReach;
    BOOL                   isInternetAvailable;
}

@property (strong, nonatomic) UIWindow *appMainWindow;
@property (strong, nonatomic) ViewController *viewController;
@property (assign, nonatomic) NSInteger userType;
@property (assign, nonatomic) NSInteger addressType;

@property (strong, nonatomic) NSMutableDictionary *userRegData;
@property (strong, nonatomic) NSArray *therapeuticAreaDetails;
@property (strong, nonatomic) NSArray *myAppointments;
@property (strong, nonatomic) NSDictionary *selectedTherapeuticDetils;
@property (strong, nonatomic) NSArray *notifications;
@property (strong, nonatomic) NSArray *notificationTypes;
@property (strong, nonatomic) NSArray *roles;
@property (strong, nonatomic) NSArray *companyDetails;



+ (MRAppControl*)sharedHelper;
- (void)launchWithApplicationMainWindow:(UIWindow *)mainWindow;
- (void)launchSplashView;
- (void)applyFadeAnimation;
- (void)loadDashBoardOnLogin;
- (void)loadDashboardScreen;
- (void)loadHomeScreen;
- (void)loadLoginView;
- (void) updateInterfaceWithReachability: (Reachability*) curReach;
- (BOOL)internetCheck;
- (void) setupReachability;
- (void) setUserDetails:(NSDictionary*)details;
- (void)setMyTherapeuticAreaDetails:(NSArray*)therapeuticDetails;
- (void)setMyAppointmentDetails:(NSArray*)appointmentsList;
- (NSDictionary*)getNotificationByID:(NSInteger)notificationID;
- (NSDictionary*)getCompanyDetailsByID:(NSInteger)companyID;
- (NSArray*)getNotificationByCompanyID:(NSInteger)companyID;
- (NSArray*)getNotificationByTherapeuticName:(NSString*)therapeuticName
                               withCompanyID:(NSInteger)companyID;
- (void)resetUserData;
- (UIImage*)getCompanyImage;

@end

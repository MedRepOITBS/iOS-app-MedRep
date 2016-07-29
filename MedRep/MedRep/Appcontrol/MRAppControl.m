//
//  MRAppControl.m
//  MedRep
//
//  Created by MedRep Developer on 10/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "Reachability.h"
#import "MRDatabaseHelper.h"
#import "SWRevealViewController.h"
#import "ViewController.h"
#import "MRHomeViewContoller.h"
#import "MRMenuViewController.h"
#import "MRDashBoardVC.h"
#import "MRWebserviceHelper.h"
#import "MRPHDashBoardViewController.h"
#import "MRPharmaMenuViewController.h"
#import "MRWelcomeViewController.h"
#import "MROTPVerifiedViewController.h"
#import "AppDelegate.h"
#import "MRContact.h"
#import "MRGroup.h"
#import "MRPostedReplies.h"
#import "MRGroupMembers.h"

@interface MRAppControl () <SWRevealViewControllerDelegate, ViewControllerDelegate,MRMenuViewControllerDelegate,MRPharmaMenuViewControllerDelegate,MRWelcomeViewControllerDelegate>

@end

@implementation MRAppControl

@synthesize appMainWindow;

+ (MRAppControl*)sharedHelper
{
    static dispatch_once_t once;
    static MRAppControl *sharedAppCont;
    
    dispatch_once(&once, ^{
        sharedAppCont = [[MRAppControl alloc] init];
    });
    return sharedAppCont;
}

- (void)launchWithApplicationMainWindow:(UIWindow *)mainWindow
{
    self.appMainWindow = mainWindow;
    [self setupReachability];
    
    self.userRegData = [[NSMutableDictionary alloc] init];
    self.userPreferenceData = [[NSMutableDictionary alloc] init];
    
    [self resetUserData];
    [self.userRegData setObject:@"" forKey:KFirstName];
    [self.userRegData setObject:@"" forKey:KLastName];
    [self.userRegData setObject:@"" forKey:KDoctorRegID];
//    [self.userRegData setObject:@"" forKey:KPassword];
//    
//    [self.userRegData setObject:@"" forKey:kManagerMobileNumber];
//    [self.userRegData setObject:@"" forKey:kManagerName];
//    [self.userRegData setObject:@"" forKey:kManagerEmail];
//
//
//    [self.userRegData setObject:[NSMutableArray arrayWithObjects:@"",@"", nil] forKey:KMobileNumber];
//    [self.userRegData setObject:[NSMutableArray arrayWithObjects:@"",@"", nil] forKey:KEmail];
//    [self.userRegData setObject:[NSMutableArray arrayWithObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",KAddressOne, @"",KAdresstwo, @"",KZIPCode, @"",KState, @"",KCity, nil]] forKey:KRegistarionStageTwo];

    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    
    [self launchSplashView];
}

- (void)resetUserData
{
    [self.userRegData setObject:@"" forKey:KFirstName];
    [self.userRegData setObject:@"" forKey:KLastName];
    [self.userRegData setObject:@"" forKey:KDoctorRegID];
    [self.userRegData setObject:@"" forKey:KPassword];
    
    [self.userRegData setObject:@"" forKey:kManagerMobileNumber];
    [self.userRegData setObject:@"" forKey:kManagerName];
    [self.userRegData setObject:@"" forKey:kManagerEmail];
    
    
    [self.userRegData setObject:[NSMutableArray arrayWithObjects:@"",@"", nil] forKey:KMobileNumber];
    [self.userRegData setObject:[NSMutableArray arrayWithObjects:@"",@"", nil] forKey:KEmail];
    [self.userRegData setObject:[NSMutableArray arrayWithObjects: [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",KAddressOne, @"",KAdresstwo, @"",KZIPCode, @"",KState, @"",KCity,@"1",KType, nil],[NSMutableDictionary dictionaryWithObjectsAndKeys:@"",KAddressOne, @"",KAdresstwo, @"",KZIPCode, @"",KState, @"",KCity,@"2",KType, nil], nil] forKey:KRegistarionStageTwo];
}

- (void)setUserDetails:(NSDictionary*)details
{
  /*  {
        accountNonExpired = 1;
        accountNonLocked = 1;
        alias = "<null>";
        alternateEmailId = "";
        authorities =     (
        );
        credentialsNonExpired = 1;
        doctorId = 38;
        emailId = "sam@gmail.com";
        enabled = 1;
        firstName = sam;
        lastName = sree;
        locations =     (
                         {
                             address1 = add1;
                             address2 = add2;
                             city = "";
                             country = "<null>";
                             locationId = "<null>";
                             state = "";
                             type = "<null>";
                             zipcode = 123456;
                         }
                         );
        loginTime = "<null>";
        middleName = sree;
        mobileNo = "";
        password = "<null>";
        phoneNo = "<null>";
        profilePicture = "<null>";
        qualification = Doctor;
        registrationNumber = 123456;
        registrationYear = 2015;
        roleId = 1;
        roleName = Admin;
        stateMedCouncil = XP;
        status = Deleted;
        therapeuticId = 1;
        therapeuticName = Demo;
        title = "DR.";
        userSecurityId = 46;
        username = "sam@gmail.com";
    }
*/
    self.userType = [[details objectForKey:@"roleId"] integerValue];
    [self.userRegData setObject:[details objectOrNilForKey:@"firstName"] forKey:KFirstName];
    [self.userRegData setObject:[details objectOrNilForKey:@"lastName"] forKey:KLastName];
    [self.userRegData setObject:[details objectOrNilForKey:@"userId"] forKey:@"userId"];
    [self.userRegData setObject:[details objectOrNilForKey:@"status"] forKey:@"status"];
    [self.userRegData setObject:[details objectOrNilForKey:kDisplayName] forKey:kDisplayName];
    
    id locations = [details objectOrNilForKey:@"locations"];
    if ([locations isKindOfClass:[NSArray class]]) {
        id firstObject = ((NSArray*)locations).firstObject;
        if ([firstObject isKindOfClass:[NSDictionary class]]) {
            NSString *city = [firstObject objectForKey:KCity];
            [self.userRegData setObject:city forKey:KCity];
        }
    }
    
    if (self.userType == 1 || self.userType == 2)
    {
        if ([details objectOrNilForKey:@"registrationNumber"])
        {
            [self.userRegData setObject:[details objectOrNilForKey:@"registrationNumber"] forKey:KDoctorRegID];
        }
        else
        {
            [self.userRegData setObject:@"" forKey:KDoctorRegID];
        }
        
        if ([details objectOrNilForKey:@"doctorId"])
        {
            [self.userRegData setObject:[details objectOrNilForKey:@"doctorId"] forKey:@"doctorId"];
        }
        
        [self.userRegData setObject:[details objectOrNilForKey:@"therapeuticId"] forKey:@"therapeuticId"];

    }
    else if (self.userType == 3 || self.userType == 4)
    {
        if ([details objectOrNilForKey:@"companyId"])
        {
            [self.userRegData setObject:[NSString stringWithFormat:@"%ld",[[details objectOrNilForKey:@"companyId"] longValue]] forKey:KDoctorRegID];
        }
        else
        {
            [self.userRegData setObject:@"" forKey:KDoctorRegID];
        }
    }
    
    //[self.userRegData setObject:@"medrep@123" forKey:KPassword];
    NSDictionary *temp = [details objectForKey:@"profilePicture"];
    [self.userRegData setObject:[details objectOrNilForKey:KTitle] forKey:KTitle];

    if ([temp isKindOfClass:[NSDictionary class]])
    {
        
        id profileDat = [temp objectForKey:@"data"];
        
        
        if (profileDat == [NSNull null] || profileDat == nil || [profileDat isEqualToString:@"<nil>"]) {
            
        }else{
        [self.userRegData setObject:[temp objectForKey:@"data"] forKey:KProfilePicture];    
        }
        
    }

    [self.userRegData setObject:[NSMutableArray arrayWithObjects:[details objectOrNilForKey:@"mobileNo"],[details objectOrNilForKey:@"phoneNo"], nil] forKey:KMobileNumber];
    [self.userRegData setObject:[NSMutableArray arrayWithObjects:[details objectOrNilForKey:@"emailId"],[details objectOrNilForKey:@"alternateEmailId"], nil] forKey:KEmail];
    
     [MRCommon setUserPhoneNumber:[details objectOrNilForKey:@"mobileNo"]];
    
    if (self.userType == 3)
    {
        [self.userRegData setObject:([MRCommon isStringEmpty:[details objectOrNilForKey:kManagerEmail]] || [details objectOrNilForKey:kManagerEmail] == nil) ? @"" : [details objectOrNilForKey:kManagerEmail] forKey:kManagerEmail];
        [self.userRegData setObject:([MRCommon isStringEmpty:[details objectOrNilForKey:kManagerMobileNumber]] || [details objectOrNilForKey:kManagerMobileNumber] == nil) ? @"" :[details objectOrNilForKey:kManagerMobileNumber] forKey:kManagerMobileNumber];
        [self.userRegData setObject:([MRCommon isStringEmpty:[details objectOrNilForKey:kManagerName]] || [details objectOrNilForKey:kManagerName] == nil) ? @"" :[details objectOrNilForKey:kManagerName] forKey:kManagerName];
        
        [self.userRegData setObject:([MRCommon isStringEmpty:[details objectOrNilForKey:KAreasCovered]] || [details objectOrNilForKey:KAreasCovered] == nil) ? @"" :[details objectOrNilForKey:KAreasCovered] forKey:KAreasCovered];
    }

    NSArray *location = [details objectOrNilForKey:@"locations"];
    
    if (location != nil && [location isKindOfClass:[NSArray class]] && location.count > 0)
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dataDict in location)
        {
            [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[dataDict objectOrNilForKey:@"address1"],KAddressOne, [dataDict objectOrNilForKey:@"address2"],KAdresstwo, [dataDict objectOrNilForKey:@"zipcode"],KZIPCode, [dataDict objectOrNilForKey:@"state"],KState, [dataDict objectOrNilForKey:@"city"],KCity, [dataDict objectOrNilForKey:KType],KType, nil]];
        }
        
        [self.userRegData setObject:array forKey:KRegistarionStageTwo];
    }
}

- (void)setUserPreferenceDetails:(NSDictionary*)details
{
    self.userType = [[details objectForKey:@"roleId"] integerValue];
    [self.userPreferenceData setObject:[details objectOrNilForKey:@"firstName"] forKey:KFirstName];
    [self.userPreferenceData setObject:[details objectOrNilForKey:@"lastName"] forKey:KLastName];
    [self.userPreferenceData setObject:[details objectOrNilForKey:@"userId"] forKey:@"userId"];
    [self.userPreferenceData setObject:[details objectOrNilForKey:@"status"] forKey:@"status"];
    [self.userPreferenceData setObject:[details objectOrNilForKey:@"therapeuticArea"] forKey:@"therapeuticArea"];
    [self.userPreferenceData setObject:[details objectOrNilForKey:@"city"] forKey:@"city"];
}

- (void)launchSplashView
{
    [self loadMasterData];
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.viewController.delegate = self;
    [self.viewController.activityIndicator startAnimating];
    self.appMainWindow.rootViewController = self.viewController;
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://183.82.106.234:8080/surveys/open/12?list"]];
}

- (void)removeSplashViewOnAnimationEnd
{
   // [self hideSplashScreen];
    [self performSelector:@selector(hideSplashScreen) withObject:nil afterDelay:0.5f ];

}
-(void)hideSplashScreen
{
    [self.viewController.activityIndicator stopAnimating];
    [self applyFadeAnimation];
    [self loadHomeScreen];
    //[self loadPharmaDashboard];
    /*
    if (nil == [MRDefaults objectForKey:kRefreshToken])
    {
        [self loadHomeScreen];
    }
    else
    {
        [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
         {
             if (status)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getMyRole:^(BOOL status, NSString *details, NSDictionary *responce)
                 {
                     if (status)
                     {
                         self.userType = [[responce objectForKey:@"roleId"] integerValue];
                         [MRCommon setUserType:self.userType];
                         
                         if ([[responce objectForKeyedSubscript:@"status"] isEqualToString:@"Not Verified"])
                         {
                             [self loadOTPScreen];
                         }
                         else
                         {
                             [self loadDashBoardOnLogin];
//                             if (self.userType == 1)
//                             {
//                                 [[MRWebserviceHelper sharedWebServiceHelper] getDoctorProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
//                                  {
//                                      if (status)
//                                      {
//                                          [self setUserDetails:responce];
//                                          [self loadDashboardScreen];
//                                      }
//                                  }];
//                             }
//                             else if (self.userType == 3)
//                             {
//                                 [[MRWebserviceHelper sharedWebServiceHelper] getPharmaProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
//                                  {
//                                      if (status)
//                                      {
//                                          [self setUserDetails:responce];
//                                          [self loadDashboardScreen];
//                                      }
//                                  }];
//                                 
//                             }
                         }
                     }
                     else
                     {
                         [self loadHomeScreen];
                     }
                 }];
             }
             else
             {
                 [self loadHomeScreen];
             }
         }];
    }
    */
}

- (void)applyFadeAnimation
{
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0f;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [[self.appMainWindow layer] addAnimation:animation forKey:@"fadeAnimation"];
}

- (void)loadDashBoardOnLogin
{
    if (self.userType == 1 || self.userType == 2)
    {
        [[MRWebserviceHelper sharedWebServiceHelper] getDoctorProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
         {
             if (status)
             {
                 [self setUserDetails:responce];
                 [self loadDashboardScreen];
             }
             else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
             {
                 [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
                  {
                      [MRCommon savetokens:responce];
                      [[MRWebserviceHelper sharedWebServiceHelper] getDoctorProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
                       {
                           if (status)
                           {
                               [self setUserDetails:responce];
                               [self loadDashboardScreen];
                           }
                       }];
                  }];
             }
         }];
    }
    else if (self.userType == 3 || self.userType == 4)
    {
        [[MRWebserviceHelper sharedWebServiceHelper] getPharmaProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
         {
             if (status)
             {
                 [self setUserDetails:responce];
                 [self loadDashboardScreen];
             }
             else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
             {
                 [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
                  {
                      [MRCommon savetokens:responce];
                      [[MRWebserviceHelper sharedWebServiceHelper] getPharmaProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
                       {
                           if (status)
                           {
                               [self setUserDetails:responce];
                               [self loadDashboardScreen];
                           }
                       }];
                  }];
             }
         }];
    }
}

- (void)loadHomeScreen
{
    MRHomeViewContoller *homeViewController = [[MRHomeViewContoller alloc] initWithNibName:@"MRHomeViewContoller" bundle:nil];
    UINavigationController *homeNavController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    homeNavController.navigationBarHidden = YES;
    self.appMainWindow.rootViewController = homeNavController;
}

- (void)loadOTPScreen
{
    MROTPVerifiedViewController *otpViewController = [[MROTPVerifiedViewController alloc] initWithNibName:@"MROTPVerifiedViewController" bundle:nil];
    otpViewController.isFromSinUp = YES;
    UINavigationController *homeNavController = [[UINavigationController alloc] initWithRootViewController:otpViewController];
    homeNavController.navigationBarHidden = YES;
    self.appMainWindow.rootViewController = homeNavController;
}

- (NSDictionary*)getCompanyDetailsByID:(NSInteger)companyID
{
    NSArray *filteredArray          = [self.companyDetails filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"companyId == %@", [NSNumber numberWithInteger:companyID]]];
    return filteredArray.count > 0 ?  [filteredArray firstObject] : nil ;
}

- (void)loadDashboardScreenOnLogin
{
    [self loadDashboardScreen];
}

- (void)loadDashboardScreen
{
    if (self.userType == 1 || self.userType == 2)
    {
        MRDashBoardVC *dashboardViewCont = [[MRDashBoardVC alloc] initWithNibName:@"MRDashBoardVC" bundle:nil];
        
        UINavigationController *dashboardNavCont = [[UINavigationController alloc] initWithRootViewController:dashboardViewCont];
        [MRCommon applyNavigationBarStyling:dashboardNavCont];
        
        MRMenuViewController *menuSlidingViewCont = [[MRMenuViewController alloc] initWithNibName:@"MRMenuViewController" bundle:nil];
        menuSlidingViewCont.delegate = self;
        UINavigationController *menuSlidingNavCont = [[UINavigationController alloc] initWithRootViewController:menuSlidingViewCont];
        menuSlidingNavCont.navigationBar.tintColor        =  [UIColor whiteColor];

        SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:menuSlidingNavCont frontViewController:dashboardNavCont];
        revealController.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:menuSlidingViewCont selector:@selector(loadDashboard) name:kDashboardNotificationFromRegistartionScren object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:menuSlidingViewCont selector:@selector(loadAppointmentList) name:kMedRepMeetingsNotification object:nil];
        
        [self.appMainWindow setRootViewController:revealController];
    }
    else
    {
//        [MRCommon showAlert:kComingsoonMSG delegate:self];
//        return;
        [self loadPharmaDashboard];
    }
    
    //Get user preferences
    [[MRWebserviceHelper sharedWebServiceHelper] getUserPreferences:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             NSArray *resArray = responce[@"Responce"];
             if (resArray.count) {
                 [self setUserPreferenceDetails:resArray[0]];
             }
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getUserPreferences:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       if (status)
                       {
                           NSArray *resArray = responce[@"Responce"];
                           if (resArray.count) {
                               [self setUserPreferenceDetails:resArray[0]];
                           }
                       }
                   }];
              }];
         }
     }];
}

- (void)loadLoginView
{
    [self.userRegData removeAllObjects];
    [self.userPreferenceData removeAllObjects];
    [self resetUserData];
    MRLoginViewController *homeViewController = [[MRLoginViewController alloc] initWithNibName:@"MRLoginViewController" bundle:nil];
    homeViewController.isFromHome = NO;
    UINavigationController *homeNavController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    homeNavController.navigationBarHidden = YES;
    self.appMainWindow.rootViewController = homeNavController;
}

- (void)setMyTherapeuticAreaDetails:(NSArray*)therapeuticDetails
{
    self.therapeuticAreaDetails = therapeuticDetails;
}

- (void)setMyAppointmentDetails:(NSArray*)appointmentsList
{
    self.myAppointments = appointmentsList;
}

- (NSDictionary*)getNotificationByID:(NSInteger)notificationID
{
    for (NSDictionary *notifcation in self.notifications)
    {
        if ([[notifcation objectForKey:@"notificationId"] integerValue]  == notificationID)
        {
            return notifcation;
        }
    }
    return [NSDictionary dictionary];
}

- (NSArray*)getNotificationByCompanyID:(NSInteger)companyID
{
    NSArray *filteredArray          = [self.notifications filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"companyId == %d", companyID]];
    
    return filteredArray;
}

- (NSArray*)getNotificationByTherapeuticName:(NSString*)therapeuticName withCompanyID:(NSInteger)companyID
{
    NSArray *filteredArray          = [self.notifications filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"companyId == %d AND therapeuticName == %@", companyID,therapeuticName]];
    
    return filteredArray;
}


- (void)loadMasterData
{
    if ([self internetCheck] == NO) return;
    
    if ([MRDatabaseHelper  getObjectDataExistance:kTherapeuticAreaEntity] == NO)
    {
        [[MRWebserviceHelper sharedWebServiceHelper] getTherapeuticAreaDetails:^(BOOL status, NSString *details, NSDictionary *responce)
         {
             [MRDatabaseHelper addTherapeuticArea:[responce objectForKey:kResponce]];
             [[MRAppControl sharedHelper] setMyTherapeuticAreaDetails:[responce objectForKey:kResponce]];
         }];
    }
    else
    {
        [MRDatabaseHelper getTherapeuticArea:^(NSArray *fetchList) {
            [[MRAppControl sharedHelper] setMyTherapeuticAreaDetails:fetchList];
        }];

    }
    
    if ([MRDatabaseHelper  getObjectDataExistance:kNotificationTypeEntity] == NO)
    {
        [[MRWebserviceHelper sharedWebServiceHelper] getNotificationTypes:^(BOOL status, NSString *details, NSDictionary *responce)
         {
             [MRDatabaseHelper addNotificationType:[responce objectForKey:kResponce]];
             [[MRAppControl sharedHelper] setNotificationTypes:[responce objectForKey:kResponce]];
         }];
    }
    else
    {
        [MRDatabaseHelper getNotificationTypes:^(NSArray *fetchList) {
            [[MRAppControl sharedHelper] setNotificationTypes:fetchList];
        }];

    }

    if ([MRDatabaseHelper  getObjectDataExistance:kCompanyDetailsEntity] == NO)
    {
        [[MRWebserviceHelper sharedWebServiceHelper] getCompanyDetails:^(BOOL status, NSString *details, NSDictionary *responce)
         {
             [MRDatabaseHelper addCompanyDetails:[responce objectForKey:kResponce]];
             [[MRAppControl sharedHelper] setCompanyDetails:[responce objectForKey:kResponce]];
         }];
    }
    else
    {
        [MRDatabaseHelper getCompanyDetails:^(NSArray *fetchList) {
            [[MRAppControl sharedHelper] setCompanyDetails:fetchList];
        }];
    }

    if ([MRDatabaseHelper  getObjectDataExistance:kRoleEntity] == NO)
    {
        [[MRWebserviceHelper sharedWebServiceHelper] getRoles:^(BOOL status, NSString *details, NSDictionary *responce)
         {
             [MRDatabaseHelper addRole:[responce objectForKey:kResponce]];
             [[MRAppControl sharedHelper] setRoles:[responce objectForKey:kResponce]];
         }];
    }
    else
    {
        [MRDatabaseHelper getRoles:^(NSArray *roles) {
            [[MRAppControl sharedHelper] setRoles:roles];
        }];
    }
}

#pragma mark ---
#pragma mark Pharma method
#pragma mark ---

- (void)loadPharmaDashboard
{
    MRPHDashBoardViewController *dashboardViewCont = [[MRPHDashBoardViewController alloc] initWithNibName:[MRCommon nibNameForDevice:@"MRPHDashBoardViewController"] bundle:nil];
    
    UINavigationController *dashboardNavCont = [[UINavigationController alloc] initWithRootViewController:dashboardViewCont];
    
    dashboardNavCont.navigationBar.tintColor        = [UIColor whiteColor];
    UIImage *image = [UIImage imageNamed:@"nabar@2x.png"];
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]) //iOS >=5.0
    {
        [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
        [[UIBarButtonItem appearanceWhenContainedIn: [UINavigationBar class], nil] setTintColor:[UIColor blackColor]];
        
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor whiteColor],
          NSForegroundColorAttributeName,nil]];
    }
    
    MRPharmaMenuViewController *menuSlidingViewCont = [[MRPharmaMenuViewController alloc] initWithNibName:@"MRPharmaMenuViewController" bundle:nil];
    menuSlidingViewCont.delegate = self;
    UINavigationController *menuSlidingNavCont = [[UINavigationController alloc] initWithRootViewController:menuSlidingViewCont];
    menuSlidingNavCont.navigationBar.tintColor        =  [UIColor whiteColor];
    SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:menuSlidingNavCont frontViewController:dashboardNavCont];
    revealController.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:menuSlidingViewCont selector:@selector(showPharmaDashboard) name:kDashboardNotificationFromRegistartionScren object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:menuSlidingViewCont selector:@selector(loadAppointmentList) name:kMedRepMeetingsNotification object:nil];

    
    
    [self.appMainWindow setRootViewController:revealController];
}

#pragma mark ---
#pragma mark Rechability method
#pragma mark ---



- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    if(curReach == internetReach)
    {
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        switch (netStatus)
        {
            case NotReachable:
            {
                isInternetAvailable = FALSE;
                break;
            }
            case ReachableViaWWAN:
            {
                isInternetAvailable = TRUE;
                break;
            }
            case ReachableViaWiFi:
            {
                isInternetAvailable = TRUE;
                break;
            }
        }
    }
}

- (BOOL)internetCheck {
    return isInternetAvailable;
}

- (void) setupReachability
{
    //Internet Check using reachability
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    [self updateInterfaceWithReachability: internetReach];
}

- (UIImage*)getCompanyImage
{
    NSString *company = [self.userRegData objectForKey:KDoctorRegID];
    NSDictionary *comapnyDetails = [self getCompanyDetailsByID:[company intValue]];
    return  [MRCommon getImageFromBase64Data:[[comapnyDetails objectForKey:@"displayPicture"] objectForKey:@"data"]];
}

-(void)registerDeviceToken{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          APP_DELEGATE.token, @"regDeviceToken",
                          @"IOS", @"platform",
                          nil];
    
    [[MRWebserviceHelper sharedWebServiceHelper] registerDeviceToken:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
    }];
}

+ (NSString*)getContactName:(MRContact*)contact {
    NSMutableString *name = [NSMutableString stringWithString:@""];
    if (contact != nil) {
        if (contact.firstName != nil && contact.firstName.length > 0) {
            name = [NSMutableString stringWithString:contact.firstName];
        }
        
        if (contact.lastName != nil && contact.lastName.length > 0) {
            if (name.length > 0) {
                [name appendString:@" "];
            }
            
            [name appendString:contact.lastName];
        }
    }
    return name;
}

+ (NSString*)getGroupMemberName:(MRGroupMembers*)members {
    NSMutableString *name = [NSMutableString stringWithString:@""];
    if (members != nil) {
        if (members.firstName != nil && members.firstName.length > 0) {
            name = [NSMutableString stringWithString:members.firstName];
        }
        
        if (members.lastName != nil && members.lastName.length > 0) {
            if (name.length > 0) {
                [name appendString:@" "];
            }
            
            [name appendString:members.lastName];
        }
    }
    return name;
}

+ (UIImage*)getContactImage:(MRContact*)contact {
    UIImage *image = [UIImage imageNamed:@"person"];;
    
    if (contact != nil) {
        if (contact.profilePic != nil) {
            image = [UIImage imageWithData:contact.profilePic];
        }
    }
    
    return image;
}

+ (void)getContactImage:(MRContact*)contact andImageView:(UIImageView*)parentView {
    if (contact.profilePic != nil) {
        parentView.image = [UIImage imageWithData:contact.profilePic];
    } else {
        NSString *fullName = [MRAppControl getContactName:contact];
        if (fullName != nil && fullName.length > 0) {
            parentView.image = nil;
            UILabel *subscriptionTitleLabel = [[UILabel alloc] initWithFrame:parentView.bounds];
            subscriptionTitleLabel.textAlignment = NSTextAlignmentCenter;
            subscriptionTitleLabel.font = [UIFont systemFontOfSize:15.0];
            subscriptionTitleLabel.textColor = [UIColor lightGrayColor];
            subscriptionTitleLabel.layer.cornerRadius = 5.0;
            subscriptionTitleLabel.layer.masksToBounds = YES;
            subscriptionTitleLabel.layer.borderWidth =1.0;
            subscriptionTitleLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
            
            NSArray *substrngs = [fullName componentsSeparatedByString:@" "];
            NSString *imageString = @"";
            for(NSString *str in substrngs){
                if (str.length > 0) {
                    imageString = [imageString stringByAppendingString:[NSString stringWithFormat:@"%c",[str characterAtIndex:0]]];
                }
            }
            subscriptionTitleLabel.text = imageString.length > 2 ? [imageString substringToIndex:2] : imageString;
            [parentView addSubview:subscriptionTitleLabel];
        } else {
            parentView.image = [UIImage imageNamed:@"person"];
        }
    }
}

+ (void)getGroupMemberImage:(MRGroupMembers*)member andImageView:(UIImageView*)parentView {
    if (member.data != nil) {
        parentView.image = [UIImage imageWithData:member.data];
    } else {
        NSString *fullName = [MRAppControl getGroupMemberName:member];
        if (fullName != nil && fullName.length > 0) {
            parentView.image = nil;
            UILabel *subscriptionTitleLabel = [[UILabel alloc] initWithFrame:parentView.bounds];
            subscriptionTitleLabel.textAlignment = NSTextAlignmentCenter;
            subscriptionTitleLabel.font = [UIFont systemFontOfSize:15.0];
            subscriptionTitleLabel.textColor = [UIColor lightGrayColor];
            subscriptionTitleLabel.layer.cornerRadius = 5.0;
            subscriptionTitleLabel.layer.masksToBounds = YES;
            subscriptionTitleLabel.layer.borderWidth =1.0;
            subscriptionTitleLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
            
            NSArray *substrngs = [fullName componentsSeparatedByString:@" "];
            NSString *imageString = @"";
            for(NSString *str in substrngs){
                if (str.length > 0) {
                    imageString = [imageString stringByAppendingString:[NSString stringWithFormat:@"%c",[str characterAtIndex:0]]];
                }
            }
            subscriptionTitleLabel.text = imageString.length > 2 ? [imageString substringToIndex:2] : imageString;
            [parentView addSubview:subscriptionTitleLabel];
        } else {
            parentView.image = [UIImage imageNamed:@"person"];
        }
    }
}

+ (UIImage*)getRepliedByProfileImage:(MRPostedReplies*)replies {
    UIImage *image = [UIImage imageNamed:@"person"];;
    
    if (replies != nil) {
        if (replies.postedByProfilePic != nil) {
            image = [UIImage imageWithData:replies.postedByProfilePic];
        }
    }
    
    return image;
}

+ (UIImage*)getGroupImage:(MRGroup*)group {
    UIImage *image = [UIImage imageNamed:@"Group"];;
    
    if (group != nil) {
        if (group.group_img_data != nil) {
            image = [UIImage imageWithData:group.group_img_data];
        }
    }
    
    return image;
}

+ (void)getGroupImage:(MRGroup*)group andImageView:(UIImageView*)parentView {
    if (group.group_img_data != nil) {
        parentView.image = [UIImage imageWithData:group.group_img_data];
    } else if (group.group_name != nil && group.group_name.length > 0) {
        UILabel *subscriptionTitleLabel = [[UILabel alloc] initWithFrame:parentView.bounds];
        subscriptionTitleLabel.textAlignment = NSTextAlignmentCenter;
        subscriptionTitleLabel.font = [UIFont systemFontOfSize:15.0];
        subscriptionTitleLabel.textColor = [UIColor lightGrayColor];
        subscriptionTitleLabel.layer.cornerRadius = 5.0;
        subscriptionTitleLabel.layer.masksToBounds = YES;
        subscriptionTitleLabel.layer.borderWidth =1.0;
        subscriptionTitleLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        NSArray *substrngs = [group.group_name componentsSeparatedByString:@" "];
        NSString *imageString = @"";
        for(NSString *str in substrngs){
            if (str.length > 0) {
                imageString = [imageString stringByAppendingString:[NSString stringWithFormat:@"%c",[str characterAtIndex:0]]];
            }
        }
        subscriptionTitleLabel.text = imageString.length > 2 ? [imageString substringToIndex:2] : imageString;
        [parentView addSubview:subscriptionTitleLabel];
    } else {
        parentView.image = [UIImage imageNamed:@"Group"];
    }
}

@end

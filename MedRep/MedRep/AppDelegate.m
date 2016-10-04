//
//  AppDelegate.m
//  MedRep
//
//  Created by MedRep Developer on 09/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "AppDelegate.h"
#import "MRAppControl.h"
#import "MRWebserviceHelper.h"
#import "MRCommon.h"
#import "MRLocationManager.h"
#import "NotificationUUIDViewController.h"

#import "SWRevealViewController.h"
#import "MRTransformDetailViewController.h"
@import GooglePlaces;
@import GoogleMaps;

@interface AppDelegate ()

@property (nonatomic)  NotificationUUIDViewController *notificationViewController;

@property (nonatomic) NSInteger counterChildPost;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[MRLocationManager sharedManager] getCurrentLocation:^(CLLocation *location)
     {
         
     }];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    [GMSServices provideAPIKey:@"AIzaSyBTgV7M14YRcPONkBYkcY8FLmXhA0ELJJA"];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window.backgroundColor = [MRCommon colorFromHexString:kStatusBarColor];
    [self.window makeKeyAndVisible];
    [GMSPlacesClient provideAPIKey:@"AIzaSyBTgV7M14YRcPONkBYkcY8FLmXhA0ELJJA"];
    _counterChildPost = 1000;
    //_launchScreen = @"Survey";
    //_launchScreen = @"Notifications";
    
    MRAppControl *appController = [MRAppControl sharedHelper];
    [appController launchWithApplicationMainWindow:self.window];
    
    return YES;
}
-(NSInteger)counterForChildPost{
    
    return _counterChildPost ++;

}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if ([self.window.rootViewController isKindOfClass:[SWRevealViewController class]] && [((UINavigationController*)((SWRevealViewController*)self.window.rootViewController).frontViewController).topViewController isKindOfClass:[MRTransformDetailViewController class]] && _enabledVideoRotation)
    {
        return UIInterfaceOrientationMaskAll;
    }
    else return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [application setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"Vamsi MedRep Local:%@",notification);
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
    [MRCommon showAlert:notification.alertBody delegate:self];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Did Register for Remote Notifications with Device Token (%@)", deviceToken);
    
    NSString * deviceTokenString = [[[[deviceToken description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                    stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"The generated device token string is : %@",deviceTokenString);
    _token = deviceTokenString;
    
    NSDictionary *userdata = [MRAppControl sharedHelper].userRegData;
    NSDictionary *dataDict = @{@"regDeviceToken" : deviceTokenString,
                               @"platform" : @"IOS"/*,
                               @"docId" : [userdata objectOrNilForKey:@"doctorId"]*/};
    
    [[MRWebserviceHelper sharedWebServiceHelper] registerDeviceTokenWithPushAPI:dataDict
                                                                    withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                                                                        if (status == NO) {
                                                                            [MRCommon showAlert:@"Failed to register for Push Notifications !!!" delegate:nil];
                                                                        }
                                                                    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
    
    self.notificationViewController.token = @"Did Fail to Register for Remote Notifications";
    [self.notificationViewController refreshScreen];
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    /*
    NSLog(@"Vamsi MedRep userInfo:%@",userInfo);
    
    NSInteger badge_value = [UIApplication sharedApplication].applicationIconBadgeNumber;
    NSLog(@"Vamsi MedRep : Current badge = %d", badge_value);
    
    badge_value+= [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"]intValue];
    NSLog(@"Vamsi MedRep : Totoal badge Value:%d",badge_value);
    
    for (id key in userInfo) {
        NSLog(@"Vamsi MedRep key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = badge_value;
    */
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                        object:nil];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.rajesh.MedRep" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MedRep" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MedRep.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Push Notification handling
-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    NSLog(@"received message, host : %@, path : %@", [url host], [url path]);
    return true;
}

@end

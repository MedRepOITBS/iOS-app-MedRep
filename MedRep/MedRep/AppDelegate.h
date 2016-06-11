//
//  AppDelegate.h
//  MedRep
//
//  Created by MedRep Developer on 09/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//
// http://www.techotopia.com/index.php/Implementing_iOS_6_Auto_Layout_Constraints_in_Code

//http://www.ioscreator.com/tutorials/auto-layout-in-ios-6-adding-constraints-through-code

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end


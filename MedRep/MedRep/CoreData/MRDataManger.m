//
//  MRDataManger.m
//  MedRep
//
//  Created by MedRep Developer on 10/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRDataManger.h"

#define CURRENT_SQLITE_NAME @"MedRep.sqlite"

@interface MRDataManger (Private)

- (NSString *)applicationDocumentsDirectory;

@end

@implementation MRDataManger



static MRDataManger *sharedDataManager = nil;

+ (MRDataManger *)sharedManager
{
    static dispatch_once_t once;
    static MRDataManger * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (nil == sharedDataManager)
        {
            sharedDataManager = [super allocWithZone:zone];
            return sharedDataManager;
        }
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    
    if (managedObjectContext_ != nil)
    {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        //managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        managedObjectContext_ = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        NSUndoManager *undoManager = [[NSUndoManager alloc] init];
        [managedObjectContext_ setUndoManager:undoManager];
        
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel_ != nil)
    {
        return managedObjectModel_;
    }
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"MedRep" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return managedObjectModel_;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator_ != nil)
    {
        return persistentStoreCoordinator_;
    }
    
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: CURRENT_SQLITE_NAME];
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    //////// Code for automatic coredata migration
    
    NSDictionary *automaticMigrationOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                               [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:automaticMigrationOptions error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // Make sure the database is encrypted when the device is locked
    NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
    if (![[NSFileManager defaultManager] setAttributes:fileAttributes ofItemAtPath:[storeURL path] error:&error])
    {
        NSLog(@"NSFileProtectionComplete error %@, %@", error, [error userInfo]);
    }
    
    BOOL success = [storeURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    if(!success)
    {
        NSLog(@"Error excluding %@ from backup", [storeURL lastPathComponent]);
    }
    
    return persistentStoreCoordinator_;
}

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

#pragma mark -
#pragma mark Application's Documents directory

- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - Public

- (void)dbSave
{
    [self dbSaveInContext:self.managedObjectContext];
}

- (void)dbSaveOnPrivateContext
{
    [self dbSaveInContext:[self getNewPrivateManagedObjectContext]];
}


- (NSManagedObject *)createObjectForEntity:(NSString *)entity
{
    return [self createObjectForEntity:entity inContext:self.managedObjectContext];
}

- (NSManagedObject *)createObjectForEntityOnPrivateContext:(NSString *)entity
{
    return [self createObjectForEntity:entity inContext:[self getNewPrivateManagedObjectContext]];
}

- (NSArray *)fetchObjectList:(NSString *)entity
{
    return [self fetchObjectList:entity inContext:self.managedObjectContext];
}

- (NSArray *)fetchObjectList:(NSString *)entity attributeName:(NSString *)attributeName attributeValue:(id)attributeValue
{
    return [self fetchObjectList:entity attributeName:attributeName attributeValue:attributeValue inContext:self.managedObjectContext];
}

- (NSArray *)fetchObjectList:(NSString *)entity predicate:(NSPredicate *)predicate
{
    return [self fetchObjectList:entity predicate:predicate inContext:self.managedObjectContext];
}

- (id)fetchObject:(NSString *)entity attributeName:(NSString *)attributeName attributeValue:(id)attributeValue
{
    NSArray *list = [self fetchObjectList:entity attributeName:attributeName attributeValue:attributeValue];
    return (0 == list.count) ? nil : [list objectAtIndex:0];
}

- (id)fetchObject:(NSString *)entity predicate:(NSPredicate *)predicate
{
    NSArray *list = [self fetchObjectList:entity predicate:predicate];
    return (0 == list.count) ? nil : [list objectAtIndex:0];
}

- (id)fetchObject:(NSString *)entity
{
    NSArray *result = [self fetchObjectList:entity];
    return (0 == result.count) ? nil : [result objectAtIndex:0];
}

- (NSArray *)fetchObjectList:(NSString *)entity attributeName:(NSString *)attributName sortOrder:(SORT_ORDER)sortOrder
{
    return  [self fetchObjectList:entity attributeName:attributName sortOrder:sortOrder inContext:self.managedObjectContext];
}


- (NSArray *)fetchObjectList:(NSString *)entity attributeName:(NSString *)attributName predicate:(NSPredicate *)aPredicate sortOrder:(SORT_ORDER)sortOrder
{
    return [self fetchObjectList:entity attributeName:attributName predicate:aPredicate sortOrder:sortOrder inContext:self.managedObjectContext];
}


- (void)removeObject:(NSManagedObject *)managedObject
{
    [self removeObject:managedObject inContext:self.managedObjectContext];
}

- (void)removeAllObjects:(NSString *)entity
{
    [self removeAllObjects:entity inContext:self.managedObjectContext];
}

- (NSInteger)countOfObjects:(NSString *)entity
{
    //   return [self countOfObjects:entity predicate:nil];
    return [self countOfObjects:entity predicate:nil inContext:self.managedObjectContext];
    
}

- (NSInteger)countOfObjects:(NSString *)entity attributeName:(NSString *)attributeName attributeValue:(id)attributeValue
{
    return [self countOfObjects:entity attributeName:attributeName attributeValue:attributeValue inContext:self.managedObjectContext];
}

- (NSInteger)countOfObjects:(NSString *)entity predicate:(NSPredicate *)predicate
{
    return [self countOfObjects:entity predicate:predicate inContext:self.managedObjectContext];
}

- (void)beginUndoGrouping
{
    [self beginUndoGroupingInContext:self.managedObjectContext];
}

- (void)endUndoGrouping
{
    [self endUndoGroupingInContext:self.managedObjectContext];
}

- (void)undoNestedGroup
{
    [self undoNestedGroupInContext:self.managedObjectContext];
}

#pragma mark -
#pragma mark core data with blocks methods

- (void)dbSaveInContext:(NSManagedObjectContext *)context{
    
    [self assertConditionForContext:context];
    
    [context performBlockAndWait:^{
        NSError *error = nil;
        [context save:&error];
        
        // Save the changes on the main context
        [context.parentContext performBlock:^{
            NSError *parentError = nil;
            [context.parentContext save:&parentError];
        }];
    }];
}

- (NSManagedObject *)createObjectForEntity:(NSString *)entity inContext:(NSManagedObjectContext *)context{
    
    [self assertConditionForContext:context];
    return [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
}

- (NSArray *)fetchObjectList:(NSString *)entity inContext:(NSManagedObjectContext *)context{
    
    [self assertConditionForContext:context];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    __block NSArray *result = nil;
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        if (nil != error)
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }];
    
    return (0 == result.count) ? nil : result;
}


- (NSArray *)fetchObjectList:(NSString *)entity attributeName:(NSString *)attributeName attributeValue:(id)attributeValue inContext:(NSManagedObjectContext *)context{
    
    [self assertConditionForContext:context];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", attributeName, attributeValue];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    
    __block NSArray *result = nil;
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        if (nil != error)
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }];
    
    return result;
}


- (NSArray *)fetchObjectList:(NSString *)entity predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    [self assertConditionForContext:context];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setIncludesSubentities:NO];
    
    if (nil != predicate)
    {
        [fetchRequest setPredicate:predicate];
    }
    
    __block NSArray *result = nil;
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        if (nil != error)
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }];
    
    return result;
}

- (id)fetchObject:(NSString *)entity attributeName:(NSString *)attributeName attributeValue:(id)attributeValue inContext:(NSManagedObjectContext *)context{
    
    NSArray *list = [self fetchObjectList:entity attributeName:attributeName attributeValue:attributeValue inContext:context];
    return (0 == list.count) ? nil : [list objectAtIndex:0];
}

- (id)fetchObject:(NSString *)entity inContext:(NSManagedObjectContext *)context{
    
    NSArray *result = [self fetchObjectList:entity inContext:context];
    return (0 == result.count) ? nil : [result objectAtIndex:0];
}

- (id)fetchObject:(NSString *)entity predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context{
    
    NSArray *list = [self fetchObjectList:entity predicate:predicate inContext:context];
    return (0 == list.count) ? nil : [list objectAtIndex:0];
}

- (NSArray *)fetchObjectList:(NSString *)entity attributeName:(NSString *)attributName sortOrder:(SORT_ORDER)sortOrder inContext:(NSManagedObjectContext *)context{
    
    [self assertConditionForContext:context];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    if (nil != attributName)
    {
        NSSortDescriptor *sortDescriptor = nil;
        
        switch(sortOrder)
        {
            case SORT_ORDER_NONE:
                break;
                
            case SORT_ORDER_ASCENDING:
                sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:attributName ascending:YES];
                break;
                
            case SORT_ORDER_DESCENDING:
                sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:attributName ascending:NO];
                break;
        }
        
        if (nil != sortDescriptor)
        {
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        }
    }
    
    __block NSArray *result = nil;
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        if (nil != error)
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }];
    
    return result;
}

- (NSArray *)fetchObjectList:(NSString *)entity attributeName:(NSString *)attributName predicate:(NSPredicate *)aPredicate sortOrder:(SORT_ORDER)sortOrder inContext:(NSManagedObjectContext *)context{
    
    [self assertConditionForContext:context];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:aPredicate];
    if (nil != attributName)
    {
        NSSortDescriptor *sortDescriptor = nil;
        
        switch(sortOrder)
        {
            case SORT_ORDER_NONE:
                break;
                
            case SORT_ORDER_ASCENDING:
                sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:attributName ascending:YES];
                break;
                
            case SORT_ORDER_DESCENDING:
                sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:attributName ascending:NO];
                break;
        }
        
        if (nil != sortDescriptor)
        {
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        }
    }
    
    __block NSArray *result = nil;
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        if (nil != error)
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }];
    
    return result;
}

- (void)removeObject:(NSManagedObject *)managedObject inContext:(NSManagedObjectContext *)context{
    
    [self assertConditionForContext:context];
    
    [context performBlockAndWait:^{
        
        [context deleteObject:managedObject];
    }];
}

- (void)removeAllObjects:(NSString *)entity inContext:(NSManagedObjectContext *)context{
    
    [self assertConditionForContext:context];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setIncludesPropertyValues:NO];
    
    __block NSArray *result = nil;
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        if (nil != error)
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }];
    
    
    for(NSManagedObject *anObject in result)
    {
        [self removeObject:anObject inContext:context];
    }
    
    [self dbSaveInContext:context];
}

- (NSInteger)countOfObjects:(NSString *)entity inContext:(NSManagedObjectContext *)context{
    
    return [self countOfObjects:entity predicate:nil inContext:context];
}

- (NSInteger)countOfObjects:(NSString *)entity attributeName:(NSString *)attributeName attributeValue:(id)attributeValue inContext:(NSManagedObjectContext *)context{
    
    NSPredicate *predicate = nil;
    if (YES == [attributeValue isKindOfClass:[NSNumber class]])
    {
        if (0 == strcmp([attributeValue objCType], @encode(int)))
        {
            predicate = [NSPredicate predicateWithFormat:@"%K == %d", attributeName, [attributeValue intValue]];
        }
        else if (0 == strcmp([attributeValue objCType], @encode(long)))
        {
            predicate = [NSPredicate predicateWithFormat:@"%K == %ld", attributeName, [attributeValue longValue]];
        }
        else if (0 == strcmp([attributeValue objCType], @encode(float)))
        {
            predicate = [NSPredicate predicateWithFormat:@"%K == %f", attributeName, [attributeValue floatValue]];
        }
        else if (0 == strcmp([attributeValue objCType], @encode(double)))
        {
            predicate = [NSPredicate predicateWithFormat:@"%K == %lf", attributeName, [attributeValue doubleValue]];
        }
    }
    else if(YES == [attributeValue isKindOfClass:[NSString class]])
    {
        predicate = [NSPredicate predicateWithFormat:@"%K == %@", attributeName, attributeValue];
    }
    
    return [self countOfObjects:entity predicate:predicate inContext:context];
}


- (NSInteger)countOfObjects:(NSString *)entity predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context{
    
    [self assertConditionForContext:context];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setIncludesSubentities:NO];
    
    if (nil != predicate)
    {
        [fetchRequest setPredicate:predicate];
    }
    
    __block NSInteger count = 0;
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        count = [context countForFetchRequest:fetchRequest error:&error];
        
        if (nil != error)
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }];
    
    return count;
}

- (void)beginUndoGroupingInContext:(NSManagedObjectContext *)context{
    
    [context performBlockAndWait:^{
        
        [context processPendingChanges];
        [context.undoManager beginUndoGrouping];
        
        [context.parentContext performBlockAndWait:^{
            
            [context.parentContext processPendingChanges];
            [context.parentContext.undoManager beginUndoGrouping];
        }];
    }];
}

- (void)endUndoGroupingInContext:(NSManagedObjectContext *)context{
    
    [context performBlockAndWait:^{
        
        [context processPendingChanges];
        [context.undoManager endUndoGrouping];
        
        [context.parentContext performBlockAndWait:^{
            
            [context.parentContext processPendingChanges];
            [context.parentContext.undoManager endUndoGrouping];
        }];
    }];
}

- (void)undoNestedGroupInContext:(NSManagedObjectContext *)context{
    
    [context performBlockAndWait:^{
        
        [context.undoManager endUndoGrouping];
        if([context.undoManager canUndo])
        {
            NSLog(@"Undo DB");
            [context.undoManager undoNestedGroup];
        }
        
        [context.parentContext performBlockAndWait:^{
            
            [context.parentContext.undoManager endUndoGrouping];
            if([context.parentContext.undoManager canUndo])
            {
                NSLog(@"Undo DB parentContext");
                [context.parentContext.undoManager undoNestedGroup];
            }
        }];
    }];
}

- (NSManagedObjectContext*)getNewPrivateManagedObjectContext{
    
    NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [privateContext performBlockAndWait:^{
        
        [privateContext setParentContext:self.managedObjectContext];
        [privateContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }];
    
    return privateContext;
}

- (void)assertConditionForContext:(NSManagedObjectContext*)context{
    
    MSAssert(NO == (NO == [NSThread isMainThread] && [context isEqual:self.managedObjectContext]));
}


@end

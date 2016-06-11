//
//  MRDataManger.h
//  MedRep
//
//  Created by MedRep Developer on 10/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MRConstants.h"


@interface MRDataManger : NSObject
{
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;

}

+ (MRDataManger *)sharedManager;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)dbSave;
- (void)dbSaveOnPrivateContext;
- (NSManagedObject *)createObjectForEntity:(NSString *)entity;
- (NSManagedObject *)createObjectForEntityOnPrivateContext:(NSString *)entity;
- (NSArray *)fetchObjectList:(NSString *)entity;
- (NSArray *)fetchObjectList:(NSString *)entity attributeName:(NSString *)attributeName attributeValue:(id)attributeValue;
- (NSArray *)fetchObjectList:(NSString *)entity predicate:(NSPredicate *)predicate;
- (id)fetchObject:(NSString *)entity attributeName:(NSString *)attributeName attributeValue:(id)attributeValue;
- (id)fetchObject:(NSString *)entity;
- (id)fetchObject:(NSString *)entity predicate:(NSPredicate *)predicate;
- (NSArray *)fetchObjectList:(NSString *)entity attributeName:(NSString *)attributName sortOrder:(SORT_ORDER)sortOrder;
- (NSArray *)fetchObjectList:(NSString *)entity attributeName:(NSString *)attributName predicate:(NSPredicate *)aPredicate sortOrder:(SORT_ORDER)sortOrder;
- (void)removeObject:(NSManagedObject *)managedObject;
- (void)removeAllObjects:(NSString *)entity;
- (NSInteger)countOfObjects:(NSString *)entity;
- (NSInteger)countOfObjects:(NSString *)entity attributeName:(NSString *)attributeName attributeValue:(id)attributeValue;
- (NSInteger)countOfObjects:(NSString *)entity predicate:(NSPredicate *)predicate;
- (void)beginUndoGrouping;
- (void)endUndoGrouping;
- (void)undoNestedGroup;

- (id)fetchObject:(NSString *)entity inContext:(NSManagedObjectContext *)context;
- (void)dbSaveInContext:(NSManagedObjectContext *)context;
- (NSManagedObject *)createObjectForEntity:(NSString *)entity inContext:(NSManagedObjectContext *)context;
- (NSArray *)fetchObjectList:(NSString *)entity inContext:(NSManagedObjectContext *)context;
- (NSArray *)fetchObjectList:(NSString *)entity attributeName:(NSString *)attributeName attributeValue:(id)attributeValue inContext:(NSManagedObjectContext *)context;
- (NSArray *)fetchObjectList:(NSString *)entity predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
- (id)fetchObject:(NSString *)entity attributeName:(NSString *)attributeName attributeValue:(id)attributeValue inContext:(NSManagedObjectContext *)context;
- (id)fetchObject:(NSString *)entity predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
- (NSArray *)fetchObjectList:(NSString *)entity attributeName:(NSString *)attributName sortOrder:(SORT_ORDER)sortOrder inContext:(NSManagedObjectContext *)context;
- (NSArray *)fetchObjectList:(NSString *)entity attributeName:(NSString *)attributName predicate:(NSPredicate *)aPredicate sortOrder:(SORT_ORDER)sortOrder inContext:(NSManagedObjectContext *)context;
- (void)removeObject:(NSManagedObject *)managedObject inContext:(NSManagedObjectContext *)context;
- (void)removeAllObjects:(NSString *)entity inContext:(NSManagedObjectContext *)context;
- (NSInteger)countOfObjects:(NSString *)entity inContext:(NSManagedObjectContext *)context;
- (NSInteger)countOfObjects:(NSString *)entity attributeName:(NSString *)attributeName attributeValue:(id)attributeValue inContext:(NSManagedObjectContext *)context;
- (NSInteger)countOfObjects:(NSString *)entity predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
- (void)beginUndoGroupingInContext:(NSManagedObjectContext *)context;
- (void)endUndoGroupingInContext:(NSManagedObjectContext *)context;
- (void)undoNestedGroupInContext:(NSManagedObjectContext *)context;

// Returns new private managed object context for threading purposes
- (NSManagedObjectContext*)getNewPrivateManagedObjectContext;
- (void)saveContext;

@end

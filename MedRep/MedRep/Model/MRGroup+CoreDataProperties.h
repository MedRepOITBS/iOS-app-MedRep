//
//  MRGroup+CoreDataProperties.h
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/21/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRGroup (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nonatomic) int64_t groupId;
@property (nullable, nonatomic, retain) NSString *groupPicture;
@property (nullable, nonatomic, retain) NSSet<MRContact *> *contacts;
@property (nullable, nonatomic, retain) NSSet<MRGroupPost *> *groupPosts;

@end

@interface MRGroup (CoreDataGeneratedAccessors)

- (void)addContactsObject:(MRContact *)value;
- (void)removeContactsObject:(MRContact *)value;
- (void)addContacts:(NSSet<MRContact *> *)values;
- (void)removeContacts:(NSSet<MRContact *> *)values;

- (void)addGroupPostsObject:(MRGroupPost *)value;
- (void)removeGroupPostsObject:(MRGroupPost *)value;
- (void)addGroupPosts:(NSSet<MRGroupPost *> *)values;
- (void)removeGroupPosts:(NSSet<MRGroupPost *> *)values;

@end

NS_ASSUME_NONNULL_END

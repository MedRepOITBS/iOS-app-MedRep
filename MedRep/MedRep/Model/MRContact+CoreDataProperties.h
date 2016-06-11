//
//  MRContact+CoreDataProperties.h
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/21/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRContact.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRContact (CoreDataProperties)

@property (nonatomic) int64_t contactId;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *role;
@property (nullable, nonatomic, retain) NSString *profilePic;
@property (nullable, nonatomic, retain) NSSet<MRGroup *> *groups;
@property (nullable, nonatomic, retain) NSSet<MRGroupPost *> *groupPosts;

@end

@interface MRContact (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(MRGroup *)value;
- (void)removeGroupsObject:(MRGroup *)value;
- (void)addGroups:(NSSet<MRGroup *> *)values;
- (void)removeGroups:(NSSet<MRGroup *> *)values;

- (void)addGroupPostsObject:(MRGroupPost *)value;
- (void)removeGroupPostsObject:(MRGroupPost *)value;
- (void)addGroupPosts:(NSSet<MRGroupPost *> *)values;
- (void)removeGroupPosts:(NSSet<MRGroupPost *> *)values;

@end

NS_ASSUME_NONNULL_END

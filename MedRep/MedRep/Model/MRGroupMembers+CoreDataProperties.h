//
//  MRGroupMembers+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/12/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRGroupMembers.h"
#import "MRGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRGroupMembers (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *group_id;
@property (nullable, nonatomic, retain) NSNumber *member_id;
@property (nullable, nonatomic, retain) NSString *status;
@property (nullable, nonatomic, retain) NSNumber *is_admin;
@property (nullable, nonatomic, retain) NSData *doctor;
@property (nullable, nonatomic, retain) NSData *memberList;
@property (nullable, nonatomic, retain) NSData *groupList;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSString *alias;
@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, retain) NSString *mimeType;
@property (nullable, nonatomic, retain) NSString *therapeuticName;
@property (nullable, nonatomic, retain) NSString *therapeuticDesc;
@property (nullable, nonatomic, retain) NSNumber *roleId;
@property (nullable, nonatomic, retain) NSString *roleName;
@property (nullable, nonatomic, retain) NSString *stateMedCouncil;
@property (nullable, nonatomic, retain) NSSet<MRGroup *> *groups;

@property (nonatomic) NSArray *allGroups;

@end

@interface MRGroupMembers (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(MRGroup *)value;
- (void)removeGroupsObject:(MRGroup *)value;
- (void)addGroups:(NSSet<MRGroup *> *)values;
- (void)removeGroups:(NSSet<MRGroup *> *)values;

@end

NS_ASSUME_NONNULL_END

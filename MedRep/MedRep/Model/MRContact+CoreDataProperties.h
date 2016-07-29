//
//  MRContact+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/9/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRContact.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRContact (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSNumber *contactId;
@property (nullable, nonatomic, retain) NSString *doctorDetails;
@property (nullable, nonatomic, retain) NSNumber *doctorId;
@property (nullable, nonatomic, retain) NSString *dPicture;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSData *profilePic;
@property (nullable, nonatomic, retain) NSString *roleId;
@property (nullable, nonatomic, retain) NSString *status;
@property (nullable, nonatomic, retain) NSString *therapeuticArea;
@property (nullable, nonatomic, retain) NSString *therapeuticName;
@property (nullable, nonatomic, retain) NSNumber *userId;
@property (nullable, nonatomic, retain) NSSet<MRGroupPost *> *groupPosts;
@property (nullable, nonatomic, retain) NSSet<MRGroup *> *groups;
@property (nullable, nonatomic, retain) NSSet<MRPostedReplies *> *comments;

@end

@interface MRContact (CoreDataGeneratedAccessors)

- (void)addGroupPostsObject:(MRGroupPost *)value;
- (void)removeGroupPostsObject:(MRGroupPost *)value;
- (void)addGroupPosts:(NSSet<MRGroupPost *> *)values;
- (void)removeGroupPosts:(NSSet<MRGroupPost *> *)values;

- (void)addGroupsObject:(MRGroup *)value;
- (void)removeGroupsObject:(MRGroup *)value;
- (void)addGroups:(NSSet<MRGroup *> *)values;
- (void)removeGroups:(NSSet<MRGroup *> *)values;

- (void)addCommentsObject:(MRPostedReplies *)value;
- (void)removeCommentsObject:(MRPostedReplies *)value;
- (void)addComments:(NSSet<MRPostedReplies *> *)values;
- (void)removeComments:(NSSet<MRPostedReplies *> *)values;

@end

NS_ASSUME_NONNULL_END

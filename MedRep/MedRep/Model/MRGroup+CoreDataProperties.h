//
//  MRGroup+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/12/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRGroup.h"
#import "MRGroupMembers.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRGroup (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *admin_id;
@property (nullable, nonatomic, retain) NSNumber *group_id;
@property (nullable, nonatomic, retain) NSData *group_img_data;
@property (nullable, nonatomic, retain) NSString *group_long_desc;
@property (nullable, nonatomic, retain) NSString *group_mime_type;
@property (nullable, nonatomic, retain) NSString *group_name;
@property (nullable, nonatomic, retain) NSString *group_short_desc;
@property (nullable, nonatomic, retain) NSData *member;
@property (nullable, nonatomic, retain) NSSet<MRPostedReplies *> *comment;
@property (nullable, nonatomic, retain) NSSet<MRGroupMembers *> *members;

@end

@interface MRGroup (CoreDataGeneratedAccessors)

- (void)addCommentObject:(MRPostedReplies *)value;
- (void)removeCommentObject:(MRPostedReplies *)value;
- (void)addComment:(NSSet<MRPostedReplies *> *)values;
- (void)removeComment:(NSSet<MRPostedReplies *> *)values;

- (void)addMembersObject:(MRGroupMembers *)value;
- (void)removeMembersObject:(MRGroupMembers *)value;
- (void)addMembers:(NSSet<MRGroupMembers *> *)values;
- (void)removeMembers:(NSSet<MRGroupMembers *> *)values;

@end

NS_ASSUME_NONNULL_END

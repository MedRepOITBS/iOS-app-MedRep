//
//  MRSharePost+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/31/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRSharePost.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRSharePost (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *commentsCount;
@property (nullable, nonatomic, retain) NSNumber *contactId;
@property (nullable, nonatomic, retain) NSNumber *contentType;
@property (nullable, nonatomic, retain) NSString *detailedText;
@property (nullable, nonatomic, retain) NSString *doctor_Name;
@property (nullable, nonatomic, retain) NSString *displayPicture;
@property (nullable, nonatomic, retain) NSNumber *group_id;
@property (nullable, nonatomic, retain) NSNumber *groupId;
@property (nullable, nonatomic, retain) NSNumber *likesCount;
@property (nullable, nonatomic, retain) NSNumber *member_id;
@property (nullable, nonatomic, retain) NSNumber *message_id;
@property (nullable, nonatomic, retain) NSString *message_type;
@property (nullable, nonatomic, retain) NSData *objectData;
@property (nullable, nonatomic, retain) NSNumber *parentSharePostId;
@property (nullable, nonatomic, retain) NSNumber *parentTransformPostId;
@property (nullable, nonatomic, retain) NSDate *post_date;
@property (nullable, nonatomic, retain) NSDate *postedOn;
@property (nullable, nonatomic, retain) NSNumber *receiver_id;
@property (nullable, nonatomic, retain) NSDate *share_date;
@property (nullable, nonatomic, retain) NSNumber *shareCount;
@property (nullable, nonatomic, retain) NSNumber *sharedByProfileId;
@property (nullable, nonatomic, retain) NSString *sharedByProfileName;
@property (nullable, nonatomic, retain) NSNumber *sharePostId;
@property (nullable, nonatomic, retain) NSString *shortText;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSString *titleDescription;
@property (nullable, nonatomic, retain) NSNumber *topic_id;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSNumber *doctor_id;
@property (nullable, nonatomic, retain) NSNumber *likes_count;
@property (nullable, nonatomic, retain) NSNumber *comment_count;
@property (nullable, nonatomic, retain) NSNumber *share_count;
@property (nullable, nonatomic, retain) NSDate *posted_on;
@property (nullable, nonatomic, retain) NSNumber *parent_share_id;
@property (nullable, nonatomic, retain) NSString *content_type;
@property (nullable, nonatomic, retain) NSString *detail_desc;
@property (nullable, nonatomic, retain) NSString *short_desc;
@property (nullable, nonatomic, retain) NSString *title_desc;
@property (nullable, nonatomic, retain) NSSet<MRPostedReplies *> *postedReplies;

@end

@interface MRSharePost (CoreDataGeneratedAccessors)

- (void)addPostedRepliesObject:(MRPostedReplies *)value;
- (void)removePostedRepliesObject:(MRPostedReplies *)value;
- (void)addPostedReplies:(NSSet<MRPostedReplies *> *)values;
- (void)removePostedReplies:(NSSet<MRPostedReplies *> *)values;

@end

NS_ASSUME_NONNULL_END

//
//  MRSharePost+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/8/16.
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
@property (nullable, nonatomic, retain) NSNumber *groupId;
@property (nullable, nonatomic, retain) NSNumber *likesCount;
@property (nullable, nonatomic, retain) NSData *objectData;
@property (nullable, nonatomic, retain) NSNumber *parentSharePostId;
@property (nullable, nonatomic, retain) NSNumber *parentTransformPostId;
@property (nullable, nonatomic, retain) NSDate *postedOn;
@property (nullable, nonatomic, retain) NSNumber *shareCount;
@property (nullable, nonatomic, retain) NSNumber *sharedByProfileId;
@property (nullable, nonatomic, retain) NSString *sharedByProfileName;
@property (nullable, nonatomic, retain) NSData *shareddByProfilePic;
@property (nullable, nonatomic, retain) NSNumber *sharePostId;
@property (nullable, nonatomic, retain) NSString *shortText;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSString *titleDescription;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSSet<MRPostedReplies *> *postedReplies;

@end

[{"message_id":1,"member_id":16,"group_id":0,"message":"Content Share, Content Transform","message_type":"Text Type","post_date":"1469595440000","receiver_id":0,"topic_id":0,"share_date":null}]


//
//Sir i checked.. Its little bit complicated for my insulin pump to come under insurance in UK .. and here i have some docs appointment lined up … i talked to Shashi too .. so wiling to stay here in US ..

@interface MRSharePost (CoreDataGeneratedAccessors)

- (void)addPostedRepliesObject:(MRPostedReplies *)value;
- (void)removePostedRepliesObject:(MRPostedReplies *)value;
- (void)addPostedReplies:(NSSet<MRPostedReplies *> *)values;
- (void)removePostedReplies:(NSSet<MRPostedReplies *> *)values;

@end

NS_ASSUME_NONNULL_END

//
//  MRPostedReplies+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 8/1/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRPostedReplies.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRPostedReplies (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *contact_id;
@property (nullable, nonatomic, retain) NSNumber *contactId;
@property (nullable, nonatomic, retain) NSNumber *contentType;
@property (nullable, nonatomic, retain) NSString *displayPicture;
@property (nullable, nonatomic, retain) NSString *detail_desc;
@property (nullable, nonatomic, retain) NSString *fileUrl;
@property (nullable, nonatomic, retain) NSNumber *groupId;
@property (nullable, nonatomic, retain) NSNumber *parentSharePostId;
@property (nullable, nonatomic, retain) NSString *doctor_Name;
@property (nullable, nonatomic, retain) NSDate *postedOn;
@property (nullable, nonatomic, retain) NSDate *posted_on;
@property (nullable, nonatomic, retain) NSNumber *postedReplyId;
@property (nullable, nonatomic, retain) NSString *url;

@property (nullable, nonatomic, retain) NSNumber *message_id;
@property (nullable, nonatomic, retain) NSNumber *member_id;
@property (nullable, nonatomic, retain) NSNumber *group_id;
@property (nullable, nonatomic, retain) NSString *message;
@property (nullable, nonatomic, retain) NSString *message_type;
@property (nullable, nonatomic, retain) NSDate *post_date;
@property (nullable, nonatomic, retain) NSNumber *receiver_Id;
@property (nullable, nonatomic, retain) NSNumber *topic_id;
@property (nullable, nonatomic, retain) NSDate *share_date;
@property (nullable, nonatomic, retain) NSString *short_desc;
@property (nullable, nonatomic, retain) MRContact *contactRelationship;
@property (nullable, nonatomic, retain) MRGroup *groupRelationship;
@property (nullable, nonatomic, retain) MRSharePost *sharePostRelationship;

@end

NS_ASSUME_NONNULL_END

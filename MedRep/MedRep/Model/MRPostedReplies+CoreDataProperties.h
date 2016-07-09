//
//  MRPostedReplies+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/9/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRPostedReplies.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRPostedReplies (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *contentType;
@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, retain) NSNumber *parentSharePostId;
@property (nullable, nonatomic, retain) NSString *postedBy;
@property (nullable, nonatomic, retain) NSData *postedByProfilePic;
@property (nullable, nonatomic, retain) NSDate *postedOn;
@property (nullable, nonatomic, retain) NSNumber *postedReplyId;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSNumber *contactId;
@property (nullable, nonatomic, retain) NSNumber *groupId;
@property (nullable, nonatomic, retain) MRContact *contactRelationship;
@property (nullable, nonatomic, retain) MRGroup *groupRelationship;

@end

NS_ASSUME_NONNULL_END

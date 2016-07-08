//
//  MRSharePost+CoreDataProperties.h
//  MedRep
//
//  Created by Namit Nayak on 7/8/16.
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
@property (nullable, nonatomic, retain) NSOrderedSet<MRPostedReplies *> *mrpostreplies;

@end

@interface MRSharePost (CoreDataGeneratedAccessors)

- (void)insertObject:(MRPostedReplies *)value inMrpostrepliesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMrpostrepliesAtIndex:(NSUInteger)idx;
- (void)insertMrpostreplies:(NSArray<MRPostedReplies *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMrpostrepliesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMrpostrepliesAtIndex:(NSUInteger)idx withObject:(MRPostedReplies *)value;
- (void)replaceMrpostrepliesAtIndexes:(NSIndexSet *)indexes withMrpostreplies:(NSArray<MRPostedReplies *> *)values;
- (void)addMrpostrepliesObject:(MRPostedReplies *)value;
- (void)removeMrpostrepliesObject:(MRPostedReplies *)value;
- (void)addMrpostreplies:(NSOrderedSet<MRPostedReplies *> *)values;
- (void)removeMrpostreplies:(NSOrderedSet<MRPostedReplies *> *)values;

@end

NS_ASSUME_NONNULL_END

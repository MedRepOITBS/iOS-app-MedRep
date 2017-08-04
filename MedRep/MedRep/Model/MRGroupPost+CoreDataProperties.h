//
//  MRGroupPost+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/6/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRGroupPost.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRGroupPost (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *groupPostId;
@property (nullable, nonatomic, retain) NSNumber *numberOfComments;
@property (nullable, nonatomic, retain) NSNumber *numberOfLikes;
@property (nullable, nonatomic, retain) NSNumber *numberOfShares;
@property (nullable, nonatomic, retain) NSString *postPic;
@property (nullable, nonatomic, retain) NSString *postText;
@property (nullable, nonatomic, retain) NSDate *postedOn;
@property (nullable, nonatomic, retain) MRContact *contact;
@property (nullable, nonatomic, retain) MRGroup *group;
@property (nullable, nonatomic, retain) NSOrderedSet<MrGroupChildPost *> *replyPost;

@end

@interface MRGroupPost (CoreDataGeneratedAccessors)

- (void)insertObject:(MrGroupChildPost *)value inReplyPostAtIndex:(NSUInteger)idx;
- (void)removeObjectFromReplyPostAtIndex:(NSUInteger)idx;
- (void)insertReplyPost:(NSArray<MrGroupChildPost *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeReplyPostAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInReplyPostAtIndex:(NSUInteger)idx withObject:(MrGroupChildPost *)value;
- (void)replaceReplyPostAtIndexes:(NSIndexSet *)indexes withReplyPost:(NSArray<MrGroupChildPost *> *)values;
- (void)addReplyPostObject:(MrGroupChildPost *)value;
- (void)removeReplyPostObject:(MrGroupChildPost *)value;
- (void)addReplyPost:(NSOrderedSet<MrGroupChildPost *> *)values;
- (void)removeReplyPost:(NSOrderedSet<MrGroupChildPost *> *)values;

@end

NS_ASSUME_NONNULL_END

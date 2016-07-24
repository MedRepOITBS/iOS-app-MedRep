//
//  MRTransformPost+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/25/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRTransformPost.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRTransformPost (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *contentType;
@property (nullable, nonatomic, retain) NSString *detailedDescription;
@property (nullable, nonatomic, retain) NSDate *postedOn;
@property (nullable, nonatomic, retain) NSString *shortArticleDescription;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSString *titleDescription;
@property (nullable, nonatomic, retain) NSNumber *transformPostId;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSString *coverImgFile;
@property (nullable, nonatomic, retain) NSString *coverImgUrl;
@property (nullable, nonatomic, retain) NSDate *createdOn;
@property (nullable, nonatomic, retain) NSString *newsDesc;
@property (nullable, nonatomic, retain) NSNumber *newsId;
@property (nullable, nonatomic, retain) NSString *postUrl;
@property (nullable, nonatomic, retain) NSNumber *sourceId;
@property (nullable, nonatomic, retain) NSString *sourceName;
@property (nullable, nonatomic, retain) NSString *tagDesc;
@property (nullable, nonatomic, retain) NSString *therapeuticId;
@property (nullable, nonatomic, retain) NSString *therapeuticName;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSString *videoFile;
@property (nullable, nonatomic, retain) NSString *videoUrl;
@property (nullable, nonatomic, retain) NSString *innerImgFile;
@property (nullable, nonatomic, retain) NSString *innerImgUrl;
@property (nullable, nonatomic, retain) NSSet<MRSharePost *> *childSharePosts;

@end

@interface MRTransformPost (CoreDataGeneratedAccessors)

- (void)addChildSharePostsObject:(MRSharePost *)value;
- (void)removeChildSharePostsObject:(MRSharePost *)value;
- (void)addChildSharePosts:(NSSet<MRSharePost *> *)values;
- (void)removeChildSharePosts:(NSSet<MRSharePost *> *)values;

@end

NS_ASSUME_NONNULL_END

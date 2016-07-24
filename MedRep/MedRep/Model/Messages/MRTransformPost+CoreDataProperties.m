//
//  MRTransformPost+CoreDataProperties.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/25/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRTransformPost+CoreDataProperties.h"

@implementation MRTransformPost (CoreDataProperties)

@dynamic contentType;
@dynamic detailedDescription;
@dynamic postedOn;
@dynamic shortArticleDescription;
@dynamic source;
@dynamic titleDescription;
@dynamic transformPostId;
@dynamic url;
@dynamic coverImgFile;
@dynamic coverImgUrl;
@dynamic createdOn;
@dynamic newsDesc;
@dynamic newsId;
@dynamic postUrl;
@dynamic sourceId;
@dynamic sourceName;
@dynamic tagDesc;
@dynamic therapeuticId;
@dynamic therapeuticName;
@dynamic title;
@dynamic userId;
@dynamic videoFile;
@dynamic videoUrl;
@dynamic innerImgFile;
@dynamic innerImgUrl;
@dynamic childSharePosts;

- (void)setTitle:(NSString *)title {
    self.titleDescription = title;
}

- (void)setTagDesc:(NSString *)tagDesc {
    self.shortArticleDescription = tagDesc;
}

- (void)setNewsDesc:(NSString *)newsDesc {
    self.detailedDescription = newsDesc;
}

- (void)setCreatedOn:(NSDate *)createdOn {
    self.postedOn = createdOn;
}

- (void)setSourceName:(NSString *)sourceName {
    self.source = self.sourceName;
}

@end

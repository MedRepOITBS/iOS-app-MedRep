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

NSString* const kNewsAndUpdates = @"News & Updates";

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
@dynamic transformDesc;
@dynamic userId;
@dynamic videoFile;
@dynamic videoUrl;
@dynamic innerImgFile;
@dynamic innerImgUrl;
@dynamic childSharePosts;
@dynamic subCategory;

- (void)setTitle:(NSString *)title {
    self.titleDescription = title;
}

- (void)setTagDesc:(NSString *)tagDesc {
    tagDesc = [self stripOutHTMLTags:tagDesc];
    self.shortArticleDescription = tagDesc;
}

- (void)setNewsDesc:(NSString *)newsDesc {
    newsDesc = [self stripOutHTMLTags:newsDesc];
    self.detailedDescription = newsDesc;
}

- (void)setTransformDesc:(NSString *)transformDesc {
    transformDesc = [self stripOutHTMLTags:transformDesc];
    self.detailedDescription = transformDesc;
}

- (void)setCreatedOn:(NSDate *)createdOn {
    self.postedOn = createdOn;
}

- (void)setSourceName:(NSString *)sourceName {
    self.source = sourceName;
}

- (void)setNewsId:(NSNumber *)newsId {
    NSInteger tempNewsId = 0;
    if (newsId != nil) {
        tempNewsId = newsId.longValue;
    }
    
    self.transformPostId = [NSNumber numberWithLong:tempNewsId];
}

- (void)setSubCategories:(NSData *)subCategories {
    
}

@end

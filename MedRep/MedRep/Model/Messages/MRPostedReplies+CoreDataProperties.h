//
//  MRPostedReplies+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/7/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRPostedReplies.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRPostedReplies (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *postedReplyId;
@property (nullable, nonatomic, retain) NSNumber *parentSharePostId;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSDate *postedOn;

@end

NS_ASSUME_NONNULL_END
//
//  MRReplies+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/4/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRReplies.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRReplies (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *parentPostId;
@property (nullable, nonatomic, retain) NSString *descriptionText;
@property (nullable, nonatomic, retain) NSData *contactPic;
@property (nullable, nonatomic, retain) NSDate *postedDate;
@property (nullable, nonatomic, retain) NSString *otherData;

@end

NS_ASSUME_NONNULL_END

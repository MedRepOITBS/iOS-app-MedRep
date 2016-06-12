//
//  MrGroupChildPost+CoreDataProperties.h
//  MedRep
//
//  Created by Namit Nayak on 6/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MrGroupChildPost.h"

NS_ASSUME_NONNULL_BEGIN

@interface MrGroupChildPost (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *postText;
@property (nullable, nonatomic, retain) NSString *postPic;
@property (nullable, nonatomic, retain) NSString *postId;

@end

NS_ASSUME_NONNULL_END

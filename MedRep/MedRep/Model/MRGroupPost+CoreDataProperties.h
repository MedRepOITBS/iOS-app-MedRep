//
//  MRGroupPost+CoreDataProperties.h
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/21/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRGroupPost.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRGroupPost (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *postText;
@property (nullable, nonatomic, retain) NSString *postPic;
@property (nonatomic) int64_t numberOfLikes;
@property (nonatomic) int64_t numberOfComments;
@property (nonatomic) int64_t numberOfShares;
@property (nonatomic) int64_t groupPostId;
@property (nullable, nonatomic, retain) MRGroup *group;
@property (nullable, nonatomic, retain) MRContact *contact;

@end

NS_ASSUME_NONNULL_END

//
//  MRSharePost+CoreDataProperties.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/8/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRSharePost+CoreDataProperties.h"

@implementation MRSharePost (CoreDataProperties)

@dynamic likesCount;
@dynamic shareCount;
@dynamic commentsCount;
@dynamic sharePostId;
@dynamic postedOn;
@dynamic sharedByProfileId;
@dynamic shareddByProfilePic;
@dynamic sharedByProfileName;
@dynamic parentSharePostId;
@dynamic contactId;
@dynamic groupId;
@dynamic parentTransformPostId;
@dynamic titleDescription;
@dynamic shortText;
@dynamic detailedText;
@dynamic objectData;
@dynamic url;
@dynamic contentType;
@dynamic source;

@end

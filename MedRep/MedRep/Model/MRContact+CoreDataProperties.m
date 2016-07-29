//
//  MRContact+CoreDataProperties.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/9/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRContact+CoreDataProperties.h"

@implementation MRContact (CoreDataProperties)

@dynamic city;
@dynamic contactId;
@dynamic doctorDetails;
@dynamic doctorId;
@dynamic dPicture;
@dynamic firstName;
@dynamic lastName;
@dynamic profilePic;
@dynamic roleId;
@dynamic status;
@dynamic therapeuticArea;
@dynamic therapeuticName;
@dynamic userId;
@dynamic groupPosts;
@dynamic groups;
@dynamic comments;

- (void)setProfilePic:(NSData *)profilePic {
    
}

@end

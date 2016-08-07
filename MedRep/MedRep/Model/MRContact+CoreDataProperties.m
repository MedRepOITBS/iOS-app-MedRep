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
@dynamic member_id;
@dynamic profilePic;
@dynamic roleId;
@dynamic connStatus;
@dynamic therapeuticArea;
@dynamic therapeuticName;
@dynamic userId;
@dynamic groupPosts;
@dynamic groups;
@dynamic comments;

- (void)setProfilePic:(NSData *)profilePic {
    
}

- (void)setMember_id:(NSNumber *)member_id {
    NSInteger memberId = 0;
    if (member_id != nil) {
        memberId = member_id.longValue;
    }
    self.doctorId = [NSNumber numberWithLong:memberId];
}

@end

//
//  MRGroupMembers+CoreDataProperties.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/12/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRGroupMembers+CoreDataProperties.h"
#import "MRConstants.h"

@implementation MRGroupMembers (CoreDataProperties)

@dynamic group_id;
@dynamic member_id;
@dynamic status;
@dynamic is_admin;
@dynamic imageUrl;
@dynamic doctor;
@dynamic memberList;
@dynamic groupList;
@dynamic firstName;
@dynamic lastName;
@dynamic alias;
@dynamic mimeType;
@dynamic therapeuticName;
@dynamic therapeuticDesc;
@dynamic roleId;
@dynamic roleName;
@dynamic stateMedCouncil;
@dynamic groups;

//- (void)setGroup_id:(NSNumber *)group_id {
//    [self willChangeValueForKey:@"group_id"];
//    [self setPrimitiveValue:group_id forKey:@"group_id"];
//    [self didChangeValueForKey:@"group_id"];
//    
//    if (self.allGroups == nil || self.allGroups.count == 0) {
//        self.allGroups = [[MRDataManger sharedManager] fetchObjectList:kGroupEntity];
//    }
//    
//    if (self.allGroups != nil && self.allGroups.count > 0) {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"group_id", group_id.longValue];
//        NSArray *filteredGroup = [self.allGroups filteredArrayUsingPredicate:predicate];
//        if (filteredGroup != nil && filteredGroup.count > 0) {
//            [self addGroupsObject:filteredGroup[0]];
//        }
//    }
//}

@end

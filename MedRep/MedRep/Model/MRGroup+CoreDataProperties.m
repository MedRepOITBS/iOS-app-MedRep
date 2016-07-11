//
//  MRGroup+CoreDataProperties.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/12/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRGroup+CoreDataProperties.h"
#import "MRConstants.h"
#import "MRGroupMembers.h"

@implementation MRGroup (CoreDataProperties)

@dynamic admin_id;
@dynamic group_id;
@dynamic group_img_data;
@dynamic group_long_desc;
@dynamic group_mime_type;
@dynamic group_name;
@dynamic group_short_desc;
@dynamic member;
@dynamic comment;
@dynamic members;

- (void)setMember:(NSData *)member {
    if ([member isKindOfClass:[NSArray class]]) {
        if (self.allMembers == nil || self.allMembers.count == 0) {
            self.allMembers = [[MRDataManger sharedManager] fetchObjectList:kGroupMembersEntity];
        }
        
        NSArray *tempMembers = [MRWebserviceHelper parseRecords:MRGroupMembers.class
                                                     allRecords:self.allMembers
                                                        context:self.managedObjectContext
                                                        andData:(NSArray*)member];
        self.members = [NSSet setWithArray:tempMembers];
    }
}

@end

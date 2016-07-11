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
    
}

@end

//
//  MRGroup+CoreDataProperties.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/8/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRGroup+CoreDataProperties.h"

@implementation MRGroup (CoreDataProperties)

@dynamic group_id;
@dynamic group_img_data;
@dynamic group_name;
@dynamic admin_id;
@dynamic group_long_desc;
@dynamic group_short_desc;
@dynamic group_mime_type;

@dynamic member;
@dynamic contacts;

@end

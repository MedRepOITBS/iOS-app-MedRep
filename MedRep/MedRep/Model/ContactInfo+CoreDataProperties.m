//
//  ContactInfo+CoreDataProperties.m
//  MedRep
//
//  Created by Namit Nayak on 8/24/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ContactInfo+CoreDataProperties.h"
#import "MRWebserviceHelper.h"

@implementation ContactInfo (CoreDataProperties)

@dynamic phoneNo;
@dynamic alternateEmail;
@dynamic email;
@dynamic mobileNo;
@dynamic name;
@dynamic firstName;
@dynamic middleName;
@dynamic lastName;

- (void)setName:(NSData *)name {
    id tempObject = name;
    if ([tempObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *nameDictionary = tempObject;
        self.firstName = [nameDictionary objectOrNilForKey:@"firstName"];
        self.middleName = [nameDictionary objectOrNilForKey:@"middleNam"];
        self.lastName = [nameDictionary objectOrNilForKey:@"lastName"];
    } else if ([tempObject isKindOfClass:[NSString class]]){
        self.firstName = (NSString*)name;
    }
}

@end

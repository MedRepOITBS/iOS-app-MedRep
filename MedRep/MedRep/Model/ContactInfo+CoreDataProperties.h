//
//  ContactInfo+CoreDataProperties.h
//  MedRep
//
//  Created by Namit Nayak on 8/24/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ContactInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *phoneNo;
@property (nullable, nonatomic, retain) NSString *alternateEmail;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *mobileNo;
@property (nullable, nonatomic, retain) NSData   *name;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *middleName;
@property (nullable, nonatomic, retain) NSString *lastName;

@end

NS_ASSUME_NONNULL_END

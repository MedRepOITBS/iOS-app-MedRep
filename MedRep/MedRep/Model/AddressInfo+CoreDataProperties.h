//
//  AddressInfo+CoreDataProperties.h
//  MedRep
//
//  Created by Namit Nayak on 8/24/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AddressInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddressInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *locationId;
@property (nullable, nonatomic, retain) NSString *address1;
@property (nullable, nonatomic, retain) NSString *address2;
@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSString *state;
@property (nullable, nonatomic, retain) NSString *country;
@property (nullable, nonatomic, retain) NSString *zipcode;
@property (nullable, nonatomic, retain) NSString *type;

@end

NS_ASSUME_NONNULL_END

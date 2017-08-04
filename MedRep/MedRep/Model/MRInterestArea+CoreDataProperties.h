//
//  MRInterestArea+CoreDataProperties.h
//  MedRep
//
//  Created by Namit Nayak on 7/31/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRInterestArea.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRInterestArea (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *id;

@end

NS_ASSUME_NONNULL_END

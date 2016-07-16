//
//  MRWorkExperience+CoreDataProperties.h
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRWorkExperience.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRWorkExperience (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *toDate;
@property (nullable, nonatomic, retain) NSString *designation;
@property (nullable, nonatomic, retain) NSString *fromDate;
@property (nullable, nonatomic, retain) NSString *hospital;
@property (nullable, nonatomic, retain) NSString *location;

@end

NS_ASSUME_NONNULL_END

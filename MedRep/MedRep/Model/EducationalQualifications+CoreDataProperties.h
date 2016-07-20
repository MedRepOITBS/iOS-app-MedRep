//
//  EducationalQualifications+CoreDataProperties.h
//  MedRep
//
//  Created by Namit Nayak on 7/19/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EducationalQualifications.h"

NS_ASSUME_NONNULL_BEGIN

@interface EducationalQualifications (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *aggregate;
@property (nullable, nonatomic, retain) NSString *collegeName;
@property (nullable, nonatomic, retain) NSString *course;
@property (nullable, nonatomic, retain) NSString *yearOfPassout;
@property (nullable, nonatomic, retain) NSString *degree;

@end

NS_ASSUME_NONNULL_END

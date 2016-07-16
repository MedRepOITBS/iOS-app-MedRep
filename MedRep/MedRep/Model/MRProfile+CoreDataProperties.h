//
//  MRProfile+CoreDataProperties.h
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRProfile.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRProfile (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSString *designation;
@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *workExperience;
@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *educationlQualification;
@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *interestArea;
@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *publications;

@end

@interface MRProfile (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inWorkExperienceAtIndex:(NSUInteger)idx;
- (void)removeObjectFromWorkExperienceAtIndex:(NSUInteger)idx;
- (void)insertWorkExperience:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeWorkExperienceAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInWorkExperienceAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceWorkExperienceAtIndexes:(NSIndexSet *)indexes withWorkExperience:(NSArray<NSManagedObject *> *)values;
- (void)addWorkExperienceObject:(NSManagedObject *)value;
- (void)removeWorkExperienceObject:(NSManagedObject *)value;
- (void)addWorkExperience:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removeWorkExperience:(NSOrderedSet<NSManagedObject *> *)values;

- (void)insertObject:(NSManagedObject *)value inEducationlQualificationAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEducationlQualificationAtIndex:(NSUInteger)idx;
- (void)insertEducationlQualification:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEducationlQualificationAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEducationlQualificationAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceEducationlQualificationAtIndexes:(NSIndexSet *)indexes withEducationlQualification:(NSArray<NSManagedObject *> *)values;
- (void)addEducationlQualificationObject:(NSManagedObject *)value;
- (void)removeEducationlQualificationObject:(NSManagedObject *)value;
- (void)addEducationlQualification:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removeEducationlQualification:(NSOrderedSet<NSManagedObject *> *)values;

- (void)insertObject:(NSManagedObject *)value inInterestAreaAtIndex:(NSUInteger)idx;
- (void)removeObjectFromInterestAreaAtIndex:(NSUInteger)idx;
- (void)insertInterestArea:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeInterestAreaAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInInterestAreaAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceInterestAreaAtIndexes:(NSIndexSet *)indexes withInterestArea:(NSArray<NSManagedObject *> *)values;
- (void)addInterestAreaObject:(NSManagedObject *)value;
- (void)removeInterestAreaObject:(NSManagedObject *)value;
- (void)addInterestArea:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removeInterestArea:(NSOrderedSet<NSManagedObject *> *)values;

- (void)insertObject:(NSManagedObject *)value inPublicationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPublicationsAtIndex:(NSUInteger)idx;
- (void)insertPublications:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePublicationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPublicationsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replacePublicationsAtIndexes:(NSIndexSet *)indexes withPublications:(NSArray<NSManagedObject *> *)values;
- (void)addPublicationsObject:(NSManagedObject *)value;
- (void)removePublicationsObject:(NSManagedObject *)value;
- (void)addPublications:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removePublications:(NSOrderedSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END

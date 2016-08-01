//
//  MRProfile+CoreDataProperties.h
//  MedRep
//
//  Created by Namit Nayak on 7/31/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRProfile.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRProfile (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *designation;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *doctorId;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSOrderedSet<EducationalQualifications *> *educationlQualification;
@property (nullable, nonatomic, retain) NSOrderedSet<MRInterestArea *> *interestArea;
@property (nullable, nonatomic, retain) NSOrderedSet<MRPublications *> *publications;
@property (nullable, nonatomic, retain) NSOrderedSet<MRWorkExperience *> *workExperience;

@end

@interface MRProfile (CoreDataGeneratedAccessors)

- (void)insertObject:(EducationalQualifications *)value inEducationlQualificationAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEducationlQualificationAtIndex:(NSUInteger)idx;
- (void)insertEducationlQualification:(NSArray<EducationalQualifications *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEducationlQualificationAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEducationlQualificationAtIndex:(NSUInteger)idx withObject:(EducationalQualifications *)value;
- (void)replaceEducationlQualificationAtIndexes:(NSIndexSet *)indexes withEducationlQualification:(NSArray<EducationalQualifications *> *)values;
- (void)addEducationlQualificationObject:(EducationalQualifications *)value;
- (void)removeEducationlQualificationObject:(EducationalQualifications *)value;
- (void)addEducationlQualification:(NSOrderedSet<EducationalQualifications *> *)values;
- (void)removeEducationlQualification:(NSOrderedSet<EducationalQualifications *> *)values;

- (void)insertObject:(MRInterestArea *)value inInterestAreaAtIndex:(NSUInteger)idx;
- (void)removeObjectFromInterestAreaAtIndex:(NSUInteger)idx;
- (void)insertInterestArea:(NSArray<MRInterestArea *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeInterestAreaAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInInterestAreaAtIndex:(NSUInteger)idx withObject:(MRInterestArea *)value;
- (void)replaceInterestAreaAtIndexes:(NSIndexSet *)indexes withInterestArea:(NSArray<MRInterestArea *> *)values;
- (void)addInterestAreaObject:(MRInterestArea *)value;
- (void)removeInterestAreaObject:(MRInterestArea *)value;
- (void)addInterestArea:(NSOrderedSet<MRInterestArea *> *)values;
- (void)removeInterestArea:(NSOrderedSet<MRInterestArea *> *)values;

- (void)insertObject:(MRPublications *)value inPublicationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPublicationsAtIndex:(NSUInteger)idx;
- (void)insertPublications:(NSArray<MRPublications *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePublicationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPublicationsAtIndex:(NSUInteger)idx withObject:(MRPublications *)value;
- (void)replacePublicationsAtIndexes:(NSIndexSet *)indexes withPublications:(NSArray<MRPublications *> *)values;
- (void)addPublicationsObject:(MRPublications *)value;
- (void)removePublicationsObject:(MRPublications *)value;
- (void)addPublications:(NSOrderedSet<MRPublications *> *)values;
- (void)removePublications:(NSOrderedSet<MRPublications *> *)values;

- (void)insertObject:(MRWorkExperience *)value inWorkExperienceAtIndex:(NSUInteger)idx;
- (void)removeObjectFromWorkExperienceAtIndex:(NSUInteger)idx;
- (void)insertWorkExperience:(NSArray<MRWorkExperience *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeWorkExperienceAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInWorkExperienceAtIndex:(NSUInteger)idx withObject:(MRWorkExperience *)value;
- (void)replaceWorkExperienceAtIndexes:(NSIndexSet *)indexes withWorkExperience:(NSArray<MRWorkExperience *> *)values;
- (void)addWorkExperienceObject:(MRWorkExperience *)value;
- (void)removeWorkExperienceObject:(MRWorkExperience *)value;
- (void)addWorkExperience:(NSOrderedSet<MRWorkExperience *> *)values;
- (void)removeWorkExperience:(NSOrderedSet<MRWorkExperience *> *)values;

@end

NS_ASSUME_NONNULL_END

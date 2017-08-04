//
//  MRPHSurveyStatistics+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 12/19/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRPHSurveyStatistics+CoreDataClass.h"
#import "MRPHSurveyPendingList+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MRPHSurveyStatistics (CoreDataProperties)

+ (NSFetchRequest<MRPHSurveyStatistics *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *pending;
@property (nullable, nonatomic, copy) NSNumber *surveyId;
@property (nullable, nonatomic, copy) NSNumber *totalCompleted;
@property (nullable, nonatomic, copy) NSNumber *totalPending;
@property (nullable, nonatomic, copy) NSNumber *totalSent;
@property (nullable, nonatomic, retain) NSSet<MRPHSurveyPendingList *> *doctorList;

@end

@interface MRPHSurveyStatistics (CoreDataGeneratedAccessors)

- (void)addDoctorListObject:(MRPHSurveyPendingList *)value;
- (void)removeDoctorListObject:(MRPHSurveyPendingList *)value;
- (void)addDoctorList:(NSSet<MRPHSurveyPendingList *> *)values;
- (void)removeDoctorList:(NSSet<MRPHSurveyPendingList *> *)values;

@end

NS_ASSUME_NONNULL_END

//
//  MRPHSurveyPendingList+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 12/20/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRPHSurveyPendingList+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MRPHSurveyPendingList (CoreDataProperties)

+ (NSFetchRequest<MRPHSurveyPendingList *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *companyId;
@property (nullable, nonatomic, copy) NSString *companyName;
@property (nullable, nonatomic, copy) NSDate *createdOn;
@property (nullable, nonatomic, copy) NSNumber *doctorId;
@property (nullable, nonatomic, copy) NSString *doctorName;
@property (nullable, nonatomic, copy) NSNumber *doctorSurveyId;
@property (nullable, nonatomic, retain) NSData *publishDocsIds;
@property (nullable, nonatomic, retain) NSData *publishSurveyId;
@property (nullable, nonatomic, retain) NSData *publishTareaIds;
@property (nullable, nonatomic, copy) NSNumber *reminder_sent;
@property (nullable, nonatomic, copy) NSNumber *repId;
@property (nullable, nonatomic, copy) NSNumber *repSurveyId;
@property (nullable, nonatomic, copy) NSString *reportUrl;
@property (nullable, nonatomic, copy) NSNumber *reportsAvailable;
@property (nullable, nonatomic, copy) NSNumber *reportsStatus;
@property (nullable, nonatomic, copy) NSDate *scheduledFinish;
@property (nullable, nonatomic, copy) NSDate *scheduledStart;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, copy) NSString *surveyDescription;
@property (nullable, nonatomic, copy) NSNumber *surveyId;
@property (nullable, nonatomic, copy) NSString *surveyTitle;
@property (nullable, nonatomic, copy) NSString *surveyUrl;
@property (nullable, nonatomic, retain) NSData *therapeuticDropDownValues;
@property (nullable, nonatomic, copy) NSNumber *therapeuticId;
@property (nullable, nonatomic, copy) NSString *therapeuticName;

@end

NS_ASSUME_NONNULL_END

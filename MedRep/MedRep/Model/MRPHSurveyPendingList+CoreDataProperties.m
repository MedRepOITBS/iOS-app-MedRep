//
//  MRPHSurveyPendingList+CoreDataProperties.m
//  MedRep
//
//  Created by Vamsi Katragadda on 12/20/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRPHSurveyPendingList+CoreDataProperties.h"

@implementation MRPHSurveyPendingList (CoreDataProperties)

+ (NSFetchRequest<MRPHSurveyPendingList *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MRPHSurveyPendingList"];
}

@dynamic companyId;
@dynamic companyName;
@dynamic createdOn;
@dynamic doctorId;
@dynamic doctorName;
@dynamic doctorSurveyId;
@dynamic publishDocsIds;
@dynamic publishSurveyId;
@dynamic publishTareaIds;
@dynamic reminder_sent;
@dynamic repId;
@dynamic repSurveyId;
@dynamic reportUrl;
@dynamic reportsAvailable;
@dynamic reportsStatus;
@dynamic scheduledFinish;
@dynamic scheduledStart;
@dynamic status;
@dynamic surveyDescription;
@dynamic surveyId;
@dynamic surveyTitle;
@dynamic surveyUrl;
@dynamic therapeuticDropDownValues;
@dynamic therapeuticId;
@dynamic therapeuticName;

+ (NSString*)primaryKeyColumnName {
    return @"doctorId";
}

//- (void)setDoctorName:(NSString*)doctorName {
//    [self willChangeValueForKey:@"doctorName"];
//    [self setPrimitiveValue:doctorName forKey:@"doctorName"];
//    [self didChangeValueForKey:@"doctorName"];
//}

@end

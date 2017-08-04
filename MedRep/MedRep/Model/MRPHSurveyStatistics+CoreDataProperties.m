//
//  MRPHSurveyStatistics+CoreDataProperties.m
//  MedRep
//
//  Created by Vamsi Katragadda on 12/19/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRPHSurveyStatistics+CoreDataProperties.h"
#import "MRWebserviceHelper.h"
#import "MRDatabaseHelper.h"

@implementation MRPHSurveyStatistics (CoreDataProperties)

+ (NSFetchRequest<MRPHSurveyStatistics *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MRPHSurveyStatistics"];
}

@dynamic pending;
@dynamic surveyId;
@dynamic totalCompleted;
@dynamic totalPending;
@dynamic totalSent;
@dynamic doctorList;

+ (NSString*)primaryKeyColumnName {
    return @"surveyId";
}

- (void)setPending:(NSData *)pending {
    /*NSArray *tempPendingList = (NSArray*)pending;
    NSArray *pendingDoctorList =
    [MRWebserviceHelper parseRecords:NSClassFromString(kSurveyStatisticsPendingListEntity) allRecords:(NSArray*)nil
                                  
                                                                  context:self.managedObjectContext
                                     andData:tempPendingList];
    if (pendingDoctorList != nil && pendingDoctorList.count > 0) {
        [self addDoctorList:[NSSet setWithArray:pendingDoctorList]];
    } else {
        if (self.doctorList != nil && self.doctorList.count > 0) {
            [self removeDoctorList:self.doctorList];
        }
    }*/
}

@end

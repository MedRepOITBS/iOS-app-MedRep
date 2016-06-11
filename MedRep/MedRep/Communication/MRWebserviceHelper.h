//
//  MRWebserviceHelper.h
//  MedRep
//
//  Created by MedRep Developer on 10/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRWebserviceConstants.h"

typedef void(^completionHandler)(BOOL status, NSString *details, NSDictionary *responce);

@interface MRWebserviceHelper : NSObject
{
    
}
@property (nonatomic, assign) kMRWebServiceType serviceType;

+ (MRWebserviceHelper*)sharedWebServiceHelper;

- (void)userLogin:(NSString*)userName
       andPasword:(NSString*)password withHandler:(completionHandler)responceHandler;

- (void)refreshToken:(completionHandler)responceHandler;

- (void)verifyMobileNumber:(NSString*)mobileNumber
                   withOTP:(NSString*)mobileOTP
               withHandler:(completionHandler)responceHandler;

- (void)getOTP:(completionHandler)responceHandler;

- (void)getRoles:(completionHandler)responceHandler;

- (void)getTherapeuticAreaDetails:(completionHandler)responceHandler;

- (void)getNotificationTypes:(completionHandler)responceHandler;

- (void)getCompanyDetails:(completionHandler)responceHandler;

- (void)getDoctorProfileDetails:(completionHandler)responceHandler;

- (void)getPharmaProfileDetails:(completionHandler)responceHandler;

- (void)getMyPendingSurveysDetails:(completionHandler)responceHandler;

- (void)getMyRepsDetails:(completionHandler)responceHandler;

- (void)sendSignUp:(NSDictionary*)userDetails
       withHandler:(completionHandler)responceHandler;

- (void)sendPharmaRepSignUp:(NSDictionary*)userDetails
       withHandler:(completionHandler)responceHandler;

- (void)uploadDP:(NSDictionary*)DPdetails
     withHandler:(completionHandler)responceHandler;

- (void)sendForgotPassword:(NSDictionary*)userDetails
               withHandler:(completionHandler)responceHandler;

- (void)updateMyDetails:(NSDictionary*)userDetails
            withHandler:(completionHandler)responceHandler;

- (void)updateMyPharmaDetails:(NSDictionary*)userDetails
                  withHandler:(completionHandler)responceHandler;

- (void)updateSurveyStatus:(NSDictionary*)surveyDetails
               withHandler:(completionHandler)responceHandler;

- (void)createNewAppointment:(NSDictionary*)appointmentDetails
                isFromUpdate:(BOOL)isFromCreate
                 withHandler:(completionHandler)responceHandler;

- (void)getMyNotificationContent:(NSInteger)detailNotificationId
                     withHandler:(completionHandler)responceHandler;

- (void)getNewSMSOTP:(NSString*)str
withComplitionHandler:(completionHandler)responceHandler;

- (void)getVerifyMobileNo:(NSString*)str
    withComplitionHandler:(completionHandler)responceHandler;

- (void)getRecreateOTP:(NSString*)str
 withComplitionHandler:(completionHandler)responceHandler;


- (void)getMyAppointments:(NSString*)appointmentDetails
                 withHandler:(completionHandler)responceHandler;

- (void)getMyNotifications:(NSString*)startDate
               withHandler:(completionHandler)responceHandler;

- (void)getMyRole:(completionHandler)responceHandler;

- (void)updateNotification:(NSDictionary*)notificationDetails
               withHandler:(completionHandler)responceHandler;

- (void)getPharmaNotifications:(NSString*)startDate
                   withHandler:(completionHandler)responceHandler;

- (void)getMyDoctorsForPharma:(completionHandler)responceHandler;

- (void)getMyPendingAppointmentForPharma:(completionHandler)responceHandler;

- (void)getMyAppointmentForPharma:(completionHandler)responceHandler;


- (void)getDoctorProfileForPharma:(NSString*)token
                      withHandler:(completionHandler)responceHandler;

- (void)updateMyNotificationForPharma:(NSDictionary*)notificationDetails
                          withHandler:(completionHandler)responceHandler;

- (void)acceptAppointmentForPharma:(NSDictionary*)appointmentDetails
                       withHandler:(completionHandler)responceHandler;

- (void)getNotificationStatsForPharma:(NSString*)notificationId
                          withHandler:(completionHandler)responceHandler;

- (void)getAppointmentsByNotificationIdForPharma:(NSString*)notificationId
                                        withHandler:(completionHandler)responceHandler;

- (void)getNotificationActivityScoreForPharma:(NSString*)notificationId
                                  withHandler:(completionHandler)responceHandler;

- (void)getDoctorActivityScoreForPharma:(NSString*)doctorId
                            withHandler:(completionHandler)responceHandler;

- (void)getDoctorProfileDetailsByID:(NSString*)doctorId
                        withHandler:(completionHandler)responceHandler;

- (void)getMyCompanyDoctors:(completionHandler)responceHandler;

- (void)getMyteam:(completionHandler)responceHandler;

- (void)getPharaRepProfile:(NSString*)pharmaId
               withHandler:(completionHandler)responceHandler;

- (void)getAppointmentsByRep:(NSString*)pharmaId
                 withHandler:(completionHandler)responceHandler;

- (void)updateAppointments:(NSDictionary*)userDetails
               withHandler:(completionHandler)responceHandler;

- (void)acceptAppointments:(NSDictionary*)appointmentDetails
               withHandler:(completionHandler)responceHandler;

- (void)getNotificationById:(NSString*)notificationID
                withHandler:(completionHandler)responceHandler;

- (void)getMyCompany:(completionHandler)responceHandler;

- (void)getDoctorNotificationStatsById:(NSString*)notificationID
                           withHandler:(completionHandler)responceHandler;

- (void)getDoctorActivityScore:(completionHandler)responceHandler;

- (void)getMyUpcomingAppointment:(completionHandler)responceHandler;

- (void)getMyCompletedAppointment:(completionHandler)responceHandler;

- (void)getMyTeamPendingAppointments:(completionHandler)responceHandler;

@end

@interface NSDictionary (CategoryName)

/**
 * Returns the object for the given key, if it is in the dictionary, else nil.
 * This is useful when using SBJSON, as that will return [NSNull null] if the value was 'null' in the parsed JSON.
 * @param The key to use
 * @return The object or, if the object was not set in the dictionary or was NSNull, nil
 */
- (id)objectOrNilForKey:(id)aKey;

- (NSDictionary *)dictionaryByReplacingNullsWithBlanks;

@end

@implementation NSArray (NullReplacement)

- (NSArray *)arrayByReplacingNullsWithBlanks  {
    NSMutableArray *replaced = [self mutableCopy];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    for (int idx = 0; idx < [replaced count]; idx++) {
        id object = [replaced objectAtIndex:idx];
        if (object == nul) [replaced replaceObjectAtIndex:idx withObject:blank];
        else if ([object isKindOfClass:[NSDictionary class]]) [replaced replaceObjectAtIndex:idx withObject:[object dictionaryByReplacingNullsWithBlanks]];
        else if ([object isKindOfClass:[NSArray class]]) [replaced replaceObjectAtIndex:idx withObject:[object arrayByReplacingNullsWithBlanks]];
    }
    return [replaced copy];
}

@end




@implementation NSDictionary (CategoryName)

- (id)objectOrNilForKey:(id)aKey {
    id object = [self objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? @"" : object;
}

- (NSDictionary *)dictionaryByReplacingNullsWithBlanks
{
    const NSMutableDictionary *replaced = [self mutableCopy];
    const id nul = [NSNull null];
    
    for (NSString *key in self) {
        id object = [self objectForKey:key];
        if (object == nul) [replaced setObject:@"" forKey:key];
        
        else if ([object isKindOfClass:[NSDictionary class]]) [replaced setObject:[object dictionaryByReplacingNullsWithBlanks] forKey:key];
        else if ([object isKindOfClass:[NSArray class]]) [replaced setObject:[object arrayByReplacingNullsWithBlanks] forKey:key];
    }
    return [NSDictionary dictionaryWithDictionary:[replaced copy]];
}
@end


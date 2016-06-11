//
//  MRNotifications.h
//  
//
//  Created by MedRep Developer on 14/10/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MRNotifications : NSManagedObject

@property (nonatomic, retain) NSNumber * companyId;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSString * createdBy;
@property (nonatomic, retain) NSString * createdOn;
@property (nonatomic, retain) NSString * externalRef;
@property (nonatomic, retain) NSNumber * favNotification;
@property (nonatomic, retain) NSString * fileList;
@property (nonatomic, retain) NSString * notificationDesc;
@property (nonatomic, retain) NSData *   notificationDetails;
@property (nonatomic, retain) NSNumber * notificationId;
@property (nonatomic, retain) NSString * notificationName;
@property (nonatomic, retain) NSNumber * readNotification;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * therapeuticDropDownValues;
@property (nonatomic, retain) NSNumber * therapeuticId;
@property (nonatomic, retain) NSString * therapeuticName;
@property (nonatomic, retain) NSNumber * totalConvertedToAppointment;
@property (nonatomic, retain) NSNumber * totalPendingNotifcation;
@property (nonatomic, retain) NSNumber * totalSentNotification;
@property (nonatomic, retain) NSNumber * totalViewedNotifcation;
@property (nonatomic, retain) NSNumber * typeId;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) NSString * updatedOn;
@property (nonatomic, retain) NSString * validUpto;
@property (nonatomic, retain) NSNumber *feedback;

@end

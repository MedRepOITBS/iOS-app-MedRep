//
//  MRNotifications.m
//  
//
//  Created by MedRep Developer on 14/10/15.
//
//

#import "MRNotifications.h"
#import "MRCommon.h"

@implementation MRNotifications

@dynamic companyId;
@dynamic companyName;
@dynamic createdBy;
@dynamic createdOn;
@dynamic dPicture;
@dynamic externalRef;
@dynamic favourite;
@dynamic favNotification;
@dynamic feedback;
@dynamic fileList;
@dynamic notificationDesc;
@dynamic notificationDetails;
@dynamic notificationId;
@dynamic notificationName;
@dynamic readNotification;
@dynamic status;
@dynamic therapeuticDropDownValues;
@dynamic therapeuticId;
@dynamic therapeuticName;
@dynamic totalConvertedToAppointment;
@dynamic totalPendingNotifcation;
@dynamic totalSentNotification;
@dynamic totalViewedNotifcation;
@dynamic typeId;
@dynamic updatedBy;
@dynamic updatedOn;
@dynamic viewCount;
@dynamic viewStatus;
@dynamic validUpto;

+ (NSString *)primaryKeyColumnName {
    return @"notificationId";
}

- (void)setNotificationId:(NSNumber *)notificationId {
    NSInteger tempNotificationId = 0;
    if (notificationId != nil) {
        tempNotificationId = notificationId.integerValue;
    }
    
    [self willChangeValueForKey:@"notificationId"];
    [self setPrimitiveValue:[NSNumber numberWithLong:tempNotificationId] forKey:@"notificationId"];
    [self didChangeValueForKey:@"notificationId"];
    
    BOOL favouriteNotification = false;
    
    if (self.favNotification != nil && self.favNotification.boolValue) {
        favouriteNotification = self.favNotification.boolValue;
    }
    
    self.favNotification = [NSNumber numberWithBool:favouriteNotification];
}

- (void)setViewStatus:(NSString *)viewStatus {
    BOOL readStatus = false;
    
    NSString *value = @"";
    
    if (viewStatus != nil && viewStatus.length > 0) {
        value = viewStatus;
        if ([viewStatus caseInsensitiveCompare:@"Viewed"] == NSOrderedSame) {
            readStatus = true;
        }
    }
    
    self.readNotification = [NSNumber numberWithBool:readStatus];
    
    [self willChangeValueForKey:@"viewStatus"];
    [self setPrimitiveValue:value forKey:@"viewStatus"];
    [self didChangeValueForKey:@"viewStatus"];
}

- (void)setNotificationDetails:(NSData *)notificationDetails {
    if (notificationDetails != nil) {
        NSDictionary *dataDict = nil;
        if ([notificationDetails isKindOfClass:[NSDictionary class]]) {
            dataDict = (NSDictionary*)notificationDetails;
        } else if ([notificationDetails isKindOfClass:[NSArray class]]) {
            dataDict = ((NSArray*)notificationDetails).firstObject;
        }
        
        if (dataDict != nil) {
            [self willChangeValueForKey:@"notificationDetails"];
            [self setPrimitiveValue:[MRCommon archiveDictionaryToData:dataDict forKey:@"notificationDetails"] forKey:@"notificationDetails"];
            [self didChangeValueForKey:@"notificationDetails"];
        }
    }
}

- (NSDictionary*)getNotificationDetails {
    NSDictionary *value = nil;
    
    if (self.notificationDetails != nil) {
        value = [MRCommon unArchiveDataToDictionary:self.notificationDetails forKey:@"notificationDetails"];
    }
    
    return value;
}

@end

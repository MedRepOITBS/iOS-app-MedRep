//
//  MRDatabaseHelper.m
//  MedRep
//
//  Created by MedRep Developer on 03/10/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRDatabaseHelper.h"
#import "MRTherapeuticArea.h"
#import "MRRole.h"
#import "MRNotificationType.h"
#import "MRCompanyDetails.h"
#import "MRNotifications.h"
#import "MRCommon.h"


static MRDatabaseHelper *sharedDataManager = nil;

@implementation MRDatabaseHelper

+ (MRDatabaseHelper *)sharedHelper
{
    static dispatch_once_t once;
    static MRDatabaseHelper * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;

}

+ (void)addRole:(NSArray*)roles
{
    for (NSDictionary *myRoledict in roles)
    {
        MRRole *myRole  = (MRRole*)[[MRDataManger sharedManager] createObjectForEntity:kRoleEntity];
        myRole.roleId           = [myRoledict objectForKey:@"roleId"];
        myRole.name             = [myRoledict objectForKey:@"name"];
        myRole.roleDescription  = [myRoledict objectForKey:@"description"];
        myRole.authority        = [myRoledict objectForKey:@"authority"];
    }
    
    [[MRDataManger sharedManager] saveContext];
}

+ (void)addTherapeuticArea:(NSArray*)therapeuticAreaList
{
    for (NSDictionary *myTherapeuticDict in therapeuticAreaList)
    {
        MRTherapeuticArea *therapeutic = (MRTherapeuticArea*)[[MRDataManger sharedManager] createObjectForEntity:kTherapeuticAreaEntity];
        therapeutic.therapeuticId   = [myTherapeuticDict objectForKey:@"therapeuticId"];
        therapeutic.therapeuticName = [myTherapeuticDict objectForKey:@"therapeuticName"];
        therapeutic.therapeuticDesc = [myTherapeuticDict objectForKey:@"therapeuticDesc"];
    }
    
    [[MRDataManger sharedManager] saveContext];
}

+ (void)addNotificationType:(NSArray*)notificationTypeList
{
    for (NSDictionary *myNotificationDict in notificationTypeList)
    {
        MRNotificationType *notificationType = (MRNotificationType*)[[MRDataManger sharedManager] createObjectForEntity:kNotificationTypeEntity];
        notificationType.typeId     = [myNotificationDict objectForKey:@"typeId"];
        notificationType.typeName   = [myNotificationDict objectForKey:@"typeName"];
        notificationType.typeDesc   = [myNotificationDict objectForKey:@"typeDesc"];
    }
    
    [[MRDataManger sharedManager] saveContext];
}

+ (void)addCompanyDetails:(NSArray*)companyDetailsList
{
    for (NSDictionary *myCompanyDetailsDict in companyDetailsList)
    {
        MRCompanyDetails *companyDetails = (MRCompanyDetails*)[[MRDataManger sharedManager] createObjectForEntity:kCompanyDetailsEntity];
        companyDetails.companyId    = [myCompanyDetailsDict objectForKey:@"companyId"];
        companyDetails.companyName  = [myCompanyDetailsDict objectForKey:@"companyName"];
        companyDetails.companyDesc  = [myCompanyDetailsDict objectForKey:@"companyDesc"];
        
        companyDetails.contactName  = [myCompanyDetailsDict objectForKey:@"contactName"];
        companyDetails.contactNo    = [myCompanyDetailsDict objectForKey:@"contactNo"];
        companyDetails.displayPicture   = [MRCommon archiveDictionaryToData:[myCompanyDetailsDict objectForKey:@"displayPicture"] forKey:@"displayPicture"];
        companyDetails.location   = [MRCommon archiveDictionaryToData:[myCompanyDetailsDict objectForKey:@"location"] forKey:@"location"];
        companyDetails.status       = [myCompanyDetailsDict objectForKey:@"status"];
    }
    
    [[MRDataManger sharedManager] saveContext];
}

+ (void)addNotifications:(NSArray*)notificationsList
{
    for (NSDictionary *myNotificationDict in notificationsList)
    {
        
        MRNotifications *oldNotification = [[MRDataManger sharedManager] fetchObject:kNotificationsEntity attributeName:@"notificationId" attributeValue:[myNotificationDict objectForKey:@"notificationId"]];
        
        if(nil == oldNotification)
        {
            
            MRNotifications *notification = (MRNotifications*)[[MRDataManger sharedManager] createObjectForEntity:kNotificationsEntity];
            
            if (![MRCommon isStringEmpty:[myNotificationDict objectForKey:@"companyId"]])
                notification.companyId          = [myNotificationDict objectForKey:@"companyId"];
            
            notification.companyName        = [myNotificationDict objectForKey:@"companyName"];
            notification.createdBy          = [myNotificationDict objectForKey:@"createdBy"];
            notification.createdOn          = [myNotificationDict objectForKey:@"createdOn"];
            notification.externalRef        = [myNotificationDict objectForKey:@"externalRef"];
            notification.favNotification    = [NSNumber numberWithBool:NO];
            // notification.fileList           = [myNotificationDict objectForKey:@"fileList"];
            notification.notificationDesc   = [myNotificationDict objectForKey:@"notificationDesc"];
            notification.notificationDetails        = [MRCommon archiveDictionaryToData:[myNotificationDict objectForKey:@"notificationDetails"] forKey:@"notificationDetails"];
            //[myNotificationDict objectForKey:@"notificationDetails"];
            
            if (![MRCommon isStringEmpty:[myNotificationDict objectForKey:@"notificationId"]])
                notification.notificationId     = [myNotificationDict objectForKey:@"notificationId"];
            
            notification.notificationName   = [myNotificationDict objectForKey:@"notificationName"];
            notification.readNotification   = [NSNumber numberWithBool:NO];
            notification.status             = [myNotificationDict objectForKey:@"status"];
            // notification.therapeuticDropDownValues     = [myNotificationDict objectForKey:@"therapeuticDropDownValues"];
            
            if (![MRCommon isStringEmpty:[myNotificationDict objectForKey:@"therapeuticId"]])
                notification.therapeuticId      = [myNotificationDict objectForKey:@"therapeuticId"];
            
            notification.therapeuticName    = [myNotificationDict objectForKey:@"therapeuticName"];
            
            //        if (![MRCommon isStringEmpty:[myNotificationDict objectForKey:@"totalConvertedToAppointment"]])
            //        notification.totalConvertedToAppointment    = [myNotificationDict objectForKey:@"totalConvertedToAppointment"];
            //
            //        if (![MRCommon isStringEmpty:[myNotificationDict objectForKey:@"totalPendingNotifcation"]])
            //        notification.totalPendingNotifcation        = [myNotificationDict objectForKey:@"totalPendingNotifcation"];
            //        if (![MRCommon isStringEmpty:[myNotificationDict objectForKey:@"totalSentNotification"]])
            //        notification.totalSentNotification      = [myNotificationDict objectForKey:@"totalSentNotification"];
            //
            //        if (![MRCommon isStringEmpty:[myNotificationDict objectForKey:@"totalViewedNotifcation"]])
            //        notification.totalViewedNotifcation     = [myNotificationDict objectForKey:@"totalViewedNotifcation"];
            
            if (![MRCommon isStringEmpty:[myNotificationDict objectForKey:@"typeId"]])
                notification.typeId         = [myNotificationDict objectForKey:@"typeId"];
            
            notification.updatedBy      = [myNotificationDict objectForKey:@"updatedBy"];
            notification.updatedOn      = [myNotificationDict objectForKey:@"updatedOn"];
            notification.validUpto      = [myNotificationDict objectForKey:@"validUpto"];
        }
    }
    
    [[MRDataManger sharedManager] saveContext];
    [MRDefaults setObject:[NSDate date] forKey:kNotificationFetchedDate];
}

+ (BOOL)getObjectDataExistance:(NSString*)managedObject
{
    return ([[MRDataManger sharedManager] countOfObjects:managedObject] == 0) ? NO : YES;
}

+ (void)getRoles:(void (^)(NSArray *fetchList))objectsList
{
    NSArray *rolesList = [[MRDataManger sharedManager] fetchObjectList:kRoleEntity];
    NSMutableArray *array = [NSMutableArray array];
    
    for (MRRole *obj in rolesList)
    {
        NSMutableDictionary *myRoledict = [NSMutableDictionary dictionary];
        
        [myRoledict setObject:obj.roleId  forKey:@"roleId"];
        [myRoledict setObject:obj.name  forKey:@"name"];
        [myRoledict setObject:obj.roleDescription  forKey:@"description"];
        [myRoledict setObject:obj.authority  forKey:@"authority"];
        [array addObject:myRoledict];
    }
    
    objectsList(array);
}

+ (void)getNotificationTypes:(void (^)(NSArray *fetchList))objectsList
{
    NSArray *notificationTypeList   = [[MRDataManger sharedManager] fetchObjectList:kNotificationTypeEntity];
    NSMutableArray *array           = [NSMutableArray array];
    for (MRNotificationType *obj in notificationTypeList)
    {
        NSMutableDictionary *myNotificationDict = [NSMutableDictionary dictionary];
        [myNotificationDict setObject:obj.typeId  forKey:@"typeId"];
        [myNotificationDict setObject:obj.typeName  forKey:@"typeName"];
        [myNotificationDict setObject:obj.typeDesc  forKey:@"typeDesc"];
        [array addObject:myNotificationDict];
    }
    
    objectsList(array);
}

+ (void)getTherapeuticArea:(void (^)(NSArray *fetchList))objectsList
{
    NSArray *therapeuticAreaList = [[MRDataManger sharedManager] fetchObjectList:kTherapeuticAreaEntity];
    NSMutableArray *array = [NSMutableArray array];
    
    for (MRTherapeuticArea *obj in therapeuticAreaList)
    {
        NSMutableDictionary *myTherapeuticDict = [NSMutableDictionary dictionary];
        [myTherapeuticDict setObject:obj.therapeuticId  forKey:@"therapeuticId"];
        [myTherapeuticDict setObject:obj.therapeuticDesc  forKey:@"therapeuticName"];
        [myTherapeuticDict setObject:obj.therapeuticDesc  forKey:@"therapeuticDesc"];
        [array addObject:myTherapeuticDict];
    }
    
    objectsList(array);
}

+ (void)getCompanyDetails:(void (^)(NSArray *fetchList))objectsList
{
    NSArray *companyDetailsList = [[MRDataManger sharedManager] fetchObjectList:kCompanyDetailsEntity];
    NSMutableArray *array = [NSMutableArray array];
    
    for (MRCompanyDetails *obj in companyDetailsList)
    {
        NSMutableDictionary *myCompanyDetailsDict = [NSMutableDictionary dictionary];
        [myCompanyDetailsDict setObject:obj.companyId  forKey:@"companyId"];
        [myCompanyDetailsDict setObject:obj.companyName  forKey:@"companyName"];
        [myCompanyDetailsDict setObject:obj.companyDesc  forKey:@"companyDesc"];
        [myCompanyDetailsDict setObject:obj.contactName  forKey:@"contactName"];
        [myCompanyDetailsDict setObject:obj.contactNo  forKey:@"contactNo"];
        [myCompanyDetailsDict setObject:[MRCommon unArchiveDataToDictionary:obj.displayPicture forKey:@"displayPicture"]  forKey:@"displayPicture"];
        [myCompanyDetailsDict setObject:[MRCommon unArchiveDataToDictionary:obj.location forKey:@"location"]  forKey:@"location"];
        [myCompanyDetailsDict setObject:obj.status  forKey:@"status"];
        [array addObject:myCompanyDetailsDict];
    }
    
    objectsList(array);
}

+ (void)getNotifications:(BOOL)isRead
           withFavourite:(BOOL)isFav
   withNotificationsList:(void (^)(NSArray *fetchList))objectsList
{
    NSArray *notificationTypeList   = nil;
    
    if (isFav)
    {
        notificationTypeList   = [[MRDataManger sharedManager] fetchObjectList:kNotificationsEntity predicate:[NSPredicate predicateWithFormat:@"favNotification == %@", [NSNumber numberWithBool:isFav]]];
    }
    else if (isRead)
    {
        notificationTypeList   = [[MRDataManger sharedManager] fetchObjectList:kNotificationsEntity predicate:[NSPredicate predicateWithFormat:@"readNotification == %@", [NSNumber numberWithBool:isRead]]];
    }
    else
    {
        notificationTypeList   = [[MRDataManger sharedManager] fetchObjectList:kNotificationsEntity];
    }
    
    NSMutableArray *array           = [NSMutableArray array];
    for (MRNotifications *notification in notificationTypeList)
    {
          NSMutableDictionary *myNotificationDict = [NSMutableDictionary dictionary];
        
         [myNotificationDict setObject:notification.companyId   forKey:@"companyId"];
         [myNotificationDict setObject:notification.companyName forKey:@"companyName"];
         [myNotificationDict setObject:notification.createdBy   forKey:@"createdBy"];
         [myNotificationDict setObject:notification.createdOn   forKey:@"createdOn"];
         [myNotificationDict setObject:notification.externalRef forKey:@"externalRef"];
         [myNotificationDict setObject:notification.favNotification forKey:@"favNotification"];
         //[myNotificationDict setObject:notification.fileList    forKey:@"fileList"];
         [myNotificationDict setObject:notification.notificationDesc    forKey:@"notificationDesc"];
         [myNotificationDict setObject:[MRCommon unArchiveDataToDictionary:notification.notificationDetails forKey:@"notificationDetails"] forKey:@"notificationDetails"];
         [myNotificationDict setObject:notification.notificationId  forKey:@"notificationId"];
         [myNotificationDict setObject:notification.notificationName    forKey:@"notificationName"];
         [myNotificationDict setObject:notification.readNotification    forKey:@"readNotification"];;
         [myNotificationDict setObject:notification.status  forKey:@"status"];
       //  [myNotificationDict setObject:notification.therapeuticDropDownValues   forKey:@"therapeuticDropDownValues"];
         [myNotificationDict setObject:notification.therapeuticId   forKey:@"therapeuticId"];
         [myNotificationDict setObject:notification.therapeuticName forKey:@"therapeuticName"];
//         [myNotificationDict setObject:notification.totalConvertedToAppointment forKey:@"totalConvertedToAppointment"];
//         [myNotificationDict setObject:notification.totalPendingNotifcation forKey:@"totalPendingNotifcation"];
//         [myNotificationDict setObject:notification.totalSentNotification   forKey:@"totalSentNotification"];
//         [myNotificationDict setObject:notification.totalViewedNotifcation  forKey:@"totalViewedNotifcation"];
         [myNotificationDict setObject:notification.typeId  forKey:@"typeId"];
         [myNotificationDict setObject:notification.updatedBy   forKey:@"updatedBy"];
         [myNotificationDict setObject:notification.updatedOn   forKey:@"updatedOn"];
         [myNotificationDict setObject:notification.validUpto   forKey:@"validUpto"];
         [array addObject:myNotificationDict];
    }
    
    objectsList(array);
}

+ (void)getNotificationsByFilter:(NSString*)companyName
           withTherapeuticName:(NSString*)therapeuticName
   withNotificationsList:(void (^)(NSArray *fetchList))objectsList
{
    NSArray *notificationsList   = nil;
    
    if (![MRCommon isStringEmpty:companyName] && ![MRCommon isStringEmpty:therapeuticName])
    {
        notificationsList   = [[MRDataManger sharedManager] fetchObjectList:kNotificationsEntity predicate:[NSPredicate predicateWithFormat:@"companyName == %@ AND therapeuticName == %@", companyName,therapeuticName]];
    }
    else if (![MRCommon isStringEmpty:companyName])
    {
        notificationsList   = [[MRDataManger sharedManager] fetchObjectList:kNotificationsEntity predicate:[NSPredicate predicateWithFormat:@"companyName == %@", companyName]];
    }
    else if (![MRCommon isStringEmpty:therapeuticName])
    {
        notificationsList   = [[MRDataManger sharedManager] fetchObjectList:kNotificationsEntity predicate:[NSPredicate predicateWithFormat:@"therapeuticName == %@", therapeuticName]];
    }
    
    NSMutableArray *array           = [NSMutableArray array];
    
    for (MRNotifications *notification in notificationsList)
    {
        NSMutableDictionary *myNotificationDict = [NSMutableDictionary dictionary];
        
        [myNotificationDict setObject:notification.companyId   forKey:@"companyId"];
        [myNotificationDict setObject:notification.companyName forKey:@"companyName"];
        [myNotificationDict setObject:notification.createdBy   forKey:@"createdBy"];
        [myNotificationDict setObject:notification.createdOn   forKey:@"createdOn"];
        [myNotificationDict setObject:notification.externalRef forKey:@"externalRef"];
        [myNotificationDict setObject:notification.favNotification forKey:@"favNotification"];
//        [myNotificationDict setObject:notification.fileList    forKey:@"fileList"];
        [myNotificationDict setObject:notification.notificationDesc    forKey:@"notificationDesc"];
        [myNotificationDict setObject:[MRCommon unArchiveDataToDictionary:notification.notificationDetails forKey:@"notificationDetails"] forKey:@"notificationDetails"];
        [myNotificationDict setObject:notification.notificationId  forKey:@"notificationId"];
        [myNotificationDict setObject:notification.notificationName    forKey:@"notificationName"];
        [myNotificationDict setObject:notification.readNotification    forKey:@"readNotification"];;
        [myNotificationDict setObject:notification.status  forKey:@"status"];
//        [myNotificationDict setObject:notification.therapeuticDropDownValues   forKey:@"therapeuticDropDownValues"];
        [myNotificationDict setObject:notification.therapeuticId   forKey:@"therapeuticId"];
        [myNotificationDict setObject:notification.therapeuticName forKey:@"therapeuticName"];
//        [myNotificationDict setObject:notification.totalConvertedToAppointment forKey:@"totalConvertedToAppointment"];
//        [myNotificationDict setObject:notification.totalPendingNotifcation forKey:@"totalPendingNotifcation"];
//        [myNotificationDict setObject:notification.totalSentNotification   forKey:@"totalSentNotification"];
//        [myNotificationDict setObject:notification.totalViewedNotifcation  forKey:@"totalViewedNotifcation"];
        [myNotificationDict setObject:notification.typeId  forKey:@"typeId"];
        [myNotificationDict setObject:notification.updatedBy   forKey:@"updatedBy"];
        [myNotificationDict setObject:notification.updatedOn   forKey:@"updatedOn"];
        [myNotificationDict setObject:notification.validUpto   forKey:@"validUpto"];
        [array addObject:myNotificationDict];
    }
    
    objectsList(array);
}

+ (void)updateNotifiction:(NSNumber*)notificationID
       userFavouriteSatus:(BOOL)isFav
           userReadStatus:(BOOL)isRead
          withSavedStatus:(void (^)(BOOL isScuccess))savedStatus
{
    BOOL isSuccess = YES;
    
     NSArray *notificationTypeList = [[MRDataManger sharedManager] fetchObjectList:kNotificationsEntity predicate:[NSPredicate predicateWithFormat:@"notificationId == %@", notificationID]];

    MRNotifications *notification = notificationTypeList.firstObject;
    
    if (isFav)
    {
        notification.favNotification = [NSNumber numberWithBool:isFav];
    }
    else if (isRead)
    {
        notification.readNotification = [NSNumber numberWithBool:isRead];
    }
    
    [[MRDataManger sharedManager] saveContext];

    savedStatus(isSuccess);
}

+ (void)updateNotifictionFeedback:(NSNumber*)notificationID
       userFeedback:(BOOL)feedback
          withSavedStatus:(void (^)(BOOL isScuccess))savedStatus
{
    BOOL isSuccess = YES;
    
    NSArray *notificationTypeList = [[MRDataManger sharedManager] fetchObjectList:kNotificationsEntity predicate:[NSPredicate predicateWithFormat:@"notificationId == %@", notificationID]];
    
    MRNotifications *notification = notificationTypeList.firstObject;
    
    {
        notification.feedback = [NSNumber numberWithBool:YES];
    }
    
    [[MRDataManger sharedManager] saveContext];
    
    savedStatus(isSuccess);
}


+ (void)cleanDatabaseOnLogout
{
    [[MRDataManger sharedManager] removeAllObjects:kNotificationsEntity];
}
@end

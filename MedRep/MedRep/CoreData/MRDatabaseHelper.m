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
#import "MRContact.h"
#import "MRSuggestedContact.h"
#import "MRGroup.h"
#import "MRGroupPost.h"
#import "MrGroupChildPost.h"
#import "AppDelegate.h"
#import "NSDate+Utilities.h"
#import "MRSharePost.h"
#import "MRPostedReplies.h"
#import "MRTransformPost.h"
#import "MRAppControl.h"
#import "MRWebserviceHelper.h"
#import "MRConstants.h"
#import "NSData+Base64Additions.h"

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

+ (void)addSuggestedContacts:(NSArray*)contacts {
    for (NSDictionary *myDict in contacts) {
        MRSuggestedContact *contact  = (MRSuggestedContact*)[[MRDataManger sharedManager] createObjectForEntity:kSuggestedContactEntity];
        contact.contactId = [[myDict objectForKey:@"id"] integerValue];
        contact.name = [myDict objectForKey:@"name"];
        contact.profilePic  = [myDict objectForKey:@"profile_pic"];
        contact.role      = [myDict objectForKey:@"role"];
    }
    [[MRDataManger sharedManager] saveContext];
}

//{"name":"John Doe","postText":"Guys, these drugs look promising!","likes":10,"comments":23,"shares":3,"profile_pic":"","post_pic":"medicine.jpg"}
+ (void)addGroups:(NSArray*)groups {
    for (NSDictionary *myDict in groups) {
        MRGroup *group  = (MRGroup*)[[MRDataManger sharedManager] createObjectForEntity:kGroupEntity];
        group.groupId = [[myDict objectForKey:@"id"] integerValue];
        group.name = [myDict objectForKey:@"name"];
        group.groupPicture = [myDict objectForKey:@"groupPicture"];
    }
    [[MRDataManger sharedManager] saveContext];
}
+ (void)addGroupChildPost:(MRGroupPost*)post withPostDict:(NSDictionary *)myDict{
   
        MrGroupChildPost *postChild  = (MrGroupChildPost*)[[MRDataManger sharedManager] createObjectForEntity:kGroupChildPostEntity];
    
    
        postChild.postId = [myDict objectForKey:@"postID"];
        postChild.postPic = [myDict objectForKey:@"post_pic"];
        postChild.postText = [myDict objectForKey:@"postText"];
    
    [post addReplyPostObject:postChild];
    
    [[MRDataManger sharedManager] saveContext];
}
+(MRGroupPost *)getGroupPostForPostID:(NSNumber *)groupId{
    
    MRGroupPost* contact = [[MRDataManger sharedManager] fetchObject:kGroupPostEntity predicate:[NSPredicate predicateWithFormat:@"groupPostId == %@",groupId]];
    return contact;

}
+(NSNumber *)getLastgroupPostID {
    
    NSArray *fetchAllGroupPosts = [[MRDataManger sharedManager] fetchObjectList:kGroupPostEntity];
    NSNumber *grpPostID = [[NSNumber alloc]initWithInt:0];
    if (fetchAllGroupPosts.count>0) {
        MRGroupPost *post = [fetchAllGroupPosts lastObject];
        grpPostID  = post.groupPostId;
        
    }
    return grpPostID;
}
+ (void)addGroupPosts:(NSArray*)posts {
    for (NSDictionary *myDict in posts) {
        MRGroupPost *post  = (MRGroupPost*)[[MRDataManger sharedManager] createObjectForEntity:kGroupPostEntity];
        
        
       
        if ([myDict objectForKey:@"id"]!=NULL) {
            post.groupPostId = [MRDatabaseHelper convertStringToNSNumber:[myDict objectForKey:@"id"]];

        }else {
                        int currentpostID = [MRDatabaseHelper getLastgroupPostID].intValue;
            currentpostID = currentpostID+1;;
            post.groupPostId = [NSNumber numberWithInt: currentpostID];

        }
        
        post.postPic = [myDict objectForKey:@"post_pic"];
        post.postText = [myDict objectForKey:@"postText"];
        
        NSDate *currentDate = nil;
        id dateValue = [myDict objectForKey:@"postedOn"];
        
        if ([dateValue isKindOfClass:[NSString class]]) {
            currentDate = [NSDate convertStringToNSDate:dateValue dateFormat:kDefaultDateFormat];
        } else {
            currentDate = dateValue;
        }
        post.postedOn = currentDate;
        
        post.numberOfComments = [MRDatabaseHelper convertStringToNSNumber:[myDict objectForKey:@"comments"]];
        post.numberOfLikes = [MRDatabaseHelper convertStringToNSNumber:[myDict objectForKey:@"likes"]];
        post.numberOfShares = [MRDatabaseHelper convertStringToNSNumber:[myDict objectForKey:@"shares"]];
        NSInteger contactId = [[myDict objectForKey:@"contactId"] integerValue];
        if (contactId) {
            MRContact* contact = [MRDatabaseHelper getContactForId:contactId];
            if (contact) {
                [post setContact:contact];
            }
        }
        NSInteger groupId = [[myDict objectForKey:@"groupId"] integerValue];
        if (groupId) {
            MRGroup* group = [MRDatabaseHelper getGroupForId:groupId];
            if (group) {
                [post setGroup:group];
            }
        }
    }
    [[MRDataManger sharedManager] saveContext];
}

+ (NSNumber*)convertStringToNSNumber:(id)value {
    NSNumber *convertedValue = [NSNumber numberWithLong:0];
    if ([value isKindOfClass:[NSString class]]) {
        NSString *tempValue = value;
        convertedValue = [NSNumber numberWithLong:tempValue.longLongValue];
    }
    
    return convertedValue;
}

+ (void)getContacts:(WebServiceResponseHandler)responseHandler {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getContactListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            [MRDatabaseHelper filterContactResponse:responce andResponseHandler:responseHandler];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getContactListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status)
                     {
                         [MRDatabaseHelper filterContactResponse:responce andResponseHandler:responseHandler];
                     } else
                     {
                         NSArray *erros =  [details componentsSeparatedByString:@"-"];
                         if (erros.count > 0)
                         [MRCommon showAlert:[erros lastObject] delegate:nil];
                     }
                 }];
             }];
        }
        else
        {
            NSArray *erros =  [details componentsSeparatedByString:@"-"];
            if (erros.count > 0)
            [MRCommon showAlert:[erros lastObject] delegate:nil];
        }
    }];
}

+ (void)filterContactResponse:(NSDictionary*)response andResponseHandler:(WebServiceResponseHandler) responseHandler {
    id result = [MRWebserviceHelper parseNetworkResponse:MRContact.class
                                                 andData:[response valueForKey:@"Responce"]];
    if (responseHandler != nil) {
        NSArray *tempResults = result;
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:true];
        result = [tempResults sortedArrayUsingDescriptors:@[sortDescriptor]];
        responseHandler(result);
    }
}

+ (MRContact*)getContactForId:(NSInteger)contactId {
    MRContact* contact = [[MRDataManger sharedManager] fetchObject:kContactEntity predicate:[NSPredicate predicateWithFormat:@"contactId == %@",[NSNumber numberWithInteger:contactId]]];
    return contact;
}

+ (NSArray*)getGroupsForIds:(NSArray*)groupIds {
    NSMutableArray* groups = [NSMutableArray array];
    for (id groupIdObject in groupIds) {
        NSInteger groupId = [groupIdObject integerValue];
        MRGroup* group = [MRDatabaseHelper getGroupForId:groupId];
        if (group) {
            [groups addObject:group];
        }
    }
    return groups;
}

+ (MRGroup*)getGroupForId:(NSInteger)groupId {
    MRGroup* group = [[MRDataManger sharedManager] fetchObject:kGroupEntity predicate:[NSPredicate predicateWithFormat:@"groupId == %@",[NSNumber numberWithInteger:groupId]]];
    return group;
}

+ (NSArray*)getGroups {
    NSArray *groups = [[MRDataManger sharedManager] fetchObjectList:kGroupEntity];
    return groups;
}

+ (NSArray*)getSuggestedContacts {
    NSArray *groups = [[MRDataManger sharedManager] fetchObjectList:kSuggestedContactEntity];
    return groups;
}

+ (NSArray*)getObjectsForType:(NSString*)entityName andPredicate:(NSPredicate*)predicate {
    NSArray *objects = nil;
    
    if (predicate != nil) {
        objects = [[MRDataManger sharedManager] fetchObjectList:entityName
                                                      predicate:predicate];
    } else {
        objects = [[MRDataManger sharedManager] fetchObjectList:entityName];
    }
    
    return objects;
}
+(NSArray *)getContactListForContactID:(int64_t)contactID {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %d",contactID];
    
    NSArray *contacts = [[MRDataManger sharedManager] fetchObjectList:kContactEntity predicate:predicate];
    return contacts;
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

+ (NSArray*)getShareArticles {
    NSArray *articles = [[MRDataManger sharedManager] fetchObjectList:kMRSharePost attributeName:@"postedOn" sortOrder:SORT_ORDER_DESCENDING];
    return articles;
}

+ (void)shareAnArticle:(MRTransformPost*)transformPost {
    NSInteger sharePostId = 1;
    
    NSArray *articles = [[MRDataManger sharedManager] fetchObjectList:kMRSharePost attributeName:@"postedOn" sortOrder:SORT_ORDER_DESCENDING];
    
    if (articles != nil && articles.count > 0) {
        MRSharePost *sharePost = articles.firstObject;
        sharePostId = sharePost.sharePostId.integerValue;
    }
    
    MRDataManger *dbManager = [MRDataManger sharedManager];
    
    NSManagedObjectContext *context = [dbManager getNewPrivateManagedObjectContext];
    
    MRSharePost *post  = (MRSharePost*)[dbManager createObjectForEntity:kMRSharePost
                                                              inContext:context];
    post.sharePostId = [NSNumber numberWithLong:sharePostId];
    post.postedOn = [NSDate date];
    post.likesCount = [NSNumber numberWithLong:0];
    post.commentsCount = [NSNumber numberWithLong:0];
    post.shareCount = [NSNumber numberWithLong:0];
    
    post.sharedByProfileId = [NSNumber numberWithLong:0];
    
    MRAppControl *appControl = [MRAppControl sharedHelper];
    NSDictionary *userDetailsDict = appControl.userRegData;
    post.sharedByProfileName = [userDetailsDict objectOrNilForKey:@"displayName"];
    
    id profilePicData = [userDetailsDict objectForKey:KProfilePicture];
    if (profilePicData != nil && [profilePicData isKindOfClass:[NSDictionary class]])
    {
        profilePicData = [profilePicData objectForKey:@"data"];
    }
    
    if (profilePicData != nil) {
        if ([profilePicData isKindOfClass:[NSString class]]) {
            post.shareddByProfilePic = [NSData decodeBase64ForString:profilePicData];
        } else {
            post.shareddByProfilePic = profilePicData;
        }
    }
    
    post.parentTransformPostId = transformPost.transformPostId;
    post.titleDescription = transformPost.titleDescription;
    post.shortText = transformPost.shortArticleDescription;
    post.detailedText = transformPost.detailedDescription;
    post.contentType = transformPost.contentType;
    post.url = transformPost.url;
    post.source = @"Transform";
    
    // Create a child post as well to show in activities section
    MRSharePost *childPost = (MRSharePost*)[dbManager createObjectForEntity:kMRSharePost
                                                                  inContext:context];
    childPost.parentSharePostId = [NSNumber numberWithLong:post.sharePostId.longValue];
    childPost.detailedText = [NSString stringWithFormat:@"Article is shared by %@ on %@", post.sharedByProfileName, [post.postedOn stringWithFormat:kYYYYMMDDFormatWithHyphen]];
    childPost.contentType = [NSNumber numberWithInteger:kTransformContentTypeText];
    
    [dbManager dbSaveInContext:context];
}

+ (NSArray*)getTransformArticles {
    NSArray *articles = [[MRDataManger sharedManager] fetchObjectList:kMRTransformPost attributeName:@"postedOn" sortOrder:SORT_ORDER_DESCENDING];
    return articles;
}

+ (void)addTransformArticles:(NSArray*)posts {
    for (NSDictionary *myDict in posts) {
        MRTransformPost *post  = (MRTransformPost*)[[MRDataManger sharedManager] createObjectForEntity:kMRTransformPost];
        post.transformPostId = [MRDatabaseHelper convertStringToNSNumber:[myDict objectForKey:@"transformPostId"]];
        post.url = [myDict objectForKey:@"url"];
        post.contentType = [myDict objectForKey:@"contextType"];
        post.detailedDescription = [myDict objectForKey:@"detailedDescription"];
        post.titleDescription = [myDict objectForKey:@"titleDescription"];
        post.source = [myDict objectForKey:@"source"];
        post.shortArticleDescription = [myDict objectForKey:@"shortArticleDescription"];
        
        NSDate *currentDate = nil;
        id dateValue = [myDict objectForKey:@"postedOn"];
        
        if ([dateValue isKindOfClass:[NSString class]]) {
            currentDate = [NSDate convertStringToNSDate:dateValue dateFormat:kDefaultDateFormat];
        } else {
            currentDate = dateValue;
        }
        post.postedOn = currentDate;
    }
    [[MRDataManger sharedManager] saveContext];
}

@end

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
#import "MRProfile.h"
#import "MRWorkExperience.h"
#import "MRInterestArea.h"
#import "EducationalQualifications.h"
#import "MRPublications.h"
#import "MRPendingRecordsCount.h"
#import "AddressInfo.h"
#import "ContactInfo.h"

static MRDatabaseHelper *sharedDataManager = nil;

@implementation MRDatabaseHelper

NSString* const kNewsAndUpdatesAPIMethodName = @"getNewsAndUpdates";
NSString* const kNewsAndTransformAPIMethodName = @"getNewsAndTransform";

+ (MRDatabaseHelper *)sharedHelper
{
    static dispatch_once_t once;
    static MRDatabaseHelper * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;

}

+ (NSString*)getOAuthErrorCode:(NSDictionary*)response {
    NSString *errorCode = [response objectForKey:@"oauth2ErrorCode"];
    if (errorCode == nil || errorCode.length == 0) {
        id tempErrorCode = [response objectForKey:@"Responce"];
        if (tempErrorCode != nil) {
            if ([tempErrorCode isKindOfClass:[NSArray class]]) {
                NSArray *tempArray = (NSArray*)tempErrorCode;
                NSDictionary *tempObject = tempArray.firstObject;
                errorCode = [tempObject objectForKey:@"oauth2ErrorCode"];
            } else if ([tempErrorCode isKindOfClass:[NSDictionary class]]) {
                NSDictionary *tempObject = tempErrorCode;
                errorCode = [tempObject objectForKey:@"oauth2ErrorCode"];;
            }
        }
    }
    return errorCode;
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

+ (void)addGroupChildPost:(MRGroupPost*)post withPostDict:(NSDictionary *)myDict{
   
        MrGroupChildPost *postChild  = (MrGroupChildPost*)[[MRDataManger sharedManager] createObjectForEntity:kGroupChildPostEntity];
    
    
        postChild.postId = [myDict objectForKey:@"postID"];
        postChild.postPic = [myDict objectForKey:@"post_pic"];
        postChild.postText = [myDict objectForKey:@"postText"];
    
    [post addReplyPostObject:postChild];
    
    [[MRDataManger sharedManager] saveContext];
}
+(MRSharePost *)getGroupPostForPostID:(NSNumber *)postId{
    
    MRGroupPost* contact = [[MRDataManger sharedManager] fetchObject:kGroupPostEntity predicate:[NSPredicate predicateWithFormat:@"groupPostId == %@",postId]];
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

+ (NSNumber*)convertStringToNSNumber:(id)value {
    NSNumber *convertedValue = [NSNumber numberWithLong:0];
    if ([value isKindOfClass:[NSString class]]) {
        NSString *tempValue = value;
        convertedValue = [NSNumber numberWithLong:tempValue.longLongValue];
    }
    
    return convertedValue;
}

+ (void)makeServiceCallForGroupsFetch:(BOOL)status details:(NSString*)details
                             response:(NSDictionary*)response
                     andResponseHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon stopActivityIndicator];
    if (status)
    {
        [MRDatabaseHelper filterGroupResponse:response andResponseHandler:responseHandler];
    }
    else {
        NSString *errorCode = [MRDatabaseHelper getOAuthErrorCode:response];
        if ([errorCode isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getGroupListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status)
                     {
                         [MRDatabaseHelper filterGroupResponse:responce andResponseHandler:responseHandler];
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
    }
}

+ (void)filterGroupResponse:(NSDictionary*)response andResponseHandler:(WebServiceResponseHandler) responseHandler {
    id result = [MRWebserviceHelper parseNetworkResponse:MRGroup.class
                                                 andData:[response valueForKey:@"Responce"]];
    if (responseHandler != nil) {
        NSArray *tempResults = [[MRDataManger sharedManager] fetchObjectList:kGroupEntity];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"group_name" ascending:true];
        result = [tempResults sortedArrayUsingDescriptors:@[sortDescriptor]];
        responseHandler(result);
    }
}

+ (void)makeServiceCallForFetchingGroups:(BOOL)status details:(NSString*)details
                             response:(NSDictionary*)response
                   andResponseHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon stopActivityIndicator];
    if (status)
    {
        [MRDatabaseHelper filterRootLevelGroupResponse:response andResponseHandler:responseHandler];
    }
    else {
        NSString *errorCode = [MRDatabaseHelper getOAuthErrorCode:response];
        if ([errorCode isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getGroupListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status)
                     {
                         [MRDatabaseHelper filterRootLevelGroupResponse:responce
                                                     andResponseHandler:responseHandler];
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
    }
}

+ (void)filterRootLevelGroupResponse:(NSDictionary*)response andResponseHandler:(WebServiceResponseHandler) responseHandler {
    if (response != nil && [response allKeys].count > 0) {
        id pendingGroups = [response objectOrNilForKey:@"pendingGroups"];
        if (pendingGroups != nil) {
            MRDataManger *dbManager = [MRDataManger sharedManager];
            NSManagedObjectContext *context = [dbManager getNewPrivateManagedObjectContext];
            
            NSArray *pendingRecordsCount = [[MRDataManger sharedManager] fetchObjectList:kPendingRecordsCountEntity
                                                                               inContext:context];
            
            MRManagedObject *entity = nil;
            if (pendingRecordsCount == nil) {
                NSString *entityName = NSStringFromClass(MRPendingRecordsCount.class);
                
                NSEntityDescription *entityDescription = [[[dbManager managedObjectModel] entitiesByName] objectForKey:entityName];
                
                entity = [[MRManagedObject alloc] initWithEntity:entityDescription
                                  insertIntoManagedObjectContext:context];
            } else {
                entity = pendingRecordsCount.firstObject;
            }
            
            NSNumber *tempCount = nil;
            if ([pendingGroups isKindOfClass:[NSNumber class]]) {
                tempCount = pendingGroups;
            }
            
            [entity setValue:[NSNumber numberWithLong:tempCount.longValue] forKey:@"pendingGroups"];
            [dbManager dbSaveInContext:context];
        }
        id groups = [response objectOrNilForKey:@"groups"];
        if (groups != nil) {
            id result = [MRWebserviceHelper parseNetworkResponse:MRGroup.class
                                                         andData:groups];
            if (responseHandler != nil) {
                NSArray *tempResults = [[MRDataManger sharedManager] fetchObjectList:kGroupEntity];
                
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"group_name" ascending:true];
                result = [tempResults sortedArrayUsingDescriptors:@[sortDescriptor]];
                responseHandler(result);
            }
        } else {
            if (responseHandler != nil) {
                responseHandler(nil);
            }
        }
    } else {
        if (responseHandler != nil) {
            responseHandler(nil);
        }
    }
}

+ (void)getGroups:(WebServiceResponseHandler)responseHandler {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getGroupListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [[MRDataManger sharedManager] removeAllObjects:kGroupEntity withPredicate:nil];
        [MRDatabaseHelper makeServiceCallForFetchingGroups:status details:details
                                                  response:responce
                                        andResponseHandler:responseHandler];
    }];
}

+ (void)getMoreGroups:(WebServiceResponseHandler)responseHandler {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getAllGroupListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [[MRDataManger sharedManager] removeAllObjects:kGroupEntity withPredicate:nil];
        [MRDatabaseHelper makeServiceCallForGroupsFetch:status details:details
                                               response:responce
                                     andResponseHandler:responseHandler];
    }];
}

+ (void)getSuggestedGroups:(WebServiceResponseHandler)responseHandler {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getSuggestedGroupListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [[MRDataManger sharedManager] removeAllObjects:kGroupEntity withPredicate:nil];
        [MRDatabaseHelper makeServiceCallForGroupsFetch:status details:details
                                                 response:responce
                                       andResponseHandler:responseHandler];
    }];
}

+ (void)getPendingGroups:(WebServiceResponseHandler)responseHandler {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] fetchPendingGroupsListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [[MRDataManger sharedManager] removeAllObjects:kGroupEntity withPredicate:nil];
        [MRDatabaseHelper makeServiceCallForGroupsFetch:status details:details
                                                 response:responce
                                       andResponseHandler:responseHandler];
    }];
}

+ (void)makeServiceCallForContactsFetch:(BOOL)status details:(NSString*)details
                               response:(NSDictionary*)response
                     andResponseHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon stopActivityIndicator];
    if (status)
    {
        [MRDatabaseHelper filterContactResponse:response andResponseHandler:responseHandler];
    }
    else {
        NSString *errorCode = [MRDatabaseHelper getOAuthErrorCode:response];
        
        if ([errorCode isEqualToString:@"invalid_token"])
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
    }
}

+ (void)filterContactResponse:(NSDictionary*)response andResponseHandler:(WebServiceResponseHandler) responseHandler {
    id result = [MRWebserviceHelper parseNetworkResponse:MRContact.class
                                                 andData:[response valueForKey:@"Responce"]];
    if (responseHandler != nil) {
        NSArray *tempResults = [[MRDataManger sharedManager] fetchObjectList:kContactEntity];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:true];
        result = [tempResults sortedArrayUsingDescriptors:@[sortDescriptor]];
        responseHandler(result);
    }
}

+ (void)makeServiceCallForFetchingConnections:(BOOL)status details:(NSString*)details
                               response:(NSDictionary*)response
                     andResponseHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon stopActivityIndicator];
    if (status)
    {
        [MRDatabaseHelper filterRootLevelContactResponse:response andResponseHandler:responseHandler];
    }
    else {
        NSString *errorCode = [MRDatabaseHelper getOAuthErrorCode:response];
        
        if ([errorCode isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getContactListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status)
                     {
                         [MRDatabaseHelper filterRootLevelContactResponse:responce andResponseHandler:responseHandler];
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
    }
}

+ (void)filterRootLevelContactResponse:(NSDictionary*)response andResponseHandler:(WebServiceResponseHandler) responseHandler {
    if (response != nil && [response allKeys].count > 0) {
        id tempValue = [response valueForKey:@"result"];
        if (tempValue != nil && [tempValue isKindOfClass:[NSDictionary class]]) {
            id pendingConnections = [tempValue objectOrNilForKey:@"pendingConnections"];
            if (pendingConnections != nil) {
                MRDataManger *dbManager = [MRDataManger sharedManager];
                NSManagedObjectContext *context = [dbManager getNewPrivateManagedObjectContext];
                
                NSArray *pendingRecordsCount = [[MRDataManger sharedManager] fetchObjectList:kPendingRecordsCountEntity
                                                                                   inContext:context];
                
                MRManagedObject *entity = nil;
                if (pendingRecordsCount == nil) {
                    NSString *entityName = NSStringFromClass(MRPendingRecordsCount.class);
                    
                    NSEntityDescription *entityDescription = [[[dbManager managedObjectModel] entitiesByName] objectForKey:entityName];
                    
                    entity = [[MRManagedObject alloc] initWithEntity:entityDescription
                                      insertIntoManagedObjectContext:context];
                } else {
                    entity = pendingRecordsCount.firstObject;
                }
                
                NSNumber *tempCount = nil;
                if ([pendingConnections isKindOfClass:[NSNumber class]]) {
                    tempCount = pendingConnections;
                }
                
                [entity setValue:[NSNumber numberWithLong:tempCount.longValue] forKey:@"pendingConnections"];
                [dbManager dbSaveInContext:context];
            }
            id myContacts = [tempValue objectOrNilForKey:@"myContacts"];
            if (myContacts != nil && [myContacts isKindOfClass:[NSArray class]]) {
                id result = [MRWebserviceHelper parseNetworkResponse:MRContact.class
                                                             andData:myContacts];
                if (responseHandler != nil) {
                    NSArray *tempResults = [[MRDataManger sharedManager] fetchObjectList:kContactEntity];
                    
                    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:true];
                    result = [tempResults sortedArrayUsingDescriptors:@[sortDescriptor]];
                    responseHandler(result);
                }
            } else {
                if (responseHandler != nil) {
                    responseHandler(nil);
                }
            }
        } else {
            if (responseHandler != nil) {
                responseHandler(nil);
            }
        }
    } else {
        if (responseHandler != nil) {
            responseHandler(nil);
        }
    }
}

+ (void)getContacts:(WebServiceResponseHandler)responseHandler {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getContactListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [[MRDataManger sharedManager] removeAllObjects:kContactEntity withPredicate:nil];
        [MRDatabaseHelper makeServiceCallForFetchingConnections:status details:details
                                                 response:responce
                                       andResponseHandler:responseHandler];
    }];
}

+ (void)getContactsByCity:(NSString*)city responseHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getAllContactsByCityListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [[MRDataManger sharedManager] removeAllObjects:kContactEntity withPredicate:nil];
        [MRDatabaseHelper makeServiceCallForContactsFetch:status details:details
                                                 response:responce
                                       andResponseHandler:responseHandler];
    }];
}

+ (void)getSuggestedContacts:(WebServiceResponseHandler)responseHandler {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getSuggestedContactListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [[MRDataManger sharedManager] removeAllObjects:kContactEntity withPredicate:nil];
        [MRDatabaseHelper makeServiceCallForContactsFetch:status details:details
                                                 response:responce
                                       andResponseHandler:responseHandler];
    }];
}

+ (void)getPendingContacts:(WebServiceResponseHandler)responseHandler {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] fetchPendingConnectionsListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRDatabaseHelper makeServiceCallForContactsFetch:status details:details
                                                 response:responce
                                       andResponseHandler:responseHandler];
    }];
}

+ (void)getPendingGroupMembers:(NSNumber*)gid
            andResponseHandler:(WebServiceResponseHandler)responseHandler {
    NSString *groupId = @"";
    if (gid != nil) {
        groupId = gid.stringValue;
    }
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] fetchPendingMembersList:groupId withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [[MRDataManger sharedManager] removeAllObjects:kContactEntity withPredicate:nil];
        [MRDatabaseHelper makeServiceCallForContactsFetch:status details:details
                                                 response:responce
                                       andResponseHandler:responseHandler];
    }];
}

+ (void)getContactsBySearchString:(NSString*)searchText
               andResponseHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon showActivityIndicator:@"searching..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getSearchContactList:searchText withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [[MRDataManger sharedManager] removeAllObjects:kContactEntity withPredicate:nil];
        [MRDatabaseHelper makeServiceCallForContactsFetch:status details:details
                                                 response:responce
                                       andResponseHandler:responseHandler];
    }];
}

+ (void)getGroupMemberStatus:(WebServiceResponseHandler)responseHandler {
//    [MRCommon showActivityIndicator:@"Requesting..."];
//    [[MRWebserviceHelper sharedWebServiceHelper] getGroupMembersStatuswithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
//        [MRCommon stopActivityIndicator];
//        if (status)
//        {
//            NSArray *responseArray = responce[@"Responce"];
//            groupsArrayObj = [NSMutableArray array];
//            groupMemberArray = [NSMutableArray array];
//            
//            for (NSDictionary *memberDict in responseArray) {
//                MRGroup *groupObj = [[MRGroup alloc] initWithDict:memberDict];
//                [groupsArrayObj addObject:groupObj];
//                if ([groupObj.group_name isEqualToString:self.mainGroupObj.group_name]) {
//                    groupMemberArray = groupObj.member;
//                }
//            }
//            [self.collectionView reloadData];
//        }
//        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
//        {
//            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
//             {
//                 [MRCommon savetokens:responce];
//                 [[MRWebserviceHelper sharedWebServiceHelper] getGroupMembersStatuswithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
//                     [MRCommon stopActivityIndicator];
//                     if (status)
//                     {
//                         NSArray *responseArray = responce[@"Responce"];
//                         groupsArrayObj = [NSMutableArray array];
//                         groupMemberArray = [NSMutableArray array];
//                         
//                         for (NSDictionary *memberDict in responseArray) {
//                             MRGroupObject *groupObj = [[MRGroupObject alloc] initWithDict:memberDict];
//                             [groupsArrayObj addObject:groupObj];
//                             if ([groupObj.group_name isEqualToString:self.mainGroupObj.group_name]) {
//                                 groupMemberArray = groupObj.member;
//                             }
//                         }
//                         [self.collectionView reloadData];
//                     }else
//                     {
//                         NSArray *erros =  [details componentsSeparatedByString:@"-"];
//                         if (erros.count > 0)
//                             [MRCommon showAlert:[erros lastObject] delegate:nil];
//                     }
//                 }];
//             }];
//        }
//        else
//        {
//            NSArray *erros =  [details componentsSeparatedByString:@"-"];
//            if (erros.count > 0)
//                [MRCommon showAlert:[erros lastObject] delegate:nil];
//        }
//    }];
}

+ (void)filterGroupDetailsResponse:(NSDictionary*)response andResponseHandler:(WebServiceResponseHandler) responseHandler {
    id result = [MRWebserviceHelper parseNetworkResponse:MRGroup.class
                                                 andData:[response valueForKey:@"Responce"]];
    if (responseHandler != nil) {
        NSArray *tempResults = [[MRDataManger sharedManager] fetchObjectList:kGroupEntity];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"group_id" ascending:true];
        result = [tempResults sortedArrayUsingDescriptors:@[sortDescriptor]];
        responseHandler(result);
    }
}

+ (void)makeServiceCallForGroupDetailsFetch:(NSInteger)groupId status:(BOOL)status details:(NSString*)details
                               response:(NSDictionary*)response
                     andResponseHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon stopActivityIndicator];
    if (status)
    {
        [MRDatabaseHelper filterGroupDetailsResponse:response andResponseHandler:responseHandler];
    }
    else {
        NSString *errorCode = [MRDatabaseHelper getOAuthErrorCode:response];
        if ([errorCode isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getGroupMembersStatusWithId:groupId withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status)
                     {
                         [MRDatabaseHelper filterGroupDetailsResponse:responce andResponseHandler:responseHandler];
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
    }
}

+ (void)getGroupMemberStatusWithId:(NSInteger)groupId
                        andHandler:(WebServiceResponseHandler)responseHandler {
    
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getGroupMembersStatusWithId:groupId withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRDatabaseHelper makeServiceCallForGroupDetailsFetch:groupId status:status details:details
                                                 response:responce
                                       andResponseHandler:responseHandler];
    }];
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
    [[MRDataManger sharedManager] removeAllObjects:kNotificationsEntity withPredicate:nil];
}

+ (NSArray*)getShareArticles {
    NSArray *articles = [[MRDataManger sharedManager] fetchObjectList:kMRSharePost attributeName:@"postedOn" sortOrder:SORT_ORDER_DESCENDING];
    return articles;
}

+ (void)shareAnArticle:(NSInteger)postType transformPost:(MRTransformPost*)transformPost
           withHandler:(WebServiceResponseHandler)handler {
    NSDictionary *dataDict = @{@"topic_id" : transformPost.transformPostId,
                               @"postMessage" :
                                     @{@"postType" : [NSNumber numberWithInteger:postType]}
                              };
    
    
    [MRDatabaseHelper postANewTopic:dataDict withHandler:handler];
    
    
//    NSInteger sharePostId = [[NSDate date] timeIntervalSince1970];
//    
//    MRDataManger *dbManager = [MRDataManger sharedManager];
//    
//    NSManagedObjectContext *context = [dbManager getNewPrivateManagedObjectContext];
//    
//    MRSharePost *post  = (MRSharePost*)[dbManager createObjectForEntity:kMRSharePost
//                                                              inContext:context];
//    post.sharePostId = [NSNumber numberWithLong:sharePostId];
//    post.postedOn = [NSDate date];
//    post.likesCount = [NSNumber numberWithLong:0];
//    post.commentsCount = [NSNumber numberWithLong:0];
//    post.shareCount = [NSNumber numberWithLong:1];
//    
//    post.sharedByProfileId = [NSNumber numberWithLong:0];
//    
//    MRAppControl *appControl = [MRAppControl sharedHelper];
//    NSDictionary *userDetailsDict = appControl.userRegData;
//    post.sharedByProfileName = [userDetailsDict objectOrNilForKey:@"displayName"];
//    
//    id profilePicData = [userDetailsDict objectForKey:KProfilePicture];
//    if (profilePicData != nil && [profilePicData isKindOfClass:[NSDictionary class]])
//    {
//        profilePicData = [profilePicData objectForKey:@"data"];
//    }
//    
//    if (profilePicData != nil) {
//        if ([profilePicData isKindOfClass:[NSString class]]) {
//            post.shareddByProfilePic = [NSData decodeBase64ForString:profilePicData];
//        } else {
//            post.shareddByProfilePic = profilePicData;
//        }
//    }
//    
//    post.parentTransformPostId = transformPost.transformPostId;
//    post.titleDescription = transformPost.titleDescription;
//    post.shortText = transformPost.shortArticleDescription;
//    post.detailedText = transformPost.detailedDescription;
//    post.contentType = transformPost.contentType;
//    post.url = transformPost.url;
//    post.source = @"Transform";
//    
//    // Create a child post as well to show in activities section
//    MRPostedReplies *childPost = (MRPostedReplies*)[dbManager createObjectForEntity:kMRPostedReplies
//                                                                  inContext:context];
//    childPost.parentSharePostId = [NSNumber numberWithLong:post.sharePostId.longValue];
//    childPost.postedReplyId = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];
//    childPost.text = [NSString stringWithFormat:@"Shared the article"];
//    childPost.postedOn = post.postedOn;
//    
//    childPost.contentType = [NSNumber numberWithInteger:kTransformContentTypeText];
//    childPost.postedBy = post.sharedByProfileName;
//    childPost.postedByProfilePic = post.shareddByProfilePic;
//    
//    [post addPostedRepliesObject:childPost];
//    
//    [dbManager dbSaveInContext:context];
}

+ (void)addCommentToAPost:(MRSharePost*)inPost
                     text:(NSString*)text
              contentData:(NSData*)data
              contentType:(NSInteger)contentType {
    
    // Set the current user in sharedBy
    MRAppControl *appControl = [MRAppControl sharedHelper];
    NSDictionary *userDetailsDict = appControl.userRegData;
    NSString *sharedByProfileName = [userDetailsDict objectOrNilForKey:@"displayName"];
    
    id profilePicData = [userDetailsDict objectForKey:KProfilePicture];
    if (profilePicData != nil && [profilePicData isKindOfClass:[NSDictionary class]])
    {
        profilePicData = [profilePicData objectForKey:@"data"];
    }
    
    NSData *shareddByProfilePic = nil;
    
    if (profilePicData != nil) {
        if ([profilePicData isKindOfClass:[NSString class]]) {
            shareddByProfilePic = [NSData decodeBase64ForString:profilePicData];
        } else {
            shareddByProfilePic = profilePicData;
        }
    }
    
    // Create new reply post
    MRDataManger *dbManager = [MRDataManger sharedManager];
    
    NSManagedObjectContext *context = [dbManager getNewPrivateManagedObjectContext];

    
   
    MRPostedReplies *childPost = (MRPostedReplies*)[dbManager createObjectForEntity:kMRPostedReplies
                                                                          inContext:context];
    
    childPost.postedReplyId = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];
    childPost.postedOn = [NSDate date];
    childPost.message = text;
    childPost.doctor_Name = sharedByProfileName;
    
    // Set the content type
    childPost.contentType = [NSNumber numberWithInteger:contentType];
    
    // Update the current post
    if (inPost != nil && inPost.sharePostId != nil) {
        childPost.parentSharePostId = [NSNumber numberWithLong:inPost.sharePostId.longValue];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"sharePostId", inPost.sharePostId.longValue];
        MRSharePost *post = [dbManager fetchObject:kMRSharePost predicate:predicate inContext:context];
        [post addPostedRepliesObject:childPost];
        
        NSInteger commentCount = 1;
        if (post.commentsCount != nil) {
            commentCount = post.commentsCount.longValue + 1;
        }
        post.commentsCount = [NSNumber numberWithLong:commentCount];
    }
    
    [dbManager dbSaveInContext:context];
}

+ (void)shareAPostWithContactOrGroup:(MRSharePost*)inPost
                             text:(NSString*)text
                      contentData:(NSData*)data
                      contentType:(NSInteger)contentType
                        contactId:(NSInteger)contactId
                          groupId:(NSInteger)groupId {
    
    // Set the current user in sharedBy
    MRAppControl *appControl = [MRAppControl sharedHelper];
    NSDictionary *userDetailsDict = appControl.userRegData;
    NSString *sharedByProfileName = [userDetailsDict objectOrNilForKey:@"displayName"];
    
    id profilePicData = [userDetailsDict objectForKey:KProfilePicture];
    if (profilePicData != nil && [profilePicData isKindOfClass:[NSDictionary class]])
    {
        profilePicData = [profilePicData objectForKey:@"data"];
    }
    
    NSData *shareddByProfilePic = nil;
    
    if (profilePicData != nil) {
        if ([profilePicData isKindOfClass:[NSString class]]) {
            shareddByProfilePic = [NSData decodeBase64ForString:profilePicData];
        } else {
            shareddByProfilePic = profilePicData;
        }
    }
    
    // Create new reply post
    MRDataManger *dbManager = [MRDataManger sharedManager];
    
    NSManagedObjectContext *context = [dbManager getNewPrivateManagedObjectContext];
    MRPostedReplies *childPost = (MRPostedReplies*)[dbManager createObjectForEntity:kMRPostedReplies
                                                                          inContext:context];
    
    childPost.postedReplyId = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];
    childPost.postedOn = [NSDate date];
    childPost.message = text;
    childPost.doctor_Name = sharedByProfileName;
    
    // Set the content type
    childPost.contentType = [NSNumber numberWithInteger:contentType];
    
    MRContact *contact;
    MRGroup *group;
    if (contactId > 0) {
        childPost.contactId = [NSNumber numberWithLong:contactId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"contactId", contactId];
        contact = [dbManager fetchObject:kContactEntity predicate:predicate inContext:context];
        childPost.contactRelationship = contact;
    }
    if (groupId > 0) {
        childPost.groupId = [NSNumber numberWithLong:groupId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"group_id", groupId];
        group = [dbManager fetchObject:kGroupEntity predicate:predicate inContext:context];
        childPost.groupRelationship = group;
    }
    
    // Update the current post
    if (inPost != nil && inPost.sharePostId != nil) {
        childPost.parentSharePostId = [NSNumber numberWithLong:inPost.sharePostId.longValue];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"sharePostId", inPost.sharePostId.longValue];
        MRSharePost *post = [dbManager fetchObject:kMRSharePost predicate:predicate inContext:context];
        [post addPostedRepliesObject:childPost];
        
        if (contact != nil) {
            [contact addCommentsObject:childPost];
        }
        NSInteger shareCount = 1;
        if (post.shareCount != nil) {
            shareCount = post.shareCount.longValue + 1;
        }
        post.shareCount = [NSNumber numberWithLong:shareCount];
    }
    
    [dbManager dbSaveInContext:context];
}

+ (void)addCommentToAPost:(MRSharePost*)inPost
                     text:(NSString*)text
              contentData:(NSData*)data
                contactId:(NSInteger)contactId
                  groupId:(NSInteger)groupId
              posteByContactName:(NSString*)name
       postedByContactPic:(NSString*)pic
        postedByContactId:(NSString*)profileId
       updateCommentCount:(BOOL)updateCommentCount
      andUpdateShareCount:(BOOL)updateShareCount {
    MRDataManger *dbManager = [MRDataManger sharedManager];
    
    NSManagedObjectContext *context = [dbManager getNewPrivateManagedObjectContext];
    MRPostedReplies *childPost = (MRPostedReplies*)[dbManager createObjectForEntity:kMRPostedReplies
                                                                          inContext:context];
    
    childPost.parentSharePostId = [NSNumber numberWithLong:inPost.sharePostId.longValue];
    childPost.postedReplyId = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];
    childPost.postedOn = [NSDate date];
    childPost.message = text;
    childPost.contentType = [NSNumber numberWithInteger:kTransformContentTypeText];
    childPost.doctor_Name = name;
    
    if (contactId > 0) {
        childPost.contactId = [NSNumber numberWithLong:contactId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"contactId", contactId];
        MRContact *contact = [dbManager fetchObject:kContactEntity predicate:predicate inContext:context];
        childPost.contactRelationship = contact;
    }
    if (groupId > 0) {
        childPost.groupId = [NSNumber numberWithLong:groupId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"group_id", groupId];
        MRGroup *group = [dbManager fetchObject:kGroupEntity predicate:predicate inContext:context];
        childPost.groupRelationship = group;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"sharePostId", inPost.sharePostId.longValue];
    MRSharePost *post = [dbManager fetchObject:kMRSharePost predicate:predicate inContext:context];
    [post addPostedRepliesObject:childPost];
    
    if (updateCommentCount) {
        NSInteger commentCount = 1;
        if (post.commentsCount != nil) {
            commentCount = post.commentsCount.longValue + 1;
        }
        post.commentsCount = [NSNumber numberWithLong:commentCount];
    }
    
    if (updateShareCount) {
        NSInteger shareCount = 1;
        if (post.shareCount != nil) {
            shareCount = post.shareCount.longValue + 1;
        }
        post.shareCount = [NSNumber numberWithLong:shareCount];
    }
    
    [dbManager dbSaveInContext:context];
}

+ (NSArray*)getTransformArticles {
    NSArray *articles = [[MRDataManger sharedManager] fetchObjectList:kMRTransformPost attributeName:@"postedOn" sortOrder:SORT_ORDER_DESCENDING];
    return articles;
}

+(NSArray *)getProfileData{
    NSArray *profileAra = [[MRDataManger sharedManager] fetchObjectList:@"MRProfile"];
    return profileAra;
    
}



+(void)deleteWorkExperienceFromTable:(NSNumber *)workExpID withHandler:(WebServiceResponseHandler)responseHandler{
    NSArray *profileAra = [[MRDataManger sharedManager] fetchObjectList:@"MRProfile"];
    MRProfile * profile = [profileAra lastObject];
    MRWorkExperience *workExp = [[MRDataManger sharedManager] fetchObject:@"MRWorkExperience" predicate:[NSPredicate predicateWithFormat:@"id == %@",workExpID]];
    
    [profile removeWorkExperienceObject:workExp];
    
    [[MRDataManger sharedManager] removeObject:workExp];
    [[MRDataManger sharedManager] saveContext];
    
    [[MRWebserviceHelper sharedWebServiceHelper] deleteWorkExperience:workExpID withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
       
        responseHandler(responce);
        
    }];
    
}
+(void)deleteEducationQualificationFromTable:(NSNumber *)educationID withHandler:(WebServiceResponseHandler)responseHandler{
    
    NSArray *profileAra = [[MRDataManger sharedManager] fetchObjectList:@"MRProfile"];
    MRProfile * profile = [profileAra lastObject];
    EducationalQualifications *educationExp = [[MRDataManger sharedManager] fetchObject:@"EducationalQualifications" predicate:[NSPredicate predicateWithFormat:@"id == %@",educationID]];
    
    [profile removeEducationlQualificationObject:educationExp];
    
    [[MRDataManger sharedManager] removeObject:educationExp];
    [[MRDataManger sharedManager] saveContext];

    [[MRWebserviceHelper sharedWebServiceHelper] deleteEducationQualification:educationID withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        responseHandler(responce);
    }];
}
+(void)deleteInterestAreaFromTable:(NSNumber *)interestID withHandler:(WebServiceResponseHandler)responseHandler{
    NSArray *profileAra = [[MRDataManger sharedManager] fetchObjectList:@"MRProfile"];
    MRProfile * profile = [profileAra lastObject];
    MRInterestArea *interestArea = [[MRDataManger sharedManager] fetchObject:@"MRInterestArea" predicate:[NSPredicate predicateWithFormat:@"id == %@",interestID]];
    
    [profile removeInterestAreaObject:interestArea];
    [[MRDataManger sharedManager] removeObject:interestArea];

    [[MRDataManger sharedManager] saveContext];
[[MRWebserviceHelper sharedWebServiceHelper] deleteInterestArea:interestID withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
    responseHandler(responce);
}];
    
}
+(void)deletePublicationAreaFromTable:(NSNumber *)publicationID withHandler:(WebServiceResponseHandler)responseHandler{
    NSArray *profileAra = [[MRDataManger sharedManager] fetchObjectList:@"MRProfile"];
    MRProfile * profile = [profileAra lastObject];
    MRPublications *publicationObj = [[MRDataManger sharedManager] fetchObject:@"MRPublications" predicate:[NSPredicate predicateWithFormat:@"id == %@",publicationID]];
    
    [profile removePublicationsObject:publicationObj];
    
    [[MRDataManger sharedManager] removeObject:publicationObj];
    [[MRDataManger sharedManager] saveContext];
[[MRWebserviceHelper sharedWebServiceHelper] deletePublish:publicationID withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
    responseHandler(responce);
}];
    
}

+(void)addInterestArea:(NSArray *)_array  andHandler:(WebServiceResponseHandler)responseHandler
{
    NSArray *profileAra = [[MRDataManger sharedManager] fetchObjectList:@"MRProfile"];
    MRProfile * profile = [profileAra lastObject];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[_array lastObject],@"name",nil];
    
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject: dict];
    
    [[MRWebserviceHelper sharedWebServiceHelper] addorUpdateInterestArea:array withUpdateFlag:NO withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        
            NSLog(@"%@",responce);
               MRInterestArea *interestArea = (MRInterestArea *)[[MRDataManger sharedManager] createObjectForEntity:@"MRInterestArea"];
                    interestArea.name  = [_array lastObject];
                    interestArea.id = [[responce objectForKey:@"id"] objectAtIndex:0];
                    [profile addInterestAreaObject:interestArea];
                    responseHandler(@"TRUE");
        
            
                
                [[MRDataManger sharedManager] saveContext];

            
        }];
        
    
    

}

+(void)updateInterest:(NSDictionary *)dictonary withInterestAreaID:(NSNumber *)iD  andHandler:(WebServiceResponseHandler)responseHandler{
 
    MRInterestArea *interestArea = [[MRDataManger sharedManager] fetchObject:@"MRInterestArea" predicate:[NSPredicate predicateWithFormat:@"id == %@",iD]];
    
    NSMutableArray *arrayObj = [[NSMutableArray alloc] init];
    
    [arrayObj addObject:dictonary];
    

    [[MRWebserviceHelper sharedWebServiceHelper] addorUpdateInterestArea:arrayObj withUpdateFlag:YES withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        
        interestArea.name  = [dictonary objectForKey:@"name"];
        [[MRDataManger sharedManager] saveContext];
        responseHandler(@"TRUE");

        
    }];
    
    
}



+(void)updatePublication:(NSDictionary *)dictonary withPublicationID:(NSNumber *)iD  andHandler:(WebServiceResponseHandler)responseHandler{

    MRPublications *publications = [[MRDataManger sharedManager] fetchObject:@"MRPublications" predicate:[NSPredicate predicateWithFormat:@"id == %@",iD]];
    
    NSMutableArray *arrayObj = [[NSMutableArray alloc] init];
    
    [arrayObj addObject:dictonary];
    


    [[MRWebserviceHelper sharedWebServiceHelper] addOrUpdatePulblishArticle:arrayObj withUpdateFlag:YES withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        publications.articleName = [dictonary objectForKey:@"articleName"];
        publications.publication = [dictonary objectForKey:@"publication"];
        publications.year = [dictonary objectForKey:@"year"];
        publications.url = [dictonary objectForKey:@"url"];
        
        [[MRDataManger sharedManager] saveContext];
        responseHandler(@"TRUE");

        
    }];
    
}
+(void)addPublications:(NSDictionary *)dictonary andHandler:(WebServiceResponseHandler)responseHandler  {
   
    
    NSMutableArray *requestAr = [[NSMutableArray alloc] init];
    
    [requestAr addObject:dictonary];
    
    [[MRWebserviceHelper sharedWebServiceHelper] addOrUpdatePulblishArticle:requestAr withUpdateFlag:NO withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        
        
        NSArray *profileAra = [[MRDataManger sharedManager] fetchObjectList:@"MRProfile"];
        MRProfile * profile = [profileAra lastObject];
        if (profile!=nil) {
            
            MRPublications * publications = (MRPublications *)[[MRDataManger sharedManager] createObjectForEntity:@"MRPublications"];
            
            publications.articleName = [dictonary objectForKey:@"articleName"];
            publications.publication = [dictonary objectForKey:@"publication"];
            publications.year = [dictonary objectForKey:@"year"];
            publications.url = [dictonary objectForKey:@"url"];

            publications.id = [[responce objectForKey:@"id"] objectAtIndex:0];
            responseHandler(@"TRUE");
            [profile addPublicationsObject:publications];
            [[MRDataManger sharedManager] saveContext];

            
            
        }

        
    }];
    
    
}


+(void)updateEducationQualification:(NSDictionary *)dictonary withEducationQualificationID:(NSNumber *)iD  andHandler:(WebServiceResponseHandler)responseHandler{
    
    
    EducationalQualifications *educationQualification = [[MRDataManger sharedManager] fetchObject:@"EducationalQualifications" predicate:[NSPredicate predicateWithFormat:@"id == %@",iD]];
    
    NSMutableArray *arrayObj = [[NSMutableArray alloc] init];
    
    [arrayObj addObject:dictonary];
    
    [[MRWebserviceHelper sharedWebServiceHelper] addOrUpdateEducationArea:arrayObj withUpdateFlag:YES withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        educationQualification.degree = [dictonary objectForKey:@"degree"];
        educationQualification.yearOfPassout = [dictonary objectForKey:@"yearOfPassout"];
        educationQualification.collegeName = [dictonary objectForKey:@"collegeName"];
        educationQualification.course = [dictonary objectForKey:@"course"];
        educationQualification.aggregate = [NSNumber numberWithFloat:[[dictonary objectForKey:@"aggregate"]integerValue]];
        
        [[MRDataManger sharedManager] saveContext];
        responseHandler(@"TRUE");

    }];
    
}

+(void)addEducationQualification:(NSDictionary *)dictonary andHandler:(WebServiceResponseHandler)responseHandler {
    NSArray *profileAra = [[MRDataManger sharedManager] fetchObjectList:@"MRProfile"];
    MRProfile * profile = [profileAra lastObject];

    if (profile!=nil) {
        
        NSMutableArray *arrayObj = [[NSMutableArray alloc] init];
        
        [arrayObj addObject:dictonary];
        
        [[MRWebserviceHelper sharedWebServiceHelper] addOrUpdateEducationArea:arrayObj withUpdateFlag:NO withHandler:^(BOOL status, NSString *details, NSDictionary *responce)  {
            
            
            NSLog(@"%@",responce);
            
          
            EducationalQualifications * educationQualification = (EducationalQualifications *)[[MRDataManger sharedManager] createObjectForEntity:@"EducationalQualifications"];
            educationQualification.id = [[responce objectForKey:@"id"] objectAtIndex:0];
            educationQualification.degree = [dictonary objectForKey:@"degree"];
            educationQualification.yearOfPassout = [dictonary objectForKey:@"yearOfPassout"];
            educationQualification.collegeName = [dictonary objectForKey:@"collegeName"];
            educationQualification.course = [dictonary objectForKey:@"course"];
            educationQualification.aggregate = [NSNumber numberWithFloat:[[dictonary objectForKey:@"aggregate"]integerValue]];
            
            
            [profile addEducationlQualificationObject:educationQualification];
            [[MRDataManger sharedManager] saveContext];
            responseHandler(@"TRUE");
            
        }];

        
    }

}



+(void)updateWorkExperience:(NSDictionary *)workExpDict withWorkExperienceID:(NSNumber *)iD  andHandler:(WebServiceResponseHandler)responseHandler{
    
    
    MRWorkExperience *workExp = [[MRDataManger sharedManager] fetchObject:@"MRWorkExperience" predicate:[NSPredicate predicateWithFormat:@"id == %@",iD]];
    

    
    NSArray *arrayObj = [NSArray arrayWithObject:workExpDict];
[[MRWebserviceHelper sharedWebServiceHelper] addOrUpdateWorkExperience:arrayObj withUpdateFlag:YES withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
   
    workExp.designation = [workExpDict objectForKey:@"designation"];
    workExp.fromDate = [workExpDict objectForKey:@"fromDate"];
    workExp.toDate = [workExpDict objectForKey:@"toDate"];
    workExp.hospital = [workExpDict objectForKey:@"hospital"];
    workExp.location = [workExpDict objectForKey:@"location"];
    workExp.currentJob = [workExpDict objectForKey:@"currentJob"];
    workExp.summary = [workExpDict objectForKey:@"summary"];
    

    [[MRDataManger sharedManager] saveContext];
    
    responseHandler(@"TRUE");
}];
    
//    [[MRDataManger sharedManager] fetchObject:@"MRWorkExperience" inContext:<#(NSManagedObjectContext *)#>]
    
    
}
+(void)addWorkExperience :(NSDictionary *)dictionary andHandler:(WebServiceResponseHandler)responseHandler{
   
    NSArray *profileAra = [[MRDataManger sharedManager] fetchObjectList:@"MRProfile"];
    MRProfile * profile = [profileAra lastObject];
    if (profile!=nil) {
        
        
        /*
         [{
         "hospital":"Apollo Hospital",
         "fromDate":"02-06-1987",
         "toDate":"02-06-1988",
         "location":"Nellore",
         "designation":"ENT"
         }]
         */
        
        NSArray *obj = [NSArray arrayWithObject:dictionary];
        [[MRWebserviceHelper sharedWebServiceHelper] addOrUpdateWorkExperience:obj withUpdateFlag:NO withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
            NSDictionary *workExpDict  = (NSDictionary *)dictionary;
            MRWorkExperience * workExp = (MRWorkExperience *)[[MRDataManger sharedManager] createObjectForEntity:@"MRWorkExperience"];
            workExp.id = [[responce objectForKey:@"id"] objectAtIndex:0];

            workExp.designation = [workExpDict objectForKey:@"designation"];
            workExp.fromDate = [workExpDict objectForKey:@"fromDate"];
            workExp.toDate = [workExpDict objectForKey:@"toDate"];
            workExp.hospital = [workExpDict objectForKey:@"hospital"];
            workExp.location = [workExpDict objectForKey:@"location"];
            workExp.currentJob = [workExpDict objectForKey:@"currentJob"];
            workExp.summary = [workExpDict objectForKey:@"summary"];
            
            responseHandler(@"TRUE");
            [profile addWorkExperienceObject:workExp];
            [[MRDataManger sharedManager] saveContext];

        }];
        
        
        
    }
    
}






+(void)addProfileData:(WebServiceResponseHandler)responseHandler{
    

    [[MRWebserviceHelper sharedWebServiceHelper] fetchDoctorInfoWithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        NSLog(@"%@",responce);
        MRDataManger *dbManager = [MRDataManger sharedManager];

         NSManagedObjectContext *context = [dbManager getNewPrivateManagedObjectContext];
        [[MRDataManger sharedManager] removeAllObjects:@"MRProfile" inContext:context
                                          andPredicate:nil];
        
        
        
        NSDictionary * result =[responce objectForKey:@"result"];
        
        NSDictionary *aboutDict = [result objectForKey:@"about"];
        MRProfile * profile = (MRProfile *)[[MRDataManger sharedManager] createObjectForEntity:@"MRProfile"];
        profile.name = [aboutDict objectForKey:@"name"];
        profile.location = [aboutDict objectForKey:@"location"];
        profile.designation = [aboutDict objectForKey:@"designation"];
        profile.id = [NSNumber numberWithInteger:[[aboutDict  objectForKey:@"id"] integerValue]];
        profile.doctorId = [NSNumber numberWithInteger:[[aboutDict  objectForKey:@"doctorId"] integerValue]];
        
        
        
        NSArray * workExpArra = [result objectForKey:@"workexperiences"];
        [workExpArra enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *workExpDict  = (NSDictionary *)obj;
            MRWorkExperience * workExp = (MRWorkExperience *)[[MRDataManger sharedManager] createObjectForEntity:@"MRWorkExperience"];
            workExp.id = [workExpDict objectForKey:@"id"];
            workExp.designation = [workExpDict objectForKey:@"designation"];
            workExp.fromDate = [workExpDict objectForKey:@"fromDate"];
            workExp.toDate = [workExpDict objectForKey:@"toDate"];
            workExp.hospital = [workExpDict objectForKey:@"hospital"];
            workExp.location = [workExpDict objectForKey:@"location"];
            workExp.currentJob = [workExpDict objectForKey:@"currentJob"];
            workExp.summary = [workExpDict objectForKey:@"summary"];
            [profile addWorkExperienceObject:workExp];
            
        }];
        NSArray *addressInfoArra= [result objectForKey:@"address"];
        
        
        
        [addressInfoArra enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
            AddressInfo *addressInfo =(AddressInfo *)[[MRDataManger sharedManager] createObjectForEntity:@"AddressInfo"];
            
            NSDictionary *addressDict = (NSDictionary *)obj;
            [addressInfo updateFromDictionary:addressDict];
            
//            addressInfo.address1 = [addressDict objectForKey:@"address1"];
//            addressInfo.address2 = [addressDict objectForKey:@"address2"];
//            addressInfo.city  =[addressDict objectForKey:@"city"];
//            addressInfo.state = [addressDict objectForKey:@"state"];
//            addressInfo.country = [addressDict objectForKey:@"country"];
//            addressInfo.zipcode = [addressDict objectForKey:@"zipcode"];
//            addressInfo.type = [NSNumber numberWithInteger:[[addressDict objectForKey:@"type"] integerValue]];
            [profile addAddressInfoObject:addressInfo];
        }];
        
        NSDictionary *contactInfoDict = [result objectForKey:@"contactInfo"];
        if (contactInfoDict!=nil) {
            ContactInfo *contactInfo = (ContactInfo *)[[MRDataManger sharedManager] createObjectForEntity:@"ContactInfo"];
            
            contactInfo.phoneNo = [contactInfoDict objectForKey:@"phoneNo"];
            contactInfo.alternateEmail = [contactInfoDict objectForKey:@"alternateEmail"];
            contactInfo.email = [contactInfoDict objectForKey:@"email"];
            contactInfo.mobileNo = [contactInfoDict objectForKey:@"mobileNo"];
            
            profile.contactInfo = contactInfo;
            
        }

        
        
        NSArray *educationQualificationArra = [result objectForKey:@"educationdetails"];
        
        [educationQualificationArra enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
            EducationalQualifications * educationQualification = (EducationalQualifications *)[[MRDataManger sharedManager] createObjectForEntity:@"EducationalQualifications"];
            NSDictionary *dictEdu = (NSDictionary *)obj;
            educationQualification.degree = [dictEdu objectForKey:@"degree"];
            educationQualification.yearOfPassout = [dictEdu objectForKey:@"yearOfPassout"];
            educationQualification.collegeName = [dictEdu objectForKey:@"collegeName"];
            educationQualification.course = [dictEdu objectForKey:@"course"];
            educationQualification.aggregate = [dictEdu objectForKey:@"aggregate"];
            educationQualification.id = [dictEdu objectForKey:@"id"];
            
            [profile addEducationlQualificationObject:educationQualification];
        
        }];
        
        /* 
         EducationalQualifications * educationQualification = (EducationalQualifications *)[[MRDataManger sharedManager] createObjectForEntity:@"EducationalQualifications"];
         
         educationQualification.degree = [dictonary objectForKey:@"degree"];
         educationQualification.yearOfPassout = [dictonary objectForKey:@"yearOfPassout"];
         educationQualification.collegeName = [dictonary objectForKey:@"collegeName"];
         educationQualification.course = [dictonary objectForKey:@"course"];
         educationQualification.aggregate = [dictonary objectForKey:@"aggregate"];
         
         
         [profile addEducationlQualificationObject:educationQualification];*/
        
        NSArray *interestArra = [result objectForKey:@"interests"];
        [interestArra enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSDictionary *interestAraDict = (NSDictionary *)obj;
            MRInterestArea * interestArea = (MRInterestArea *)[[MRDataManger sharedManager] createObjectForEntity:@"MRInterestArea"];
            interestArea.name = [interestAraDict objectForKey:@"name"];
           interestArea.id = [interestAraDict objectForKey:@"id"];
            
            [profile addInterestAreaObject:interestArea];
            
            
        }];

        NSArray *publicationsArra = [result objectForKey:@"publications"];
        [publicationsArra enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSDictionary *publicationAraDict = (NSDictionary *)obj;
            MRPublications * interestArea = (MRPublications *)[[MRDataManger sharedManager] createObjectForEntity:@"MRPublications"];
            interestArea.publication = [publicationAraDict objectForKey:@"publication"];
            interestArea.articleName = [publicationAraDict objectForKey:@"articleName"];
            interestArea.year = [publicationAraDict objectForKey:@"year"];
            interestArea.url = [publicationAraDict objectForKey:@"url"];
            interestArea.id = [publicationAraDict objectForKey:@"id"];
            [profile addPublicationsObject:interestArea];
            
        }];
        [[MRDataManger sharedManager] saveContext];

        id profileAra = [[MRDataManger sharedManager] fetchObjectList:@"MRProfile"];
        
        responseHandler(profileAra);
        
        
        
    }];
    
    
    
    
    
 
    
   

    
    
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
+(void)fetchShare:(WebServiceResponseHandler)responseHandler{
    [MRCommon showActivityIndicator:@"Requesting..."];

    
    
    [[MRWebserviceHelper sharedWebServiceHelper] getShare:nil
                                              withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                                                  [[MRDataManger sharedManager] removeAllObjects:kMRSharePost withPredicate:nil];
                              
                                                  id result = [MRWebserviceHelper parseNetworkResponse:NSClassFromString(kMRSharePost)
                                                               
                                                                                        andData:[responce valueForKey:@"Responce"]];
                                                  responseHandler(result);
                                                  
                                              }];
    
    
}

+ (void)fetchNewsAndUpdates:(NSString*)category
                 methodName:(NSString*)methodName
                withHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getNewsAndUpdates:category
                                                        methodName:methodName
                                                       withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [[MRDataManger sharedManager] removeAllObjects:kMRTransformPost withPredicate:nil];
        [MRDatabaseHelper makeServiceCallForNewsAndUpdatesFetch:category
                                                     methodName:methodName
                                                         status:status
                                                        details:details
                                                 response:responce
                                       andResponseHandler:responseHandler];
    }];
}

+ (void)makeServiceCallForNewsAndUpdatesFetch:(NSString*)category
                                   methodName:(NSString*)methodName
                                       status:(BOOL)status
                                      details:(NSString*)details
                                     response:(NSDictionary*)response
                           andResponseHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon stopActivityIndicator];
    if (status)
    {
        [MRDatabaseHelper parseNewsAndUpdatesResponse:response andResponseHandler:responseHandler];
    }
    else {
        NSString *errorCode = [MRDatabaseHelper getOAuthErrorCode:response];
        if ([errorCode isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getNewsAndUpdates:category
                                                                     methodName:methodName
                                                                    withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status)
                     {
                         [MRDatabaseHelper parseNewsAndUpdatesResponse:responce
                                                    andResponseHandler:responseHandler];
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
            if (erros.count > 0) {
                [MRCommon showAlert:[erros lastObject] delegate:nil];
            }
            
            if (responseHandler != nil) {
                responseHandler(nil);
            }
        }
    }
}

+ (void)parseNewsAndUpdatesResponse:(NSDictionary*)response
                 andResponseHandler:(WebServiceResponseHandler) responseHandler {
    id result = [MRWebserviceHelper parseNetworkResponse:NSClassFromString(kMRTransformPost)
                                                 andData:[response valueForKey:@"Responce"]];
    if (responseHandler != nil) {
        NSArray *tempResults = [[MRDataManger sharedManager] fetchObjectList:kMRTransformPost];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"postedOn" ascending:false];
        NSSortDescriptor *titleDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"titleDescription" ascending:true];
        result = [tempResults sortedArrayUsingDescriptors:@[sortDescriptor, titleDescriptor]];
        responseHandler(result);
    }
}

+ (void)addConnections:(NSArray*)selectedContacts
    andResponseHandler:(WebServiceResponseHandler)handler {
    NSMutableDictionary *dictReq = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    selectedContacts, @"connIdList",
                                    nil];
    
    [MRCommon showActivityIndicator:@"Adding..."];
    [[MRWebserviceHelper sharedWebServiceHelper] addMembers:dictReq withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status) {
            if (handler != nil) {\
                handler([NSNumber numberWithBool:status]);
                [MRCommon showAlert:NSLocalizedString(kConnectionAdded, "") delegate:nil];
            }
        }
        else {
            NSString *errorCode = [MRDatabaseHelper getOAuthErrorCode:responce];
            if ([errorCode isEqualToString:@"invalid_token"])
            {
                [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
                 {
                     [MRCommon savetokens:responce];
                     [[MRWebserviceHelper sharedWebServiceHelper] addMembers:dictReq withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                         [MRCommon stopActivityIndicator];
                         if (status) {
                             if (handler != nil) {
                                 handler([NSNumber numberWithBool:status]);
                                 [MRCommon showAlert:NSLocalizedString(kConnectionAdded, "") delegate:nil];
                             }
                         }else
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
        }
    }];
}

+ (void)postANewTopic:(NSDictionary*)reqDict withHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] postNewTopic:reqDict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRDatabaseHelper makeServiceCallForPostANewTopic:reqDict
                                                    status:status
                                                  details:details
                                               response:responce
                                     andResponseHandler:responseHandler];
    }];
}

+ (void)makeServiceCallForPostANewTopic:reqDict
                                 status:(BOOL)status
                                details:(NSString*)details
                             response:(NSDictionary*)response
                   andResponseHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon stopActivityIndicator];
    if (status)
    {
        responseHandler([NSNumber numberWithBool:status]);
    }
    else {
        NSString *errorCode = [MRDatabaseHelper getOAuthErrorCode:response];
        if ([errorCode isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce) {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] postNewTopic:reqDict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status)
                     {
                         responseHandler([NSNumber numberWithBool:status]);
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
    }
}

+ (void)fetchShareDetailsById:(NSInteger)topicId
                withHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getShareDetailsById:topicId
                                                       withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                                                           [MRDatabaseHelper makeServiceCallForGetShareDetailsById:topicId
                                                                                                            status:status
                                                                                                           details:details
                                                                                                          response:responce
                                                                                                andResponseHandler:responseHandler];
                                                       }];
}

+ (void)makeServiceCallForGetShareDetailsById:(NSInteger)topicId
                                       status:(BOOL)status
                                      details:(NSString*)details
                                     response:(NSDictionary*)response
                           andResponseHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon stopActivityIndicator];
    if (status)
    {
        [MRDatabaseHelper parseGetShareDetailsByIdResponse:response andResponseHandler:responseHandler];
    }
    else {
        NSString *errorCode = [MRDatabaseHelper getOAuthErrorCode:response];
        if ([errorCode isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getShareDetailsById:topicId
                                                                    withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                                                                        [MRCommon stopActivityIndicator];
                                                                        if (status)
                                                                        {
                                                                            [MRDatabaseHelper parseGetShareDetailsByIdResponse:responce
                                                                                                       andResponseHandler:responseHandler];
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
            if (erros.count > 0) {
                [MRCommon showAlert:[erros lastObject] delegate:nil];
            }
            
            if (responseHandler != nil) {
                responseHandler(nil);
            }
        }
    }
}

+ (void)parseGetShareDetailsByIdResponse:(NSDictionary*)response
                 andResponseHandler:(WebServiceResponseHandler) responseHandler {
    id result = [MRWebserviceHelper parseNetworkResponse:NSClassFromString(kMRPostedReplies)
                                                 andData:[response valueForKey:@"Responce"]];
    if (responseHandler != nil) {
        responseHandler(result);
    }
}

+ (void)getMessagesOfAMember:(NSInteger)memberId
                     groupId:(NSInteger)groupId
                 withHandler:(WebServiceResponseHandler)handler {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getPostsForAMember:memberId
                                                            groupId:groupId
                                                         withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                                                             [MRDatabaseHelper makeServiceCallForGetMessagesOfAMember:memberId
                                                                                                              groupId:groupId
                                                                                                              status:status
                                                                                                             details:details
                                                                                                            response:responce
                                                                                                  andResponseHandler:handler];
                                                         }];
}

+ (void)makeServiceCallForGetMessagesOfAMember:(NSInteger)memberId
                                       groupId:(NSInteger)groupId
                                       status:(BOOL)status
                                      details:(NSString*)details
                                     response:(NSDictionary*)response
                           andResponseHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon stopActivityIndicator];
    if (status)
    {
        [MRDatabaseHelper parseGetShareDetailsByIdResponse:response andResponseHandler:responseHandler];
    }
    else {
        NSString *errorCode = [MRDatabaseHelper getOAuthErrorCode:response];
        if ([errorCode isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getPostsForAMember:memberId
                                                                           groupId:groupId
                                                                      withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                                                                          [MRCommon stopActivityIndicator];
                                                                          if (status)
                                                                          {
                                                                              [MRDatabaseHelper parseGetShareDetailsByIdResponse:responce
                                                                                                              andResponseHandler:responseHandler];
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
            if (erros.count > 0) {
                [MRCommon showAlert:[erros lastObject] delegate:nil];
            }
            
            if (responseHandler != nil) {
                responseHandler(nil);
            }
        }
    }
}

+ (void)editLocation:dataDict andHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] editLocation:dataDict
                                                  withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                                                      [MRDatabaseHelper makeServiceCallForEditLocation:dataDict
                                                                                                status:status
                                                                                               details:details
                                                                                              response:responce
                                                                                    andResponseHandler:responseHandler];
    }];
}

+ (void)makeServiceCallForEditLocation:(NSDictionary*)dataDict
                                status:(BOOL)status
                               details:(NSString*)details
                              response:(NSDictionary*)response
                           andResponseHandler:(WebServiceResponseHandler)responseHandler {
    [MRCommon stopActivityIndicator];
    if (status)
    {
        [MRDatabaseHelper updateLocationDataInCoreData:dataDict
                                              response:response
                                    andResponseHandler:responseHandler];
    }
    else {
        NSString *errorCode = [MRDatabaseHelper getOAuthErrorCode:response];
        
        if ([errorCode isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] editLocation:dataDict
                                                               withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status)
                     {
                         [MRDatabaseHelper updateLocationDataInCoreData:dataDict
                                                               response:response
                                                     andResponseHandler:responseHandler];
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
    }
}

+ (void)updateLocationDataInCoreData:dataDict
                            response:(NSDictionary*)response
                  andResponseHandler:(WebServiceResponseHandler) responseHandler {
    if (response != nil && [response allKeys].count > 0) {
        id tempValue = [response valueForKey:@"status"];
        if (tempValue != nil) {
            if ([tempValue isKindOfClass:[NSString class]]) {
                NSString *status = tempValue;
                if (status.length > 0  && [status caseInsensitiveCompare:@"success"] == NSOrderedSame) {
                    id locationDataDict = [dataDict objectOrNilForKey:@"location"];
                    if (locationDataDict != nil && [locationDataDict isKindOfClass:[NSDictionary class] ]) {
                        [MRWebserviceHelper parseNetworkResponse:AddressInfo.class
                                                         andData:@[locationDataDict]];
                    } else if ([dataDict isKindOfClass:[NSDictionary class]]) {
                        ContactInfo *entity = [[MRDataManger sharedManager] fetchObject:NSStringFromClass(ContactInfo.class)];
                        [entity updateFromDictionary:dataDict];
                    }
                    responseHandler(tempValue);
                } else {
                    if (responseHandler != nil) {
                        responseHandler(nil);
                    }
                }
            } else {
                if (responseHandler != nil) {
                    responseHandler(nil);
                }
            }
        } else {
            if (responseHandler != nil) {
                responseHandler(nil);
            }
        }
    } else {
        if (responseHandler != nil) {
            responseHandler(nil);
        }
    }
}

@end

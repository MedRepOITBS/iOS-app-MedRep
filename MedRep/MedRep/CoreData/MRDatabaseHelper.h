//
//  MRDatabaseHelper.h
//  MedRep
//
//  Created by MedRep Developer on 03/10/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRoleEntity                 @"MRRole"
#define kTherapeuticAreaEntity      @"MRTherapeuticArea"
#define kNotificationTypeEntity     @"MRNotificationType"
#define kCompanyDetailsEntity       @"MRCompanyDetails"
#define kNotificationsEntity        @"MRNotifications"

#define kContactEntity              @"MRContact"
#define kGroupEntity                @"MRGroup"
#define kGroupMembersEntity         @"MRGroupMembers"
#define kGroupPostEntity            @"MRGroupPost"
#define kSuggestedContactEntity     @"MRSuggestedContact"
#define kGroupChildPostEntity       @"MrGroupChildPost"

#define kMRTransformPost     @"MRTransformPost"
#define kMRSharePost         @"MRSharePost"
#define kMRPostedReplies     @"MRPostedReplies"

@class MRGroupPost;
@class MRTransformPost, MRSharePost;

typedef void (^WebServiceResponseHandler)(id result);

@interface MRDatabaseHelper : NSObject
{
    
}

+ (MRDatabaseHelper *)sharedHelper;

+ (void)addSuggestedContacts:(NSArray*)contacts;
+ (void)addGroups:(NSArray*)groups;
+ (void)addGroupPosts:(NSArray*)groupPosts;

+ (void)getGroups:(WebServiceResponseHandler)responseHandler;
+ (void)getSuggestedGroups:(WebServiceResponseHandler)responseHandler;
+ (void)getPendingGroups:(WebServiceResponseHandler)responseHandler;

+ (void)getContacts:(WebServiceResponseHandler)responseHandler;
+ (void)getContactsByCity:(NSString*)city responseHandler:(WebServiceResponseHandler)responseHandler;
+ (void)getSuggestedContacts:(WebServiceResponseHandler)responseHandler;
+ (void)getPendingContacts:(WebServiceResponseHandler)responseHandler;
+ (void)getContactsBySearchString:(NSString*)searchText
               andResponseHandler:(WebServiceResponseHandler)responseHandler;

+ (void)getGroupMemberStatusWithId:(NSInteger)groupId
                        andHandler:(WebServiceResponseHandler)responseHandler;

+ (NSArray*)getObjectsForType:(NSString*)entityName andPredicate:(NSPredicate*)predicate;

+ (void)addRole:(NSArray*)roles;
+ (void)addTherapeuticArea:(NSArray*)therapeuticAreaList;
+ (void)addNotificationType:(NSArray*)notificationTypeList;
+ (void)addCompanyDetails:(NSArray*)companyDetailsList;
+ (void)addNotifications:(NSArray*)notificationsList;

+ (BOOL)getObjectDataExistance:(NSString*)managedObject;

+ (void)getRoles:(void (^)(NSArray *roles))myRoles;

+ (void)getNotificationTypes:(void (^)(NSArray *fetchList))objectsList;

+ (void)getTherapeuticArea:(void (^)(NSArray *fetchList))objectsList;

+ (void)getCompanyDetails:(void (^)(NSArray *fetchList))objectsList;

+ (void)getNotifications:(BOOL)isRead
           withFavourite:(BOOL)isFav
   withNotificationsList:(void (^)(NSArray *fetchList))objectsList;

+ (void)updateNotifiction:(NSNumber*)notificationID
       userFavouriteSatus:(BOOL)isFav
           userReadStatus:(BOOL)isRead
          withSavedStatus:(void (^)(BOOL isScuccess))savedStatus;

+ (void)updateNotifictionFeedback:(NSNumber*)notificationID
                     userFeedback:(BOOL)feedback
                  withSavedStatus:(void (^)(BOOL isScuccess))savedStatus;

+ (void)getNotificationsByFilter:(NSString*)companyName
             withTherapeuticName:(NSString*)therapeuticName
           withNotificationsList:(void (^)(NSArray *fetchList))objectsListt;

+ (void)cleanDatabaseOnLogout;
+(MRGroupPost *)getGroupPostForPostID:(NSNumber *)groupId;
+ (void)addGroupChildPost:(MRGroupPost*)post withPostDict:(NSDictionary *)myDict;
+(NSArray *)getContactListForContactID:(int64_t)contactID;

+ (NSArray*)getShareArticles;
+ (void)shareAnArticle:(MRTransformPost*)transformPost;

+ (void)addCommentToAPost:(MRSharePost*)inPost
                     text:(NSString*)text
              contentData:(NSData*)data
              contentType:(NSInteger)contentType;

+ (void)shareAPostWithContactOrGroup:(MRSharePost*)inPost
                                text:(NSString*)text
                         contentData:(NSData*)data
                         contentType:(NSInteger)contentType
                           contactId:(NSInteger)contactId
                             groupId:(NSInteger)groupId;

+ (NSArray*)getTransformArticles;
+ (void)addTransformArticles:(NSArray*)posts;


@end

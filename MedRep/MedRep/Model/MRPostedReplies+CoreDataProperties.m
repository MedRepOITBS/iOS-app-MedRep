//
//  MRPostedReplies+CoreDataProperties.m
//  MedRep
//
//  Created by Vamsi Katragadda on 8/1/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRPostedReplies+CoreDataProperties.h"
#import "MRDataManger.h"

@implementation MRPostedReplies (CoreDataProperties)

@dynamic contactId;
@dynamic contentType;
@dynamic displayPicture;
@dynamic fileUrl;
@dynamic groupId;
@dynamic parentSharePostId;
@dynamic doctor_Name;
@dynamic postedOn;
@dynamic postedReplyId;
@dynamic url;
@dynamic message_id;
@dynamic member_id;
@dynamic group_id;
@dynamic message;
@dynamic message_type;
@dynamic post_date;
@dynamic receiver_Id;
@dynamic topic_id;
@dynamic share_date;
@dynamic contactRelationship;
@dynamic groupRelationship;
@dynamic sharePostRelationship;

- (void)setMessage_id:(NSNumber *)message_id {
    [self willChangeValueForKey:@"message_id"];
    [self setPrimitiveValue:message_id forKey:@"message_id"];
    [self didChangeValueForKey:@"message_id"];
    
    NSInteger replyId = 0;
    if (message_id != nil) {
        replyId = message_id.longValue;
    }
    self.postedReplyId = [NSNumber numberWithLong:replyId];
}

- (void)setMember_id:(NSNumber *)member_id {
    NSInteger tempMemberid = 0;
    if (member_id != nil) {
        tempMemberid = member_id.longValue;
    }
    
    self.contactId = [NSNumber numberWithLong:tempMemberid];
}

- (void)setGroup_id:(NSNumber *)group_id {
    NSInteger tempGroupId = 0;
    if (group_id != nil) {
        tempGroupId = group_id.longValue;
    }
    
    self.groupId = [NSNumber numberWithLong:tempGroupId];
    
    if (tempGroupId > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %ld", @"group_id", tempGroupId];
        MRGroup *group = [[MRDataManger sharedManager] fetchObject:kGroupEntity
                                                             predicate:predicate
                                                             inContext:self.managedObjectContext];
        
        [self setGroupRelationship:group];
    }
}

- (void)setPost_date:(NSDate *)post_date {
    self.postedOn = post_date;
}

- (void)setReceiver_Id:(NSNumber *)receiver_Id {
    NSInteger tempReceiverId = 0;
    if (receiver_Id != nil) {
        tempReceiverId = receiver_Id.longValue;
    }
    
    self.contactId = [NSNumber numberWithLong:tempReceiverId];
}

- (void)setMessage:(NSString *)message {
    message = [self stripOutHTMLTags:message];
    
    [self willChangeValueForKey:@"message"];
    [self setPrimitiveValue:message forKey:@"message"];
    [self didChangeValueForKey:@"message"];
}


- (void)setContactId:(NSNumber *)contactId {
    [self willChangeValueForKey:@"contactId"];
    [self setPrimitiveValue:contactId forKey:@"contactId"];
    [self didChangeValueForKey:@"contactId"];
    
    if (contactId != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %ld", @"doctorId", contactId.longValue];
        MRContact *contact = [[MRDataManger sharedManager] fetchObject:kContactEntity
                                                                 predicate:predicate
                                                                 inContext:self.managedObjectContext];
    
        [self setContactRelationship:contact];
    }
}

- (void)setTopic_id:(NSNumber *)topic_id {
    NSInteger tempTopicId = 0;
    if (topic_id != nil) {
        tempTopicId = topic_id.longValue;
    }
    
    self.parentSharePostId = [NSNumber numberWithLong:tempTopicId];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %ld", @"sharePostId", tempTopicId];
    MRSharePost *sharePost = [[MRDataManger sharedManager] fetchObject:kMRSharePost
                                    predicate:predicate
                                    inContext:self.managedObjectContext];
    [self setSharePostRelationship:sharePost];
}

- (void)setMessage_type:(NSString *)message_type {
    NSInteger tempContentType = kTransformContentTypeText;
    if (message_type != nil && message_type.length > 0) {
        if ([message_type caseInsensitiveCompare:@"TEXT"] == NSOrderedSame) {
            tempContentType = kTransformContentTypeText;
        } else if ([message_type caseInsensitiveCompare:@"IMAGE"] == NSOrderedSame) {
            tempContentType = kTransformContentTypeImage;
        }
    }
    self.contentType = [NSNumber numberWithInteger:tempContentType];
}

@end

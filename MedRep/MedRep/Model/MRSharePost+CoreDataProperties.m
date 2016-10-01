//
//  MRSharePost+CoreDataProperties.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/31/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRSharePost+CoreDataProperties.h"
#import "MRConstants.h"
#import "MRPostedReplies.h"

@implementation MRSharePost (CoreDataProperties)

@dynamic commentsCount;
@dynamic contactId;
@dynamic contentType;
@dynamic detailedText;
@dynamic doctor_Name;
@dynamic displayPicture;
@dynamic group_id;
@dynamic groupId;
@dynamic like;
@dynamic likesCount;
@dynamic member_id;
@dynamic message_id;
@dynamic message_type;
@dynamic messages;
@dynamic objectData;
@dynamic parentSharePostId;
@dynamic parentTransformPostId;
@dynamic post_date;
@dynamic postedOn;
@dynamic receiver_id;
@dynamic share_date;
@dynamic shareCount;
@dynamic sharedByProfileId;
@dynamic sharedByProfileName;
@dynamic sharePostId;
@dynamic shortText;
@dynamic source;
@dynamic titleDescription;
@dynamic topic_id;
@dynamic url;
@dynamic doctor_id;
@dynamic likes_count;
@dynamic comment_count;
@dynamic share_count;
@dynamic posted_on;
@dynamic parent_share_id;
@dynamic content_type;
@dynamic detail_desc;
@dynamic short_desc;
@dynamic title_desc;
@dynamic transform_post_id;
@dynamic postedReplies;

//- (void)setLike:(NSNumber *)like {
//    BOOL tempLike = false;
//    if (like != nil) {
//        tempLike = like.boolValue;
//    }
//    
//    [self willChangeValueForKey:@"like"];
//    [self setPrimitiveValue:[NSNumber numberWithBool:tempLike] forKey:@"like"];
//    [self didChangeValueForKey:@"like"];
//}

- (void)setLikes_count:(NSNumber *)likes_count {
    NSInteger tempLikes = [self updateValueOfKey:likes_count andKey:@"likes_count"];
    self.likesCount = [NSNumber numberWithLong:tempLikes];
}

- (void)setComment_count:(NSNumber *)comment_count {
    NSInteger tempLikes = [self updateValueOfKey:comment_count andKey:@"comment_count"];
    self.commentsCount = [NSNumber numberWithLong:tempLikes];
}

- (void)setShare_count:(NSNumber *)share_count {
    NSInteger tempLikes = [self updateValueOfKey:share_count andKey:@"share_count"];
    self.shareCount = [NSNumber numberWithLong:tempLikes];
}

- (NSInteger)updateValueOfKey:(NSNumber*)value andKey:(NSString*)key {
    NSInteger tempLikes = 0;
    if (value != nil) {
        tempLikes = value.longValue;
    }
    
    [self willChangeValueForKey:key];
    [self setPrimitiveValue:[NSNumber numberWithLong:tempLikes] forKey:key];
    [self didChangeValueForKey:key];
    
    return tempLikes;
}

- (void)setTopic_id:(NSNumber *)topic_id {
    NSInteger topicId = 0;
    if (topic_id != nil) {
        topicId = topic_id.longValue;
    }
    
    self.sharePostId = [NSNumber numberWithLong:topicId];
    self.parentSharePostId = [NSNumber numberWithLong:topicId];
    self.parentTransformPostId = [NSNumber numberWithLong:topicId];
}

-(void)setMember_id:(NSNumber *)member_id{
    self.sharedByProfileId = member_id;
    
}

-(void)setMessage_id:(NSString *)message_id{
    NSInteger tempMessageId = 0;
    if (message_id != nil) {
        tempMessageId = message_id.longLongValue;
    }
    self.sharePostId  = [NSNumber numberWithLongLong:tempMessageId];
}

-(void)setGroup_id:(NSNumber *)group_id{
    
    self.groupId = group_id;
}

-(void)setMessage_type:(NSString *)message_type {
    [self applyMessageType:message_type];
    
    [self willChangeValueForKey:@"message_type"];
    [self setPrimitiveValue:message_type forKey:@"message_type"];
    [self didChangeValueForKey:@"message_type"];
}

- (void)setMessages:(NSData *)messages {
    if (self.postedReplies.count > 0) {
        [self removePostedReplies:self.postedReplies];
    }
    
    NSArray *messagesList = nil;
    if ([messages isKindOfClass:[NSDictionary class]]) {
        messagesList = @[messages];
    } else if ([messages isKindOfClass:[NSArray class]]) {
        messagesList = (NSArray*)messages;
    }
    
    for (NSDictionary *message in messagesList) {
        id messageAttribute = [message objectOrNilForKey:@"message"];
        if ([messageAttribute isKindOfClass:[NSString class]]) {
            continue;
        }
        NSArray *messageRelationship = [MRWebserviceHelper parseRecords:[MRPostedReplies class]
                                                             allRecords:nil
                                                                context:self.managedObjectContext
                                                                andData:@[messageAttribute]];
        if (messageRelationship != nil && messageRelationship.count > 0) {
            [self addPostedReplies:[NSSet setWithArray:messageRelationship]];
        }
    }
}

- (void)setContent_type:(NSString *)content_type {
    [self applyMessageType:content_type];
    [self setMessage_type:content_type];
}

- (void)applyMessageType:(NSString*)message_type {
    if ([message_type caseInsensitiveCompare:@"Image"] == NSOrderedSame) {
        self.contentType =[NSNumber numberWithInt: kTransformContentTypeImage] ;
    } else if ([message_type caseInsensitiveCompare:@"PDF"] == NSOrderedSame) {
        self.contentType =[NSNumber numberWithInt: kTransformContentTypePDF] ;
    } else if ([message_type caseInsensitiveCompare:@"Video"] == NSOrderedSame) {
        self.contentType =[NSNumber numberWithInt: kTransformContentTypeVideo] ;
    } else {
         self.contentType =[NSNumber numberWithInt: kTransformContentTypeText];
    }
}

-(void)setPost_date:(NSDate *)post_date {
    self.postedOn =  post_date;
}

- (void)setPosted_on:(NSDate *)posted_on {
    self.postedOn = posted_on;
}

- (void)setTitle_desc:(NSString *)title_desc {
    self.titleDescription = title_desc;
}

- (void)setDoctor_Name:(NSString *)doctor_Name {
    self.sharedByProfileName = doctor_Name;
    
    [self willChangeValueForKey:@"doctor_Name"];
    [self setPrimitiveValue:doctor_Name forKey:@"doctor_Name"];
    [self didChangeValueForKey:@"doctor_Name"];
}

- (void)setTransform_post_id:(NSNumber *)transform_post_id {
    NSInteger postId = 0;
    if (transform_post_id != nil) {
        postId = transform_post_id.longLongValue;
        self.source = @"Transform";
    }
    
    self.parentTransformPostId = [NSNumber numberWithLongLong:postId];
}

@end

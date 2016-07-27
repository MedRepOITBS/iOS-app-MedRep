//
//  MRSharePost+CoreDataProperties.m
//  MedRep
//
//  Created by Namit Nayak on 7/27/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRSharePost+CoreDataProperties.h"
#import "MRConstants.h"
@implementation MRSharePost (CoreDataProperties)

@dynamic commentsCount;
@dynamic contactId;
@dynamic contentType;
@dynamic detailedText;
@dynamic groupId;
@dynamic likesCount;
@dynamic objectData;
@dynamic parentSharePostId;
@dynamic parentTransformPostId;
@dynamic postedOn;
@dynamic shareCount;
@dynamic sharedByProfileId;
@dynamic sharedByProfileName;
@dynamic shareddByProfilePic;
@dynamic sharePostId;
@dynamic shortText;
@dynamic source;
@dynamic titleDescription;
@dynamic url;
@dynamic member_id;
@dynamic message_id;
@dynamic group_id;
@dynamic message;
@dynamic message_type;
@dynamic post_date;
@dynamic receiver_id;
@dynamic topic_id;
@dynamic share_date;
@dynamic postedReplies;



-(void)setMessage:(NSString *)message{
    
    self.titleDescription = message;
    
}

-(void)setMember_id:(NSNumber *)member_id{
    self.sharedByProfileId = member_id;
    
}

-(void)setMessage_id:(NSString *)message_id{
    self.parentSharePostId  = message_id;
}
-(void)setGroup_id:(NSNumber *)group_id{
    
    self.groupId = group_id;
}
-(void)setMessage_type:(NSString *)message_type{
    
    if ([message_type isEqualToString:@"Text"]) {
        self.contentType =[NSNumber numberWithInt: kTransformContentTypeText] ;
    }
    
    
}


-(void)setPost_date:(NSDate *)post_date{
    
    self.postedOn =  post_date;
    
}

//-(void)setReceiver_id:(NSNumber *)receiver_id{
//    
//    
//}
//
//-(void)setTopic_id:(NSNumber *)topic_id{
//    
//    
//    
//}
//
//-(void)setShare_date:(NSDate *)share_date{
//    
//    
//}





@end

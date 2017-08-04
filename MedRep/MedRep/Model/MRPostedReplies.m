//
//  MRPostedReplies.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/8/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRPostedReplies.h"
#import "MRContact.h"
#import "MRGroup.h"
#import "MRSharePost.h"

@implementation MRPostedReplies

// Insert code here to add functionality to your managed object subclass

+ (NSString*)primaryKeyColumnName {
    return @"message_id";
}

@end

//
//  MRContact.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/7/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRContact.h"
#import "MRGroup.h"
#import "MRGroupPost.h"
#import "MRPostedReplies.h"

@implementation MRContact

// Insert code here to add functionality to your managed object subclass

+ (NSString*)primaryKeyColumnName {
    return @"contactId";
}

@end

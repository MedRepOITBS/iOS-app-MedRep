//
//  MRGroupMembers.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/12/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRGroupMembers.h"

@implementation MRGroupMembers

@synthesize allGroups;

// Insert code here to add functionality to your managed object subclass

+ (NSString*)primaryKeyColumnName {
    return @"member_id";
}

@end

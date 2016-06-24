//
//  MRGroupObject.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/14/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRGroupObject.h"
#import "MRGroupUserObject.h"

@implementation MRGroupObject

- (id) init {
    self = [super init];
    
    if(self)
    {
        self.group_name = @"";
        self.admin_id = @"";
        self.group_long_desc = @"";
        self.group_short_desc = @"";
        self.group_img_data = @"";
        self.group_mimeType = @"";
        self.group_id = @"";
        
        _member = [NSMutableArray array];
    }
    
    return self;
}

- (id) initWithDict:(NSDictionary*)infoDictionary {
    self = [self init] ;
    
    if(self)
    {
        self.group_name = [[infoDictionary objectForKey:@"group_name"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"group_name"] : @"";
        self.admin_id = [infoDictionary objectForKey:@"admin_id"];
        self.group_long_desc = [[infoDictionary objectForKey:@"group_long_desc"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"group_long_desc"] : @"";
        self.group_short_desc = [[infoDictionary objectForKey:@"group_short_desc"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"group_short_desc"] : @"";
        self.group_img_data = [[infoDictionary objectForKey:@"group_img_data"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"group_img_data"] : @"";
        self.group_mimeType = [[infoDictionary objectForKey:@"group_mimeType"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"group_mimeType"] : @"";
        self.group_id = [infoDictionary objectForKey:@"group_id"];
        
        NSArray *memberData = [[infoDictionary objectForKey:@"member"] isKindOfClass:[NSArray class]] ? [infoDictionary objectForKey:@"member"] : @[];
        
        for (NSDictionary *dic in memberData) {
            [_member addObject:[[MRGroupUserObject alloc] initWithDict:dic]];
        }
    }
    
    return self;
}

@end

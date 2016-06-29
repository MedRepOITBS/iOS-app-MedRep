//
//  MRGroupUserObject.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/14/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRGroupUserObject.h"

@implementation MRGroupUserObject

- (id) init {
    self = [super init];
    
    if(self)
    {
        self.middleName = @"";
        self.firstName = @"";
        self.lastName = @"";
        self.title = @"";
        self.mobileNo = @"";
        self.emailId = @"";
        self.alternateEmailId = @"";
        self.status = @"";
        self.imgData = @"";
        self.mimeType = @"";
        self.therapeuticName = @"";
        self.member_id = @"";
        self.doctorId = @"";
        self.displayName = @"";
        self.therapeuticId = @"";
        self.therapeuticArea = @"";
        self.dPicture = @"";
        self.userId = @"";
        self.contactId = @"";
        self.city = @"";
    }
    
    return self;
}

- (id) initWithDict:(NSDictionary*)infoDictionary {
    self = [self init] ;
    
    if(self)
    {
        self.firstName = [[infoDictionary objectForKey:@"firstName"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"firstName"] : @"";
        self.middleName = [[infoDictionary objectForKey:@"middleName"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"middleName"] : @"";
        self.lastName = [[infoDictionary objectForKey:@"lastName"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"lastName"] : @"";
        self.title = [[infoDictionary objectForKey:@"title"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"title"] : @"";
        self.mobileNo = [[infoDictionary objectForKey:@"mobileNo"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"mobileNo"] : @"";
        self.emailId = [[infoDictionary objectForKey:@"emailId"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"emailId"] : @"";
        self.alternateEmailId = [[infoDictionary objectForKey:@"alternateEmailId"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"alternateEmailId"] : @"";
        self.status = [[infoDictionary objectForKey:@"status"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"status"] : @"";
        self.imgData = [[infoDictionary objectForKey:@"data"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"data"] : @"";
        self.mimeType = [[infoDictionary objectForKey:@"mimeType"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"mimeType"] : @"";
        self.therapeuticName = [[infoDictionary objectForKey:@"therapeuticName"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"therapeuticName"] : @"";
        self.therapeuticArea = [[infoDictionary objectForKey:@"therapeuticArea"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"therapeuticArea"] : @"";
        self.city = [[infoDictionary objectForKey:@"city"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"city"] : @"";
        self.member_id = [infoDictionary objectForKey:@"member_id"];
        self.doctorId = [infoDictionary objectForKey:@"doctorId"];
        self.userId = [infoDictionary objectForKey:@"userId"];
        self.contactId = [infoDictionary objectForKey:@"contactId"];
        self.displayName = [[infoDictionary objectForKey:@"displayName"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"displayName"] : @"";
        self.therapeuticId = [[infoDictionary objectForKey:@"therapeuticId"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"therapeuticId"] : @"";
        
        if (!self.imgData.length) {
            NSDictionary *profileDict = [infoDictionary objectForKey:@"profilePicture"];
            if (profileDict) {
                self.imgData = [[profileDict objectForKey:@"data"] isKindOfClass:[NSString class]] ? [profileDict objectForKey:@"data"] : @"";
            }else{
                self.imgData = [[infoDictionary objectForKey:@"dPicture"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"dPicture"] : @"";
            }
        }
    }
    
    return self;
}

@end

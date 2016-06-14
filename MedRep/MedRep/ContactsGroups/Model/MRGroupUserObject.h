//
//  MRGroupUserObject.h
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/14/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRGroupUserObject : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *middleName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *mobileNo;
@property (nonatomic, strong) NSString *emailId;
@property (nonatomic, strong) NSString *alternateEmailId;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *imgData;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *therapeuticName;

- (id) initWithDict:(NSDictionary*)infoDictionary;

@end
//
//  MRGroupObject.h
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/14/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRGroupObject : NSObject

@property (nonatomic, strong) NSString *group_id;
@property (nonatomic, strong) NSString *group_name;
@property (nonatomic, strong) NSString *admin_id;
@property (nonatomic, strong) NSString *group_long_desc;
@property (nonatomic, strong) NSString *group_short_desc;
@property (nonatomic, strong) NSString *group_img_data;
@property (nonatomic, strong) NSString *group_mimeType;

- (id) initWithDict:(NSDictionary*)infoDictionary;


@end

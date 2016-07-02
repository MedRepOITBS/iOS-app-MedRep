//
//  MRDrugDetailModel.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 7/2/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRDrugDetailModel.h"

@implementation MRDrugDetailModel

- (id) init {
    self = [super init];
    
    if(self)
    {
        self.brand = @"";
        self.category = @"";
        self.d_class = @"";
        self.generic_id = @"";
        self.idMedicine = @"";
        self.package_qty = @"";
        self.manufacturer = @"";
        self.package_price = @"";
        self.package_type = @"";
        self.unit_price = @"";
        self.unit_type = @"";
        self.unit_qty = @"";
    }
    
    return self;
}

- (id) initWithDict:(NSDictionary*)infoDictionary {
    self = [self init] ;
    
    if(self)
    {
        self.brand = [[infoDictionary objectForKey:@"brand"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"brand"] : @"";
        self.category = [[infoDictionary objectForKey:@"category"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"category"] : @"";
        self.d_class = [[infoDictionary objectForKey:@"d_class"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"d_class"] : @"";
        self.generic_id = [infoDictionary objectForKey:@"generic_id"];
        self.idMedicine = [infoDictionary objectForKey:@"id"];
        self.package_qty = [infoDictionary objectForKey:@"package_qty"];
        self.manufacturer = [[infoDictionary objectForKey:@"manufacturer"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"manufacturer"] : @"";
        self.package_price = [infoDictionary objectForKey:@"package_price"];
        self.package_type = [[infoDictionary objectForKey:@"package_type"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"package_type"] : @"";
        self.unit_price = [infoDictionary objectForKey:@"unit_price"];
        self.unit_qty = [infoDictionary objectForKey:@"unit_qty"];
        self.unit_type = [[infoDictionary objectForKey:@"unit_type"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"unit_type"] : @"";
    }
    
    return self;
}

@end

@implementation MRDrugConstituentsModel

- (id) init {
    self = [super init];
    
    if(self)
    {
        self.name = @"";
        self.qty = @"";
        self.strength = @"";
        self.generic_id = @"";
        self.idConstituent = @"";
    }
    
    return self;
}

- (id) initWithDict:(NSDictionary*)infoDictionary {
    self = [self init] ;
    
    if(self)
    {
        self.name = [[infoDictionary objectForKey:@"name"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"name"] : @"";
        self.qty = [infoDictionary objectForKey:@"qty"];
        self.strength = [[infoDictionary objectForKey:@"strength"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"strength"] : @"";
        self.generic_id = [[infoDictionary objectForKey:@"generic_id"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"generic_id"] : @"";
        self.idConstituent = [infoDictionary objectForKey:@"id"];
    }
    
    return self;
}

@end

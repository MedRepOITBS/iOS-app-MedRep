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
        self.brand = [[infoDictionary objectForKey:@"name"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"name"] : @"";
        
        self.package_type = [[infoDictionary objectForKey:@"form"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"form"] : @"";
        self.unit_price = [infoDictionary objectForKey:@"price"];
        self.generic_id = [infoDictionary objectForKey:@"medicine_id"];
        self.idMedicine = [infoDictionary objectForKey:@"medicine_id"];
        self.unit_qty = [infoDictionary objectForKey:@"standardUnits"];
        self.unit_type = [[infoDictionary objectForKey:@"packageForm"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"packageForm"] : @"";
        
        self.category = [[infoDictionary objectForKey:@"packageForm"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"packageForm"] : @"";
        self.d_class = [[infoDictionary objectForKey:@"form"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"form"] : @"";
        self.package_qty = [infoDictionary objectForKey:@"size"];
        self.manufacturer = [[infoDictionary objectForKey:@"manufacturer"] isKindOfClass:[NSString class]] ? [infoDictionary objectForKey:@"manufacturer"] : @"";
        self.package_price = [infoDictionary objectForKey:@"price"];
        
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

- (id) initWithDict:(NSDictionary*)constituent {
    self = [self init] ;
    
    if(self)
    {
        if (constituent != nil) {
            self.name = [[constituent objectForKey:@"name"] isKindOfClass:[NSString class]] ? [constituent objectForKey:@"name"] : @"";
            self.strength = [[constituent objectForKey:@"strength"] isKindOfClass:[NSString class]] ? [constituent objectForKey:@"strength"] : @"";
        } else {
            self.name = @"";
            self.strength = @"";
        }
        
        self.qty = [constituent objectForKey:@"size"];
        self.generic_id = [[constituent objectForKey:@"generic_id"] isKindOfClass:[NSString class]] ? [constituent objectForKey:@"medicine_id"] : @"";
        self.idConstituent = [constituent objectForKey:@"id"];
        
        
    }
    
    return self;
}

@end

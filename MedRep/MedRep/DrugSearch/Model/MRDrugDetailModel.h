//
//  MRDrugDetailModel.h
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 7/2/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRDrugDetailModel : NSObject

@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *d_class;
@property (nonatomic, strong) NSString *generic_id;
@property (nonatomic, strong) NSString *idMedicine;
@property (nonatomic, strong) NSString *package_qty;
@property (nonatomic, strong) NSString *manufacturer;
@property (nonatomic, strong) NSString *package_price;
@property (nonatomic, strong) NSString *package_type;
@property (nonatomic, strong) NSString *unit_price;
@property (nonatomic, strong) NSString *unit_qty;
@property (nonatomic, strong) NSString *unit_type;

- (id) initWithDict:(NSDictionary*)infoDictionary;

@end

@interface MRDrugConstituentsModel : NSObject

@property (nonatomic, strong) NSString *generic_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *qty;
@property (nonatomic, strong) NSString *strength;
@property (nonatomic, strong) NSString *idConstituent;

- (id) initWithDict:(NSDictionary*)infoDictionary;

@end

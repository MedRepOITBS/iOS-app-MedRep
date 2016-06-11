//
//  MRRole.h
//  MedRep
//
//  Created by MedRep Developer on 03/10/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MRRole : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * roleDescription;
@property (nonatomic, retain) NSNumber * roleId;
@property (nonatomic, retain) NSString * authority;

@end

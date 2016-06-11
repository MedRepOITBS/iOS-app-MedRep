//
//  MRNotificationType.h
//  MedRep
//
//  Created by MedRep Developer on 03/10/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MRNotificationType : NSManagedObject

@property (nonatomic, retain) NSNumber * typeId;
@property (nonatomic, retain) NSString * typeName;
@property (nonatomic, retain) NSString * typeDesc;

@end

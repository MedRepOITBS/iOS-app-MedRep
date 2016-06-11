//
//  MRTherapeuticArea.h
//  MedRep
//
//  Created by MedRep Developer on 03/10/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MRTherapeuticArea : NSManagedObject

@property (nonatomic, retain) NSNumber * therapeuticId;
@property (nonatomic, retain) NSString * therapeuticName;
@property (nonatomic, retain) NSString * therapeuticDesc;

@end

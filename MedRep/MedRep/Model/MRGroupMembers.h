//
//  MRGroupMembers.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/12/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MRManagedObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRGroupMembers : MRManagedObject

// Insert code here to declare functionality of your managed object subclass
@property (nonatomic) NSArray *allGroups;

@end

NS_ASSUME_NONNULL_END

#import "MRGroupMembers+CoreDataProperties.h"

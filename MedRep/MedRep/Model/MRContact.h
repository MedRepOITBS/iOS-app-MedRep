//
//  MRContact.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/7/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MRManagedObject.h"

@class MRManagedObject, MRGroup, MRGroupPost, MRPostedReplies;

NS_ASSUME_NONNULL_BEGIN

@interface MRContact : MRManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "MRContact+CoreDataProperties.h"

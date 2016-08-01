//
//  MRProfile.h
//  MedRep
//
//  Created by Namit Nayak on 7/31/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EducationalQualifications, MRInterestArea, MRPublications, MRWorkExperience;

NS_ASSUME_NONNULL_BEGIN

@interface MRProfile : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "MRProfile+CoreDataProperties.h"

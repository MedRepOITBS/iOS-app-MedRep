//
//  MRTransformPageData+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 9/3/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRTransformPageData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRTransformPageData (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *subCategories;
@property (nullable, nonatomic, retain) NSData *transforms;

@end

NS_ASSUME_NONNULL_END

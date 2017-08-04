//
//  MRTransformPageData+CoreDataProperties.m
//  MedRep
//
//  Created by Vamsi Katragadda on 9/3/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRTransformPageData+CoreDataProperties.h"
#import "MRDataManger.h"
#import "TransformSubCategories.h"
#import "MRWebserviceHelper.h"
#import "MRTransformPost.h"

@implementation MRTransformPageData (CoreDataProperties)

@dynamic subCategories;
@dynamic transforms;

- (void)setSubCategories:(NSData *)subCategories {
    [[MRDataManger sharedManager] removeAllObjects:NSStringFromClass(TransformSubCategories.class)
                                     withPredicate:nil];
    if ([subCategories isKindOfClass:[NSArray class]]) {
        
        MRDataManger *dbManager = [MRDataManger sharedManager];
        
        NSString *entityName = NSStringFromClass(TransformSubCategories.class);
        NSEntityDescription *entityDescription = [[[dbManager managedObjectModel] entitiesByName] objectForKey:entityName];
        
        NSArray *tempList = (NSArray*)subCategories;
        for (NSString *category in tempList) {
            TransformSubCategories *entity =
                    (TransformSubCategories*)[[MRManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
            entity.title = category;
        }
    }
}

- (void)setTransforms:(NSData *)transforms {
    [[MRDataManger sharedManager] removeAllObjects:kMRTransformPost
                                     withPredicate:nil];
    [MRWebserviceHelper parseRecords:MRTransformPost.class
                          allRecords:nil
                             context:self.managedObjectContext
                             andData:(NSArray*)transforms];
}

@end

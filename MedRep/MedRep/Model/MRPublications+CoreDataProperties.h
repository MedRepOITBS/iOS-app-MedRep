//
//  MRPublications+CoreDataProperties.h
//  MedRep
//
//  Created by Namit Nayak on 8/12/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRPublications.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRPublications (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *articleName;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSString *publication;
@property (nullable, nonatomic, retain) NSString *year;
@property (nullable, nonatomic, retain) NSString *url;

@end

NS_ASSUME_NONNULL_END

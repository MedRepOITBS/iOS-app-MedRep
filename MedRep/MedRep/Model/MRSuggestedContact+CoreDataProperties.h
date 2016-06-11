//
//  MRSuggestedContact+CoreDataProperties.h
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/21/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRSuggestedContact.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRSuggestedContact (CoreDataProperties)

@property (nonatomic) int64_t contactId;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *role;
@property (nullable, nonatomic, retain) NSString *profilePic;

@end


NS_ASSUME_NONNULL_END

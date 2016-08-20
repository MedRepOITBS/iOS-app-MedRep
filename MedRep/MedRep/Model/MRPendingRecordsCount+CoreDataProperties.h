//
//  MRPendingRecordsCount+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 8/20/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRPendingRecordsCount.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRPendingRecordsCount (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *pendingConnections;
@property (nullable, nonatomic, retain) NSNumber *pendingGroups;

@end

NS_ASSUME_NONNULL_END

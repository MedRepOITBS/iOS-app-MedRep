//
//  MRGroup+CoreDataProperties.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/8/16.
//  Copyright © 2016 MedRep. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MRGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRGroup (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *group_id;
@property (nullable, nonatomic, retain) NSData *group_img_data;
@property (nullable, nonatomic, retain) NSString *group_name;
@property (nullable, nonatomic, retain) NSNumber *admin_id;
@property (nullable, nonatomic, retain) NSString *group_long_desc;
@property (nullable, nonatomic, retain) NSString *group_short_desc;
@property (nullable, nonatomic, retain) NSString *group_mime_type;
@property (nullable, nonatomic, retain) NSData *member;
@property (nullable, nonatomic, retain) NSSet<MRContact *> *contacts;

@end

@interface MRGroup (CoreDataGeneratedAccessors)

- (void)addContactsObject:(MRContact *)value;
- (void)removeContactsObject:(MRContact *)value;
- (void)addContacts:(NSSet<MRContact *> *)values;
- (void)removeContacts:(NSSet<MRContact *> *)values;

@end

NS_ASSUME_NONNULL_END

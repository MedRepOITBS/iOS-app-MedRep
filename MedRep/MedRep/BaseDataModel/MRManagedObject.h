//
//  MRManagedObject.h
//
//
//

#import <CoreData/CoreData.h>

@protocol MRManagedObject<NSObject>

@property (strong, nonatomic, readonly) NSString *className;
@property (strong, nonatomic, readonly) NSString *primaryKeyColumnName;
@property (strong, nonatomic, readonly) NSString *primaryKeyValue;

@property (strong, nonatomic) NSDate *lastRefreshedDate;

- (NSManagedObjectContext *)managedObjectContext;

+ (NSString *)primaryKeyColumnName;

+ (NSString *)getActualColumnName:(NSString*)aliasName;

- (NSDictionary *)toDictionary;

- (void)updateFromDictionary:(NSDictionary *)dictionary;

- (NSString *)toJSON;

- (float)sizeInBytes;

- (NSString*)stripOutHTMLTags:(NSString*)originalString;

@end

@interface MRManagedObject : NSManagedObject<MRManagedObject>

@end
 
//
//  MRManagedObject.m
//  
//
//

#import "MRManagedObject.h"
#import "NSDictionary+CaseInsensitive.h"
#import "NSDate+Utilities.h"
#import <malloc/malloc.h>
#import <objc/runtime.h>
#import "NSData+Base64Additions.h"

NSString* const kServerDateFormat = @"yyyy-MM-dd'T'HH:mm:ss";

@implementation MRManagedObject

NSString *const kLastRefreshedDateAttributeName = @"lastRefreshedDate";

- (NSManagedObjectContext *)managedObjectContext
{
	return [super managedObjectContext];
}

+ (NSString *)primaryKeyColumnName
{
    [NSException raise:@"You need to derive and override the primaryKeyColumnName" format:@""];
    
    return nil;
}

- (NSString *)className
{
	return [NSString stringWithUTF8String:class_getName([self class])];
}

- (NSString *)primaryKeyColumnName
{
	return [[self class] primaryKeyColumnName];
}

- (NSString *)primaryKeyValue
{
	return [self valueForKey:[self primaryKeyColumnName]];
}

- (NSDictionary *)toDictionary
{
	NSArray *attributes = [[[self entity] attributesByName] allKeys];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[attributes count] + 1];

	for (NSString *attr in attributes)
	{
		NSObject *value = [self valueForKey:attr];

		/*if ([value isKindOfClass:[NSDate class]])
		{
			NSDate *dateValue = (NSDate *)value;
			value = [dateValue dotNetStringValue];
		}
        else */if ([value isKindOfClass:[NSData class]] || [value isKindOfClass:[NSMutableData class]])
        {
            value = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData*)value];
        }

		if (value)
		{
			[dict setObject:value forKey:attr];
		}
	}

	return dict;
}

- (CGFloat)sizeInBytes
{
	float totalSize = 0;
	NSArray *attributes = [[[self entity] attributesByName] allKeys];
	for (NSString *attr in attributes)
	{
		NSObject *value = [self valueForKey:attr];
		totalSize += malloc_size((__bridge const void *)(value));
	}
	return totalSize;
}

- (void)updateFromDictionary:(NSDictionary *)dictionary
{
	[self safeSetValuesForKeysWithDictionary:dictionary];
}

- (void)safeSetValuesForKeysWithDictionary:(NSDictionary *)keyedValues
{
	NSDictionary *attributes = [[self entity] attributesByName];
    for (NSString *attribute in attributes)
	{
		id value = [keyedValues objectForCaseInsensitiveKey:attribute];

		if (!value)
		{
			continue;
		}

		if (value == [NSNull null])
		{
			value = nil;
		}

		NSAttributeType attributeType = [[attributes objectForKey:attribute] attributeType];
		if (attributeType == NSStringAttributeType && [value isKindOfClass:[NSNumber class]])
		{
			value = [value stringValue];
		}
        else if ((attributeType == NSBooleanAttributeType) && [value isKindOfClass:[NSString class]])
        {
            value = [NSNumber numberWithBool:[value boolValue]];
        }
		else if ((attributeType == NSInteger16AttributeType || attributeType == NSInteger32AttributeType || attributeType == NSInteger64AttributeType || attributeType == NSBooleanAttributeType) && [value isKindOfClass:[NSString class]])
		{
			value = [NSNumber numberWithInteger:[value integerValue]];
		}
		else if ((attributeType == NSFloatAttributeType || attributeType == NSDoubleAttributeType || attributeType == NSDecimalAttributeType) && [value isKindOfClass:[NSString class]])
		{
			value = [NSNumber numberWithDouble:[value doubleValue]];
		}
        else if (attributeType == NSDateAttributeType)
        {
            if ([value isKindOfClass:[NSString class]])
            {
                value = [NSDate convertStringToNSDate:value dateFormat:kServerDateFormat];
            }
            else if ([value isKindOfClass:[NSNumber class]])
            {
                NSNumber *dateValue = value;
                value = [[NSDate alloc]initWithTimeIntervalSince1970:(dateValue.doubleValue/1000)];
            }
        } else if (attributeType == NSBinaryDataAttributeType) {
            if ([value isKindOfClass:[NSString class]]) {
                value = [NSData decodeBase64ForString:value];
            }
        }

        //if (value)
        {
            [self setValue:value forKey:attribute];
        }
	}
}

- (NSDate *)lastRefreshedDate
{
	if (![[[self entity] attributesByName] objectForKey:@"lastRefreshedDate"])
	{
		return nil;
	}

	return [super primitiveValueForKey:@"lastRefreshedDate"];
}

- (void)setLastRefreshedDate:(NSDate *)lastRefreshedDate
{
	if (![[[self entity] attributesByName] objectForKey:@"lastRefreshedDate"])
	{
		return;
	}

	[self willChangeValueForKey:@"lastRefreshedDate"];
	[super setPrimitiveValue:lastRefreshedDate forKey:@"lastRefreshedDate"];
	[self didChangeValueForKey:@"lastRefreshedDate"];
}

- (void)awakeFromInsert
{
	[super awakeFromInsert];

	if ([[[self entity] attributesByName] objectForKey:@"lastRefreshedDate"])
	{
		[self setPrimitiveValue:[NSDate date] forKey:@"lastRefreshedDate"];
	}
}

- (NSString *)toJSON
{
	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self toDictionary]
													   options:NSJSONWritingPrettyPrinted
														 error:&error];

	if (error)
	{
		NSLog(@"Error serializing JSON %@.", error);
		return nil;
	}

	return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end

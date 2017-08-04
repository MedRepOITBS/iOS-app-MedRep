//
//  NSDictionary+CaseInsensitive.m
// 
//
//

#import "NSDictionary+CaseInsensitive.h"

@implementation NSDictionary (CaseInsensitive)

- (id)objectForCaseInsensitiveKey:(id)aKey
{
	for (NSString *key in self.allKeys)
	{
		if ([key compare:aKey options:NSCaseInsensitiveSearch] == NSOrderedSame)
		{
			return [self objectForKey:key];
		}
	}
	return nil;
}

@end

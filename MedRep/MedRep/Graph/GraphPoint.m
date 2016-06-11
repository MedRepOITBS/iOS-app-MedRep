//
//  GraphPoint.m
//  MedRep
//
//  Created by MedRep Developer on 16/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "GraphPoint.h"


@implementation GraphPoint
@synthesize x;
@synthesize y;
@synthesize barColor;

- (id)init
{
	if (self = [super init])
	{
		x = 0;
		y = 0;
		barColor = nil;
	}
	return self;
}

@end

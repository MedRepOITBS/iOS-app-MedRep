//
//  GraphPoint.h
//  MedRep
//
//  Created by MedRep Developer on 16/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.

#import <Foundation/Foundation.h>
@import UIKit;

@interface GraphPoint : NSObject 
{
	CGFloat x;
	CGFloat y;
	UIColor *barColor;
}
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, retain) UIColor *barColor;

@end

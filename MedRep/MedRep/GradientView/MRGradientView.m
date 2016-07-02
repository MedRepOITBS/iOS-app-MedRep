//
//  MRGradientView.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/2/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRGradientView.h"
#import "MRCommon.h"

@implementation MRGradientView

- (void)drawRect:(CGRect)rect {
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat locations[] = {0.5, 0.84};
    
    CGColorRef startColor = [MRCommon colorFromHexString:@"0xF87D2D"].CGColor;
    CGColorRef endColor = [MRCommon colorFromHexString:@"0xF54D29"].CGColor;
    
    NSArray *colors = @[(__bridge id)startColor, (__bridge id)endColor];
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorspace,
                                                         (__bridge CFArrayRef)colors, locations);
    
    CGPoint startPoint = CGPointMake(rect.size.width * 0.22, rect.size.height * 0.34);
    CGPoint endPoint = CGPointMake(startPoint.x + (rect.size.width * 0.50) * cos(240),
                                   startPoint.y + (rect.size.width * 0.50) * cos(240));
    
    CGFloat startRadius = 0;
    CGFloat endRadius = 240;
    
    CGContextDrawRadialGradient(context, gradient, startPoint, startRadius, endPoint, endRadius, kCGGradientDrawsAfterEndLocation);
}

@end

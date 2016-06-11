//
//  GraphView.m
//  MedRep
//
//  Created by MedRep Developer on 16/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "GraphView.h"
#import "GraphPoint.h"

@interface GraphView (Private)
- (void)drawBackground:(CGRect)rect inContext:(CGContextRef)context;
- (void)extractColorComponent:(UIColor *)actualColor 
				 redComponent:(CGFloat *)redComponent 
			   greenComponent:(CGFloat *)greenComponent
				blueComponent:(CGFloat *)blueComponent 
			   alphaComponent:(CGFloat *)alphaComponent;
- (void)drawGraphLayoutInContext:(CGContextRef)context;
- (CGPoint)resetPointToPlot:(CGPoint)point;
- (void)plotPoint:(CGPoint)point inContext:(CGContextRef)context;
- (CGPoint)graphPointToPlotPoint:(CGPoint)point;
- (void)drawLineOnGraphFromPoint:(CGPoint)fromPoint
						 toPoint:(CGPoint)toPoint
					   inContext:(CGContextRef)context;
- (void)drawXScale:(CGContextRef)context;
- (void)drawYScale:(CGContextRef)context;
- (CGRect)graphAreaRect;

- (void)drawLineGraph:(CGRect)rect inContext:(CGContextRef)context;
- (void)drawBarGraph:(CGRect)rect inContext:(CGContextRef)context;
- (void)drawPieGraph:(CGRect)rect inContext:(CGContextRef)context;

- (void)drawBar:(CGPoint)aPoint color:(UIColor *)color inContext:(CGContextRef)context;
@end

@implementation GraphView
@synthesize graphBackgroundColor;
@synthesize graphPoints;
@synthesize leftBorder, bottomBorder;
@synthesize graphOrigin;
@synthesize showXScale;
@synthesize showYScale;
@synthesize axisLabelsX;
@synthesize axisLabelsY;
@synthesize scaleX;
@synthesize scaleY;
@synthesize showPointText;
@synthesize graphLineColor;
@synthesize graphPointColor;
@synthesize graphTextColor;
@synthesize graphTextBackgroundColor;
@synthesize gridSize;
@synthesize graphType;
@synthesize barColor;
@synthesize barBorderColor;
@synthesize showLegend;

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
	{
		self.backgroundColor = [UIColor clearColor];
		graphBackgroundColor = [UIColor whiteColor];
		leftBorder = 25;
		bottomBorder = 0;
		gridSize = 50;
		graphPoints = nil;
		graphOrigin = CGPointZero;
		
		showXScale = YES;
		showYScale = YES;
		showPointText = YES;
		
		graphLineColor = [UIColor greenColor];
		graphPointColor = [UIColor redColor] ;
		graphTextColor = [UIColor blackColor];
		graphTextBackgroundColor = [UIColor greenColor];
		
		scaleX = 10;
		scaleY = 10;
		
		graphType = GRAPH_TYPE_BAR;
		
		barColor = [UIColor greenColor];
		barBorderColor = [UIColor blackColor];
		
		showLegend = NO;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[self drawBackground:rect inContext:context];
	[self drawGraphLayoutInContext:context];
	
	switch(graphType)
	{
		case GRAPH_TYPE_BAR:
			[self drawBarGraph:rect inContext:context];
			break;
		case GRAPH_TYPE_NONE:
			break;
	}
}

- (void)dealloc 
{
}

#pragma mark -
#pragma mark graph type drawings

- (void)drawBarGraph:(CGRect)rect inContext:(CGContextRef)context
{
	for(NSInteger index = 0; index < [graphPoints count]; ++index)
	{
		GraphPoint *aPoint = [graphPoints objectAtIndex:index];
		aPoint.y -= graphOrigin.y;
		aPoint.x -= graphOrigin.x;
		
		[self drawBar:CGPointMake(aPoint.x / scaleX, aPoint.y / scaleY) 
				color:aPoint.barColor
			inContext:context];
        
        [self plotPoint:CGPointMake(aPoint.x / scaleX, aPoint.y / scaleY) inContext:context];
	}
	
	if (YES == showXScale)
	{
		[self drawXScale:context];
	}
	
	if (YES == showYScale)
	{
		[self drawYScale:context];
	}
}

#pragma mark -
#pragma mark Private
#pragma mark -

- (void)drawBar:(CGPoint)aPoint color:(UIColor *)color inContext:(CGContextRef)context
{
	CGRect borderRect = [self graphAreaRect];
	aPoint = [self graphPointToPlotPoint:aPoint];
	
	NSInteger height = borderRect.size.height - aPoint.y;
	CGRect rect = CGRectMake(aPoint.x, aPoint.y, 40, height);
	
	CGFloat colorRed = 0;
	CGFloat colorGreen = 0;
	CGFloat colorBlue = 0;
	CGFloat colorAlpha = 0;
	
	[self extractColorComponent:(nil == color) ? barColor : color
				   redComponent:&colorRed 
				 greenComponent:&colorGreen 
				  blueComponent:&colorBlue
				 alphaComponent:&colorAlpha];
	
	CGContextSetRGBFillColor(context, colorRed, colorGreen, colorBlue, colorAlpha);
	CGContextFillRect(context, rect);
	CGContextSetLineWidth(context, 0.3);
	CGContextSetStrokeColorWithColor(context, barBorderColor.CGColor);
	CGContextStrokePath(context);
	CGContextStrokeRect(context, rect);
}

- (void)drawBackground:(CGRect)rect inContext:(CGContextRef)context
{
	CGFloat colorRed = 0;
	CGFloat colorGreen = 0;
	CGFloat colorBlue = 0;
	CGFloat colorAlpha = 0;
	
	[self extractColorComponent:graphBackgroundColor
				   redComponent:&colorRed 
				 greenComponent:&colorGreen 
				  blueComponent:&colorBlue
				 alphaComponent:&colorAlpha];
	
	CGContextSetRGBFillColor(context, colorRed, colorGreen, colorBlue, colorAlpha);
	CGContextAddRect(context, rect);
	CGContextFillPath(context);	
	CGContextClosePath(context);
}

- (void)extractColorComponent:(UIColor *)actualColor
				 redComponent:(CGFloat *)redComponent 
			   greenComponent:(CGFloat *)greenComponent 
				blueComponent:(CGFloat *)blueComponent  
			   alphaComponent:(CGFloat *)alphaComponent
{
	CGColorRef color = [actualColor CGColor];
	const CGFloat *colorComponents = CGColorGetComponents(color);
	
	switch(CGColorGetNumberOfComponents(color))
	{
		case 2:
			{
				*redComponent = *greenComponent = *blueComponent = colorComponents[0];
				*alphaComponent = colorComponents[1];
			}
			break;
			
		case 4:
			{
				*redComponent = colorComponents[0];
				*greenComponent = colorComponents[1];
				*blueComponent = colorComponents[2];
				*alphaComponent = colorComponents[3];
			}
			break;
	}
}

- (void)drawGraphLayoutInContext:(CGContextRef)context
{
	CGRect borderRect = [self graphAreaRect];
	
	CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextSetLineWidth(context, 0.5);
	
//	CGContextAddRect(context, borderRect);
//	CGContextStrokePath(context);
	
	CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
	CGContextSetLineWidth(context, 0.1);
	
//	for(NSInteger index = borderRect.origin.x + gridSize; index < borderRect.origin.x + borderRect.size.width; index += gridSize)
//	{
//		CGContextMoveToPoint(context, index, borderRect.origin.y);
//		CGContextAddLineToPoint(context, index, borderRect.size.height);
//	}
	
	for(NSInteger index = borderRect.origin.y + gridSize; index < borderRect.origin.y + borderRect.size.height; index += gridSize)
	{
		CGPoint startPoint = [self resetPointToPlot:CGPointMake(borderRect.origin.x, index)];
		CGContextMoveToPoint(context, startPoint.x, startPoint.y);

		CGPoint endPoint = [self resetPointToPlot:CGPointMake(borderRect.size.height + bottomBorder, index)];
		CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
	}

	CGContextStrokePath(context);

}

- (CGPoint)resetPointToPlot:(CGPoint)point
{
	CGSize graphAreaSize = [self graphAreaRect].size;
	point.y = graphAreaSize.height - point.y;
	return point;
}

- (void)plotPoint:(CGPoint)point inContext:(CGContextRef)context
{
	CGPoint plotPoint = [self graphPointToPlotPoint:point];
	
	CGFloat colorRed = 0;
	CGFloat colorGreen = 0;
	CGFloat colorBlue = 0;
	CGFloat colorAlpha = 0;
	
	[self extractColorComponent:graphPointColor
				   redComponent:&colorRed 
				 greenComponent:&colorGreen 
				  blueComponent:&colorBlue
				 alphaComponent:&colorAlpha];
	
//	CGRect framePoint = CGRectMake(plotPoint.x - 3, plotPoint.y - 3, 0, 0);
//	
//	CGContextSetRGBFillColor(context, colorRed, colorGreen, colorBlue, colorAlpha);
//	CGContextFillEllipseInRect(context, framePoint);
//	CGContextSetLineWidth(context, 0.3);
//	CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
//	CGContextAddEllipseInRect(context, framePoint);
//	CGContextStrokePath(context);
	
	if (YES == showPointText)
	{
//		[self extractColorComponent:graphTextBackgroundColor
//					   redComponent:&colorRed 
//					 greenComponent:&colorGreen 
//					  blueComponent:&colorBlue
//					 alphaComponent:&colorAlpha];
//		
//		CGContextSetRGBFillColor(context, colorRed, colorGreen, colorBlue, colorAlpha);
//		CGContextFillRect(context, CGRectMake(plotPoint.x - 10, plotPoint.y - 12, 20, 8));
//		CGContextStrokeRect(context, CGRectMake(plotPoint.x - 10, plotPoint.y - 12, 20, 8));
//		CGContextStrokePath(context);
		
		[self extractColorComponent:graphTextColor
					   redComponent:&colorRed 
					 greenComponent:&colorGreen 
					  blueComponent:&colorBlue
					 alphaComponent:&colorAlpha];
		
		CGContextSetRGBFillColor(context, colorRed, colorGreen, colorBlue, colorAlpha);
		NSString *text = [NSString stringWithFormat:@"%.0f", point.y * scaleY + graphOrigin.y];
		[text drawAtPoint:CGPointMake(plotPoint.x + 15 , plotPoint.y - 25)
				 withFont:[UIFont systemFontOfSize:20]];
	}
}

- (void)drawLineOnGraphFromPoint:(CGPoint)fromPoint
						 toPoint:(CGPoint)toPoint 
					   inContext:(CGContextRef)context
{
	fromPoint = [self graphPointToPlotPoint:fromPoint];
	toPoint =[self graphPointToPlotPoint:toPoint];
	
	CGContextSetStrokeColorWithColor(context, graphLineColor.CGColor);
	CGContextSetLineWidth(context, 2.0);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextSetShouldAntialias(context, YES);
	CGContextSetAllowsAntialiasing(context, YES);
	CGContextMoveToPoint(context, fromPoint.x, fromPoint.y);
	CGContextAddLineToPoint(context, toPoint.x, toPoint.y);
	
	CGContextStrokePath(context);
}

- (CGPoint)graphPointToPlotPoint:(CGPoint)point
{
	point.x *= [UIScreen mainScreen].bounds.size.width / 8;
	point.y *= gridSize;
	
	point.x += leftBorder;

	point = [self resetPointToPlot:point];
	
	return point;
}

- (CGRect)graphAreaRect
{
	CGRect borderRect = self.frame;
	
	borderRect.origin.x = leftBorder;
	borderRect.origin.y = 0;
	borderRect.size.width -= leftBorder;// * 2;
	borderRect.size.height -= bottomBorder;// * 2;
	
	return borderRect;
}

- (void)drawXScale:(CGContextRef)context
{
	CGRect borderRect = [self graphAreaRect];
	
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
	
	NSInteger posX = borderRect.origin.x + gridSize;
	NSInteger posY = borderRect.origin.y;
	
	for(NSInteger index = 0; index < axisLabelsX.count; ++index, posX += gridSize)
	{
		CGPoint startPoint = [self resetPointToPlot:CGPointMake(posX, posY)];
		NSString *text = [axisLabelsX objectAtIndex:index];
		
		[text drawAtPoint:CGPointMake(startPoint.x - 10, startPoint.y + 3) 
				 withFont:[UIFont systemFontOfSize:7]];
	}
}

- (void)drawYScale:(CGContextRef)context
{
	CGRect borderRect = [self graphAreaRect];
	
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
	
	NSInteger posX = borderRect.origin.x;
	NSInteger posY = borderRect.origin.y + gridSize;
	
	for(NSInteger index = 0; index < axisLabelsY.count; ++index, posY += gridSize)
	{
		CGPoint startPoint = [self resetPointToPlot:CGPointMake(posX, posY)];
		NSString *text = [axisLabelsY objectAtIndex:index];
		
		[text drawAtPoint:CGPointMake(startPoint.x - 20, startPoint.y - 6) 
				 withFont:[UIFont systemFontOfSize:15]];
	}
	
}

@end

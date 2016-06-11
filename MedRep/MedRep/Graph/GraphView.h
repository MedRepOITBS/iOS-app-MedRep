//
//  GraphView.h
//  MedRep
//
//  Created by MedRep Developer on 16/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
	GRAPH_TYPE_NONE = 0,
	GRAPH_TYPE_BAR,
} GRAPH_TYPE;

@interface GraphView : UIView 
{
	UIColor *graphBackgroundColor;

	NSInteger leftBorder;
	NSInteger bottomBorder;
	NSInteger gridSize;
	NSArray *graphPoints;
	CGPoint graphOrigin;
	
	CGFloat scaleX;
	CGFloat scaleY;
	
	BOOL showXScale;
	BOOL showYScale;
	BOOL showPointText;
	
	NSArray *axisLabelsX;
	NSArray *axisLabelsY;
	
	UIColor *graphLineColor;
	UIColor *graphPointColor;
	UIColor *graphTextColor;
	UIColor *graphTextBackgroundColor;
	
	UIColor *barColor;
	UIColor *barBorderColor;
	
	GRAPH_TYPE graphType;
	BOOL showLegend;
}

@property (nonatomic, assign) GRAPH_TYPE graphType;
@property (nonatomic, retain) UIColor *graphBackgroundColor;
@property (nonatomic, assign) NSInteger leftBorder;
@property (nonatomic, assign) NSInteger bottomBorder;
@property (nonatomic, retain) NSArray *graphPoints;
@property (nonatomic, assign) CGPoint graphOrigin;
@property (nonatomic, assign) BOOL showXScale;
@property (nonatomic, assign) BOOL showYScale;
@property (nonatomic, assign) CGFloat scaleX;
@property (nonatomic, assign) CGFloat scaleY;
@property (nonatomic, retain) NSArray *axisLabelsX;
@property (nonatomic, retain) NSArray *axisLabelsY;
@property (nonatomic, assign) BOOL showPointText;
@property (nonatomic, retain) UIColor *graphLineColor;
@property (nonatomic, retain) UIColor *graphPointColor;
@property (nonatomic, retain) UIColor *graphTextColor;
@property (nonatomic, retain) UIColor *graphTextBackgroundColor;
@property (nonatomic, assign) NSInteger gridSize;
@property (nonatomic, retain) UIColor *barColor;
@property (nonatomic, retain) UIColor *barBorderColor;
@property (nonatomic, assign) BOOL showLegend;

@end

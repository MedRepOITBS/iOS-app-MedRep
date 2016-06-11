//
//  MRRegHeaderView.m
//  MedRep
//
//  Created by MedRep Developer on 24/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRRegHeaderView.h"

@implementation MRRegHeaderView

//	Purpose			:	Object creator method for MRRegHeaderView class.
//	Parameter		:	Nil
//	Return type     :	MRRegHeaderView*
//	Comments		:	Nil.
+ (MRRegHeaderView*)regHeaderView
{
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"MRRegHeaderView" owner:self options:nil];
    MRRegHeaderView *regHeaderView      = (MRRegHeaderView*)[nibViews lastObject];
    regHeaderView.backgroundColor       = [UIColor redColor];
    regHeaderView.exclusiveTouch        = YES;
    return regHeaderView;
}

- (IBAction)pickLocationButtonAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickLocationButtonActionDelegate:)])
    {
        [self.delegate pickLocationButtonActionDelegate:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)addButtonAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(addButtonClicked:)])
    {
        [self.delegate addButtonClicked:self.section];
    }
}

@end

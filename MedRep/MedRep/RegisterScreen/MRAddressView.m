//
//  MRAddressView.m
//  MedRep
//
//  Created by MedRep Developer on 18/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRAddressView.h"

@implementation MRAddressView


//	Purpose			:	Object creator method for MRAddressView class.
//	Parameter		:	Nil
//	Return type     :	MRAddressView*
//	Comments		:	Nil.
+ (MRAddressView*)addressView
{
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"MRAddressView" owner:self options:nil];
    MRAddressView *addressView   = (MRAddressView*)[nibViews lastObject];
    addressView.exclusiveTouch = YES;
    return addressView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

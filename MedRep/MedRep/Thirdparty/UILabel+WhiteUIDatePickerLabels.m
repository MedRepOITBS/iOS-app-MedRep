//
//  UILabel+WhiteUIDatePickerLabels.m
//  MedRep
//
//  Created by MedRep Developer on 15/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "UILabel+WhiteUIDatePickerLabels.h"
#import <objc/runtime.h>


/*
 I need similar for my app and have ended up going the long way round. It's a real shame there isn't an easier way to simply switch to a white text version of UIDatePicker.
 
 The code below uses a category on UILabel to force the label's text colour to be white when the setTextColor: message is sent to the label. In order to not do this for every label in the app I've filtered it to only apply if it's a subview of a UIDatePicker class. Finally, some of the labels have their colours set before they are added to their superviews. To catch these the code overrides the willMoveToSuperview: method.
 
 It would likely be better to split the below into more than one category but I've added it all here for ease of posting.*/




@implementation UILabel (WhiteUIDatePickerLabels)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceSelector:@selector(setTextColor:)
                      withNewSelector:@selector(swizzledSetTextColor:)];
        [self swizzleInstanceSelector:@selector(willMoveToSuperview:)
                      withNewSelector:@selector(swizzledWillMoveToSuperview:)];
    });
}

// Forces the text colour of the label to be white only for UIDatePicker and its components
-(void) swizzledSetTextColor:(UIColor *)textColor {
    if([self view:self hasSuperviewOfClass:[UIDatePicker class]] ||
       [self view:self hasSuperviewOfClass:NSClassFromString(@"UIDatePickerWeekMonthDayView")] ||
       [self view:self hasSuperviewOfClass:NSClassFromString(@"UIDatePickerContentView")]){
        [self swizzledSetTextColor:[UIColor whiteColor]];
    } else {
        //Carry on with the default
        [self swizzledSetTextColor:textColor];
    }
}

// Some of the UILabels haven't been added to a superview yet so listen for when they do.
- (void) swizzledWillMoveToSuperview:(UIView *)newSuperview {
    [self swizzledSetTextColor:self.textColor];
    [self swizzledWillMoveToSuperview:newSuperview];
}

// -- helpers --
- (BOOL) view:(UIView *) view hasSuperviewOfClass:(Class) class {
    if(view.superview){
        if ([view.superview isKindOfClass:class]){
            return true;
        }
        return [self view:view.superview hasSuperviewOfClass:class];
    }
    return false;
}

+ (void) swizzleInstanceSelector:(SEL)originalSelector
                 withNewSelector:(SEL)newSelector
{
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);
    
    BOOL methodAdded = class_addMethod([self class],
                                       originalSelector,
                                       method_getImplementation(newMethod),
                                       method_getTypeEncoding(newMethod));
    
    if (methodAdded) {
        class_replaceMethod([self class],
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}


@end

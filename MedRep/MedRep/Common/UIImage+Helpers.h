//
//  UIImage+Helpers.h
//  MedRep
//
//  Created by Namit Nayak on 7/29/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helpers)

+ (void) loadFromURL: (NSURL*) url callback:(void (^)(UIImage *image))callback;

@end
//
//  UIImage+Helpers.m
//  MedRep
//
//  Created by Namit Nayak on 7/29/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "UIImage+Helpers.h"


@implementation UIImage (Helpers)

+ (void) loadFromURL: (NSURL*) url callback:(void (^)(UIImage *image))callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        NSError * error = nil;
        NSData * imageData = [NSData dataWithContentsOfURL:url options:0 error:&error];
        if (error)
            callback(nil);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imageData];
            callback(image);
        });
    });
}
@end
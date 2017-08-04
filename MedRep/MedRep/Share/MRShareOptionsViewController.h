//
//  ShareOptionsViewController.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/2/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSharePost;

@protocol MRShareOptionsSelectionDelegate <NSObject>

- (void)shareToSelected;

@end

@interface MRShareOptionsViewController : UIViewController

@property (nonatomic) MRSharePost *parentPost;
@property (nonatomic,weak) id<MRShareOptionsSelectionDelegate> delegate;

@end

//
//  MRShareDetailViewController.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/4/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSharePost;

@protocol PostDataUpdated <NSObject>

- (void)refetchPost:(NSIndexPath*)indexPath;

@end

@interface MRShareDetailViewController : UIViewController

@property (nonatomic) MRSharePost *post;
@property (nonatomic) NSIndexPath *indexPath;

@property (nonatomic,weak) id<PostDataUpdated> delegate;

@end

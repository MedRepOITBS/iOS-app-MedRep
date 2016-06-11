//
//  MRMenuViewController.h
//  MedRep
//
//  Created by MedRep Developer on 28/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRMenuViewControllerDelegate <NSObject>

- (void)loadLoginView;

@end

@interface MRMenuViewController : UIViewController
{
    
}

@property (nonatomic, assign) id<MRMenuViewControllerDelegate> delegate;

@end


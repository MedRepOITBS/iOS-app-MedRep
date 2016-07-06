//
//  MRTabView.h
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/20/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRTabViewDelegate <NSObject>

@optional
- (void)connectButtonTapped;
- (void)transformButtonTapped;
- (void)shareButtonTapped;
- (void)serveButtonTapped;

@end

@interface MRTabView : UIView

@property (assign) id<MRTabViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *connectView;
@property (weak, nonatomic) IBOutlet UIView *transformView;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIView *serveView;

@end

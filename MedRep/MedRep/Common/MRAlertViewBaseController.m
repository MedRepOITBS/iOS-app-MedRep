//
//  MRAlertViewBaseController.m
//  MedRep
//
//  Created by Hima Bindhu on 10/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRAlertViewBaseController.h"
#import "AMSmoothAlertView.h"
#import "FXBlurView.h"

@interface MRAlertViewBaseController ()

{
    AMBouncingView *circleView;
    //GPUImageiOSBlurFilter *_blurFilter;
}

@property (nonatomic, strong) UIImageView *logoView;


@end

@implementation MRAlertViewBaseController

#pragma mark - Public Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.opaque = YES;
    self.view.alpha = 1;
    
    self.holderView.layer.cornerRadius = 3.0f;
    
    //_blurFilter = [[GPUImageiOSBlurFilter alloc] init];
    //_blurFilter.blurRadiusInPixels = 2.0;
    [self alertPopupView];
    //[self circleSetupForAlertType:AlertInfo andColor:[UIColor redColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self triggerDropAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateCircleViewFrame
{
    UIView * circleMask = [self.view viewWithTag:2000];
    circleMask.frame = CGRectMake([self screenFrame].size.width/2, (([self screenFrame].size.height/2)-self.holderView.frame.size.height/2) , 60, 60);
}

#pragma mark - Private Methods

- (void) circleSetupForAlertType:(AlertType) type andColor:(UIColor*) color
{
    UIView * circleMask = [[UIView alloc] initWithFrame:CGRectMake([self screenFrame].size.width/2, (([self screenFrame].size.height/2)-self.holderView.frame.size.height/2) , 60, 60)];
    circleMask.tag = 2000;
    
    circleView = [[AMBouncingView alloc]initSuccessCircleWithFrame:CGRectMake(0, 0, 0, 0) andImageSize:60 forAlertType:type andColor:color];
    
    _logoView = [[UIImageView alloc]initWithFrame:CGRectMake(circleMask.frame.size.width/2-30, circleMask.frame.size.height/2-30 , 0, 0)];
    
    switch (type) {
        case AlertSuccess:
            [_logoView setImage:[UIImage imageNamed:@"checkMark.png"]];
            break;
        case AlertFailure:
            [_logoView setImage:[UIImage imageNamed:@"crossMark.png"]];
            break;
        case AlertInfo:
            [_logoView setImage:[UIImage imageNamed:@"info.png"]];
            break;
            
        default:
            break;
    }
    _logoView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:circleMask];
    [circleMask addSubview:circleView];
    [circleMask addSubview:_logoView];
}

- (CGRect) screenFrame
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return screenRect;
}

-(void) triggerDropAnimations
{
    
    NSMutableArray* animationBlocks = [[NSMutableArray alloc] init];
    
    typedef void(^animationBlock)(BOOL);
    
    // getNextAnimation
    // removes the first block in the queue and returns it
    animationBlock (^getNextAnimation)() = ^{
        animationBlock block = animationBlocks.count ? (animationBlock)[animationBlocks objectAtIndex:0] : nil;
        if (block){
            [animationBlocks removeObjectAtIndex:0];
            return block;
        }else{
            return ^(BOOL finished){};
        }
    };
    
    //block 1
    [animationBlocks addObject:^(BOOL finished){;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.bgImageView.alpha = 1.0;
        } completion: getNextAnimation()];
    }];
    
    //block 2
    [animationBlocks addObject:^(BOOL finished){;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.holderView.center = CGPointMake([self screenFrame].size.width/2, ([self screenFrame].size.height/2)+self.holderView.frame.size.height*0.1);
        } completion: getNextAnimation()];
    }];
    
    //block 3
    [animationBlocks addObject:^(BOOL finished){;
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.holderView.center = CGPointMake([self screenFrame].size.width/2, ([self screenFrame].size.height/2));
        } completion: getNextAnimation()];
    }];
    
    //add a block to our queue
    [animationBlocks addObject:^(BOOL finished){;
        [self circleAnimation];
    }];
    
    // execute the first block in the queue
    getNextAnimation()(YES);
}

- (void) alertPopupView
{
    self.holderView.center = CGPointMake([self screenFrame].size.width/2, -[self screenFrame].size.height/2);
    [self.holderView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.holderView.layer setShadowOpacity:0.4];
    [self.holderView.layer setShadowRadius:20.0f];
    [self.holderView.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    
    [self performScreenshotAndBlur];
}

-(void) performScreenshotAndBlur
{
    UIImage * image = [self convertViewToImage];
    //UIImage *blurredSnapshotImage = [_blurFilter imageByFilteringImage:image];
    UIImage *blurredSnapshotImage = [image blurredImageWithRadius:2 iterations:3 tintColor:nil];
    
    [self.bgImageView setImage:blurredSnapshotImage];
    self.bgImageView.alpha = 0.0;
}

-(UIImage *)convertViewToImage
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *capturedScreen = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return capturedScreen;
}

- (void) circleAnimation
{
    NSMutableArray* animationBlocks = [NSMutableArray new];
    
    typedef void(^animationBlock)(BOOL);
    
    // getNextAnimation
    // removes the first block in the queue and returns it
    animationBlock (^getNextAnimation)() = ^{
        animationBlock block = animationBlocks.count ? (animationBlock)[animationBlocks objectAtIndex:0] : nil;
        if (block){
            [animationBlocks removeObjectAtIndex:0];
            return block;
        }else{
            return ^(BOOL finished){};
        }
    };
    
    //block 1
    [animationBlocks addObject:^(BOOL finished){;
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            circleView.frame = [circleView newFrameWithWidth:85 andHeight:85];
            _logoView.frame = [self newFrameForView:_logoView withWidth:40 andHeight:40];
        } completion: getNextAnimation()];
    }];
    
    //block 2
    [animationBlocks addObject:^(BOOL finished){;
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            circleView.frame = [circleView newFrameWithWidth:50 andHeight:50];
            _logoView.frame = [self newFrameForView:_logoView withWidth:15 andHeight:15];
        } completion: getNextAnimation()];
    }];
    
    //block 3
    [animationBlocks addObject:^(BOOL finished){;
        [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            circleView.frame = [circleView newFrameWithWidth:60 andHeight:60];
            _logoView.frame = [self newFrameForView:_logoView withWidth:20 andHeight:20];
        } completion:^(BOOL finished) {
        }];
    }];
    
    // execute the first block in the queue
    getNextAnimation()(YES);
}

- (CGRect) newFrameForView:(UIView*) uiview withWidth:(float) width andHeight:(float) height
{
    return CGRectMake(uiview.frame.origin.x + ((uiview.frame.size.width - width)/2),
                      uiview.frame.origin.y + ((uiview.frame.size.height - height)/2),
                      width,
                      height);
}

@end

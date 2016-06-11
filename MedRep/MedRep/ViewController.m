//
//  ViewController.m
//  MedRep
//
//  Created by MedRep Developer on 09/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "ViewController.h"
#import "MRCommon.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *splashLogo;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.spImage.image = [UIImage imageNamed:[self getImageForDevice]];
    
    CABasicAnimation* shrink    = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    shrink.fromValue            = [NSNumber numberWithDouble:0.5];
    shrink.toValue              = [NSNumber numberWithDouble:1.0];
    shrink.duration             = 0.5;
    shrink.autoreverses         = YES;
    shrink.removedOnCompletion  = NO;
    shrink.delegate             = self;
    shrink.repeatCount          = 2.0;
    [shrink setValue:self.splashLogo.layer forKey:@"Key"];
    [self.splashLogo.layer addAnimation:shrink forKey:@"Key"];


    // Do any additional setup after loading the view, typically from a nib.
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    NSLog(@"%f",self.view.frame.size.height);

    NSLog(@"%f",[UIScreen mainScreen].bounds.size.height);

    [self.delegate removeSplashViewOnAnimationEnd];
}

- (NSString*)getImageForDevice
{
    if ([MRCommon isIPad])
    {
        return @"Default@3x.png";//@"Default-Portrait@2x.png";
    }
    else if ([MRCommon isiPhone5])
    {
        return @"Default-568h.png";
    }
    else if ([MRCommon deviceHasFivePointFiveInchScreen])
    {
        return @"Default@3x.png";
    }
    else if ([MRCommon deviceHasFourPointSevenInchScreen])
    {
        return @"Default-667h.png";
    }
    
    return @"Default.png";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

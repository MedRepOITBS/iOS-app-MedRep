//
//  MRTransformDetailViewController.h
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRTransformPost;

@interface MRTransformDetailViewController : UIViewController

@property (nonatomic) NSInteger currentTabIndex;

@property (nonatomic, strong) MRTransformPost *post;
@property (weak, nonatomic) IBOutlet UIImageView *contentImage;
@property (weak, nonatomic) IBOutlet UITextView *detailLbl;
@property (weak, nonatomic) IBOutlet UIButton *gotoButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

- (IBAction)shareAction:(UIButton *)sender;
- (IBAction)gotoWebAction:(id)sender;

@end

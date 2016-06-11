//
//  MRRegHeaderView.h
//  MedRep
//
//  Created by MedRep Developer on 24/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRRegHeaderView;

@protocol MRRegHeaderViewDelegate <NSObject>

- (void)addButtonClicked:(NSInteger)addType;
- (void)pickLocationButtonActionDelegate:(MRRegHeaderView*)section;
@end

@interface MRRegHeaderView : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickLocationImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickLocationButtonWidthConstraint;

@property (weak, nonatomic) IBOutlet UILabel *addLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addIConHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addIConWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addIConTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addIConBottom;
@property (nonatomic, assign) NSInteger section;
@property (weak, nonatomic) IBOutlet UIImageView *addIconImage;
@property (nonatomic, assign) id<MRRegHeaderViewDelegate> delegate;

+ (MRRegHeaderView*)regHeaderView;

@property (weak, nonatomic) IBOutlet UIButton *pickLocationButton;
@property (weak, nonatomic) IBOutlet UIImageView *pickLocationImage;

- (IBAction)pickLocationButtonAction:(id)sender;
@end

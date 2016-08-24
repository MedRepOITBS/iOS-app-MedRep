//
//  CommonProfileSectionTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRProfile.h"
@protocol CommonProfileSectionTableViewCellDelegate;

@interface CommonProfileSectionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *indicatorImageView;

@property (nonatomic,weak) IBOutlet UILabel *sectionTitleName;
@property (nonatomic,weak) IBOutlet  UILabel *sectionDescName;
@property (nonatomic,weak) IBOutlet UIButton *addButton;
-(void)setCommonProfileDataForType:(NSString *)type withUserProfileData:(MRProfile *)profile;
@property (nonatomic,weak) id<CommonProfileSectionTableViewCellDelegate> delegate;

-(IBAction)addButtonTapped:(id)sender;
@end

@protocol CommonProfileSectionTableViewCellDelegate <NSObject>

@optional

-(void)CommonProfileSectionTableViewCellDelegateForButtonPressed:(CommonProfileSectionTableViewCell *)cell withButtonType:(NSString *)buttonType;

@end
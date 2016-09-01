//
//  ProfileBasicTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ProfileBasicTableViewCellDelegate;

@interface ProfileBasicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *profileimageView;
@property (weak, nonatomic) IBOutlet UILabel *userLocation;
@property (nonatomic,weak) id<ProfileBasicTableViewCellDelegate> delegate;

@property(weak,nonatomic) IBOutlet UIButton *imageBtn;

@property (weak, nonatomic) IBOutlet UIButton *pencilBtn;

-(IBAction)imageButtonTapped:(id)sender;
@end
@protocol ProfileBasicTableViewCellDelegate <NSObject>

@optional

-(void)ProfileBasicTableViewCellDelegateForButtonPressed:(ProfileBasicTableViewCell *)cell withButtonType:(NSString *)buttonType;

@end
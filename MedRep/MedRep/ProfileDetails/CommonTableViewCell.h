//
//  CommonTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CommonTableViewCellDelegate;

@interface CommonTableViewCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel *title;
@property(nonatomic,weak) IBOutlet UITextField *inputTextField;
@property (nonatomic,weak) id<CommonTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWidthConstraint;

@end

@protocol CommonTableViewCellDelegate <NSObject>
@optional

-(void)CommonTableViewCellDelegateForTextFieldDidEndEditing:(CommonTableViewCell *)cell withTextField:(UITextField *)textField;

@end

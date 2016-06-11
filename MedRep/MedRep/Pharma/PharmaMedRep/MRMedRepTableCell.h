//
//  MRProductTableCell.h
//  Gravity
//
//  Created by Apple on 26/09/15.
//  Copyright © 2015 Sprim. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRMedRepTableCell;

@protocol MRMedRepTableCellDelegate <NSObject>

@optional

- (void)accessoryButtonDelegationAction:(MRMedRepTableCell *)tCell;

@end


@interface MRMedRepTableCell : UITableViewCell

@property(assign, nonatomic) id<MRMedRepTableCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *cellTitleLabel;

- (IBAction)accessoryButtonAction:(id)sender;

@end

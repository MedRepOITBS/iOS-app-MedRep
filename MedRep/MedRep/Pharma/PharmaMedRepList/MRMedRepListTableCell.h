//
//  MRProductTableCell.h
//  Gravity
//
//  Created by Apple on 26/09/15.
//  Copyright © 2015 Sprim. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRMedRepListTableCell;

@protocol MRMedRepListTableCellDelegate <NSObject>

@optional

- (void)accessoryButtonDelegationAction:(MRMedRepListTableCell *)tCell;

@end


@interface MRMedRepListTableCell : UITableViewCell

@property(assign, nonatomic) id<MRMedRepListTableCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *cellTitleLabel;

- (IBAction)accessoryButtonAction:(id)sender;

@end

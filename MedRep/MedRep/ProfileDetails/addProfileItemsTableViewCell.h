//
//  addProfileItemsTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol addProfileItemsTableViewCellDelegate;
@interface addProfileItemsTableViewCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UIButton *addPlaceHolderButton;
@property (nonatomic,weak) id<addProfileItemsTableViewCellDelegate> delegate;

@end


@protocol addProfileItemsTableViewCellDelegate <NSObject>
@optional

-(void)addProfileItemsTableViewCellDelegateForButtonPressed:(addProfileItemsTableViewCell *)cell;

@end
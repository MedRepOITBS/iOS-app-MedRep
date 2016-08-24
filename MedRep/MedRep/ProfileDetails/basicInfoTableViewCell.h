//
//  basicInfoTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol basicInfoTableViewCellDelegate;

@interface basicInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleOther;
@property (weak,nonatomic) IBOutlet UIView *viewLabel;
@property (nonatomic,weak) id<basicInfoTableViewCellDelegate> delegate;
-(IBAction)deleteBtnTapped:(id)sender;
@end


@protocol basicInfoTableViewCellDelegate <NSObject>

@optional

-(void)basicInfoTableViewCellDelegateForButtonPressed:(basicInfoTableViewCell *)cell withButtonType:(NSString *)buttonType;

@end
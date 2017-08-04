//
//  ExpericeFillUpTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ExpericeFillUpTableViewCellDelegate;

@interface ExpericeFillUpTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateDesc;
@property (weak, nonatomic) IBOutlet UILabel *otherDesc;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak,nonatomic) IBOutlet UIView *viewLabel;
@property (nonatomic,weak) id<ExpericeFillUpTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

-(IBAction)deleteBtnTapped:(id)sender;
@end


@protocol ExpericeFillUpTableViewCellDelegate <NSObject>

@optional

-(void)ExpericeFillUpTableViewCellDelegateForButtonPressed:(ExpericeFillUpTableViewCell *)cell withButtonType:(NSString *)buttonType;

@end
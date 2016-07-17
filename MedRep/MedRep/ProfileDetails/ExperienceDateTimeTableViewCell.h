//
//  ExperienceDateTimeTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ExperienceDateTimeTableViewCellDelegate;

@interface ExperienceDateTimeTableViewCell : UITableViewCell <UITextFieldDelegate>
- (IBAction)currentBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *checkCurrentBtn;
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UIView *toView;
@property (weak, nonatomic) IBOutlet UITextField *toMMTextField;
@property (weak, nonatomic) IBOutlet UITextField *toYYYTextField;
@property (nonatomic,weak) id<ExperienceDateTimeTableViewCellDelegate> delegate;
@property (nonatomic) BOOL isChecked;
@end

@protocol ExperienceDateTimeTableViewCellDelegate <NSObject>
@optional

-(void)ExperienceDateTimeTableViewCellDelegateForTextFieldClicked:(ExperienceDateTimeTableViewCell *)cell withTextField:(UITextField *)textField;
-(void)getCurrentCheckButtonVal:(BOOL)isCurrentCheck;
@end

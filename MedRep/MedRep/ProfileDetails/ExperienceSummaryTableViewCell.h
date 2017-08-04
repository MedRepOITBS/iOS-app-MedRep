//
//  ExperienceSummaryTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ExperienceSummaryTableViewCellDelegate;

@interface ExperienceSummaryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *summaryTextField;
@property (nonatomic,weak) id<ExperienceSummaryTableViewCellDelegate> delegate;

- (void)setSummaryTextData:(NSString*)summaryText andParentView:(UIView*)parentView;

@end

@protocol ExperienceSummaryTableViewCellDelegate <NSObject>

@optional

-(void)ExperienceSummaryTableViewCellDelegateForTextViewDidEndEditing:(ExperienceSummaryTableViewCell *)cell
                                                         withTextView:(UITextView *)textView;

@end

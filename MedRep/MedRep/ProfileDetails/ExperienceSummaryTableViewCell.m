//
//  ExperienceSummaryTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "ExperienceSummaryTableViewCell.h"

@interface ExperienceSummaryTableViewCell () <UITextViewDelegate>

@property (nonatomic, strong) NSString *summaryText;
@property (nonatomic) UIView *parentView;

@end

@implementation ExperienceSummaryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.summaryTextField setDelegate:self];
    [self.summaryTextField.layer setCornerRadius:4.0f];
    [self.summaryTextField.layer setBorderWidth:0.5f];
    [self.summaryTextField.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.superview.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(closeOnKeyboardPressed:)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneOnKeyboardPressed:)],
                           nil];
    [numberToolbar sizeToFit];
    self.summaryTextField.inputAccessoryView = numberToolbar;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeKeyboardNotification) name:@"NOTIFY_KEYBORD_OFF_TEXTVIEW" object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSummaryTextData:(NSString*)summaryText andParentView:(UIView*)parentView {
    self.parentView = parentView;
    self.summaryText = summaryText;
    [self.summaryTextField setText:summaryText];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_DATE_PICKER" object:nil];

    UITableView *tempParentView = (UITableView*)self.parentView;
    CGRect rect = CGRectMake(tempParentView.frame.origin.x, tempParentView.frame.origin.y - 300,
                             tempParentView.frame.size.width, tempParentView.frame.size.height);
    [tempParentView setFrame:rect];
//    [tempParentView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]
//                          atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self doneTypingInTextView:textView];
}
-(void)removeKeyboardNotification{
    if (self.summaryTextField != nil) {
        [self.summaryTextField resignFirstResponder];
    }
    
}
- (void)doneTypingInTextView:(UITextView*)textView {

    NSLog(@"textfield %@",textView.text);
    
    self.summaryText = textView.text;
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(ExperienceSummaryTableViewCellDelegateForTextViewDidEndEditing:withTextView:)]) {
        [self.delegate ExperienceSummaryTableViewCellDelegateForTextViewDidEndEditing:self
                                                                         withTextView:textView];
    }
    
    UITableView *tempParentView = (UITableView*)self.parentView;
    CGRect rect = CGRectMake(tempParentView.frame.origin.x, tempParentView.frame.origin.y + 300,
                             tempParentView.frame.size.width, tempParentView.frame.size.height);
    [tempParentView setFrame:rect];
}

- (void)closeOnKeyboardPressed:(id)sender {
    self.summaryTextField.text = self.summaryText;
    [self.summaryTextField resignFirstResponder];
}

- (void)doneOnKeyboardPressed:(id)sender {
    [self.summaryTextField resignFirstResponder];
}

@end

//
//  MRFeedBackResultCell.h
//  MedRep
//
//  Created by MedRep Developer on 28/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRFeedBackResultCell : UITableViewCell
{
    
}
@property (weak, nonatomic) IBOutlet UILabel *serialNumberText;
@property (weak, nonatomic) IBOutlet UILabel *feedbackTitleText;
@property (weak, nonatomic) IBOutlet UILabel *yesLabel;
@property (weak, nonatomic) IBOutlet UILabel *noLabel;
@property (weak, nonatomic) IBOutlet UILabel *yesPercentScore;
@property (weak, nonatomic) IBOutlet UILabel *noPercentScore;
@property (weak, nonatomic) IBOutlet UILabel *yesProgressLabel;
@property (weak, nonatomic) IBOutlet UILabel *noProgressLabel;
@property (weak, nonatomic) IBOutlet UIView   *starView;
@property (weak, nonatomic) IBOutlet UIButton *starOne;
@property (weak, nonatomic) IBOutlet UIButton *starTwo;
@property (weak, nonatomic) IBOutlet UIButton *starThree;
@property (weak, nonatomic) IBOutlet UIButton *starFour;
@property (weak, nonatomic) IBOutlet UIButton *starFive;
@property (weak, nonatomic) IBOutlet UILabel  *ratingLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noprogressWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yesProgressWidth;

- (void)configureFeedbackCell:(NSInteger)feedBackrow
                  andFeedBack:(NSDictionary*)feedBack;

@end

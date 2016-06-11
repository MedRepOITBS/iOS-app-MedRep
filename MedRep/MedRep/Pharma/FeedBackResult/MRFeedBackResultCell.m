//
//  MRFeedBackResultCell.m
//  MedRep
//
//  Created by MedRep Developer on 28/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRFeedBackResultCell.h"

#define kFeedBack  [NSArray arrayWithObjects:@"How do you rate this product?\n", @"Will you prescribe this Product/\nMedicine to yourPatients?", @"Will you recommend this Product/\nMedicine to your Doctors?", nil]

@implementation MRFeedBackResultCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)configureFeedbackCell:(NSInteger)feedBackrow
                  andFeedBack:(NSDictionary*)feedBack
{
    self.serialNumberText.text = [NSString stringWithFormat:@"%ld.", (long)feedBackrow+1];
    self.feedbackTitleText.text = [kFeedBack objectAtIndex:feedBackrow];

    if (feedBackrow == 0)
    {
        self.starView.hidden = NO;
        self.ratingLabel.hidden = NO;
        [self unselectImage];
        [self rateButtonAction:[[feedBack objectForKey:@"ratingAverage"] integerValue]];
        self.ratingLabel.text =  [NSString stringWithFormat:@"%.1f / 5",[[feedBack objectForKey:@"ratingAverage"] floatValue]];
        self.yesLabel.hidden =
        self.noLabel.hidden =
        self.yesPercentScore.hidden =
        self.noPercentScore.hidden =
        self.yesProgressLabel.hidden =
        self.noProgressLabel.hidden = YES;
    }
    else
    {
        self.starView.hidden = YES;
        
        self.yesLabel.hidden =
        self.noLabel.hidden =
        self.yesPercentScore.hidden =
        self.noPercentScore.hidden =
        self.yesProgressLabel.hidden =
        self.noProgressLabel.hidden = NO;
        self.ratingLabel.hidden = YES;
        
        CGFloat yesFeedback = 0.0;
        CGFloat noFeedback = 0.0;
        
        if (feedBackrow == 1)
        {
            if ([[feedBack objectForKey:@"totalCount"] integerValue] == 0)
            {
                yesFeedback = 0;
                self.yesPercentScore.text = [NSString stringWithFormat:@"%.1f%@",yesFeedback, @"%"];

                noFeedback = 0;
                self.noPercentScore.text = [NSString stringWithFormat:@"%.1f%@",noFeedback, @"%"];

            }
            else
            {
                if ([[feedBack objectForKey:@"prescribeYes"] integerValue] == 0)
                {
                    yesFeedback = 0;
                    self.yesPercentScore.text = [NSString stringWithFormat:@"%.1f%@",yesFeedback, @"%"];
                }
                else
                {
                    yesFeedback = ([[feedBack objectForKey:@"prescribeYes"] floatValue] / [[feedBack objectForKey:@"totalCount"] floatValue] ) * 100;
                    self.yesPercentScore.text = [NSString stringWithFormat:@"%.1f%@",yesFeedback, @"%"];
                    yesFeedback = 2 * yesFeedback;

                }

                if ([[feedBack objectForKey:@"prescribeNo"] integerValue] == 0)
                {
                    noFeedback = 0;
                    self.noPercentScore.text = [NSString stringWithFormat:@"%.1f%@",noFeedback, @"%"];
                }
                else
                {
                    noFeedback = ( [[feedBack objectForKey:@"prescribeNo"] floatValue] / [[feedBack objectForKey:@"totalCount"] floatValue]) * 100;
                    self.noPercentScore.text = [NSString stringWithFormat:@"%.1f%@",noFeedback, @"%"];
                    noFeedback = 2 * noFeedback;;
                }
            }

            self.noprogressWidth.constant = noFeedback;
            self.yesProgressWidth.constant = yesFeedback;
        }
        else if (feedBackrow == 2)
        {
            if ([[feedBack objectForKey:@"totalCount"] integerValue] == 0)
            {
                yesFeedback = 0;
                self.yesPercentScore.text = [NSString stringWithFormat:@"%.1f%@",yesFeedback, @"%"];

                noFeedback = 0;
                self.noPercentScore.text = [NSString stringWithFormat:@"%.1f%@",noFeedback, @"%"];
            }
            else
            {
                if ([[feedBack objectForKey:@"recomendYes"] integerValue] == 0)
                {
                    yesFeedback = 0;
                    self.yesPercentScore.text = [NSString stringWithFormat:@"%.1f%@",yesFeedback, @"%"];
                }
                else
                {
                    yesFeedback = ([[feedBack objectForKey:@"recomendYes"] floatValue] / [[feedBack objectForKey:@"totalCount"] floatValue]) * 100;
                    self.yesPercentScore.text = [NSString stringWithFormat:@"%.1f%@",yesFeedback, @"%"];
                    yesFeedback = (200 * yesFeedback)/100;
                }
                
                if ([[feedBack objectForKey:@"recomendNo"] integerValue] == 0)
                {
                    noFeedback = 0;
                    self.noPercentScore.text = [NSString stringWithFormat:@"%.1f%@",noFeedback, @"%"];
                }
                else
                {
                    noFeedback = ([[feedBack objectForKey:@"recomendNo"] floatValue] / [[feedBack objectForKey:@"totalCount"] floatValue]) * 100;
                    self.noPercentScore.text = [NSString stringWithFormat:@"%.1f%@",noFeedback, @"%"];
                    noFeedback = (200 * noFeedback)/100;
                }
            }
            
            self.noprogressWidth.constant = noFeedback;
            self.yesProgressWidth.constant = yesFeedback;
        }
    }
}

- (void)rateButtonAction:(NSInteger)rating
{
    switch (rating + 99)
    {
        case 100:
        {
            [self.starOne setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
        }
            break;
        case 101:
        {
            [self.starOne setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.starTwo setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
        }
            break;
        case 102:
        {
            [self.starOne setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.starTwo setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.starThree setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
        }
            break;
        case 103:
        {
            [self.starOne setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.starTwo setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.starThree setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.starFour setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
        }
            break;
        case 104:
        {
            [self.starOne setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.starTwo setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.starThree setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.starFour setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
            [self.starFive setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

- (void)unselectImage
{
    [self.starOne setImage:[UIImage imageNamed:@"starunselected.png"] forState:UIControlStateNormal];
    [self.starTwo setImage:[UIImage imageNamed:@"starunselected.png"] forState:UIControlStateNormal];
    [self.starThree setImage:[UIImage imageNamed:@"starunselected.png"] forState:UIControlStateNormal];
    [self.starFour setImage:[UIImage imageNamed:@"starunselected.png"] forState:UIControlStateNormal];
    [self.starFour setImage:[UIImage imageNamed:@"starunselected.png"] forState:UIControlStateNormal];
    
}

@end

//
//  MRShareDetailTableViewCell.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/4/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRShareDetailTableViewCell.h"
#import "MRReplies.h"
#import "MRCommon.h"

@interface MRShareDetailTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *contactPic;
@property (weak, nonatomic) IBOutlet UILabel *shortDescription;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *time;

@end

@implementation MRShareDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentData:(MRReplies *)reply {
    if (reply.descriptionText != nil && reply.descriptionText.length > 0) {
        [self.shortDescription setText:reply.descriptionText];
    }
    
    [self.date setText:[MRCommon stringWithRelativeWordsForDate:reply.postedDate]];
    [self.time setText:[MRCommon convertDateToString:reply.postedDate andFormat:kHourAMPMFormat]];
}

@end

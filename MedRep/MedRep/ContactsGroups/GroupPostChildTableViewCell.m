//
//  GroupPostChildTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 6/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "GroupPostChildTableViewCell.h"
#import "MRConstants.h"
#import "MRDataManger.h"
#import "MRAppControl.h"
#import "NSDate+Utilities.h"
#import "MRPostedReplies.h"
#import "MRSharePost.h"

@interface GroupPostChildTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *commentPic;
@property (weak, nonatomic) IBOutlet UITextView *postText;
@property (weak,nonatomic) IBOutlet UILabel *profileNameLabel;
@property (strong,nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *postedDate;
@property (strong,nonatomic) IBOutlet NSLayoutConstraint *verticalContstraint;

@end

@implementation GroupPostChildTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillCellWithData:(MRPostedReplies*)post {
    MRSharePost *sharePost = nil;
    if (post.parentSharePostId != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"sharePostId", post.parentSharePostId.longValue];
        sharePost = [[MRDataManger sharedManager] fetchObject:kMRSharePost predicate:predicate];
    }
    
    if (post.image == nil) {
        if (sharePost != nil && sharePost.objectData != nil) {
            self.heightConstraint.constant = 146;
            self.commentPic.image = [UIImage imageWithData:sharePost.objectData];
        } else {
            self.heightConstraint.constant = 0;
        }
    } else {
        self.heightConstraint.constant = 146;
        self.commentPic.image = [UIImage imageWithData:post.image];
    }
    
    NSString *postText = post.text;
    if (postText == nil || postText.length == 0) {
        if (sharePost != nil && sharePost.titleDescription != nil) {
            postText = sharePost.titleDescription;
        }
    }
    
    self.postText.text = postText;
    self.profileNameLabel.text = post.postedBy;
    self.profilePic.image = [MRAppControl getRepliedByProfileImage:post];
    
    self.postedDate.text = [NSString stringWithFormat:@"%@",[post.postedOn stringWithFormat:kIdletimeFormat]];
    
}

@end

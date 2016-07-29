//
//  MRGroupPostItemTableViewCell.m
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/16/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRGroupPostItemTableViewCell.h"
#import "MRConstants.h"
#import "MRSharePost.h"
#import "MRTransformPost.h"
#import "MRContact.h"

@interface MRGroupPostItemTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView* profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel* contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* postLabel;
@property (weak, nonatomic) IBOutlet UIImageView* postImageView;
@property (weak, nonatomic) IBOutlet UILabel* commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel* likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel* shareCountLabel;
@property (weak, nonatomic) IBOutlet UIView *likeView;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profilePicWidthConstraint;

@property (nonatomic) MRSharePost *post;

@end

@implementation MRGroupPostItemTableViewCell


- (void)likeButtonTapped:(UIGestureRecognizer*)gesture {
    UIView *sender = gesture.view;
    
    NSInteger tagIndex = sender.tag - 1;
    
    NSInteger likeCount = [_likeCountLabel.text integerValue];
    likeCount = likeCount +1;
    self.post.likesCount = [NSNumber numberWithLong:likeCount];
    [self.post.managedObjectContext save:nil];
    
    _shareCountLabel.text = [NSString stringWithFormat:@"%ld",(long)likeCount];
    
    tagIndex = tagIndex / 100;
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(likeButtonTapped:)]) {
        [self.delegate likeButtonTapped:tagIndex];
    }
    [self.parentTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:tagIndex inSection:0]]
                                withRowAnimation:UITableViewRowAnimationNone];
}

- (void)shareButtonTapped:(UIGestureRecognizer*)gesture {
    if (self.delegate != nil &&
        [self.delegate respondsToSelector:@selector(shareButtonTapped:)]) {
        [self.delegate shareButtonTapped:self.post];
    }
}

- (void)commentButtonTapped:(UIGestureRecognizer*)gesture {
    
    if([self.delegate respondsToSelector:@selector(commentButtonTapped:)]){
        [self.delegate commentButtonTapped:self.post];
    }
}

- (void)awakeFromNib {
    // Initialization code
    UITapGestureRecognizer *likeTapGestureRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeButtonTapped:)];
    [self.likeView addGestureRecognizer:likeTapGestureRecognizer];
    
    UITapGestureRecognizer *shareTapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareButtonTapped:)];
    [self.shareView addGestureRecognizer:shareTapGestureRecognizer];
    
    UITapGestureRecognizer *commentTapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentButtonTapped:)];
    [self.commentView addGestureRecognizer:commentTapGestureRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

/*
 
 [{"message_id":1,"member_id":16,"group_id":0,"message":"Content Share, Content Transform","message_type":"Text Type","post_date":"1469595440000","receiver_id":0,"topic_id":0,"share_date":null}]
 
 */

- (void)setPostContent:(MRSharePost *)post  tagIndex:(NSInteger)tagIndex {
    self.post = post;
    
    NSLog(@"Post : %ld",post.sharePostId.longValue);
    
    self.postLabel.text = post.titleDescription;
    
    UIImage *image = nil;
    
    if (self.post.contentType.integerValue == kTransformContentTypeImage) {
        if (self.post.url != nil && self.post.url.length > 0) {
            image = [UIImage imageNamed:self.post.url];
        } else if (self.post.objectData != nil) {
            image = [UIImage imageWithData:self.post.objectData];
        }
    }
    
    if (image != nil) {
        self.postImageView.image = image;
        self.postImageHeightConstraint.constant = 128;
    } else {
        self.postImageHeightConstraint.constant = 0;
    }
    
    NSString *name = @"";
    if (self.post.sharedByProfileName != nil) {
        name = self.post.sharedByProfileName;
    }
    self.contactNameLabel.text = name;
    
    NSData* imageData = post.shareddByProfilePic;
    if (imageData && imageData.length > 0) {
        self.profilePicImageView.image = [UIImage imageWithData:imageData];
    } else {
        self.profilePicImageView.image = [UIImage imageNamed:@"person"];
    }
    
    tagIndex++;
    [self.likeView setTag:tagIndex];
    self.likeCountLabel.text = [NSString stringWithFormat:@"%ld",post.likesCount.longValue];
    
    tagIndex++;
    [self.shareView setTag:tagIndex];
    self.shareCountLabel.text = [NSString stringWithFormat:@"%ld",post.shareCount.longValue];
    
    tagIndex++;
    [self.commentView setTag:tagIndex];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%ld",post.commentsCount.longValue];
    
//    if (post.replyPost!=NULL) {
//        
//    }
    if (post.postedReplies != NULL) {
        
    }

}

@end

//
//  MRGroupPostItemTableViewCell.m
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/16/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRGroupPostItemTableViewCell.h"
#import "MRGroupPost.h"
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

@property (nonatomic) MRGroupPost *post;

@end

@implementation MRGroupPostItemTableViewCell


- (void)likeButtonTapped:(UIGestureRecognizer*)gesture {
    UIView *sender = gesture.view;
    
    NSInteger tagIndex = sender.tag - 1;
    
    NSInteger likeCount = [_likeCountLabel.text integerValue];
    likeCount = likeCount +1;
    self.post.numberOfLikes = [NSNumber numberWithLong:likeCount];
    [self.post.managedObjectContext save:nil];
    
    _shareCountLabel.text = [NSString stringWithFormat:@"%ld",(long)likeCount];
    
    tagIndex = tagIndex / 100;
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(likeButtonTapped)]) {
        [self.delegate likeButtonTapped];
    }
    [self.parentTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:tagIndex inSection:0]]
                                withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)shareButtonTapped:(UIGestureRecognizer*)gesture {
    if (self.delegate != nil &&
        [self.delegate respondsToSelector:@selector(shareButtonTapped:)]) {
        [self.delegate shareButtonTapped:self.post];
    }
}

- (void)commentButtonTapped:(UIGestureRecognizer*)gesture {
    
    if([self.delegate respondsToSelector:@selector(mrGroupPostItemTableViewCell:withCommentButtonTapped:)]){
        [self.delegate mrGroupPostItemTableViewCell:self withCommentButtonTapped:gesture.view];
        
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

//{"name":"John Doe","postText":"Guys, these drugs look promising!","likes":10,"comments":23,"shares":3,"profile_pic":"","post_pic":""}

- (void)setPostContent:(MRGroupPost *)post  tagIndex:(NSInteger)tagIndex {
    self.post = post;
    
    self.contactNameLabel.text = post.contact.name;
    self.postLabel.text = post.postText;
    self.profilePicImageView.image = [UIImage imageNamed:post.contact.profilePic];
    NSString* imageName = post.postPic;
    if (imageName) {
        self.postImageView.image = [UIImage imageNamed:imageName];
    } else {
        self.postImageView.image = nil;
    }
    
    tagIndex++;
    [self.likeView setTag:tagIndex];
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@",post.numberOfLikes];
    
    tagIndex++;
    [self.shareView setTag:tagIndex];
    self.shareCountLabel.text = [NSString stringWithFormat:@"%@",post.numberOfShares];
    
    tagIndex++;
    [self.commentView setTag:tagIndex];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%@",post.numberOfComments];
}

@end

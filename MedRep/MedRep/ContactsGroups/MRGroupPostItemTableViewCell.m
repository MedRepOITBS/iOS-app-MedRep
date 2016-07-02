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

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

@property (weak, nonatomic) IBOutlet UIImageView* profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel* contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* postLabel;
@property (weak, nonatomic) IBOutlet UIImageView* postImageView;
@property (weak, nonatomic) IBOutlet UILabel* commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel* likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel* shareCountLabel;

@property (nonatomic) MRGroupPost *post;

@end

@implementation MRGroupPostItemTableViewCell


-(IBAction)likeButtonTapped:(id)sender{
    
    NSInteger tagIndex = ((UIButton*)sender).tag - 1;
    
    NSInteger likeCount = [_likeCountLabel.text integerValue];
    likeCount = likeCount +1;
    self.post.numberOfLikes = likeCount;
    [self.post.managedObjectContext save:nil];
    
    _shareCountLabel.text = [NSString stringWithFormat:@"%ld",(long)likeCount];
    
    tagIndex = tagIndex / 100;
    
    if (self.delegate != nil) {
        [self.delegate likeButtonTapped];
    }
    [self.parentTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:tagIndex inSection:0]]
                                withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(IBAction)shareButtonTapped:(id)sender {
    
}

-(IBAction)commentButtonTapped:(id)sender{
    
    if([self.delegate respondsToSelector:@selector(mrGroupPostItemTableViewCell:withCommentButtonTapped:)]){
        [self.delegate mrGroupPostItemTableViewCell:self withCommentButtonTapped:sender];
        
    }
    
    
}
- (void)awakeFromNib {
    // Initialization code
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
    [self.likeButton setTag:tagIndex];
    self.likeCountLabel.text = [NSString stringWithFormat:@"%lld",post.numberOfLikes];
    
    tagIndex++;
    [self.shareButton setTag:tagIndex];
    self.shareCountLabel.text = [NSString stringWithFormat:@"%lld",post.numberOfShares];
    
    tagIndex++;
    [self.commentButton setTag:tagIndex];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%lld",post.numberOfComments];
}

@end

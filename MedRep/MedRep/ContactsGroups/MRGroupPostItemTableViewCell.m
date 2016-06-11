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


@end

@implementation MRGroupPostItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//{"name":"John Doe","postText":"Guys, these drugs look promising!","likes":10,"comments":23,"shares":3,"profile_pic":"","post_pic":""}

- (void)setPostContent:(MRGroupPost *)post {
    self.contactNameLabel.text = post.contact.name;
    self.postLabel.text = post.postText;
    self.profilePicImageView.image = [UIImage imageNamed:post.contact.profilePic];
    NSString* imageName = post.postPic;
    if (imageName) {
        self.postImageView.image = [UIImage imageNamed:imageName];
    } else {
        self.postImageView.image = nil;
    }
    NSInteger likeCount = post.numberOfLikes;
    if (likeCount > 0) {
        self.likeCountLabel.text = [NSString stringWithFormat:@"%ld",(long)likeCount];
    }
    
    NSInteger shareCount = post.numberOfShares;
    if (likeCount > 0) {
        self.shareCountLabel.text = [NSString stringWithFormat:@"%ld",shareCount];
    }
    
    NSInteger commentCount = post.numberOfComments;
    if (likeCount > 0) {
        self.commentCountLabel.text = [NSString stringWithFormat:@"%ld",commentCount];
    }
}

@end

//
//  MRMyWallItemTableViewCell.m
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/16/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRMyWallItemTableViewCell.h"
#import "MRConstants.h"
#import "MRPostedReplies.h"
#import "MRSharePost.h"
#import "MRTransformPost.h"
#import "MRContact.h"
#import "NSDate+Utilities.h"
#import "MRProfileDetailsViewController.h"

@interface MRMyWallItemTableViewCell()

@property (nonatomic) UIViewController *parentViewController;

@property (weak, nonatomic) IBOutlet UILabel *postedOnLabel;

@property (weak, nonatomic) IBOutlet UIImageView* profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel* contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* postLabel;

@property (weak, nonatomic) IBOutlet UIImageView* postImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profilePicWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postImageViewTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profilePicLeadingConstant;

@property (nonatomic) MRSharePost *post;
@property (nonatomic) MRPostedReplies *postedReply;

@end

@implementation MRMyWallItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setPostedReplyContent:(MRPostedReplies *)post
                     tagIndex:(NSInteger)tagIndex
      andParentViewController:(UIViewController *)parentViewController {
    
    self.profilePicLeadingConstant.constant = 20.0;
    
    self.postedReply = post;
    
    self.postLabel.text = post.message;
    self.postedOnLabel.text = [NSDate convertNSDateToNSString:post.postedOn
                                                   dateFormat:kIdletimeFormat];
    
    UIImage *image = nil;
    
    if (self.post.url != nil && self.post.url.length > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.post.url]];
            if (imageData != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.postImageView.image = [UIImage imageWithData:imageData];
                    self.postImageHeightConstraint.constant = 128;
                    self.postImageViewTopConstraint.constant = 18;
                });
            }
        });
    } else if (self.post.objectData != nil) {
        image = [UIImage imageWithData:self.post.objectData];
    }
    
    if ((self.post.url != nil && self.post.url.length > 0) ||
        self.post.objectData != nil) {
        [self.postImageView setHidden:NO];
        self.postImageView.image = image;
        self.postImageHeightConstraint.constant = 128;
        self.postImageViewTopConstraint.constant = 18;
    } else {
        [self.postImageView setHidden:YES];
        self.postImageView.image = nil;
        self.postImageHeightConstraint.constant = 0;
        self.postImageViewTopConstraint.constant = 0;
    }
    
    NSString *name = @"No Name";
    if (self.post.sharedByProfileName != nil && self.post.sharedByProfileName.length > 0) {
        name = self.post.sharedByProfileName;
    }
    self.contactNameLabel.text = name;
    
    if (post.displayPicture != nil && post.displayPicture.length > 0) {
        self.profilePicImageView.image = [UIImage imageNamed:@"person"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:post.displayPicture]];
            if (imageData != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.profilePicImageView.image = [UIImage imageWithData:imageData];
                });
            }
        });
    } else {
        self.profilePicImageView.image = [UIImage imageNamed:@"person"];
    }
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(authorImageSelected)];
    [recognizer setNumberOfTapsRequired:1];
    [self.profilePicImageView addGestureRecognizer:recognizer];
}

- (void)setPostContent:(MRSharePost *)post tagIndex:(NSInteger)tagIndex
                            andParentViewController:(UIViewController *)parentViewController {
    self.profilePicLeadingConstant.constant = 8.0;
    
    self.post = post;
    
    NSLog(@"Post : %ld",post.sharePostId.longValue);
    
    self.postLabel.text = post.titleDescription;
    self.postedOnLabel.text = [NSDate convertNSDateToNSString:post.postedOn
                                                   dateFormat:kIdletimeFormat];
    
    UIImage *image = nil;
    
    if (self.post.url != nil && self.post.url.length > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.post.url]];
            if (imageData != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.postImageView.image = [UIImage imageWithData:imageData];
                    self.postImageHeightConstraint.constant = 128;
                    self.postImageViewTopConstraint.constant = 18;
                });
            }
        });
    } else if (self.post.objectData != nil) {
        image = [UIImage imageWithData:self.post.objectData];
    }
    
    if ((self.post.url != nil && self.post.url.length > 0) ||
        self.post.objectData != nil) {
        [self.postImageView setHidden:NO];
        self.postImageView.image = image;
        self.postImageHeightConstraint.constant = 128;
        self.postImageViewTopConstraint.constant = 18;
    } else {
        [self.postImageView setHidden:YES];
        self.postImageView.image = nil;
        self.postImageHeightConstraint.constant = 0;
        self.postImageViewTopConstraint.constant = 0;
    }
    
    NSString *name = @"No Name";
    if (self.post.sharedByProfileName != nil && self.post.sharedByProfileName.length > 0) {
        name = self.post.sharedByProfileName;
    }
    self.contactNameLabel.text = name;
    
    if (post.displayPicture != nil && post.displayPicture.length > 0) {
        self.profilePicImageView.image = [UIImage imageNamed:@"person"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:post.displayPicture]];
            if (imageData != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.profilePicImageView.image = [UIImage imageWithData:imageData];
                });
            }
        });
    } else {
        self.profilePicImageView.image = [UIImage imageNamed:@"person"];
    }
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(authorImageSelected)];
    [recognizer setNumberOfTapsRequired:1];
    [self.profilePicImageView addGestureRecognizer:recognizer];
}

- (void)authorImageSelected {
    if (self.parentViewController != nil) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ProfileStoryboard" bundle:nil];
        MRProfileDetailsViewController *profViewController = [sb instantiateInitialViewController];
        
        if (self.post.doctor_id != nil) {
            profViewController.doctorId = self.post.doctor_id.longValue;
        }
        
        profViewController.isFromSinUp = NO;
        [profViewController setShowAsReadable:YES];
        
        [self.parentViewController.navigationController pushViewController:profViewController animated:YES];
    }
}

@end

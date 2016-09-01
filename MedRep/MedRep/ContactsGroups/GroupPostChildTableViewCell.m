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
#import "MRProfileDetailsViewController.h"

@interface GroupPostChildTableViewCell ()

@property (nonatomic) UIViewController *parentViewController;

@property (weak, nonatomic) IBOutlet UIImageView *commentPic;
@property (weak, nonatomic) IBOutlet UILabel *postText;
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

- (void)fillCellWithData:(MRPostedReplies*)post
 andParentViewController:(UIViewController *)parentViewController {
    self.parentViewController = parentViewController;
    
    MRSharePost *sharePost = nil;
    if (post.parentSharePostId != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"sharePostId", post.parentSharePostId.longValue];
        sharePost = [[MRDataManger sharedManager] fetchObject:kMRSharePost predicate:predicate];
    }
    
    if (post.fileUrl == nil || post.fileUrl.length == 0) {
        if (sharePost != nil && sharePost.objectData != nil) {
            self.heightConstraint.constant = 146;
            self.commentPic.image = [UIImage imageWithData:sharePost.objectData];
        } else {
            self.heightConstraint.constant = 0;
        }
    } else {
        self.heightConstraint.constant = 146;
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        // If you need custom color, use color property
        // activityIndicator.color = yourDesirableColor;
        [self.commentPic addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:post.fileUrl]];
            if (imageData != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.commentPic.image = [UIImage imageWithData:imageData];
                    [activityIndicator stopAnimating];
                    [activityIndicator removeFromSuperview];
                });
            }
        });
    }
    
    NSString *postText = @"";
    if (post.message != nil && post.message.length > 0) {
        postText = post.message;
    } else {
        if (postText == nil || postText.length == 0) {
            if (sharePost != nil && sharePost.titleDescription != nil) {
                postText = sharePost.titleDescription;
            }
        }
    }
    
    self.postText.text = postText;
    [self.postText sizeToFit];
    
    NSString *postedBy = @"";
    if (post.doctor_Name != nil && post.doctor_Name.length > 0) {
        postedBy = post.doctor_Name;
    }
    self.profileNameLabel.text = postedBy;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(authorImageSelected)];
    [recognizer setNumberOfTapsRequired:1];
    [self.profilePic addGestureRecognizer:recognizer];
    [MRAppControl getRepliedByProfileImage:post andImageView:self.profilePic];
    
    self.postedDate.text = [NSString stringWithFormat:@"%@",[post.postedOn stringWithFormat:kIdletimeFormat]];
    
}

- (void)authorImageSelected {
    if (self.parentViewController != nil) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ProfileStoryboard" bundle:nil];
        MRProfileDetailsViewController *profViewController = [sb instantiateInitialViewController];
        
        profViewController.isFromSinUp = NO;
        [profViewController setShowAsReadable:YES];
        [self.parentViewController.navigationController pushViewController:profViewController animated:YES];
    }
}

@end

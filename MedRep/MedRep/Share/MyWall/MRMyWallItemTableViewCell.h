//
//  MRGroupPostItemTableViewCell.h
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/16/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSharePost;
@class MRPostedReplies;

@interface MRMyWallItemTableViewCell : UITableViewCell

@property (nonatomic,weak) UITableView *parentTableView;

- (void)setPostedReplyContent:(MRPostedReplies *)post
              tagIndex:(NSInteger)tagIndex
andParentViewController:(UIViewController *)parentViewController;

- (void)setPostContent:(MRSharePost*)post tagIndex:(NSInteger)tagIndex
                           andParentViewController:(UIViewController*)parentViewController;

@end

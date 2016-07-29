//
//  MRGroupPostItemTableViewCell.h
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/16/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSharePost;
@protocol MRGroupPostItemTableViewCellDelegate;

@interface MRGroupPostItemTableViewCell : UITableViewCell

@property (nonatomic,weak) id<MRGroupPostItemTableViewCellDelegate> delegate;

@property (nonatomic,weak) UITableView *parentTableView;
- (void)setPostContent:(MRSharePost*)post tagIndex:(NSInteger)tagIndex;

@end

@protocol MRGroupPostItemTableViewCellDelegate <NSObject>
@optional

- (void)commentButtonTapped:(MRSharePost*)post;
- (void)likeButtonTapped:(NSInteger)index;
- (void)shareButtonTapped:(MRSharePost*)groupPost;

@end
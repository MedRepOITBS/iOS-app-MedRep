//
//  MRGroupPostItemTableViewCell.h
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/16/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRGroupPost;
@protocol MRGroupPostItemTableViewCellDelegate;

@interface MRGroupPostItemTableViewCell : UITableViewCell

@property (nonatomic,weak) id<MRGroupPostItemTableViewCellDelegate> delegate;

@property (nonatomic,weak) UITableView *parentTableView;
- (void)setPostContent:(MRGroupPost*)post tagIndex:(NSInteger)tagIndex;

@end

@protocol MRGroupPostItemTableViewCellDelegate <NSObject>
@optional

-(void)mrGroupPostItemTableViewCell:(MRGroupPostItemTableViewCell *)cell withCommentButtonTapped:(id)sender;

- (void)likeButtonTapped;

@end
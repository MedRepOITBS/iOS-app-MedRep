//
//  GroupPostChildTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 6/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRPostedReplies;

@interface GroupPostChildTableViewCell : UITableViewCell

- (void)fillCellWithData:(MRPostedReplies*)post andParentViewController:(UIViewController *)parentViewController;

@end

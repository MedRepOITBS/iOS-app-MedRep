//
//  MRGroupPostItemTableViewCell.h
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/16/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRGroupPost;

@interface MRGroupPostItemTableViewCell : UITableViewCell

- (void)setPostContent:(MRGroupPost*)post;

@end

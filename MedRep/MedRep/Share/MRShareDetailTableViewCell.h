//
//  MRShareDetailTableViewCell.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/4/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRReplies;

@interface MRShareDetailTableViewCell : UITableViewCell

- (void)setContentData:(MRReplies*)reply;

@end

//
//  MRGroupTableViewCell.h
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/21/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRGroupObject.h"

@class MRGroup;

@interface MRGroupTableViewCell : UITableViewCell

- (void)setGroup:(MRGroup*)group;
- (void)setGroupData:(MRGroupObject*)group;

@end

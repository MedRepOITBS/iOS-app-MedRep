//
//  MRShareOptionTableViewCell.h
//  MedRep
//
//  Created by Vamsi Katragadda on 7/7/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRContact, MRGroup;

@interface MRShareOptionTableViewCell : UITableViewCell

- (void)setContactDataInCell:(MRContact*)contact;
- (void)setGroupDataInCell:(MRGroup*)group;

@end

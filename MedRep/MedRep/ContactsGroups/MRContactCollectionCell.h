//
//  MRContactCollectionCell.h
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRContact, MRGroup;

@interface MRContactCollectionCell : UICollectionViewCell

- (void)setData:(MRContact*)contact;
- (void)setGroupData:(MRGroup*)group;

@end

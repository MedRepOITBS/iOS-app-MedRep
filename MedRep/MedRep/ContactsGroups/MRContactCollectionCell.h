//
//  MRContactCollectionCell.h
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRContact;

@interface MRContactCollectionCell : UICollectionViewCell

- (void)setData:(MRContact*)contact;

@end

//
//  MRTransformTitleCollectionViewCell.h
//  MedRep
//
//  Created by Vamsi Katragadda on 6/14/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRTransformTitleCollectionViewCell : UICollectionViewCell

- (void)setHeading:(NSString*)title;
- (void)setCorners;
- (void)clearCorners;

@end

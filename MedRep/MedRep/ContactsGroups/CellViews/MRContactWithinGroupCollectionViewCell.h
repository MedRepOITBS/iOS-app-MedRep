//
//  MRContactWithinGroupCollectionViewCell.h
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRContactWithinGroupCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameTxt;
@property (weak, nonatomic) IBOutlet UIButton *rejectBtn;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;

- (IBAction)rejectAction:(id)sender;
- (IBAction)acceptAction:(id)sender;

@end

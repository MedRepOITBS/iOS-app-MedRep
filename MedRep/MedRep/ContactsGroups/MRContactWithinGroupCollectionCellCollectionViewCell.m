//
//  MRContactWithinGroupCollectionCellCollectionViewCell.m
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/21/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRContactWithinGroupCollectionCellCollectionViewCell.h"
#import "MRContact.h"
#import "MRGroup.h"

@interface MRContactWithinGroupCollectionCellCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UILabel* label;

@end

@implementation MRContactWithinGroupCollectionCellCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setContact:(MRContact *)contact {
    self.imageView.image = [UIImage imageNamed:contact.profilePic];
    self.label.text = contact.name;
}

- (void)setGroup:(MRGroup *)group {
    self.imageView.image = [UIImage imageNamed:group.groupPicture];
    self.label.text = group.name;
}

@end

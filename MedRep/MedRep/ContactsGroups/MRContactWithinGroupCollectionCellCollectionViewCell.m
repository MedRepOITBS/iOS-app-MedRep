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
#import "MRAppControl.h"

@interface MRContactWithinGroupCollectionCellCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UILabel* label;

@end

@implementation MRContactWithinGroupCollectionCellCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setContact:(MRContact *)contact {
    [MRAppControl getContactImage:contact andImageView:self.imageView];
    self.label.text = [MRAppControl getContactName:contact];
}

- (void)setGroup:(MRGroup *)group {
    [MRAppControl getGroupImage:group andImageView:self.imageView];
    //[UIImage imageNamed:group.groupPicture];
    self.label.text = group.group_name;
}

@end

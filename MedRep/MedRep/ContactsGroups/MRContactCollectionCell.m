//
//  MRContactCollectionCell.m
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRContactCollectionCell.h"
#import "MRContact.h"

@interface MRContactCollectionCell()

@property (weak, nonatomic) IBOutlet UILabel* name;
@property (weak, nonatomic) IBOutlet UILabel* detail;
@property (weak, nonatomic) IBOutlet UIImageView* picture;

@end

@implementation MRContactCollectionCell

- (void)awakeFromNib {
    // Initialization code
}


//{"name":"John Doe","description":"ortho","profile_pic":""}
- (void)setData:(MRContact*)contact {
    self.name.text = contact.name;
    self.detail.text = contact.role;
    NSString* imageName = contact.profilePic;
    if (imageName) {
       self.picture.image = [UIImage imageNamed:imageName];
    } else {
        self.picture.image = nil;
    }
}

@end

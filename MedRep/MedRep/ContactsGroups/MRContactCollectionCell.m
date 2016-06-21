//
//  MRContactCollectionCell.m
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRContactCollectionCell.h"
#import "MRContact.h"
#import "MRCommon.h"

@interface MRContactCollectionCell()

@property (weak, nonatomic) IBOutlet UILabel* name;
@property (weak, nonatomic) IBOutlet UILabel* detail;
@property (weak, nonatomic) IBOutlet UIImageView* picture;

@end

@implementation MRContactCollectionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setGroupData:(MRGroupObject*)group{
    self.picture.image = [MRCommon getImageFromBase64Data:[group.group_img_data dataUsingEncoding:NSUTF8StringEncoding]];
    self.name.text = group.group_name;
    self.detail.text = group.group_short_desc;
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

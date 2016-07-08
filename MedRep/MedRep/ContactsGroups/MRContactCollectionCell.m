//
//  MRContactCollectionCell.m
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRContactCollectionCell.h"
#import "MRGroupUserObject.h"
#import "MRCommon.h"
#import "MRAppControl.h"
#import "MRContact.h"
#import "MRGroup.h"

@interface MRContactCollectionCell()

@property (weak, nonatomic) IBOutlet UILabel* name;
@property (weak, nonatomic) IBOutlet UILabel* detail;
@property (weak, nonatomic) IBOutlet UIImageView* picture;

@end

@implementation MRContactCollectionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setGroupData:(MRGroup*)group{
    for (UIView *view in self.picture.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    NSLog(@"%@", group.group_name);
    self.name.text = group.group_name;
    self.detail.text = group.group_short_desc;
    
    [MRAppControl getGroupImage:group andImageView:self.picture];
}

//{"name":"John Doe","description":"ortho","profile_pic":""}
/*- (void)setData:(MRContact*)contact {
    for (UIView *view in self.picture.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    self.name.text = contact.name;
    self.detail.text = contact.role;
    NSString* imageName = contact.profilePic;
    if (imageName.length) {
       self.picture.image = [UIImage imageNamed:imageName];
    } else {
        self.picture.image = nil;
        if (contact.name.length > 0) {
            UILabel *subscriptionTitleLabel = [[UILabel alloc] initWithFrame:self.picture.bounds];
            subscriptionTitleLabel.textAlignment = NSTextAlignmentCenter;
            subscriptionTitleLabel.font = [UIFont systemFontOfSize:15.0];
            subscriptionTitleLabel.textColor = [UIColor lightGrayColor];
            subscriptionTitleLabel.layer.cornerRadius = 5.0;
            subscriptionTitleLabel.layer.masksToBounds = YES;
            subscriptionTitleLabel.layer.borderWidth =1.0;
            subscriptionTitleLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
            
            NSArray *substrngs = [contact.name componentsSeparatedByString:@" "];
            NSString *imageString = @"";
            for(NSString *str in substrngs){
                if (str.length > 0) {
                    imageString = [imageString stringByAppendingString:[NSString stringWithFormat:@"%c",[str characterAtIndex:0]]];
                }
            }
            subscriptionTitleLabel.text = imageString.length > 2 ? [imageString substringToIndex:2] : imageString;
            [self.picture addSubview:subscriptionTitleLabel];
        }
    }
}*/

- (void)setData:(MRContact*)contact {
    for (UIView *view in self.picture.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    NSString *fullName = [MRAppControl getContactName:contact];
    self.name.text = fullName;
    self.picture.image = [MRAppControl getContactImage:contact];
    
    self.detail.text = contact.therapeuticArea.length ? contact.therapeuticArea : contact.therapeuticName;
    if (contact.profilePic != nil ) {
        self.picture.image = [UIImage imageWithData:contact.profilePic];
    } else {
        self.picture.image = nil;
        if (fullName.length > 0) {
            UILabel *subscriptionTitleLabel = [[UILabel alloc] initWithFrame:self.picture.bounds];
            subscriptionTitleLabel.textAlignment = NSTextAlignmentCenter;
            subscriptionTitleLabel.font = [UIFont systemFontOfSize:15.0];
            subscriptionTitleLabel.textColor = [UIColor lightGrayColor];
            subscriptionTitleLabel.layer.cornerRadius = 5.0;
            subscriptionTitleLabel.layer.masksToBounds = YES;
            subscriptionTitleLabel.layer.borderWidth =1.0;
            subscriptionTitleLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
            
            NSString *imageString = @"";
            if (fullName.length > 0) {
                imageString = [imageString stringByAppendingString:[NSString stringWithFormat:@"%c",[fullName characterAtIndex:0]]];
            }
            subscriptionTitleLabel.text = imageString;
            [self.picture addSubview:subscriptionTitleLabel];
        }
    }
}

@end

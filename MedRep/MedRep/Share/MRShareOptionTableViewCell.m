//
//  MRShareOptionTableViewCell.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/7/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRShareOptionTableViewCell.h"
#import "MRContact.h"
#import "MRGroup.h"
#import "MRAppControl.h"

@interface MRShareOptionTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *contactPic;
@property (weak, nonatomic) IBOutlet UILabel *contactName;

@end


@implementation MRShareOptionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContactDataInCell:(MRContact*)contact {
    
    NSString *fullName = [MRAppControl getContactName:contact];
    self.contactName.text = fullName;
    self.contactPic.image = [MRAppControl getContactImage:contact];
    
    if (contact.profilePic != nil ) {
        self.contactPic.image = [UIImage imageWithData:contact.profilePic];
    } else {
        self.contactPic.image = nil;
        if (fullName.length > 0) {
            UILabel *subscriptionTitleLabel = [[UILabel alloc] initWithFrame:self.contactPic.bounds];
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
            [self.contactPic addSubview:subscriptionTitleLabel];
        }
    }
}

- (void)setGroupDataInCell:(MRGroup*)group {
    
    NSString *fullName = group.group_name;
    self.contactName.text = fullName;
    
    if (group.group_img_data != nil ) {
//        self.contactPic.image = [UIImage imageWithData:group.profilePic];
    } else {
        self.contactPic.image = nil;
        if (fullName.length > 0) {
            UILabel *subscriptionTitleLabel = [[UILabel alloc] initWithFrame:self.contactPic.bounds];
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
            [self.contactPic addSubview:subscriptionTitleLabel];
        } else {
            self.contactPic.image = [UIImage imageNamed:@"person"];
        }
    }
}

@end

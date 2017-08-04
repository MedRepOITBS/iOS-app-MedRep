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
    [MRAppControl getContactImage:contact andImageView:self.contactPic];
}

- (void)setGroupDataInCell:(MRGroup*)group {
    
    self.contactName.text = group.group_name;
    [MRAppControl getGroupImage:group andImageView:self.contactPic];
}

@end

//
//  addProfileItemsTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "addProfileItemsTableViewCell.h"

@implementation addProfileItemsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setButtonTitleForType:(NSString *)type{
 
    

    if ([type isEqualToString:@"WORK_EXP"] || [type isEqualToString:@"WORK_EXP_DETAIL"]) {
        
        [self.addPlaceHolderButton setTitle:@"+ Add Experience" forState:UIControlStateNormal];

        
        
    }else if([type isEqualToString:@"INTEREST_AREA"] || [type isEqualToString:@"INTEREST_AREA_DETAIL"]) {
        [self.addPlaceHolderButton setTitle:@"+ Add Interest Area" forState:UIControlStateNormal];

        
    }else if([type isEqualToString:@"EDUCATION_QUAL"] ||[type isEqualToString:@"EDUCATION_QUAL_DETAIL"] ){
        [self.addPlaceHolderButton setTitle:@"+ Add Qualification" forState:UIControlStateNormal];

        
    }else if ([type isEqualToString:@"PUBLICATION"]|| [type isEqualToString:@"PUBLICATION_DETAIL"]) {
        
        [self.addPlaceHolderButton setTitle:@"+ Add Publication" forState:UIControlStateNormal];

    }

    
}
-(IBAction)buttonPressed:(id)sender{
    if ([self.delegate respondsToSelector:@selector(addProfileItemsTableViewCellDelegateForButtonPressed:)]) {
        [self.delegate  addProfileItemsTableViewCellDelegateForButtonPressed:self];
    }
}
@end

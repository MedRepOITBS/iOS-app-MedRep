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
        self.addPlaceHolderButton.tag = 2050;
        [self.addPlaceHolderButton setTitle:@"+ Add Experience" forState:UIControlStateNormal];

        
        
    }else if([type isEqualToString:@"INTEREST_AREA"] || [type isEqualToString:@"INTEREST_AREA_DETAIL"]) {
         self.addPlaceHolderButton.tag = 2051;
        [self.addPlaceHolderButton setTitle:@"+ Add Interest Area" forState:UIControlStateNormal];

        
    }else if([type isEqualToString:@"EDUCATION_QUAL"] ||[type isEqualToString:@"EDUCATION_QUAL_DETAIL"] ){
        self.addPlaceHolderButton.tag = 2052;
        [self.addPlaceHolderButton setTitle:@"+ Add Qualification" forState:UIControlStateNormal];

        
    }else if ([type isEqualToString:@"PUBLICATION"]|| [type isEqualToString:@"PUBLICATION_DETAIL"]) {
        self.addPlaceHolderButton.tag = 2053;
        [self.addPlaceHolderButton setTitle:@"+ Add Publication" forState:UIControlStateNormal];

    }

    
}
-(IBAction)buttonPressed:(id)sender{
    if ([self.delegate respondsToSelector:@selector(addProfileItemsTableViewCellDelegateForButtonPressed:withButtonType:)]) {
        NSInteger buttonIndex = ((UIButton *)sender).tag;
        switch (buttonIndex) {
            case 2050:
                
            {
                [self.delegate  addProfileItemsTableViewCellDelegateForButtonPressed:self withButtonType:@"WORK_EXP"];

            }
                break;
            case 2051:
                
            {
                [self.delegate  addProfileItemsTableViewCellDelegateForButtonPressed:self withButtonType:@"INTEREST_AREA"];
                
            }
                break;
            case 2052:
                
            {
                [self.delegate  addProfileItemsTableViewCellDelegateForButtonPressed:self withButtonType:@"EDUCATION_QUAL"];
                
            }
                break;
            case 2053:
                
            {
                [self.delegate  addProfileItemsTableViewCellDelegateForButtonPressed:self withButtonType:@"PUBLICATION"];
                
            }
                break;
                
            default:
                break;
        }
    }
}
@end

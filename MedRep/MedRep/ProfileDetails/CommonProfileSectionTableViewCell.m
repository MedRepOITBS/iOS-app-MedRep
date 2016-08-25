//
//  CommonProfileSectionTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "CommonProfileSectionTableViewCell.h"


@implementation CommonProfileSectionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)addButtonTapped:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(CommonProfileSectionTableViewCellDelegateForButtonPressed:withButtonType:)]) {
        NSInteger buttonIndex = ((UIButton *)sender).tag;
        switch (buttonIndex) {
            case 401:
                
            {
                [self.delegate  CommonProfileSectionTableViewCellDelegateForButtonPressed:self withButtonType:@"WORK_EXP"];
                
            }
                break;
            case 402:
                
            {
                [self.delegate  CommonProfileSectionTableViewCellDelegateForButtonPressed:self withButtonType:@"INTEREST_AREA"];
                
            }
                break;
            case 403:
                
            {
                [self.delegate  CommonProfileSectionTableViewCellDelegateForButtonPressed:self withButtonType:@"EDUCATION_QUAL"];
                
            }
                break;
            case 404:
                
            {
                [self.delegate  CommonProfileSectionTableViewCellDelegateForButtonPressed:self withButtonType:@"PUBLICATION"];
                
            }
                break;
                
            default:
                break;
        }
    }
}
-(void)setCommonProfileDataForType:(NSString *)type withUserProfileData:(MRProfile *)profile{
    
    
    if ([type isEqualToString:@"WORK_EXP"]) {
       
        if ([profile.workExperience.array count]>0) {
            _sectionDescName.hidden = YES;
        }
        _sectionTitleName.text = @"Work Experience";
        _sectionDescName.text = @"Add Details of your Work Experience and make it easier for colleagues to find you.";
        _addButton.tag = 401;
        
    } else if([type isEqualToString:@"INTEREST_AREA"]) {
        _sectionTitleName.text = @"Therapeutic Areas";
        _sectionDescName.text = @"Add your Therapeutic Area";
        
        if ([profile.interestArea.array count]>0) {
            _sectionDescName.hidden = YES;
        }
        
        _addButton.tag = 402;
    }else if([type isEqualToString:@"EDUCATION_QUAL"]){
        
        if ([profile.educationlQualification.array count]>0) {
            _sectionDescName.hidden = YES;
        }
        _sectionTitleName.text = @"Educational Qualifications";
        _sectionDescName.text = @"Add your Qualification";
        
        _addButton.tag = 403;
        
    }else if ([type isEqualToString:@"PUBLICATION"]) {
        
        if ([profile.publications.array count]>0) {
            _sectionDescName.hidden = YES;
        }
        _sectionTitleName.text = @"Publications";
        _sectionDescName.text = @"Add a Publication and be recognised for your research";
        
        _addButton.tag = 404;
    } else if ([type isEqualToString:@"ADDRESS_INFO"]) {
        
        if ([profile.addressInfo.array count]>0) {
            _sectionDescName.hidden = YES;
        }
        _sectionTitleName.text = @"Addresses";
        _sectionDescName.text = @"Edit your addresses if there is any change in them.";
        _addButton.tag = 405;
    }
}
@end

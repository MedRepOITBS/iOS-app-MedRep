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
-(void)setCommonProfileDataForType:(NSString *)type{
    
    
    if ([type isEqualToString:@"WORK_EXP"]) {
       
        _sectionTitleName.text = @"Work Experience";
        _sectionDescName.text = @"Add Details of your Work Experience and make it easier for colleagues to find you.";

        
    }else if([type isEqualToString:@"INTEREST_AREA"]) {
        _sectionTitleName.text = @"Interest Areas";
        _sectionDescName.text = @"Add your Interest Area";

        
    }else if([type isEqualToString:@"EDUCATION_QUAL"]){
        _sectionTitleName.text = @"Educational Qualifications";
        _sectionDescName.text = @"Add your Qualification";
        
        
    }else if ([type isEqualToString:@"PUBLICATION"]) {
        
        _sectionTitleName.text = @"Publications";
        _sectionDescName.text = @"Add a Publication and be recognised for your research";
        
    }
    
}
@end

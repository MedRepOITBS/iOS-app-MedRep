//
//  CommonProfileSectionTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonProfileSectionTableViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *sectionTitleName;
@property (nonatomic,weak) IBOutlet  UILabel *sectionDescName;

-(void)setCommonProfileDataForType:(NSString *)type;

@end

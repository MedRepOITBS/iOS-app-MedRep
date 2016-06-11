//
//  MRMenuTableViewCell.h
//  MedRep
//
//  Created by MedRep Developer on 01/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRMenuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellIcon;
@property (weak, nonatomic) IBOutlet UILabel *menuTitle;

@end

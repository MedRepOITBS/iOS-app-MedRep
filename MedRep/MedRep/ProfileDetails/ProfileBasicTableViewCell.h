//
//  ProfileBasicTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileBasicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *profileimageView;
@property (weak, nonatomic) IBOutlet UILabel *userLocation;

@end

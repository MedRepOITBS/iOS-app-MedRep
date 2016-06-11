//
//  MRRegistationViewController.h
//  MedRep
//
//  Created by MedRep Developer on 16/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRRegTableViewCell.h"
#import "MRRegHeaderView.h"

@interface MRRegistationViewController : UIViewController<MRRegTableViewCellDelagte, MRRegHeaderViewDelegate>

@property (assign, nonatomic) BOOL isFromSinUp;
@property (assign, nonatomic) BOOL isFromEditing;
@end

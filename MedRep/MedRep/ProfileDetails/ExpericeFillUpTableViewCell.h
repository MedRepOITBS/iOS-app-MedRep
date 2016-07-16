//
//  ExpericeFillUpTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpericeFillUpTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateDesc;
@property (weak, nonatomic) IBOutlet UILabel *otherDesc;
@property (weak, nonatomic) IBOutlet UILabel *title;

@end

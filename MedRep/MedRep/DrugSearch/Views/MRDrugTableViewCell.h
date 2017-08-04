//
//  MRDrugTableViewCell.h
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 7/2/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRDrugTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *brand;
@property (weak, nonatomic) IBOutlet UILabel *type;
@property (weak, nonatomic) IBOutlet UILabel *company;

@end

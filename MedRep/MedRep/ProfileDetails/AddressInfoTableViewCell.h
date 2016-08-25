//
//  AddressInfoTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 8/24/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *hospitalAddressView;
@property (weak, nonatomic) IBOutlet UIView *clinicAddressView;
@property (weak, nonatomic) IBOutlet UILabel *hp_address1Lbl;
@property (weak, nonatomic) IBOutlet UILabel *hp_address2Lbl;
@property (weak, nonatomic) IBOutlet UILabel *hp_cityStateZipLbl;
@property (weak, nonatomic) IBOutlet UILabel *cl_address1Lbl;
@property (weak, nonatomic) IBOutlet UILabel *cl_address2Lbl;
@property (weak, nonatomic) IBOutlet UILabel *cl_cityStateZipLbl;

@end

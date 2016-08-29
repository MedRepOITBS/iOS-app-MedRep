//
//  AddressInfoTableViewCell.m
//  MedRep
//
//  Created by Namit Nayak on 8/24/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "AddressInfoTableViewCell.h"
#import "AddressInfo.h"
#import "ContactInfo.h"
#import "EditLocationViewController.h"

@interface AddressInfoTableViewCell ()

@property (nonatomic) AddressInfo *addressInfo;
@property (nonatomic) ContactInfo *contactInfo;
@property (nonatomic) UIViewController *parentViewController;

@property (weak, nonatomic) IBOutlet UIView *hospitalAddressView;
@property (weak, nonatomic) IBOutlet UILabel *hp_address1Lbl;
@property (weak, nonatomic) IBOutlet UILabel *hp_address2Lbl;
@property (weak, nonatomic) IBOutlet UILabel *hp_cityStateZipLbl;
@property (weak, nonatomic) IBOutlet UILabel *hp_countryZiplbl;

@end

@implementation AddressInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellData:(AddressInfo *)addressInfo contactInfo:(ContactInfo*)contactInfo
andParentViewController:(UIViewController*)parentViewController {
    self.addressInfo = addressInfo;
    self.contactInfo = contactInfo;
    self.parentViewController = parentViewController;
    
    self.hp_address1Lbl.text =addressInfo.address1;
    self.hp_address2Lbl.text = addressInfo.address2;
    self.hp_cityStateZipLbl.text = [NSString stringWithFormat:@"%@, %@, %@",addressInfo.city,addressInfo.state,addressInfo.zipcode];
    
    NSMutableString *countryZipString = [NSMutableString new];
    if (addressInfo.country != nil && addressInfo.country.length > 0) {
        [countryZipString appendString:addressInfo.country];
    }
    
    if (addressInfo.zipcode != nil && addressInfo.zipcode.length > 0) {
        if (countryZipString.length > 0) {
            [countryZipString appendString:@"-"];
        }
        [countryZipString appendString:addressInfo.zipcode];
    }
    self.hp_countryZiplbl.text = countryZipString;
}

- (IBAction)editAddressButtonTapped:(id)sender {
    EditLocationViewController *editLocationVC = [EditLocationViewController new];
    editLocationVC.addressObject = self.addressInfo;
    editLocationVC.contactInfo = self.contactInfo;
    [self.parentViewController.navigationController pushViewController:editLocationVC  animated:YES];
}

@end

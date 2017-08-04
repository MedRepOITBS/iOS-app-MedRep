//
//  AddressInfoTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 8/24/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddressInfo, ContactInfo;

@interface AddressInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteAddressButton;

@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteAddressButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteAddressButtonTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editButtonTrailingConstraint;

- (void)setCellData:(AddressInfo*)addressInfo contactInfo:(ContactInfo*)contactInfo
andParentViewController:(UIViewController*)parentViewController;

@end

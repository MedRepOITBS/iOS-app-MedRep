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

- (void)setCellData:(AddressInfo*)addressInfo contactInfo:(ContactInfo*)contactInfo
andParentViewController:(UIViewController*)parentViewController;

@end

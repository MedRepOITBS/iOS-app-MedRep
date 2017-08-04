//
//  ContactInfoTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 8/24/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *primaryContactNumberLbl;
@property (weak, nonatomic) IBOutlet UILabel *secondaryContactNumberLbl;
@property (weak, nonatomic) IBOutlet UILabel *primaryEmailLbl;
@property (weak, nonatomic) IBOutlet UILabel *secondaryEmailLbl;

@end

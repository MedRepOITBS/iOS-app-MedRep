//
//  CommonTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 7/15/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonTableViewCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel *title;
@property(nonatomic,weak) IBOutlet UITextField *inputTextField;



@end

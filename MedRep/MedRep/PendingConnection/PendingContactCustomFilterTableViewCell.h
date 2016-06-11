//
//  PendingContactTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 6/9/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PendingContactCustomFilterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *customFilterName;
@property (weak, nonatomic) IBOutlet UIButton *checkImage;

-(BOOL)isButtonChecked;
@end

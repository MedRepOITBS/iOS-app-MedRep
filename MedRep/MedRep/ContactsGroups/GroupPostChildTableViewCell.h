//
//  GroupPostChildTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 6/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupPostChildTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *commentPic;
@property (weak, nonatomic) IBOutlet UITextView *postText;
@property (strong,nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (strong,nonatomic) IBOutlet NSLayoutConstraint *verticalContstraint;
@end

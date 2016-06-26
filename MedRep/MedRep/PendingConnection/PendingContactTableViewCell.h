//
//  PendingContactTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 6/9/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRPendingMemberProtocol <NSObject>

-(void) rejectAction:(NSInteger)index;
-(void) acceptAction:(NSInteger)index;

@end

@interface PendingContactTableViewCell : UITableViewCell

@property (nonatomic, assign) id<MRPendingMemberProtocol> cellDelegate;

@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *phoneNo;
@property (weak, nonatomic) IBOutlet UIButton *rejectBtn;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;

- (IBAction)rejectAction:(id)sender;
- (IBAction)acceptAction:(id)sender;

@end

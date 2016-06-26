//
//  MRAddMemberTableViewCell.h
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/16/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRAddMemberProtocol <NSObject>

-(void) selectedMemberAtIndex:(NSInteger)index;

@end

@interface MRAddMemberTableViewCell : UITableViewCell

@property (nonatomic, assign) id<MRAddMemberProtocol> cellDelegate;

@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *phoneNo;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;

- (IBAction)checkMarkClicked:(id)sender;

@end

//
//  AddMemberTableViewCell.h
//  MedRep
//
//  Created by Namit Nayak on 8/6/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MRAddMemberTableViewCellProtocol <NSObject>
@optional
-(void) rejectAction:(NSInteger)index;
-(void) acceptAction:(NSInteger)index;

@end
@interface AddMemberTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameTxt;
@property (weak, nonatomic) IBOutlet UIButton *rejectBtn;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;
@property (nonatomic, assign) id<MRAddMemberTableViewCellProtocol> cellDelegate;

- (IBAction)rejectAction:(id)sender;
- (IBAction)acceptAction:(id)sender;
@end

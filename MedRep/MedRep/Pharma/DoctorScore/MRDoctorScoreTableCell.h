//
//  MRDoctorScoreTableCell.h
//  Gravity
//
//  Created by Apple on 26/09/15.
//  Copyright © 2015 Sprim. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRDoctorScoreTableCell;

@protocol MRDoctorScoreTableCellDeleagte <NSObject>
- (void)doctorLocationButtonActiondelagate:(MRDoctorScoreTableCell*)scoreCell;
@end

@interface MRDoctorScoreTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellImgView;
@property (weak, nonatomic) IBOutlet UILabel *cellTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellDescLabel;
@property (weak, nonatomic) IBOutlet UIView *locationButton;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (nonatomic, assign) id<MRDoctorScoreTableCellDeleagte> cellDelegate;

@property (weak, nonatomic) IBOutlet UIButton *locationButtonAction;

@end


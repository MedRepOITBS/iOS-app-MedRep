//
//  MRRegistationTwoViewController.h
//  MedRep
//
//  Created by MedRep Developer on 27/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRRegTableViewCell.h"
#import "MRRegHeaderView.h"

@interface MRRegistationTwoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,MRRegTableViewCellDelagte, MRRegHeaderViewDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UIView *addressViewHeader;
@property (weak, nonatomic) IBOutlet UIButton *hospitalButton;
@property (weak, nonatomic) IBOutlet UIButton *privateClinicButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UITableView *regTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextButtonTopConstraint;
@property (assign, nonatomic) BOOL isFromSinUp;
@property (assign, nonatomic) NSInteger registrationStage;
@property (assign, nonatomic) BOOL isFromEditing;

- (IBAction)privateButtonAction:(id)sender;
- (IBAction)hospitalButtonAction:(id)sender;
- (IBAction)nextButtonAction:(id)sender;


@end

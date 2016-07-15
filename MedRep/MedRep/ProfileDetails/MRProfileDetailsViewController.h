//
//  MRProfileDetailsViewController.h
//  
//
//  Created by MedRep Developer on 12/12/15.
//
//

#import <UIKit/UIKit.h>

@interface MRProfileDetailsViewController : UITableViewController

@property (assign, nonatomic) BOOL isFromSinUp;

- (IBAction)changeButtonAction:(id)sender;
- (IBAction)profileEditButtonAction:(id)sender;
- (IBAction)addressEditButtonAction:(id)sender;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alternateEmailViewHeightConstratint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mobileNumberViewHeightConstraint;
//@property (weak, nonatomic) IBOutlet UILabel *alterNateEmailTitleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *alternateMobileTitleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
//@property (weak, nonatomic) IBOutlet UILabel *mobileNumberLabel;
//@property (weak, nonatomic) IBOutlet UILabel *AlternateMobileNumberLabel;
//@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
//@property (weak, nonatomic) IBOutlet UILabel *alternateEmailLabel;
//@property (weak, nonatomic) IBOutlet UILabel *addressOneLabel;
//@property (weak, nonatomic) IBOutlet UILabel *addressTwoLabel;
@end

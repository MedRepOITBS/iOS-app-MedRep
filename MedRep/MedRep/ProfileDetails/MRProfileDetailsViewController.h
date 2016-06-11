//
//  MRProfileDetailsViewController.h
//  
//
//  Created by MedRep Developer on 12/12/15.
//
//

#import <UIKit/UIKit.h>

@interface MRProfileDetailsViewController : UIViewController

@property (assign, nonatomic) BOOL isFromSinUp;

- (IBAction)changeButtonAction:(id)sender;
- (IBAction)profileEditButtonAction:(id)sender;
- (IBAction)addressEditButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alternateEmailViewHeightConstratint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mobileNumberViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *alterNateEmailTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *alternateMobileTitleLabel;

@end

//
//  InterestPublicationViewController.h
//  MedRep
//
//  Created by Namit Nayak on 7/19/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MRInterestArea;
@interface InterestViewController : UIViewController
@property (nonatomic,weak) IBOutlet UITextField *interestAreaTextField;
@property (nonatomic,strong) NSString *fromScreen;
@property (nonatomic,strong) MRInterestArea *interestAreaObj;
@property (nonatomic,weak) IBOutlet UIButton *theurpaticBtn;
-(IBAction)theurpaticBtnTapped:(id)sender;
@end

//
//  AddExperienceTableViewController.h
//  MedRep
//
//  Created by Namit Nayak on 7/14/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MRWorkExperience;
@interface AddExperienceTableViewController : UIViewController

@property (nonatomic,strong) NSString *fromScreen;
@property (nonatomic,strong) MRWorkExperience *workExperience;
@end

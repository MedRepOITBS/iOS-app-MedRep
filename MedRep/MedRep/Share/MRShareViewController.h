//
//  MRContactDetailViewController.h
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/22/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRContact;
@class MRGroup;

@interface MRShareViewController : UIViewController

- (void)setContact:(MRContact*)contact;
- (void)setGroup:(MRGroup*)group;

@end

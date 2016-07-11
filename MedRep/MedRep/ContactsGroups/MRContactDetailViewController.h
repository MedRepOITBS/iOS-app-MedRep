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

@interface MRContactDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) BOOL isSuggestedGroup;

@property (nonatomic, assign) NSInteger launchMode;

- (void)setContact:(MRContact*)contact;
- (void)setGroup:(MRGroup*)group;

@end

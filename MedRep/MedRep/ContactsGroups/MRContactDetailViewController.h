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
@class MRGroupObject;

@interface MRContactDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *contactList;

- (void)setContact:(MRContact*)contact;
- (void)setGroup:(MRGroup*)group;
- (void)setGroupData:(MRGroupObject*)group;

@end

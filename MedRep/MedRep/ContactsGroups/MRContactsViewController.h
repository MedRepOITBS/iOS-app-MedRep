//
//  MRContactsViewController.h
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRGroupsListViewController,PendingContactsViewController;

@interface MRContactsViewController : UIViewController

@property (strong, nonatomic) MRGroupsListViewController* groupsListViewController;
@property (strong,nonatomic) PendingContactsViewController *pendingContactsViewController;
@end

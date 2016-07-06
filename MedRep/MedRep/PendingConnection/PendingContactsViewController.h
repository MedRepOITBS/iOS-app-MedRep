//
//  PendingContactsViewController.h
//  MedRep
//
//  Created by Namit Nayak on 6/8/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PendingContactsViewController : UIViewController <UITableViewDataSource ,UITableViewDelegate>

@property (nonatomic, assign) BOOL isFromGroup;
@property (nonatomic, assign) BOOL isFromMember;
@property (strong, nonatomic) NSString *gid;

@end

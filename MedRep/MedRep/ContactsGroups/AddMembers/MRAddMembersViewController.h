//
//  MRAddMembersViewController.h
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/16/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRAddMembersViewController : UIViewController

@property (assign, nonatomic) NSInteger groupID;
@property (strong, nonatomic) NSMutableArray *pendingContactListArray;

@end

//
//  MemberListViewController.h
//  MedRep
//
//  Created by Namit Nayak on 8/6/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberListViewController : UIViewController
@property (strong, nonatomic) NSArray* contactsUnderGroup;
@property (strong, nonatomic) IBOutlet UIView *navView;

@end

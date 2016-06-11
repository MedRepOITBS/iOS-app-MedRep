//
//  MRListViewController.h
//  MedRep
//
//  Created by MedRep Developer on 20/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    MRListVIewTypeNone = 0,
    MRListVIewTypeTherapetic,
    MRListVIewTypeNotificationTherapetic,
    MRListVIewTypeAddress,
    MRListVIewTypeCompanyList,
} MRListVIewType;

@protocol MRListViewControllerDelegate <NSObject>

- (void)dismissPopoverController;
- (void)selectedListItem:(id)listItem;

@end

@interface MRListViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (nonatomic, retain) NSArray *listItems;
@property (nonatomic, assign) id<MRListViewControllerDelegate> delegate;
@property (nonatomic, assign) MRListVIewType listType;
@property (nonatomic, assign) BOOL isFromCallMedrep;

@end

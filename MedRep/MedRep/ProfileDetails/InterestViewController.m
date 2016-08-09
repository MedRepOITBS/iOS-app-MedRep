//
//  InterestPublicationViewController.m
//  MedRep
//
//  Created by Namit Nayak on 7/19/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "InterestViewController.h"
#import "MRDatabaseHelper.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "WYPopoverController.h"
#import "MRListViewController.h"
#import "MRInterestArea.h"
@interface InterestViewController ()
@property (strong, nonatomic) WYPopoverController *myPopoverController;
@end

@implementation InterestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title  = @"Add Therapeutic Area";

    
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"]  style:UIBarButtonItemStyleDone target:self action:@selector(backButtonTapped:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;

    [self setupData];
    
}
-(void)setupData{
    UIBarButtonItem *revealButtonItem;
    if (_interestAreaObj!=nil) {
        self.interestAreaLabel.text = _interestAreaObj.name;
    
        revealButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"UPDATE" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
    }else{
        revealButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
    }
    self.navigationItem.rightBarButtonItem = revealButtonItem;
    
}


-(void)backButtonTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)doneButtonTapped:(id)sender{
    NSString *interestArticle = [self.interestAreaLabel.text stringByTrimmingCharactersInSet:
                                        [NSCharacterSet whitespaceCharacterSet]];
    
    
    if ((interestArticle!=nil && [interestArticle isEqualToString:@""] )|| [interestArticle isEqualToString:@"Select Therapeutic Area"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select the Therapeutic Area." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    
    if ([_fromScreen isEqualToString:@"UPDATE"]) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:interestArticle,@"name",_interestAreaObj.id,@"id", nil];
        [MRDatabaseHelper updateInterest:dict withInterestAreaID:_interestAreaObj.id andHandler:^(id result) {
            if ([result isEqualToString:@"TRUE"]) {
                
                [MRCommon showAlert:@"Therapeutic Area Updated Successfully." delegate:nil];
                
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [MRCommon showAlert:@"Due to server error not able to update Therapeutic Area. Please try again later." delegate:nil];
                
            }

        } ];
    }else{
        [MRDatabaseHelper addInterestArea:[NSArray arrayWithObjects:interestArticle, nil] andHandler:^(id result) {
            if ([result isEqualToString:@"TRUE"]) {
                
                [MRCommon showAlert:@"Therapeutic Area Added Successfully." delegate:nil];
                
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [MRCommon showAlert:@"Due to server error not able to update Therapeutic Area. Please try again later." delegate:nil];
                
            }

        }];
    }
    
}




-(IBAction)theurpaticBtnTapped:(id)sender{
    
        UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        overlayView.tag = 2000;
        overlayView.backgroundColor = kRGBCOLORALPHA(0, 0, 0, 0.5);
        [self.view addSubview:overlayView];
        [MRCommon addUpdateConstarintsTo:self.view withChildView:overlayView];
        
        WYPopoverTheme *popOverTheme = [WYPopoverController defaultTheme];
        popOverTheme.outerStrokeColor = [UIColor lightGrayColor];
        [WYPopoverController setDefaultTheme:popOverTheme];
        
        MRListViewController *moreViewController = [[MRListViewController alloc] initWithNibName:@"MRListViewController" bundle:nil];
        
            moreViewController.modalInPopover = NO;
            moreViewController.delegate = self;
            moreViewController.listType = MRListVIewTypeTherapetic;
            moreViewController.listItems = [MRAppControl sharedHelper].therapeuticAreaDetails;
    
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        moreViewController.preferredContentSize = CGSizeMake(width, 200);
        
        UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController:moreViewController] ;
        contentViewController.navigationBar.hidden = YES;
        
        self.myPopoverController = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
        self.myPopoverController.delegate = self;
        self.myPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(0,2, 0, 2);
        self.myPopoverController.wantsDefaultContentAppearance = YES;
        [self.myPopoverController presentPopoverFromRect:_theurpaticBtn.bounds
                                                  inView:_theurpaticBtn
                                permittedArrowDirections:WYPopoverArrowDirectionUp
                                                animated:YES
                                                 options:WYPopoverAnimationOptionFadeWithScale];
        
    

}

#pragma mark - WYPopoverControllerDelegate

- (void)popoverControllerDidPresentPopover:(WYPopoverController *)controller
{
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    UIView *overlayView = [self.view viewWithTag:2000];
    [overlayView removeFromSuperview];
    
    self.myPopoverController.delegate = nil;
    self.myPopoverController = nil;
}

- (void)dismissPopoverController
{
    [self.myPopoverController dismissPopoverAnimated:YES completion:^{
        [self popoverControllerDidDismissPopover:self.myPopoverController];
    }];
}

- (void)selectedListItem:(id)listItem
{
    NSDictionary *item = (NSDictionary*)listItem;
    
    if ([item objectForKey:@"therapeuticId"]) {
        _interestAreaLabel.text =[item objectForKey:@"therapeuticName"];
        [[MRAppControl sharedHelper].userRegData setObject:[item objectForKey:@"therapeuticId"] forKey:@"therapeuticId"];
        //[myTherapeuticDict objectForKey:@"therapeuticId"];
    }
    
   
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

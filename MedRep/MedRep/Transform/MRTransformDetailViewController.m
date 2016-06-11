//
//  MRTransformDetailViewController.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRTransformDetailViewController.h"
#import "NotificationWebViewController.h"
#import "MPTransformData.h"

@interface MRTransformDetailViewController ()
@property (strong, nonatomic) IBOutlet UIView *navView;
@end

@implementation MRTransformDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Detail";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    //Dummy data
    if (self.selectedContent != nil) {
        if (self.selectedContent.title != nil && self.selectedContent.title.length > 0) {
            _titleLbl.text = self.selectedContent.title;
        }
        
        if (self.selectedContent.detailDescription != nil) {
            _detailLbl.text = self.selectedContent.detailDescription;
        }
        
        if (self.selectedContent.icon != nil && self.selectedContent.icon.length > 0) {
            _contentImage.image = [UIImage imageNamed:self.selectedContent.icon];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)backButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareAction:(UIButton *)sender {
    
}

- (IBAction)gotoWebAction:(id)sender {
    NotificationWebViewController *notiFicationViewController = [[NotificationWebViewController alloc] initWithNibName:@"NotificationWebViewController" bundle:nil];
    notiFicationViewController.isFromTransform = YES;
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}

@end

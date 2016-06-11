//
//  MRHomeViewContoller.m
//  MedRep
//
//  Created by MedRep Developer on 16/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRHomeViewContoller.h"
#import "MROptionsViewController.h"
#import "MRConstants.h"
#import "MRCommon.h"
#import "MRWebserviceHelper.h"
#import "MRAppControl.h"

@interface MRHomeViewContoller ()
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@end

@implementation MRHomeViewContoller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInButtonAction:(id)sender
{
    MRLoginViewController *homeViewController = [[MRLoginViewController alloc] initWithNibName:@"MRLoginViewController" bundle:nil];
    homeViewController.isFromHome = YES;
    [self.navigationController pushViewController:homeViewController animated:YES];
}

- (IBAction)registerButtonAction:(id)sender
{
    MROptionsViewController *homeViewController = [[MROptionsViewController alloc] initWithNibName:@"MROptionsViewController" bundle:nil];
    [self.navigationController pushViewController:homeViewController animated:YES];
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

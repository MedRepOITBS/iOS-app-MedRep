//
//  NotificationUUIDViewController.m
//  MedRep
//
//  Created by Vamsi Katragadda on 6/12/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "NotificationUUIDViewController.h"
#import "MRAppControl.h"

@interface NotificationUUIDViewController ()
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;

@end

@implementation NotificationUUIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.uuidLabel.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)continueButtonClicked:(id)sender {
    MRAppControl *appController = [MRAppControl sharedHelper];
    [appController launchWithApplicationMainWindow:self.appWindow];
}

- (void)refreshScreen {
    self.uuidLabel.text = self.token;
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

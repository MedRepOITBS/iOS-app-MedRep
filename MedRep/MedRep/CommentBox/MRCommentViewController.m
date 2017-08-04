//
//  MRCommentViewController.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/9/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRCommentViewController.h"

@interface MRCommentViewController ()

@property (weak, nonatomic) IBOutlet UIView *parentView;

@end

@implementation MRCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.parentView.layer setCornerRadius:30.0];
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

@end

//
//  UINotificationChartViewController.m
//  MedRep
//
//  Created by Namit Nayak on 9/24/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "UINotificationChartViewController.h"
#import "PNChart.h"
@interface UINotificationChartViewController ()

@end

@implementation UINotificationChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *items = @[[PNPieChartDataItem dataItemWithValue:10 color:PNRed],
                       [PNPieChartDataItem dataItemWithValue:20 color:PNBlue description:@"WWDC"],
                       [PNPieChartDataItem dataItemWithValue:40 color:PNGreen description:@"GOOL I/O"],
                       ];
    
    
    
    PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(40.0, 155.0, 240.0, 240.0) items:items];
    pieChart.descriptionTextColor = [UIColor whiteColor];
    pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
    [pieChart strokeChart];
    [self.mainView addSubview:pieChart];
    // Do any additional setup after loading the view from its nib.
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

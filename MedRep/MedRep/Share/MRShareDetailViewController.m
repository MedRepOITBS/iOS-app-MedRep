//
//  MRShareDetailViewController.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/4/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRShareDetailViewController.h"
#import "MRShareDetailTableViewCell.h"
#import "MRCommon.h"
#import "MRGroupPost.h"

@interface MRShareDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (nonatomic) NSArray *recentActivity;
@property (weak, nonatomic) IBOutlet UILabel *emptyMessage;
@property (weak, nonatomic) IBOutlet UITableView *activitiesTable;

@end

@implementation MRShareDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Detail";
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self.activitiesTable registerNib:[UINib nibWithNibName:@"MRShareDetailTableViewCell"
                               bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MRShareDetailTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MRCommon applyNavigationBarStyling:self.navigationController];
    [self setEmptyMessage];
}

- (void)backButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setEmptyMessage {
    if (self.recentActivity != nil && self.recentActivity.count > 0) {
        [self.emptyMessage setHidden:YES];
        [self.activitiesTable setHidden:NO];
    } else {
        [self.emptyMessage setHidden:NO];
        [self.activitiesTable setHidden:YES];
    }
}

// Table View Data Source & Delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    
    if (self.recentActivity != nil) {
        rows = self.recentActivity.count;
    }
    
    return rows;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    
    if (self.recentActivity != nil && self.recentActivity.count > 0) {
        title = kRecentActivity;
    }
    
    return title;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MRShareDetailTableViewCell"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end

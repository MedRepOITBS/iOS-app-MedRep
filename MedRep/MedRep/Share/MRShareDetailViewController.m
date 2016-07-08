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
#import "MRDatabaseHelper.h"
#import "GroupPostChildTableViewCell.h"
#import "MrGroupChildPost.h"
#import "MRAppControl.h"
@interface MRShareDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (nonatomic) NSArray *recentActivity;
@property (weak, nonatomic) IBOutlet UILabel *emptyMessage;
@property (weak, nonatomic) IBOutlet UITableView *activitiesTable;
@property (strong,nonatomic)NSDictionary *userdata;
@property (nonatomic) NSInteger userType;
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
  self.post =  [MRDatabaseHelper getGroupPostForPostID:self.post.groupPostId];
    self.recentActivity = [NSArray arrayWithArray:self.post.replyPost.array];
    _userdata = [MRAppControl sharedHelper].userRegData;
    
    
    _userType = [MRAppControl sharedHelper].userType;
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
    GroupPostChildTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"groupChildCell"];
    if (cell == nil) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"GroupPostChildTableViewCell" owner:self options:nil];
        cell = (GroupPostChildTableViewCell *)[arr objectAtIndex:0];
    }
    NSArray *aara = [self.post.replyPost array];
    
    
    MrGroupChildPost *childPost = (MrGroupChildPost *)[aara objectAtIndex:indexPath.row];
    
    if ([childPost.postPic isEqualToString:@""]) {
        cell.heightConstraint.constant = 0;
        cell.verticalContstraint.constant = 0;
        [cell setNeedsUpdateConstraints];
    }else {
        NSString * imagePath = childPost.postPic;
        
        cell.commentPic.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
        
    }
    
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
    cell.profileNameLabel.text              = (_userType == 2 || _userType == 1) ? [NSString stringWithFormat:@"Dr. %@ %@", [_userdata objectForKey:KFirstName],[_userdata objectForKey:KLastName]] : [NSString stringWithFormat:@"Mr. %@ %@", [_userdata objectForKey:KFirstName],[_userdata objectForKey:KLastName]];
    cell.profilePic.image = [MRCommon getImageFromBase64Data:[_userdata objectForKey:KProfilePicture]];
    
    cell.postText.text = childPost.postText;
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    
    return 100;
    
}


@end

//
//  MRGroupsListViewController.m
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/21/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRGroupsListViewController.h"
#import "MRContactsViewController.h"
#import "MRDatabaseHelper.h"
#import "MRGroup.h"
#import "MRGroupTableViewCell.h"
#import "MRContactDetailViewController.h"
#import "MRCreateGroupViewController.h"
#import "MRWebserviceHelper.h"
#import "MRCommon.h"
#import "MRGroupUserObject.h"
#import "MRGroupObject.h"

@interface MRGroupsListViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIActionSheetDelegate>{
    NSMutableArray *groupsArray;
    NSMutableArray *filteredGroupsArray;
}

@property (weak, nonatomic) IBOutlet UITableView* groupList;
@property (weak, nonatomic) IBOutlet UISearchBar* searchBar;
@property (weak, nonatomic) IBOutlet UIButton* switchButton;
@property (weak, nonatomic) IBOutlet UIButton* moreOptions;
@property (strong, nonatomic) UIActionSheet *menu;
@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;
@property (strong, nonatomic) IBOutlet UIView *navView;

@property (strong, nonatomic) NSArray* groups;
@property (strong, nonatomic) NSArray* filteredGroups;

@end

@implementation MRGroupsListViewController

- (void)viewTapped:(UITapGestureRecognizer*)tapGesture {
    [self.searchBar resignFirstResponder];
    self.tapGesture.enabled = NO;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    self.tapGesture.numberOfTapsRequired = 1;
    self.tapGesture.cancelsTouchesInView = YES;
    self.tapGesture.enabled = NO;
    [self.view addGestureRecognizer:self.tapGesture];
    
    self.navigationItem.title = @"Groups";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self.groupList registerNib:[UINib nibWithNibName:@"MRGroupTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"groupCell"];
    // Do any additional setup after loading the view from its nib.
    self.groups = [MRDatabaseHelper getGroups];
    self.filteredGroups = self.groups;
    
    filteredGroupsArray = [NSMutableArray array];
    groupsArray = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.searchBar resignFirstResponder];
    
    [self getGroupList];
}

- (void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return self.filteredGroups.count;
    return filteredGroupsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRGroupTableViewCell* groupCell = [tableView dequeueReusableCellWithIdentifier:@"groupCell"];
    [groupCell setGroupData:filteredGroupsArray[indexPath.row]];
    return groupCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
    //return 130; //unhide collection view and view below in cell xib to see all contacts
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MRContactDetailViewController* detailViewController = [[MRContactDetailViewController alloc] init];
    [detailViewController setGroupData:filteredGroupsArray[indexPath.row]];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction)switchButtonTapped:(id)sender {
    [UIView transitionWithView:self.navigationController.view
                      duration:0.75
                       options:UIViewAnimationOptionTransitionCurlDown
                    animations:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    completion:nil];
}

- (IBAction)popOverTapped:(id)sender {
    if (!self.menu) {
        self.menu = [[UIActionSheet alloc] initWithTitle:@"More Options"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"Pending Connections",@"More Connections",@"Create Group", nil];
    }
    [self.menu showFromRect:self.moreOptions.frame inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2 ) {
        [UIView transitionWithView:self.navigationController.view
                          duration:0.75
                           options:UIViewAnimationOptionTransitionCurlUp
                        animations:^{
                            MRCreateGroupViewController* detailViewController = [[MRCreateGroupViewController alloc] init];
                            [self.navigationController pushViewController:detailViewController animated:NO];
                        }
                        completion:nil];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    /*if (searchText.length == 0) {
        self.filteredGroups = self.groups;
    } else {
        self.filteredGroups = [self.groups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[cd] %@",@"name",searchText]];
    }*/
    
    if (searchText.length == 0) {
        filteredGroupsArray = groupsArray;
    } else {
        filteredGroupsArray = [[groupsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[cd] %@",@"group_name",searchText]] mutableCopy];
    }
    [self.groupList reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.tapGesture.enabled = YES;
}

- (void)getGroupList{
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getGroupListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            groupsArray = [NSMutableArray array];
            NSArray *responseArray = responce[@"Responce"];
            for (NSDictionary *dic in responseArray) {
                MRGroupObject *groupObj = [[MRGroupObject alloc] initWithDict:dic];
                [groupsArray addObject:groupObj];
            }
            filteredGroupsArray = groupsArray;
            [_groupList reloadData];
        }
        else
        {
            NSArray *erros =  [details componentsSeparatedByString:@"-"];
            if (erros.count > 0)
                [MRCommon showAlert:[erros lastObject] delegate:nil];
        }
    }];
}

@end

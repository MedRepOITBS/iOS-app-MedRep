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

@interface MRGroupsListViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView* groupList;
@property (weak, nonatomic) IBOutlet UISearchBar* searchBar;
@property (weak, nonatomic) IBOutlet UIButton* switchButton;
@property (weak, nonatomic) IBOutlet UIButton* moreOptions;
@property (strong, nonatomic) UIActionSheet *menu;
@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;

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
    
    UIImageView* titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navLogo.png"]];
    [self.navigationItem setTitleView:titleImage];
    [self.groupList registerNib:[UINib nibWithNibName:@"MRGroupTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"groupCell"];
    // Do any additional setup after loading the view from its nib.
    self.groups = [MRDatabaseHelper getGroups];
    self.filteredGroups = self.groups;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.searchBar resignFirstResponder];
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
    return self.filteredGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRGroupTableViewCell* groupCell = [tableView dequeueReusableCellWithIdentifier:@"groupCell"];
    [groupCell setGroup:self.filteredGroups[indexPath.row]];
    return groupCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MRContactDetailViewController* detailViewController = [[MRContactDetailViewController alloc] init];
    [detailViewController setGroup:self.filteredGroups[indexPath.row]];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction)switchButtonTapped:(id)sender {
    [UIView transitionWithView:self.navigationController.view
                      duration:0.75
                       options:UIViewAnimationOptionTransitionCurlDown
                    animations:^{
                        [self.navigationController popToRootViewControllerAnimated:NO];
                    }
                    completion:nil];
    
}

- (IBAction)popOverTapped:(id)sender {
    
    if (!self.menu) {
        self.menu = [[UIActionSheet alloc] initWithTitle:@"More Options"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"Pending Connections",@"More Connections", nil];
    }
    [self.menu showFromRect:self.moreOptions.frame inView:self.view animated:YES];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.filteredGroups = self.groups;
    } else {
        self.filteredGroups = [self.groups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[cd] %@",@"name",searchText]];
    }
    [self.groupList reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.tapGesture.enabled = YES;
}

@end

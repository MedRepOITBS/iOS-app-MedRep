//
//  MRAddMembersViewController.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/16/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRAddMembersViewController.h"
#import "MRAddMemberTableViewCell.h"
#import "MRConstants.h"
#import "MRWebserviceHelper.h"
#import "MRContactsViewController.h"
#import "MRContact.h"

@interface MRAddMembersViewController () <MRAddMemberProtocol, UISearchBarDelegate>{
    NSMutableArray *selectedContacts;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewMembers;
@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UISearchBar* searchBar;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;
@property (strong, nonatomic) NSMutableArray* fileredContacts;

- (IBAction)addMembers:(id)sender;

@end

@implementation MRAddMembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (_groupID) {
        self.navigationItem.title = @"Invite Members";
        [self.addBtn setTitle:@"Invite Members" forState:UIControlStateNormal];
    }else{
        self.navigationItem.title = @"Add Connections";
        [self.addBtn setTitle:@"Add Connections" forState:UIControlStateNormal];
    }
    //[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    selectedContacts = [NSMutableArray array];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    self.tapGesture.numberOfTapsRequired = 1;
    self.tapGesture.cancelsTouchesInView = YES;
    self.tapGesture.enabled = NO;
    [self.view addGestureRecognizer:self.tapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
        
    [self.searchBar resignFirstResponder];
    [self getAllContactsByCity];
}

- (void)viewTapped:(UITapGestureRecognizer*)tapGesture {
    [self.searchBar resignFirstResponder];
    self.tapGesture.enabled = NO;
}

- (void)getAllContactsByCity {
    [MRDatabaseHelper getContactsByCity:[MRAppControl sharedHelper].userRegData[KCity]
                        responseHandler:^(id results) {
        _fileredContacts = results;
        [self.tableViewMembers reloadData];
    }];
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

- (IBAction)addMembers:(id)sender {
    if (!selectedContacts.count){
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please select at least one contact to add" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        return;
    }
    
    [self addMember];
}

-(void) addMember{
    if (_groupID) {
        NSMutableDictionary *dictReq = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%ld",(long)_groupID], @"group_id",
                                        selectedContacts, @"memberList",
                                        @"PENDING", @"status",
                                        @"false",@"is_admin",
                                        nil];
        
        [MRCommon showActivityIndicator:@"Adding..."];
        [[MRWebserviceHelper sharedWebServiceHelper] addMembersToGroup:dictReq withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
            [MRCommon stopActivityIndicator];
            if (status) {
                for (UIViewController *vc in self.parentViewController.childViewControllers) {
                    if ([vc isKindOfClass:[MRContactsViewController class]]) {
                        [self.navigationController popToViewController:vc animated:YES];
                    }
                }
            }
            else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
            {
                [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
                 {
                     [MRCommon savetokens:responce];
                     [[MRWebserviceHelper sharedWebServiceHelper] addMembersToGroup:dictReq withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                         [MRCommon stopActivityIndicator];
                         if (status) {
                             for (UIViewController *vc in self.parentViewController.childViewControllers) {
                                 if ([vc isKindOfClass:[MRContactsViewController class]]) {
                                     [self.navigationController popToViewController:vc animated:YES];
                                 }
                             }
                         }else
                         {
                             NSArray *erros =  [details componentsSeparatedByString:@"-"];
                             if (erros.count > 0)
                                 [MRCommon showAlert:[erros lastObject] delegate:nil];
                         }
                     }];
                 }];
            }
            else
            {
                NSArray *erros =  [details componentsSeparatedByString:@"-"];
                if (erros.count > 0)
                    [MRCommon showAlert:[erros lastObject] delegate:nil];
            }
        }];
    }else{
        [MRDatabaseHelper addConnections:selectedContacts
                      andResponseHandler:^(id result) {
                          [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                                              object:nil];
                          
                          for (UIViewController *vc in self.parentViewController.childViewControllers) {
                              if ([vc isKindOfClass:[MRContactsViewController class]]) {
                                  [self.navigationController popToViewController:vc animated:YES];
                              }
                          }
                      }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fileredContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static  NSString *ident1 = @"MRAddMemberTableViewCell";
    MRAddMemberTableViewCell *cell = (MRAddMemberTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ident1];
    
    if (cell == nil) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"MRAddMemberTableViewCell" owner:self options:nil];
        cell = (MRAddMemberTableViewCell *)[arr objectAtIndex:0];
    }
    
    MRContact *contact = [_fileredContacts objectAtIndex:indexPath.row];
    
    cell.userName.text = [MRAppControl getContactName:contact];
    [cell.profilePic setImage:nil];
    [MRAppControl getContactImage:contact andImageView:cell.profilePic];
    
    cell.phoneNo.text = contact.therapeuticName;
    cell.checkBtn.tag = indexPath.row;
    cell.cellDelegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

-(void) selectedMemberAtIndex:(NSInteger)index{
    MRContact *contact = [_fileredContacts objectAtIndex:index];
    
    if (_groupID) {
        if ([selectedContacts containsObject:contact.doctorId]) {
            [selectedContacts removeObject:contact.doctorId];
        }else{
            [selectedContacts addObject:contact.doctorId];
        }
    }else{
        if ([selectedContacts containsObject:contact.doctorId]) {
            [selectedContacts removeObject:contact.doctorId];
        }else{
            [selectedContacts addObject:contact.doctorId];
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.fileredContacts = _pendingContactListArray;
    }
    [self.tableViewMembers reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.tapGesture.enabled = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (searchBar.text == nil || searchBar.text.length == 0) {
        [self getAllContactsByCity];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    
    [MRDatabaseHelper getContactsBySearchString:searchBar.text andResponseHandler:^(id results) {
        _fileredContacts = results;
        [_tableViewMembers reloadData];
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self getAllContactsByCity];
}

@end

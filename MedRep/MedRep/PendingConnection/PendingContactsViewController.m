//
//  PendingContactsViewController.m
//  MedRep
//
//  Created by Namit Nayak on 6/8/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "PendingContactsViewController.h"
#import "PendingContactCustomFilterTableViewCell.h"
#import "PendingContactTableViewCell.h"
#import "MRConstants.h"
#import "MRContact.h"
#import "MRGroup.h"
#import "MRContactsViewController.h"

@interface PendingContactsViewController () <MRPendingMemberProtocol> {
    NSMutableArray *fileredContacts;
}
@property (nonatomic)BOOL isCustomFilterViewOpen;
@property (nonatomic,strong) NSMutableArray *customFilterArray;
//@property (weak, nonatomic) IBOutlet UITableView *pendingContactTableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *customFilterView;
@property (weak, nonatomic) IBOutlet UITableView *customFilterTableView;
@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;
@property (weak, nonatomic) IBOutlet UITableView *pendingTableView;
@property (nonatomic,strong) NSMutableArray *pendingContactListArra;
@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *emptyMessageLabel;

@end

@implementation PendingContactsViewController

- (void)viewTapped:(UITapGestureRecognizer*)tapGesture {
    [self.searchBar resignFirstResponder];
    self.tapGesture.enabled = NO;
}

- (IBAction)tapGesture:(id)sender {
    _customFilterView.hidden = YES;
}

-(void) acceptAction:(NSInteger)index{
    if (_gid > 0) {
        MRContact *user = _pendingContactListArra[index];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_gid,@"group_id", [NSString stringWithFormat:@"%ld",user.doctorId.longValue],@"member_id",@"ACTIVE",@"status", nil];
        
        [MRCommon showActivityIndicator:@"Requesting..."];
        [[MRWebserviceHelper sharedWebServiceHelper] updateGroupMembersStatus:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
            [MRCommon stopActivityIndicator];
            if (status)
            {
                for (UIViewController *vc in self.parentViewController.childViewControllers) {
                    if ([vc isKindOfClass:[MRContactsViewController class]]) {
                        [self.navigationController popToViewController:vc animated:YES];
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                                    object:nil];
            }
            else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
            {
                [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
                 {
                     [MRCommon savetokens:responce];
                     [[MRWebserviceHelper sharedWebServiceHelper] updateGroupMembersStatus:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                         [MRCommon stopActivityIndicator];
                         if (status)
                         {
                             for (UIViewController *vc in self.parentViewController.childViewControllers) {
                                 if ([vc isKindOfClass:[MRContactsViewController class]]) {
                                     [self.navigationController popToViewController:vc animated:YES];
                                 }
                             }
                             
                             [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                                                 object:nil];
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
        MRContact *user = _pendingContactListArra[index];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@[[NSString stringWithFormat:@"%ld",user.doctorId.longValue]],@"connList",@"ACTIVE",@"status", nil];
        
        [MRCommon showActivityIndicator:@"Requesting..."];
        [[MRWebserviceHelper sharedWebServiceHelper] updateConnectionStatus:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
            [MRCommon stopActivityIndicator];
            if (status)
            {
                for (UIViewController *vc in self.parentViewController.childViewControllers) {
                    if ([vc isKindOfClass:[MRContactsViewController class]]) {
                        [self.navigationController popToViewController:vc animated:YES];
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                                    object:nil];
            }
            else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
            {
                [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
                 {
                     [MRCommon savetokens:responce];
                     [[MRWebserviceHelper sharedWebServiceHelper] updateConnectionStatus:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                         [MRCommon stopActivityIndicator];
                         if (status)
                         {
                             for (UIViewController *vc in self.parentViewController.childViewControllers) {
                                 if ([vc isKindOfClass:[MRContactsViewController class]]) {
                                     [self.navigationController popToViewController:vc animated:YES];
                                 }
                             }
                             
                             [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                                                 object:nil];
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
    }
}

-(void) rejectAction:(NSInteger)index{
    if (_gid > 0) {
        MRContact *user = _pendingContactListArra[index];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_gid,@"group_id",@[[NSString stringWithFormat:@"%ld",user.doctorId.longValue]],@"memberList", nil];
        
        [MRCommon showActivityIndicator:@"Requesting..."];
        [[MRWebserviceHelper sharedWebServiceHelper] removeGroupMember:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
            [MRCommon stopActivityIndicator];
            if (status)
            {
                for (UIViewController *vc in self.parentViewController.childViewControllers) {
                    if ([vc isKindOfClass:[MRContactsViewController class]]) {
                        [self.navigationController popToViewController:vc animated:YES];
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                                    object:nil];
            }
            else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
            {
                [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
                 {
                     [MRCommon savetokens:responce];
                     [[MRWebserviceHelper sharedWebServiceHelper] removeGroupMember:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                         [MRCommon stopActivityIndicator];
                         if (status)
                         {
                             for (UIViewController *vc in self.parentViewController.childViewControllers) {
                                 if ([vc isKindOfClass:[MRContactsViewController class]]) {
                                     [self.navigationController popToViewController:vc animated:YES];
                                 }
                             }
                             
                             [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                                                 object:nil];
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
        MRContact *user = _pendingContactListArra[index];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@[[NSString stringWithFormat:@"%ld",user.doctorId.longValue]],@"connList",@"REJECT",@"status", nil];
        
        [MRCommon showActivityIndicator:@"Requesting..."];
        [[MRWebserviceHelper sharedWebServiceHelper] removeConnection:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
            [MRCommon stopActivityIndicator];
            if (status)
            {
                for (UIViewController *vc in self.parentViewController.childViewControllers) {
                    if ([vc isKindOfClass:[MRContactsViewController class]]) {
                        [self.navigationController popToViewController:vc animated:YES];
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                                    object:nil];
            }
            else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
            {
                [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
                 {
                     [MRCommon savetokens:responce];
                     [[MRWebserviceHelper sharedWebServiceHelper] removeConnection:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                         [MRCommon stopActivityIndicator];
                         if (status)
                         {
                             for (UIViewController *vc in self.parentViewController.childViewControllers) {
                                 if ([vc isKindOfClass:[MRContactsViewController class]]) {
                                     [self.navigationController popToViewController:vc animated:YES];
                                 }
                             }
                             
                             [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshContactList
                                                                                 object:nil];
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
    }
}

-(IBAction)backButtonTapped:(id)sender{
    [UIView transitionWithView:self.navigationController.view
                      duration:0.75
                       options:UIViewAnimationOptionTransitionCurlDown
                    animations:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    completion:nil];
}

- (IBAction)dropDownButtonTapped:(id)sender {
    if (_customFilterView.hidden) {
//        self.heightConstraint.constant = 0;
        [UIView animateWithDuration:2.0 delay:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            self.heightConstraint.constant = 210;
            [self.customFilterView updateConstraintsIfNeeded];
            _customFilterView.hidden = NO;
            _isCustomFilterViewOpen = YES;
            [self.customFilterTableView reloadData];
        } completion:^(BOOL finished) {
            
        }];
       
    }else{
        _isCustomFilterViewOpen = NO;
        _customFilterView.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.customFilterTableView.delegate  = self;
    self.customFilterTableView.dataSource = self;
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    self.pendingTableView.hidden = NO;
    self.tapGesture.numberOfTapsRequired = 1;
    self.tapGesture.cancelsTouchesInView = YES;
    self.tapGesture.enabled = YES;
    [self.view addGestureRecognizer:self.tapGesture];
    
    [self.pendingTableView reloadData];
    self.pendingTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Pending Connections";
    //[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshLabels];
    
    if (_isFromGroup) {
        [self getPendingGroups];
        self.navigationItem.title = @"Pending Groups";
    }else if (_isFromMember) {
        [self getPendingMembers];
        self.navigationItem.title = @"Pending Members";
    }else{
        [self getPendingConnections];
        self.navigationItem.title = @"Pending Connections";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshLabels {
    
    if (fileredContacts == nil || fileredContacts.count == 0) {
        [self.emptyMessageLabel setHidden:false];
        [self.pendingTableView setHidden:true];
        
        NSString *key = kNoPendingContacts;
        
        if (_isFromGroup) {
            key = kNoPendingGroups;
        } else if (_isFromMember) {
            key = kNoPendingGroupMembers;
        }
        
        [self.emptyMessageLabel setText:NSLocalizedString(key, "")];
    } else {
        [self.emptyMessageLabel setHidden:true];
        [self.pendingTableView setHidden:false];
        
        [self.pendingTableView reloadData];
    }
}

-(void)getPendingConnections {
    [MRDatabaseHelper getPendingContacts:^(id result) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like [cd]%@", @"connStatus", @"PENDING"];
        fileredContacts = [[[MRDataManger sharedManager] fetchObjectList:kContactEntity predicate:predicate] mutableCopy];
        _pendingContactListArra = result;
        [self refreshLabels];
    }];
}

-(void)getPendingMembers {
    [MRDatabaseHelper getPendingGroupMembers:_gid andResponseHandler:^(id result) {
        fileredContacts = result;
        _pendingContactListArra = result;
        [self refreshLabels];
    }];
}

-(void)getPendingGroups {
    [MRDatabaseHelper getPendingGroups:^(id result) {
        fileredContacts = result;
        _pendingContactListArra = result;
        [self refreshLabels];
    }];
}

- (void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isCustomFilterViewOpen) {
        return 2;
    }else {
        return fileredContacts.count;
        
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isCustomFilterViewOpen) {
        static  NSString *ident = @"pendingCell";
        PendingContactCustomFilterTableViewCell *   cell = (PendingContactCustomFilterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ident];
        
        if (cell == nil) {
            NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"PendingContactCustomCell" owner:self options:nil];
            cell = (PendingContactCustomFilterTableViewCell *)[arr objectAtIndex:0];
        }
        
        NSDictionary *dict = [[self getDataForCustomFilter] objectAtIndex:indexPath.row];
        ((PendingContactCustomFilterTableViewCell *)cell).customFilterName.text = [dict objectForKey:@"name"];
        
        return cell;
    }else {
        static  NSString *ident1 = @"pendingContactTable";
        PendingContactTableViewCell *   cell = (PendingContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ident1];
        
        if (cell == nil) {
            NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"PendingContactTableViewCell" owner:self options:nil];
            cell = (PendingContactTableViewCell *)[arr objectAtIndex:0];
        }
        
        cell.cellDelegate = self;
        cell.acceptBtn.tag = indexPath.row;
        cell.rejectBtn.tag = indexPath.row;
        
        if (_isFromGroup) {
            MRGroup *group = [fileredContacts objectAtIndex:indexPath.row];
            NSString *groupName = @"";
            if (group.group_name != nil) {
                groupName = group.group_name;
            }
            cell.userName.text = groupName;
            
            cell.phoneNo.text = @"";
            cell.profilePic.image = [MRAppControl getGroupImage:group];
            cell.acceptBtn.hidden = YES;
            cell.rejectBtn.hidden = YES;
            
            return cell;
        }
        
        if (!_canEdit && _isFromMember) {
            cell.acceptBtn.hidden = YES;
            cell.rejectBtn.hidden = YES;
        }
        
        MRContact *contact = [fileredContacts objectAtIndex:indexPath.row];
        cell.userName.text = [MRAppControl getContactName:contact];
        cell.phoneNo.text = contact.therapeuticArea;
        cell.profilePic.image = [MRAppControl getContactImage:contact];
        
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isCustomFilterViewOpen) {
        return 44;
    }else {
        return 72;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(NSArray *)getDataForCustomFilter{
    _customFilterArray = [NSMutableArray array];
    
    [_customFilterArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Therauptic Area",@"name",@"1",@"fitlerId", nil]];
        [_customFilterArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Location",@"name",@"1",@"fitlerId", nil]];
    return _customFilterArray ;
}

/*-(NSArray *)getFilterDataFromModel {
    
    _pendingContactListArra = [NSMutableArray array];
    
    [_pendingContactListArra addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Namit Nayak",@"name",@"(732)-234-1234",@"contactNo",@"profile_pic1.jpeg",@"profile_pic", nil]];
    [_pendingContactListArra addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Adam Johns",@"name",@"(732)-234-4321",@"contactNo",@"profile_pic2.jpeg",@"profile_pic", nil]];
    [_pendingContactListArra addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Bill Paraon",@"name",@"(732)-234-9803",@"contactNo",@"profile_pic3.jpeg",@"profile_pic", nil]];
    [_pendingContactListArra addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Vamsi Katragadda",@"name",@"(732)-234-456",@"contactNo",@"profile_pic4.jpeg",@"profile_pic", nil]];
    
    return _pendingContactListArra;
}*/

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length == 0) {
        fileredContacts = _pendingContactListArra;
    } else {
        fileredContacts = [[_pendingContactListArra filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K contains[cd] %@) OR (%K contains[cd] %@)",@"firstName",searchText,@"lastName",searchText]] mutableCopy];
    }
    [_pendingTableView reloadData];
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

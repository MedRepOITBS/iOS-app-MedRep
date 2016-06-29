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
#import "MRCommon.h"
#import "MRWebserviceHelper.h"
#import "MRGroupUserObject.h"
#import "MRGroupObject.h"
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
        MRGroupUserObject *user = _pendingContactListArra[index];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_gid,@"group_id", [NSString stringWithFormat:@"%@",user.member_id],@"member_id",@"ACTIVE",@"status", nil];
        
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
            }
            else
            {
                NSArray *erros =  [details componentsSeparatedByString:@"-"];
                if (erros.count > 0)
                    [MRCommon showAlert:[erros lastObject] delegate:nil];
            }
        }];
    }else{
        MRGroupUserObject *user = _pendingContactListArra[index];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@[[NSString stringWithFormat:@"%@",user.contactId]],@"connList",@"ACTIVE",@"status", nil];
        
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
        MRGroupUserObject *user = _pendingContactListArra[index];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_gid,@"group_id",@[[NSString stringWithFormat:@"%@",user.member_id]],@"memberList", nil];
        
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
            }
            else
            {
                NSArray *erros =  [details componentsSeparatedByString:@"-"];
                if (erros.count > 0)
                    [MRCommon showAlert:[erros lastObject] delegate:nil];
            }
        }];
    }else{
        MRGroupUserObject *user = _pendingContactListArra[index];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@[[NSString stringWithFormat:@"%@",user.contactId]],@"connList",@"REJECT",@"status", nil];
        
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
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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

-(void)getPendingConnections {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] fetchPendingConnectionsListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            fileredContacts = [NSMutableArray array];
            _pendingContactListArra = [NSMutableArray array];
            NSArray *responseArray = responce[@"Responce"];
            for (NSDictionary *dic in responseArray) {
                MRGroupUserObject *groupObj = [[MRGroupUserObject alloc] initWithDict:dic];
                [_pendingContactListArra addObject:groupObj];
            }
            fileredContacts = _pendingContactListArra;
            [_pendingTableView reloadData];
        }
        else
        {
            NSArray *erros =  [details componentsSeparatedByString:@"-"];
            if (erros.count > 0)
                [MRCommon showAlert:[erros lastObject] delegate:nil];
        }
    }];
}

-(void)getPendingMembers {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] fetchPendingMembersList:_gid withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            fileredContacts = [NSMutableArray array];
            _pendingContactListArra = [NSMutableArray array];
            NSArray *responseArray = responce[@"Responce"];
            for (NSDictionary *dic in responseArray) {
                MRGroupUserObject *groupObj = [[MRGroupUserObject alloc] initWithDict:dic];
                [_pendingContactListArra addObject:groupObj];
            }
            fileredContacts = _pendingContactListArra;
            [_pendingTableView reloadData];
        }
        else
        {
            NSArray *erros =  [details componentsSeparatedByString:@"-"];
            if (erros.count > 0)
                [MRCommon showAlert:[erros lastObject] delegate:nil];
        }
    }];
}

-(void)getPendingGroups {
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] fetchPendingGroupsListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            fileredContacts = [NSMutableArray array];
            _pendingContactListArra = [NSMutableArray array];
            NSArray *responseArray = responce[@"Responce"];
            for (NSDictionary *dic in responseArray) {
                MRGroupObject *groupObj = [[MRGroupObject alloc] initWithDict:dic];
                [_pendingContactListArra addObject:groupObj];
            }
            fileredContacts = _pendingContactListArra;
            [_pendingTableView reloadData];
        }
        else
        {
            NSArray *erros =  [details componentsSeparatedByString:@"-"];
            if (erros.count > 0)
                [MRCommon showAlert:[erros lastObject] delegate:nil];
        }
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
            MRGroupObject *contact = [fileredContacts objectAtIndex:indexPath.row];
            for (UIView *view in cell.profilePic.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    [view removeFromSuperview];
                }
            }
            
            NSString *fullName = [NSString stringWithFormat:@"%@",contact.group_name];
            cell.userName.text = fullName;
            cell.phoneNo.text = contact.group_short_desc;
            if (contact.group_img_data.length) {
                cell.profilePic.image = [MRCommon getImageFromBase64Data:[contact.group_img_data dataUsingEncoding:NSUTF8StringEncoding]];
            } else {
                cell.profilePic.image = nil;
                if (fullName.length > 0) {
                    UILabel *subscriptionTitleLabel = [[UILabel alloc] initWithFrame:cell.profilePic.bounds];
                    subscriptionTitleLabel.textAlignment = NSTextAlignmentCenter;
                    subscriptionTitleLabel.font = [UIFont systemFontOfSize:15.0];
                    subscriptionTitleLabel.textColor = [UIColor lightGrayColor];
                    subscriptionTitleLabel.layer.cornerRadius = 5.0;
                    subscriptionTitleLabel.layer.masksToBounds = YES;
                    subscriptionTitleLabel.layer.borderWidth =1.0;
                    subscriptionTitleLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
                    
                    NSArray *substrngs = [fullName componentsSeparatedByString:@" "];
                    NSString *imageString = @"";
                    for(NSString *str in substrngs){
                        if (str.length > 0) {
                            imageString = [imageString stringByAppendingString:[NSString stringWithFormat:@"%c",[str characterAtIndex:0]]];
                        }
                    }
                    subscriptionTitleLabel.text = imageString.length > 2 ? [imageString substringToIndex:2] : imageString;
                    [cell.profilePic addSubview:subscriptionTitleLabel];
                }
            }
            
            cell.acceptBtn.hidden = YES;
            cell.rejectBtn.hidden = YES;
            
            return cell;
        }
        
        if (!_canEdit && _isFromMember) {
            cell.acceptBtn.hidden = YES;
            cell.rejectBtn.hidden = YES;
        }
        
        MRGroupUserObject *contact = [fileredContacts objectAtIndex:indexPath.row];
        for (UIView *view in cell.profilePic.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                [view removeFromSuperview];
            }
        }
        
        NSString *fullName = [NSString stringWithFormat:@"%@ %@",contact.firstName, contact.lastName];
        cell.userName.text = fullName;
        cell.phoneNo.text = contact.therapeuticArea;
        if (contact.imgData.length) {
            cell.profilePic.image = [MRCommon getImageFromBase64Data:[contact.imgData dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            cell.profilePic.image = nil;
            if (fullName.length > 0) {
                UILabel *subscriptionTitleLabel = [[UILabel alloc] initWithFrame:cell.profilePic.bounds];
                subscriptionTitleLabel.textAlignment = NSTextAlignmentCenter;
                subscriptionTitleLabel.font = [UIFont systemFontOfSize:15.0];
                subscriptionTitleLabel.textColor = [UIColor lightGrayColor];
                subscriptionTitleLabel.layer.cornerRadius = 5.0;
                subscriptionTitleLabel.layer.masksToBounds = YES;
                subscriptionTitleLabel.layer.borderWidth =1.0;
                subscriptionTitleLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
                
                NSArray *substrngs = [fullName componentsSeparatedByString:@" "];
                NSString *imageString = @"";
                for(NSString *str in substrngs){
                    if (str.length > 0) {
                        imageString = [imageString stringByAppendingString:[NSString stringWithFormat:@"%c",[str characterAtIndex:0]]];
                    }
                }
                subscriptionTitleLabel.text = imageString.length > 2 ? [imageString substringToIndex:2] : imageString;
                [cell.profilePic addSubview:subscriptionTitleLabel];
            }
        }
        
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
        fileredContacts = [[_pendingContactListArra filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[cd] %@",@"firstName",searchText]] mutableCopy];
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

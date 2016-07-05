//
//  MRJoinGroupViewController.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/28/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRJoinGroupViewController.h"
#import "MRAddMemberTableViewCell.h"
#import "MRGroupObject.h"
#import "MRCommon.h"
#import "MRAppControl.h"
#import "MRWebserviceHelper.h"

@interface MRJoinGroupViewController () <MRAddMemberProtocol, UISearchBarDelegate>{
    NSMutableArray *selectedContacts;
}

@property (strong, nonatomic) NSMutableArray *pendingContactListArray;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMembers;
@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UISearchBar* searchBar;
@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;
@property (strong, nonatomic) NSMutableArray* fileredContacts;

- (IBAction)addMembers:(id)sender;

@end

@implementation MRJoinGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Groups List";
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

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.searchBar resignFirstResponder];
    [self getAllGroups];
}

- (void)viewTapped:(UITapGestureRecognizer*)tapGesture {
    [self.searchBar resignFirstResponder];
    self.tapGesture.enabled = NO;
}

- (void)getAllGroups{
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getAllGroupListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            _pendingContactListArray = [NSMutableArray array];
            NSArray *responseArray = responce[@"Responce"];
            for (NSDictionary *dic in responseArray) {
                MRGroupObject *groupObj = [[MRGroupObject alloc] initWithDict:dic];
                [_pendingContactListArray addObject:groupObj];
            }
            _fileredContacts = _pendingContactListArray;
            [_tableViewMembers reloadData];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getAllGroupListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status)
                     {
                         _pendingContactListArray = [NSMutableArray array];
                         NSArray *responseArray = responce[@"Responce"];
                         for (NSDictionary *dic in responseArray) {
                             MRGroupObject *groupObj = [[MRGroupObject alloc] initWithDict:dic];
                             [_pendingContactListArray addObject:groupObj];
                         }
                         _fileredContacts = _pendingContactListArray;
                         [_tableViewMembers reloadData];
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

- (void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)addMembers:(id)sender {
    if (!selectedContacts.count){
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please select at least one group to add" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        return;
    }
    
    [self addMember];
}

-(void) addMember{
    NSMutableDictionary *dictReq = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    selectedContacts, @"groupList",
                                    @"PENDING", @"status",
                                    [MRAppControl sharedHelper].userRegData[@"doctorId"], @"member_id",
                                    nil];
    
    [MRCommon showActivityIndicator:@"Adding..."];
    [[MRWebserviceHelper sharedWebServiceHelper] joinGroup:dictReq withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] joinGroup:dictReq withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     [MRCommon stopActivityIndicator];
                     if (status) {
                         [self.navigationController popViewControllerAnimated:YES];
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
    
    MRGroupObject *contact = [_fileredContacts objectAtIndex:indexPath.row];
    
    for (UIView *view in cell.profilePic.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    NSString *fullName = contact.group_name;
    cell.userName.text = fullName;
    cell.phoneNo.text = contact.group_short_desc;
    cell.checkBtn.tag = indexPath.row;
    cell.cellDelegate = self;
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
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

-(void) selectedMemberAtIndex:(NSInteger)index{
    MRGroupObject *contact = [_fileredContacts objectAtIndex:index];
    if ([selectedContacts containsObject:contact.group_id]) {
        [selectedContacts removeObject:contact.group_id];
    }else{
        [selectedContacts addObject:contact.group_id];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.fileredContacts = _pendingContactListArray;
    }else{
        self.fileredContacts = [[self.pendingContactListArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[cd] %@",@"group_name",searchText]] mutableCopy];
    }
    [self.tableViewMembers reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.tapGesture.enabled = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

@end

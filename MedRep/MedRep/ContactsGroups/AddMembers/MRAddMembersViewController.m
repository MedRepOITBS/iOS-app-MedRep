//
//  MRAddMembersViewController.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/16/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRAddMembersViewController.h"
#import "MRAddMemberTableViewCell.h"
#import "MRGroupUserObject.h"
#import "MRCommon.h"
#import "MRWebserviceHelper.h"
#import "MRContactsViewController.h"

@interface MRAddMembersViewController () <MRAddMemberProtocol>{
    NSMutableArray *selectedContacts;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewMembers;
@property (strong, nonatomic) IBOutlet UIView *navView;

- (IBAction)addMembers:(id)sender;

@end

@implementation MRAddMembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Add Members";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    selectedContacts = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getAllContactsByCity];
}

- (void)getAllContactsByCity{
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getAllContactsByCityListwithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            _pendingContactListArray = [NSMutableArray array];
            NSArray *responseArray = responce[@"Responce"];
            for (NSDictionary *dic in responseArray) {
                MRGroupUserObject *groupObj = [[MRGroupUserObject alloc] initWithDict:dic];
                [_pendingContactListArray addObject:groupObj];
            }
            [_tableViewMembers reloadData];
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
            else
            {
                NSArray *erros =  [details componentsSeparatedByString:@"-"];
                if (erros.count > 0)
                    [MRCommon showAlert:[erros lastObject] delegate:nil];
            }
        }];
    }else{
        NSMutableDictionary *dictReq = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        selectedContacts, @"connIdList",
                                        nil];
        
        [MRCommon showActivityIndicator:@"Adding..."];
        [[MRWebserviceHelper sharedWebServiceHelper] addMembers:dictReq withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
            [MRCommon stopActivityIndicator];
            if (status) {
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _pendingContactListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static  NSString *ident1 = @"MRAddMemberTableViewCell";
    MRAddMemberTableViewCell *cell = (MRAddMemberTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ident1];
    
    if (cell == nil) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"MRAddMemberTableViewCell" owner:self options:nil];
        cell = (MRAddMemberTableViewCell *)[arr objectAtIndex:0];
    }
    
    MRGroupUserObject *contact = [_pendingContactListArray objectAtIndex:indexPath.row];
    
    for (UIView *view in cell.profilePic.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    NSString *fullName = [NSString stringWithFormat:@"%@ %@",contact.firstName, contact.lastName];
    cell.userName.text = fullName;
    cell.phoneNo.text = contact.therapeuticName;
    cell.checkBtn.tag = indexPath.row;
    cell.cellDelegate = self;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

-(void) selectedMemberAtIndex:(NSInteger)index{
    MRGroupUserObject *contact = [_pendingContactListArray objectAtIndex:index];
    
    if (_groupID) {
        if ([selectedContacts containsObject:contact.doctorId]) {
            [selectedContacts removeObject:contact.doctorId];
        }else{
            [selectedContacts addObject:contact.doctorId];
        }
    }else{
        if ([selectedContacts containsObject:contact.userId]) {
            [selectedContacts removeObject:contact.userId];
        }else{
            [selectedContacts addObject:contact.userId];
        }
    }
}

@end

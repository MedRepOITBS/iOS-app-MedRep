//
//  MRGroupMembersViewController.m
//  MedRep
//
//  Created by Vamsi Katragadda on 8/12/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRGroupMembersViewController.h"
#import "MRCommon.h"
#import "MRAppControl.h"
#import "MRWebserviceHelper.h"
#import "MRDatabaseHelper.h"
#import "MRGroup.h"
#import "PendingContactTableViewCell.h"

@interface MRGroupMembersViewController () <UITableViewDelegate, UITableViewDataSource,
                                            MRPendingMemberProtocol>

@property (nonatomic) NSArray *sectionTitles;
@property (nonatomic) NSArray *pendingMembersList;
@property (nonatomic) NSArray *membersList;

@property (strong, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MRGroupMembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Group Members";
    //[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PendingContactTableViewCell" bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"pendingContactTable"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getGroupMembersStatusWithGroupId];
}

- (void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getGroupMembersStatusWithGroupId {
    [MRDatabaseHelper getGroupMemberStatusWithId:self.group.group_id.longValue
                                      andHandler:^(id result) {
                                          NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"group_id", self.group.group_id.longValue];
                                          NSArray *tempResults = result;
                                          tempResults = [tempResults filteredArrayUsingPredicate:predicate];
                                          if (tempResults != nil && tempResults.count > 0) {
                                              MRGroup *tempGroup = tempResults.firstObject;
                                              self.group = tempGroup;
                                              if (tempGroup.members != nil && tempGroup.members.count > 0) {
                                                  self.sectionTitles = @[kActiveGroupMembers];
                                                  self.pendingMembersList = nil;
                                                  self.membersList = tempGroup.members.allObjects;
                                                  
                                                  [self.tableView setHidden:NO];
                                                  [self.tableView reloadData];
                                                  
                                              } else {
                                                  self.sectionTitles = nil;
                                                  self.pendingMembersList = nil;
                                                  self.membersList = nil;
                                                  
                                                  [self.tableView setHidden:YES];
                                              }
                                          } else {
                                              self.sectionTitles = nil;
                                              self.pendingMembersList = nil;
                                              self.membersList = nil;
                                              
                                              [self.tableView setHidden:YES];
                                          }
                                      }];
}


#pragma mark - UITableView Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionCount = 0;
    
    if (self.sectionTitles != nil) {
        sectionCount = self.sectionTitles.count;
    }
    
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    
    NSString *currentSection = [self.sectionTitles objectAtIndex:section];
    if ([currentSection caseInsensitiveCompare:kPendingGroupMembers] == NSOrderedSame) {
        if (self.pendingMembersList != nil) {
            rowCount = self.pendingMembersList.count;
        }
    } else {
        if (self.membersList != nil) {
            rowCount = self.membersList.count;
        }
    }
    
    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    
    if (self.sectionTitles != nil && self.sectionTitles.count > 0) {
        title = [self.sectionTitles objectAtIndex:section];
    }
    
    return title;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static  NSString *ident1 = @"pendingContactTable";
    PendingContactTableViewCell *cell = (PendingContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ident1];
    
    if (cell == nil) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"PendingContactTableViewCell" owner:self options:nil];
        cell = (PendingContactTableViewCell *)[arr objectAtIndex:0];
    }
    
    cell.cellDelegate = self;
    cell.tag = (indexPath.section * 10000) + indexPath.row;
    
    NSArray *dataArray = nil;
    NSString *currentSection = [self.sectionTitles objectAtIndex:indexPath.section];
    if ([currentSection caseInsensitiveCompare:kPendingGroupMembers] == NSOrderedSame) {
        dataArray = self.pendingMembersList;
    } else {
        dataArray = self.membersList;
    }
    
    MRGroupMembers *currentMember = [dataArray objectAtIndex:indexPath.row];
    
    if (currentMember.is_admin != nil && currentMember.is_admin.boolValue) {
        [cell.acceptConnectionView setHidden:NO];
        [cell.rejectConnectionView setHidden:NO];
    } else {
        [cell.acceptConnectionView setHidden:YES];
        [cell.rejectConnectionView setHidden:YES];
    }
    
    cell.userName.text = [MRAppControl getGroupMemberName:currentMember];
    [MRAppControl getGroupMemberImage:currentMember andImageView:cell.profilePic];
    
    NSString *therepauticArea = @"";
    if (currentMember.therapeuticName != nil && currentMember.therapeuticName.length > 0) {
        therepauticArea = currentMember.therapeuticName;
    }
    [cell.phoneNo setText:therepauticArea];
    
    return cell;
}

#pragma mark - MRPendingMemberProtocol
-(void) acceptAction:(NSInteger)index{
    NSInteger section = index / 10000;
    
    NSArray *dataArray = nil;
    NSString *currentSection = [self.sectionTitles objectAtIndex:section];
    if ([currentSection caseInsensitiveCompare:kPendingGroupMembers] == NSOrderedSame) {
        dataArray = self.pendingMembersList;
    } else {
        dataArray = self.membersList;
    }
    
    NSInteger row = index % 1000;
    MRGroupMembers *user = [dataArray objectAtIndex:row];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.group.group_id,@"group_id", [NSString stringWithFormat:@"%ld",user.member_id.longValue],@"member_id",@"ACTIVE",@"status", nil];
    
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] updateGroupMembersStatus:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            [self getGroupMembersStatusWithGroupId];
            [self.tableView reloadData];
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
                          [self getGroupMembersStatusWithGroupId];
                          [self.tableView reloadData];
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

-(void) rejectAction:(NSInteger)index{
    NSInteger section = index / 10000;
    
    NSArray *dataArray = nil;
    NSString *currentSection = [self.sectionTitles objectAtIndex:section];
    if ([currentSection caseInsensitiveCompare:kPendingGroupMembers] == NSOrderedSame) {
        dataArray = self.pendingMembersList;
    } else {
        dataArray = self.membersList;
    }
    
    NSInteger row = index % 1000;
    MRGroupMembers *user = [dataArray objectAtIndex:row];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.group.group_id,@"group_id",@[[NSString stringWithFormat:@"%ld",user.member_id.longValue]],@"memberList", nil];
    
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] removeGroupMember:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            [self getGroupMembersStatusWithGroupId];
            [self.tableView reloadData];
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
                         [self getGroupMembersStatusWithGroupId];
                         [self.tableView reloadData];
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

@end

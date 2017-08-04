//
//  MemberListViewController.m
//  MedRep
//
//  Created by Namit Nayak on 8/6/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MemberListViewController.h"
#import "AddMemberTableViewCell.h"
#import "MRGroupMembers.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "MRWebserviceHelper.h"
@interface MemberListViewController () <MRAddMemberTableViewCellProtocol>
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@end

@implementation MemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Group Member List";
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
}
- (void)backButtonAction
{
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

-(void) acceptAction:(NSInteger)index{
//    MRGroupMembers *user = self.contactsUnderGroup[index];
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                          [NSNumber numberWithLong:self.mainGroup.group_id.longValue],@"group_id", [NSString stringWithFormat:@"%@",user.member_id],@"member_id",@"ACTIVE",@"status", nil];
//    
//    [MRCommon showActivityIndicator:@"Requesting..."];
//    [[MRWebserviceHelper sharedWebServiceHelper] updateGroupMembersStatus:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
//        [MRCommon stopActivityIndicator];
//        if (status)
//        {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
//        {
//            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
//             {
//                 [MRCommon savetokens:responce];
//                 [[MRWebserviceHelper sharedWebServiceHelper] updateGroupMembersStatus:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
//                     [MRCommon stopActivityIndicator];
//                     if (status)
//                     {
//                         [self.navigationController popViewControllerAnimated:YES];
//                     }else
//                     {
//                         NSArray *erros =  [details componentsSeparatedByString:@"-"];
//                         if (erros.count > 0)
//                             [MRCommon showAlert:[erros lastObject] delegate:nil];
//                     }
//                 }];
//             }];
//        }
//        else
//        {
//            NSArray *erros =  [details componentsSeparatedByString:@"-"];
//            if (erros.count > 0)
//                [MRCommon showAlert:[erros lastObject] delegate:nil];
//        }
//    }];
}

-(void) rejectAction:(NSInteger)index{
//    MRGroupMembers *user = self.contactsUnderGroup[index];
////    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
////                          [NSNumber numberWithLong:self.mainGroup.group_id.longValue],@"group_id",@[[NSString stringWithFormat:@"%@",user.member_id]],@"memberList", nil];
//    
//    [MRCommon showActivityIndicator:@"Requesting..."];
//    [[MRWebserviceHelper sharedWebServiceHelper] removeGroupMember:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
//        [MRCommon stopActivityIndicator];
//        if (status)
//        {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
//        {
//            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
//             {
//                 [MRCommon savetokens:responce];
//                 [[MRWebserviceHelper sharedWebServiceHelper] removeGroupMember:dict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
//                     [MRCommon stopActivityIndicator];
//                     if (status)
//                     {
//                         [self.navigationController popViewControllerAnimated:YES];
//                     }else
//                     {
//                         NSArray *erros =  [details componentsSeparatedByString:@"-"];
//                         if (erros.count > 0)
//                             [MRCommon showAlert:[erros lastObject] delegate:nil];
//                     }
//                 }];
//             }];
//        }
//        else
//        {
//            NSArray *erros =  [details componentsSeparatedByString:@"-"];
//            if (erros.count > 0)
//                [MRCommon showAlert:[erros lastObject] delegate:nil];
//        }
//    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
   return  _contactsUnderGroup.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    NSString *ident = @"AddMemberTableViewCell";
   
    
    AddMemberTableViewCell *cell = (AddMemberTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"AddMemberTableViewCell" owner:self options:nil];
        cell = (AddMemberTableViewCell *)[arr objectAtIndex:0];
    }
    cell.cellDelegate = self;
    cell.acceptBtn.tag = indexPath.row;
    cell.rejectBtn.tag = indexPath.row;
    
    MRGroupMembers *user = self.contactsUnderGroup[indexPath.row];
    cell.nameTxt.text = [MRAppControl getGroupMemberName:user];
    [MRAppControl getGroupMemberImage:user andImageView:cell.imgView];
    
    if ([user.status caseInsensitiveCompare:@"Active"] == NSOrderedSame) {
        cell.acceptBtn.hidden = YES;
        cell.rejectBtn.hidden = YES;
    }else{
        cell.acceptBtn.hidden = NO;
        cell.rejectBtn.hidden = NO;
    }
    

    return cell;
    
}
@end

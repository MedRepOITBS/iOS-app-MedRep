//
//  MRAddMembersViewController.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/16/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRAddMembersViewController.h"
#import "MRAddMemberTableViewCell.h"

@interface MRAddMembersViewController ()

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static  NSString *ident1 = @"MRAddMemberTableViewCell";
    MRAddMemberTableViewCell *cell = (MRAddMemberTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ident1];
    
    if (cell == nil) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"MRAddMemberTableViewCell" owner:self options:nil];
        cell = (MRAddMemberTableViewCell *)[arr objectAtIndex:0];
    }
    
    NSDictionary *dict = [[self getFilterDataFromModel] objectAtIndex:indexPath.row];
    
    [cell.profilePic setImage:[UIImage imageNamed:[dict objectForKey:@"profile_pic"]]];
    [cell.userName setText:[dict objectForKey:@"name"]];
    [cell.phoneNo setText:[dict objectForKey:@"contactNo"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

-(NSArray *)getFilterDataFromModel {
    
    NSMutableArray * _pendingContactListArra = [NSMutableArray array];
    
    [_pendingContactListArra addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Namit Nayak",@"name",@"(732)-234-1234",@"contactNo",@"profile_pic1.jpeg",@"profile_pic", nil]];
    [_pendingContactListArra addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Adam Johns",@"name",@"(732)-234-4321",@"contactNo",@"profile_pic2.jpeg",@"profile_pic", nil]];
    [_pendingContactListArra addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Bill Paraon",@"name",@"(732)-234-9803",@"contactNo",@"profile_pic3.jpeg",@"profile_pic", nil]];
    [_pendingContactListArra addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Vamsi Katragadda",@"name",@"(732)-234-456",@"contactNo",@"profile_pic4.jpeg",@"profile_pic", nil]];
    
    return _pendingContactListArra;
}

@end

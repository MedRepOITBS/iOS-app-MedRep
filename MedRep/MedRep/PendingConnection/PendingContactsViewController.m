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
@interface PendingContactsViewController ()
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


@end

@implementation PendingContactsViewController
- (void)viewTapped:(UITapGestureRecognizer*)tapGesture {
    [self.searchBar resignFirstResponder];
    self.tapGesture.enabled = NO;
}
- (IBAction)tapGesture:(id)sender {
    NSLog(@"aaa");
    _customFilterView.hidden = YES;
}
-(IBAction)backButtonTapped:(id)sender{
    [UIView transitionWithView:self.navigationController.view
                      duration:0.75
                       options:UIViewAnimationOptionTransitionCurlDown
                    animations:^{
                        [self.navigationController popToRootViewControllerAnimated:NO];
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
    UIImageView* titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navLogo.png"]];
    [self.navigationItem setTitleView:titleImage];
    self.customFilterTableView.delegate  = self;
    self.customFilterTableView.dataSource = self;
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    self.pendingTableView.hidden = NO;
    self.tapGesture.numberOfTapsRequired = 1;
    self.tapGesture.cancelsTouchesInView = YES;
    self.tapGesture.enabled = NO;
    [self.view addGestureRecognizer:self.tapGesture];
    [self.pendingTableView reloadData];
    self.pendingTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isCustomFilterViewOpen) {
        return 2;
    }else {
        return 4;
        
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
        
        NSDictionary *dict = [[self getFilterDataFromModel] objectAtIndex:indexPath.row];
        
        [cell.profilePic setImage:[UIImage imageNamed:[dict objectForKey:@"profile_pic"]]];
        [cell.userName setText:[dict objectForKey:@"name"]];
        [cell.phoneNo setText:[dict objectForKey:@"contactNo"]];
        
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
//"profile_pic1.jpeg"},{"id":"2","groupId":["1"],"name":"Joseph King","role":"ortho","profile_pic":"profile_pic2.jpeg"},{"id":"3","groupId":["1"],"name":"Daniel Johnson","role":"ortho","profile_pic":"profile_pic3.jpeg"},{"id":"4","groupId":["1"],"name":"David Beckham","role":"ortho","profile_pic":"profile_pic4.jpeg"},{"id":"5","groupId":["1"],"name":"Fan Kid","role":"ortho","profile_pic":"profile_p
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}



-(NSArray *)getDataForCustomFilter{
    
    _customFilterArray = [NSMutableArray array];
    
    [_customFilterArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Therauptic Area",@"name",@"1",@"fitlerId", nil]];
        [_customFilterArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Location",@"name",@"1",@"fitlerId", nil]];
    return _customFilterArray ;
}


-(NSArray *)getFilterDataFromModel {
    
    _pendingContactListArra = [NSMutableArray array];
    
    [_pendingContactListArra addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Namit Nayak",@"name",@"(732)-234-1234",@"contactNo",@"profile_pic1.jpeg",@"profile_pic", nil]];
    [_pendingContactListArra addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Adam Johns",@"name",@"(732)-234-4321",@"contactNo",@"profile_pic2.jpeg",@"profile_pic", nil]];
    [_pendingContactListArra addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Bill Paraon",@"name",@"(732)-234-9803",@"contactNo",@"profile_pic3.jpeg",@"profile_pic", nil]];
    [_pendingContactListArra addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Vamsi Katragadda",@"name",@"(732)-234-456",@"contactNo",@"profile_pic4.jpeg",@"profile_pic", nil]];
    
    return _pendingContactListArra;
}



- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar                     // called when text starts editing
{
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar                      // called when text ends editing
{
    }
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

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

    //
//  MRContactsViewController.m
//  MedRep
//
//  Created by Vivekan Arther Subaharan on 5/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRContactsViewController.h"
#import "MRContactCollectionCell.h"
#import "MRGroupsListViewController.h"
#import "UIPopoverController+iPhone.h"
#import "MRPopoverControllerViewController.h"
#import "MRContactDetailViewController.h"
#import "MRDatabaseHelper.h"
#import "PendingContactsViewController.h"
#import "PieMenu.h"
#import "MRWebserviceHelper.h"
#import "MRCommon.h"

@interface MRContactsViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView* myContactsCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView* suggestedContactsCollectionView;
@property (weak, nonatomic) IBOutlet UISearchBar* searchBar;
@property (weak, nonatomic) IBOutlet UIButton* switchButton;
@property (weak, nonatomic) IBOutlet UIButton* moreOptions;
@property (weak, nonatomic) IBOutlet UITabBar* tabBar;
@property (weak, nonatomic) IBOutlet UITabBarItem* myContactsButton;
@property (weak, nonatomic) IBOutlet UITabBarItem* suggestedContactsButton;
@property (strong, nonatomic) UIActionSheet *menu;
@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;
//@property (strong, nonatomic) IBOutlet PieMenu *pieMenu;

@property (strong, nonatomic) NSArray* myContacts;
@property (strong, nonatomic) NSArray* fileredContacts;
@property (strong, nonatomic) NSArray* suggestedContacts;
@property (weak, nonatomic) IBOutlet UILabel *noContactErrorMsgLbl;
@property (weak, nonatomic) IBOutlet UIButton *clickHereToAddBtn;
@property (strong, nonatomic) IBOutlet UIView *navView;

@end

@implementation MRContactsViewController

- (void)readData {
    
    
    self.myContacts = [MRDatabaseHelper getContacts];

    self.suggestedContacts = [MRDatabaseHelper getSuggestedContacts];
    if (self.myContacts != nil && self.myContacts.count >0) {
        [self setErrorMessageBtnVisibility :YES];
    }else {
        [self setErrorMessageBtnVisibility:NO ];
    }
}

-(void)setErrorMessageBtnVisibility:(BOOL)isVisible {
    self.noContactErrorMsgLbl.hidden = isVisible;
    self.clickHereToAddBtn.hidden = isVisible;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fileredContacts.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRContactCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"contactCell" forIndexPath:indexPath];
    if (collectionView ==  self.myContactsCollectionView) {
        [cell setData:[self.fileredContacts objectAtIndex:indexPath.row]];
    } else {
        [cell setData:[self.fileredContacts objectAtIndex:indexPath.row]];
    }
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.bounds.size.width/2 - 2, 50);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 4; // This is the minimum inter item spacing, can be more
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.suggestedContactsCollectionView) {
        return;
    }
    MRContactDetailViewController* detailViewController = [[MRContactDetailViewController alloc] init];
    [detailViewController setContact:self.fileredContacts[indexPath.row]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}

//- (void)setupPieMenu {
//    self.pieMenu = [[PieMenu alloc] init];
//    PieMenuItem *itemA = [[PieMenuItem alloc] initWithTitle:@"Connect"
//                                                      label:nil
//                                                     target:self
//                                                   selector:@selector(itemSelected:)
//                                                   userInfo:nil
//                                                       icon:[UIImage imageNamed:@"Contact.png"]];
//    
//    PieMenuItem *itemB = [[PieMenuItem alloc] initWithTitle:@"Share"
//                                                      label:nil
//                                                     target:self
//                                                   selector:@selector(itemSelected:)
//                                                   userInfo:nil
//                                                       icon:[UIImage imageNamed:@"Contact.png"]];
//    
//    PieMenuItem *itemC = [[PieMenuItem alloc] initWithTitle:@"Transform"
//                                                      label:nil
//                                                     target:self
//                                                   selector:@selector(itemSelected:)
//                                                   userInfo:nil
//                                                       icon:[UIImage imageNamed:@"Contact.png"]];
//    
//    PieMenuItem *itemD = [[PieMenuItem alloc] initWithTitle:@"Serve"
//                                                      label:nil
//                                                     target:self
//                                                   selector:@selector(itemSelected:)
//                                                   userInfo:nil
//                                                       icon:[UIImage imageNamed:@"Contact.png"]];
//    
//    
//    
//
//    
//    //[pieMenu addItem:itemD]; 
//    [self.pieMenu addItem:itemA];
//    [self.pieMenu addItem:itemB];
//    [self.pieMenu addItem:itemC];
//    [self.pieMenu addItem:itemD];
//
//}

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
    
//    [self setupPieMenu];
    [self.tabBar setSelectedItem:self.myContactsButton];
    self.suggestedContactsCollectionView.hidden = YES;
    [self.myContactsCollectionView registerNib:[UINib nibWithNibName:@"MRContactCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"contactCell"];
    [self.suggestedContactsCollectionView registerNib:[UINib nibWithNibName:@"MRContactCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"contactCell"];
    [self readData];
    self.fileredContacts = self.myContacts;
    self.navigationItem.title = @"Connect";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.searchBar resignFirstResponder];
    
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

- (IBAction)switchButtonTapped:(id)sender {
    [UIView transitionWithView:self.navigationController.view
                      duration:0.75
                       options:UIViewAnimationOptionTransitionCurlUp
                    animations:^{
                        [self.navigationController pushViewController:self.groupsListViewController animated:NO];
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

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [UIView transitionWithView:self.navigationController.view
                          duration:0.75
                           options:UIViewAnimationOptionTransitionCurlUp
                        animations:^{
                            [self.navigationController pushViewController:self.pendingContactsViewController animated:NO];
                        }
                        completion:nil];
    }else if (buttonIndex == 1){
        [self getMoreConnections];
    }
   
// PendingContactsViewController * pendingContactVC = [UIStoryboard]
}

- (void)getMoreConnections{
    [MRCommon showActivityIndicator:@"Requesting..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getMoreConnectionswithHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            //Success
        }
        else
        {
            NSArray *erros =  [details componentsSeparatedByString:@"-"];
            if (erros.count > 0)
                [MRCommon showAlert:[erros lastObject] delegate:nil];
        }
    }];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item == self.myContactsButton) {
//        [self.switchButton setImage:[UIImage imageNamed:@"Group.png"] forState:UIControlStateNormal];
//        [self.switchButton setImage:[UIImage imageNamed:@"Group.png"] forState:UIControlStateSelected];
        self.myContactsCollectionView.hidden = NO;
        self.suggestedContactsCollectionView.hidden = YES;
        self.fileredContacts = self.myContacts;
        [self.myContactsCollectionView reloadData];
    } else {
//        [self.switchButton setImage:[UIImage imageNamed:@"Contact.png"] forState:UIControlStateNormal];
//        [self.switchButton setImage:[UIImage imageNamed:@"Contact.png"] forState:UIControlStateSelected];
        self.myContactsCollectionView.hidden = YES;
        self.suggestedContactsCollectionView.hidden = NO;
        self.fileredContacts = self.suggestedContacts;
        [self.suggestedContactsCollectionView reloadData];
    }
    self.searchBar.text = @"";
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (self.myContactsCollectionView.hidden == NO) {
        if (searchText.length == 0) {
            self.fileredContacts = self.myContacts;
        } else {
            self.fileredContacts = [self.myContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[cd] %@",@"name",searchText]];
        }
        [self.myContactsCollectionView reloadData];
    } else {
        if (searchText.length == 0) {
            self.fileredContacts = self.suggestedContacts;
        } else {
            self.fileredContacts = [self.suggestedContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[cd] %@",@"name",searchText]];
        }
        [self.suggestedContactsCollectionView reloadData];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.tapGesture.enabled = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

@end

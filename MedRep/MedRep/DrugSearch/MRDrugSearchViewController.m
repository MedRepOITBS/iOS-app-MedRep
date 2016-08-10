//
//  MRDrugSearchViewController.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRDrugSearchViewController.h"
#import "MRDrugDetailViewController.h"
#import "MRCommon.h"
#import "MRWebserviceHelper.h"
#import "MRDevEnvironmentConfig.h"
#import "MRDrugDetailModel.h"
#import "WYPopoverController.h"
#import "MRListViewController.h"
#import "MRConstants.h"
#import "MRDrugTableViewCell.h"
#import "SWRevealViewController.h"

@interface MRDrugSearchViewController () <UIScrollViewDelegate, UITextFieldDelegate, MRListViewControllerDelegate, WYPopoverControllerDelegate> {
    NSMutableArray *resultarray;
    NSDictionary *selectedDrug;
    
    NSString *searchString;
    NSString *selectedMedicine;
    NSMutableArray *medicineSuggestions;
    NSMutableArray *medicineAlterations;
    NSMutableArray *drugConstituentsArray;
    
    MRDrugDetailModel *drugDetail;
}

@property (weak, nonatomic) IBOutlet UIView *titleView;

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *productType;
@property (weak, nonatomic) IBOutlet UILabel *composition;
@property (weak, nonatomic) IBOutlet UIView *suggestionView;
@property (weak, nonatomic) IBOutlet UILabel *selectedName;
@property (weak, nonatomic) IBOutlet UILabel *selectedDesc;
@property (weak, nonatomic) IBOutlet UITableView *suggestionsTable;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *selectedQty;
@property (weak, nonatomic) IBOutlet UITextField *searchTxt;
@property (strong, nonatomic) WYPopoverController *myPopoverController;

- (IBAction)rightMove:(id)sender;
- (IBAction)leftMove:(id)sender;

@end

@implementation MRDrugSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    SWRevealViewController *revealController = [self revealViewController];
    revealController.delegate = self;
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    self.navigationItem.title = @"Search for Drugs";
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController
                                                                        action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    //dummy data
    resultarray = [NSMutableArray array];
    NSDictionary *d1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Trycin",@"title",@"Trycin-Tabs.jpg",@"image",@"Tablet is a medium-hard, sugary confection from Scotland. Tablet is usually made from sugar, condensed milk, and butter, which is boiled to a soft-ball stage and allowed to crystallize. It is often flavoured with vanilla or whisky, and sometimes has nut pieces in it.",@"description",@"5 mg",@"qty",nil];
    [resultarray addObject:d1];
    d1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Calshell",@"title",@"CALSHELL.jpg",@"image",@"Tablet is a medium-hard, sugary confection from Scotland. Tablet is usually made from sugar, condensed milk, and butter, which is boiled to a soft-ball stage and allowed to crystallize. It is often flavoured with vanilla or whisky, and sometimes has nut pieces in it.",@"description",@"15 mg",@"qty",nil];
    [resultarray addObject:d1];
    d1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Selvit",@"title",@"selvit.jpeg",@"image",@"Tablet is a medium-hard, sugary confection from Scotland. Tablet is usually made from sugar, condensed milk, and butter, which is boiled to a soft-ball stage and allowed to crystallize. It is often flavoured with vanilla or whisky, and sometimes has nut pieces in it.",@"description",@"10 mg",@"qty",nil];
    [resultarray addObject:d1];
    d1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Paracetamol",@"title",@"Paracetamol.jpg",@"image",@"Tablet is a medium-hard, sugary confection from Scotland. Tablet is usually made from sugar, condensed milk, and butter, which is boiled to a soft-ball stage and allowed to crystallize. It is often flavoured with vanilla or whisky, and sometimes has nut pieces in it.",@"description",@"20 mg",@"qty",nil];
    [resultarray addObject:d1];
    //end of dummy data
    
    int xOffset = 0;
    for(int index=0; index < [resultarray count]; index++)
    {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset,10,100, 110)];
        img.image = [UIImage imageNamed:[resultarray objectAtIndex:index][@"image"]];
        img.tag = index;
        img.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapped:)];
        [img addGestureRecognizer:tap];
        
        [_scrollView addSubview:img];
        xOffset+=110;
    }
    _scrollView.contentSize = CGSizeMake(xOffset,110);
    
    [self mapData:[resultarray objectAtIndex:0]];
    
    _detailView.hidden = YES;
    _suggestionView.hidden = YES;
    
    _searchTxt.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    _searchTxt.leftViewMode = UITextFieldViewModeAlways;
    
//    [self.titleView setBackgroundColor:[MRCommon colorFromHexString:kStatusBarColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MRCommon applyNavigationBarStyling:self.navigationController andBarColor:@"#20B18A"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)backButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rightMove:(id)sender {
    [_scrollView setContentOffset:CGPointMake(120, 0) animated:YES];
}

- (IBAction)leftMove:(id)sender {
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)showDetail:(id)sender {
    MRDrugDetailViewController *notiFicationViewController = [[MRDrugDetailViewController alloc] initWithNibName:@"MRDrugDetailViewController" bundle:nil];
    notiFicationViewController.selectedDict = selectedDrug;
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length>3) {
        searchString = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self getMedicineSuggestions];
    }else{
        if (self.myPopoverController) {
            UIView *overlayView = [self.view viewWithTag:2000];
            [overlayView removeFromSuperview];
            
            self.myPopoverController.delegate = nil;
            self.myPopoverController = nil;
        }
    }
    
    return YES;
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
//    if (textField.text.length) {
//        searchString = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//        [self getMedicineSuggestions];
//    }
    return YES;
}

-(void)imgTapped:(UITapGestureRecognizer *)img{
    [self mapData:[resultarray objectAtIndex:img.view.tag]];
}

-(void) mapData:(NSDictionary *)dict{
    selectedDrug = dict;
    _selectedName.text = dict[@"title"];
    _selectedDesc.text = dict[@"description"];
    _selectedQty.text = dict[@"qty"];
}

-(void)setDetailView{
    _detailView.hidden = NO;
    
    _selectedName.text = drugDetail.brand;
    _productType.text = drugDetail.category;
    _selectedDesc.text = drugDetail.manufacturer;
    _selectedQty.text = [NSString stringWithFormat:@"%@ %@ - MRP ₹ %.1f",drugDetail.package_qty, drugDetail.package_type,[drugDetail.package_price doubleValue]];
    _composition.text = drugConstituentsArray.count ? [self prepareComposition] : @"Compositon details not available";
}

-(NSString *) prepareComposition {
    NSString *str = @"";
    for (MRDrugConstituentsModel *model in drugConstituentsArray) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%@: %@ + ",model.name, model.strength]];
        str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    }
    return str.length > 3 ? [str substringToIndex:str.length - 3] : @"";
}

- (void)showPopoverInView:(UITextField*)button
{
    if (self.myPopoverController) {
        UIView *overlayView = [self.view viewWithTag:2000];
        [overlayView removeFromSuperview];
        
        self.myPopoverController.delegate = nil;
        self.myPopoverController = nil;
    }
    
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayView.tag = 2000;
    overlayView.backgroundColor = kRGBCOLORALPHA(0, 0, 0, 0.5);
    [self.view addSubview:overlayView];
    [MRCommon addUpdateConstarintsTo:self.view withChildView:overlayView];
    
    WYPopoverTheme *popOverTheme = [WYPopoverController defaultTheme];
    popOverTheme.outerStrokeColor = [UIColor clearColor];
    [WYPopoverController setDefaultTheme:popOverTheme];
    
    MRListViewController *moreViewController = [[MRListViewController alloc] initWithNibName:@"MRListViewController" bundle:nil];
    
    moreViewController.modalInPopover = NO;
    moreViewController.delegate = self;
    
    moreViewController.listType = MRListVIewTypeMedicineList;
    moreViewController.listItems = medicineSuggestions;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    moreViewController.preferredContentSize = CGSizeMake(width, 200);
    
    UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController:moreViewController] ;
    contentViewController.navigationBar.hidden = YES;
    
    self.myPopoverController = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
    self.myPopoverController.delegate = self;
    self.myPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(0,2, 0, 2);
    self.myPopoverController.wantsDefaultContentAppearance = YES;
    [self.myPopoverController presentPopoverFromRect:button.bounds
                                              inView:button
                            permittedArrowDirections:WYPopoverArrowDirectionUp
                                            animated:YES
                                             options:WYPopoverAnimationOptionFadeWithScale];
    
}

#pragma mark - WYPopoverControllerDelegate
- (void)popoverControllerDidPresentPopover:(WYPopoverController *)controller
{
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    UIView *overlayView = [self.view viewWithTag:2000];
    [overlayView removeFromSuperview];
    
    [self.searchTxt resignFirstResponder];
    self.myPopoverController.delegate = nil;
    self.myPopoverController = nil;
}

- (void)dismissPopoverController
{
    [self.myPopoverController dismissPopoverAnimated:YES completion:^{
        [self popoverControllerDidDismissPopover:self.myPopoverController];
    }];
}

- (void)selectedListItem:(id)listItem
{
    NSDictionary *item = (NSDictionary*)listItem;
    if ([item objectForKey:@"selectedMedicine"]) {
        selectedMedicine = [item objectForKey:@"selectedMedicine"];
        _searchTxt.text = selectedMedicine;
        
        [self getMedicineDetails];
        [self getMedicineAlternatives];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return medicineAlterations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static  NSString *ident = @"MRDrugTableViewCell";
    MRDrugTableViewCell * cell = (MRDrugTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ident];
    
    if (cell == nil) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"MRDrugTableViewCell" owner:self options:nil];
        cell = (MRDrugTableViewCell *)[arr objectAtIndex:0];
    }
    
    MRDrugDetailModel *model = [medicineAlterations objectAtIndex:indexPath.row];
    cell.brand.text = model.brand;
    cell.company.text = model.manufacturer;
    cell.type.text = model.category;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedMedicine = ((MRDrugDetailModel*)[medicineAlterations objectAtIndex:indexPath.row]).brand;
    [self getMedicineDetails];
}

-(void) getMedicineSuggestions{
    NSMutableDictionary *dictReq = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    searchString, @"id",
                                    kDrugSearchAPIKey, @"key",
                                    @"1000", @"limit",
                                    nil];
    
    [MRCommon showActivityIndicator:@"Loading..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getMedicineSuggestions:dictReq withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        medicineSuggestions = [NSMutableArray array];
        
        if (status) {
            if ([responce[@"status"] isEqualToString:@"ok" ]) {
                NSDictionary *resp = responce[@"response"];
                if (resp) {
                    NSArray *suggestions = resp[@"suggestions"];
                    for (NSDictionary *dict in suggestions) {
                        [medicineSuggestions addObject:dict[@"suggestion"]];
                    }
                    
                    if (medicineSuggestions.count) {
                        [self showPopoverInView:_searchTxt];
                    }else{
                        [[[UIAlertView alloc] initWithTitle:@"" message:@"No drugs found!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                        if (self.myPopoverController) {
                            UIView *overlayView = [self.view viewWithTag:2000];
                            [overlayView removeFromSuperview];
                            
                            self.myPopoverController.delegate = nil;
                            self.myPopoverController = nil;
                        }
                    }
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

-(void) getMedicineAlternatives{
    NSMutableDictionary *dictReq = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    selectedMedicine, @"id",
                                    kDrugSearchAPIKey, @"key",
                                    @"1000", @"limit",
                                    nil];
    
    [MRCommon showActivityIndicator:@"Loading..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getMedicineAlternatives:dictReq withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        medicineAlterations = [NSMutableArray array];
        
        if (status) {
            NSDictionary *resp = responce[@"response"];
            if (resp) {
                NSArray *suggestions = resp[@"medicine_alternatives"];
                for (NSDictionary *dict in suggestions) {
                    MRDrugDetailModel *drug = [[MRDrugDetailModel alloc] initWithDict:dict];
                    [medicineAlterations addObject:drug];
                }
                
                if (medicineAlterations.count) {
                    _suggestionView.hidden = NO;
                    [_suggestionsTable reloadData];
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

-(void) getMedicineDetails{
    NSMutableDictionary *dictReq = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    selectedMedicine, @"id",
                                    kDrugSearchAPIKey, @"key",
                                    nil];
    
    [MRCommon showActivityIndicator:@"Loading..."];
    [[MRWebserviceHelper sharedWebServiceHelper] getMedicineDetails:dictReq withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        [MRCommon stopActivityIndicator];
        drugConstituentsArray = [NSMutableArray array];
        
        if (status) {
            if ([responce[@"status"] isEqualToString:@"ok" ]) {
                NSDictionary *resp = responce[@"response"];
                if (resp) {
                    drugDetail = [[MRDrugDetailModel alloc] initWithDict:resp[@"medicine"]];
                    
                    NSArray *suggestions = resp[@"constituents"];
                    for (NSDictionary *dict in suggestions) {
                        MRDrugConstituentsModel *drug = [[MRDrugConstituentsModel alloc] initWithDict:dict];
                        [drugConstituentsArray addObject:drug];
                    }
                    
                    [self setDetailView];
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

@end

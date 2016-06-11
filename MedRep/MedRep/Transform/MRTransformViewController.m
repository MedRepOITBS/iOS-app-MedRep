//
//  MRTransformViewController.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/8/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRTransformViewController.h"
#import "MPTransformTableViewCell.h"
#import "MRTransformDetailViewController.h"
#import "MRWebserviceHelper.h"
#import "MRCommon.h"
#import "MRDatabaseHelper.h"
#import "MRAppControl.h"
#import "MRShareViewController.h"
#import "MPTransformData.h"

@interface MRTransformViewController ()<UISearchBarDelegate>{
    UILabel *infoLbl;
}

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIView *slideView;
@property (weak, nonatomic) IBOutlet UIButton *newsButton;
@property (weak, nonatomic) IBOutlet UIButton *eduButton;
@property (weak, nonatomic) IBOutlet UIButton *slideButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideViewWidth;
@property (weak, nonatomic) IBOutlet UISearchBar *search;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) NSMutableArray *contentData;

- (IBAction)newsTapped:(UIButton *)sender;
- (IBAction)eduTapped:(UIButton *)sender;
- (IBAction)sortTapped:(UIButton *)sender;
- (IBAction)sliderButtonTapped:(UIButton *)sender;
- (IBAction)connect:(id)sender;
- (IBAction)share:(id)sender;

@end

@implementation MRTransformViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Transform";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    //[self.view bringSubviewToFront:_slideButton];
    [self flashOn:_slideButton];
    _slideButton.transform=CGAffineTransformMakeRotation(M_PI / 4);
    
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.slideView addGestureRecognizer:gestureRecognizer];
    _contentData = [NSMutableArray array];
    
//    [self getNews];
    
    [self setButtonStates:self.eduButton activateButton:self.newsButton];
    
    [self createDummyData];
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

- (void)backButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sortTapped:(UIButton *)sender {

}

- (IBAction)newsTapped:(UIButton *)sender {
    [self setButtonStates:self.eduButton activateButton:self.newsButton];
//    [_eduButton setBackgroundColor:[UIColor colorWithRed:32/255.0 green:177/255.0 blue:138/255.0 alpha:1.0]];//green
//    [_newsButton setBackgroundColor:[UIColor colorWithRed:26/255.0 green:133/255.0 blue:213/255.0 alpha:1.0]];//blue
    
    //[self getNews];
}

- (IBAction)eduTapped:(UIButton *)sender {
    
    [self setButtonStates:self.newsButton activateButton:self.eduButton];
    
//    [_newsButton setBackgroundColor:[UIColor colorWithRed:32/255.0 green:177/255.0 blue:138/255.0 alpha:1.0]];//green
//    [_eduButton setBackgroundColor:[UIColor colorWithRed:26/255.0 green:133/255.0 blue:213/255.0 alpha:1.0]];//blue
    
    //[self getMaterial];
}

- (void)setButtonStates:(UIButton*) deactivate activateButton:(UIButton *)activate {
    [deactivate setBackgroundColor:[UIColor colorWithRed:32/255.0 green:177/255.0 blue:138/255.0 alpha:1.0]];
    [activate setBackgroundColor:[UIColor colorWithRed:32/255.0 green:150/255.0 blue:138/255.0 alpha:1.0]];
}

-(void)swipeHandler:(UISwipeGestureRecognizer *)recognizer {
    [self sliderButtonTapped:nil];
}

- (IBAction)sliderButtonTapped:(UIButton *)sender {
    if (_slideView.frame.origin.x < self.view.frame.size.width) {
        CGRect basketTopFrame = _slideView.frame;
        basketTopFrame.origin.x = self.view.frame.size.width;
        //CGRect basketTopFrame1 = _slideButton.frame;
        //basketTopFrame1.origin.x = self.view.frame.size.width-15;
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _slideView.frame = basketTopFrame;
            //_slideButton.frame = basketTopFrame1;
        } completion:^(BOOL finished){
            _slideButton.hidden = false;
        }];
    }else{
        CGRect napkinBottomFrame = _slideView.frame;
        napkinBottomFrame.origin.x = self.view.frame.size.width-90;
        //CGRect napkinBottomFrame1 = _slideButton.frame;
        //napkinBottomFrame1.origin.x = self.view.frame.size.width-125;
        [UIView animateWithDuration:0.5 delay:0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
            _slideView.frame = napkinBottomFrame;
            //_slideButton.frame = napkinBottomFrame1;
        } completion:^(BOOL finished){
            _slideButton.hidden = true;
        }];
    }
}

- (IBAction)connect:(id)sender {
    [self sliderButtonTapped:nil];
}

- (IBAction)share:(id)sender {
    [self sliderButtonTapped:nil];
//    MRShareViewController *notiFicationViewController = [[MRShareViewController alloc] initWithNibName:@"MRShareViewController" bundle:nil];
//    //notiFicationViewController.selectedContent = [self.contentData objectAtIndex:indexPath.row];
//    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contentData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"MPTransformTableViewCell";
    MPTransformTableViewCell *regCell = (MPTransformTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (regCell == nil)
    {
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"MPTransformTableViewCell" owner:nil options:nil];
        regCell = (MPTransformTableViewCell *)[nibViews lastObject];
    }
    
    MPTransformData *transformData = self.contentData[indexPath.row];
    if (transformData != nil) {
        if (transformData.icon != nil && transformData.icon.length > 0) {
            regCell.img.image = [UIImage imageNamed:transformData.icon];
        }
        
        if (transformData.title != nil && transformData.title.length > 0) {
            regCell.titleLbl.text = transformData.title;
        }
        
        if (transformData.shortDescription != nil && transformData.shortDescription.length > 0) {
            regCell.descLbl.text = transformData.shortDescription;
        }
    }
    
    return regCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_slideView.frame.origin.x < self.view.frame.size.width) {
        [self sliderButtonTapped:nil];
    }
    MRTransformDetailViewController *notiFicationViewController = [[MRTransformDetailViewController alloc] initWithNibName:@"MRTransformDetailViewController" bundle:nil];
    notiFicationViewController.selectedContent = self.contentData[indexPath.row];
    //notiFicationViewController.selectedContent = [self.contentData objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    if (_slideView.frame.origin.x < self.view.frame.size.width) {
        [self sliderButtonTapped:nil];
    }
    
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    if (_slideView.frame.origin.x < self.view.frame.size.width) {
        [self sliderButtonTapped:nil];
    }
    
    return YES;
}

- (void)flashOff:(UIView *)v
{
    [UIView animateWithDuration:1.05 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = .3;  //don't animate alpha to 0, otherwise you won't be able to interact with it
    } completion:^(BOOL finished) {
        [self flashOn:v];
    }];
}

- (void)flashOn:(UIView *)v
{
    [UIView animateWithDuration:1.05 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = 1;
    } completion:^(BOOL finished) {
        [self flashOff:v];
    }];
}

- (void)getNews{
    [[MRWebserviceHelper sharedWebServiceHelper] getNewswithHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             //dummy data
             NSMutableArray *myArray = [NSMutableArray array];
             NSDictionary *d1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Medrep",@"titile",@"It's a notification",@"message",@"20160617103000",@"startDate",@"NEW",@"status",[NSNumber numberWithInt:1],@"notificationId",@"Image",@"type",[NSNumber numberWithInt:1],@"companyId",@"Eye",@"therapeuticName", nil];
             [myArray addObject:d1];
             [myArray addObject:d1];
             [myArray addObject:d1];
             [myArray addObject:d1];
             [myArray addObject:d1];
             //responce = [NSDictionary dictionaryWithObject:myArray forKey:kResponce];
             //end of dummy data
             
             [MRCommon stopActivityIndicator];
             _contentData = [responce objectForKey:kResponce];
             [MRAppControl sharedHelper].notifications = [responce objectForKey:kResponce];
             
             if (self.contentData.count == 0){
                 infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, _table.frame.size.width, 25)];
                 infoLbl.textAlignment = NSTextAlignmentCenter;
                 infoLbl.text = @"No Articles found!!";
                 [_table addSubview:infoLbl];
             }else{
                 [infoLbl removeFromSuperview];
             }
             
             [self.table reloadData];
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getMyNotifications:[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMdd"] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       [MRCommon stopActivityIndicator];
                       if (status)
                       {
                           [MRAppControl sharedHelper].notifications = [responce objectForKey:kResponce];
                           
                           if (self.contentData.count == 0){
                               infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, _table.frame.size.width, 25)];
                               infoLbl.textAlignment = NSTextAlignmentCenter;
                               infoLbl.text = @"No Notifications found!!";
                               [_table addSubview:infoLbl];
                           }else{
                               [infoLbl removeFromSuperview];
                           }
                           
                           [self.table reloadData];
                       }
                   }];
              }];
         }
         else
         {
             [MRCommon stopActivityIndicator];
             if (self.contentData.count == 0){
                 infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, _table.frame.size.width, 25)];
                 infoLbl.textAlignment = NSTextAlignmentCenter;
                 infoLbl.text = @"No Notifications found!!";
                 [_table addSubview:infoLbl];
             }else{
                 [infoLbl removeFromSuperview];
             }
         }
         
     }];
}

- (void)getMaterial{
    [[MRWebserviceHelper sharedWebServiceHelper] getMaterialwithHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         if (status)
         {
             //dummy data
             NSMutableArray *myArray = [NSMutableArray array];
             NSDictionary *d1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Medrep",@"titile",@"It's a notification",@"message",@"20160617103000",@"startDate",@"NEW",@"status",[NSNumber numberWithInt:1],@"notificationId",@"Image",@"type",[NSNumber numberWithInt:1],@"companyId",@"Eye",@"therapeuticName", nil];
             [myArray addObject:d1];
             [myArray addObject:d1];
             [myArray addObject:d1];
             [myArray addObject:d1];
             [myArray addObject:d1];
             //responce = [NSDictionary dictionaryWithObject:myArray forKey:kResponce];
             //end of dummy data
             
             [MRCommon stopActivityIndicator];
             _contentData = [responce objectForKey:kResponce];
             [MRAppControl sharedHelper].notifications = [responce objectForKey:kResponce];
             
             if (self.contentData.count == 0){
                 infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, _table.frame.size.width, 25)];
                 infoLbl.textAlignment = NSTextAlignmentCenter;
                 infoLbl.text = @"No Articles found!!";
                 [_table addSubview:infoLbl];
             }else{
                 [infoLbl removeFromSuperview];
             }
             
             [self.table reloadData];
         }
         else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
         {
             [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
              {
                  [MRCommon savetokens:responce];
                  [[MRWebserviceHelper sharedWebServiceHelper] getMyNotifications:[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMdd"] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                   {
                       [MRCommon stopActivityIndicator];
                       if (status)
                       {
                           [MRAppControl sharedHelper].notifications = [responce objectForKey:kResponce];
                           
                           if (self.contentData.count == 0){
                               infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, _table.frame.size.width, 25)];
                               infoLbl.textAlignment = NSTextAlignmentCenter;
                               infoLbl.text = @"No Notifications found!!";
                               [_table addSubview:infoLbl];
                           }else{
                               [infoLbl removeFromSuperview];
                           }
                           
                           [self.table reloadData];
                       }
                   }];
              }];
         }
         else
         {
             [MRCommon stopActivityIndicator];
             if (self.contentData.count == 0){
                 infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, _table.frame.size.width, 25)];
                 infoLbl.textAlignment = NSTextAlignmentCenter;
                 infoLbl.text = @"No Notifications found!!";
                 [_table addSubview:infoLbl];
             }else{
                 [infoLbl removeFromSuperview];
             }
         }
         
     }];
}

- (void)createDummyData {
    // Create Dummy Data
    MPTransformData *transformData = [MPTransformData new];
    [transformData setIcon:@"comapny-logo.png"];
    [transformData setTitle:@"Could High-Dose Vitamin D Help Fight Multiple Sclerosis"];
    [transformData setShortDescription:@"Supplementation appears safe but experts says it's too soon for general..."];
    [transformData setDetailDescription:@"Supplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for general"];
    [self.contentData addObject:transformData];
    
    transformData = [MPTransformData new];
    [transformData setIcon:@"PHdashboard-banner.png"];
    [transformData setTitle:@"Painkillers Often Gateway to Heroin for U.S Teens: Survey"];
    [transformData setShortDescription:@"Heroin is cheaper, easier to obtain than narcotics like OxyContin experts say..."];
    [transformData setDetailDescription:@""];
    [self.contentData addObject:transformData];
    
    transformData = [MPTransformData new];
    [transformData setIcon:@"PHdashboard-bg.png"];
    [transformData setTitle:@"It's Not Too late"];
    [transformData setShortDescription:@"Influenza activity usually active in Janurary or February..."];
    [transformData setDetailDescription:@""];
    [self.contentData addObject:transformData];
    
    transformData = [MPTransformData new];
    [transformData setIcon:@"comapny-logo2.png"];
    [transformData setTitle:@"Best Cancer Screening Methods"];
    [transformData setShortDescription:@"Source:HealthDay - Related Medline Plus"];
    [transformData setDetailDescription:@""];
    [self.contentData addObject:transformData];
    
    transformData = [MPTransformData new];
    [transformData setIcon:@"bg.png"];
    [transformData setTitle:@"Could High-Dose Vitamin D Help Fight Multiple Sclerosis"];
    [transformData setShortDescription:@"Supplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for generalSupplementation appears safe but experts says it's too soon for general"];
    [transformData setDetailDescription:@""];
    [self.contentData addObject:transformData];
    
    transformData = [MPTransformData new];
    [transformData setIcon:@"latestNotificatins.png"];
    [transformData setTitle:@"Painkillers Often Gateway to Heroin for U.S Teens: Survey"];
    [transformData setShortDescription:@"Heroin is cheaper, easier to obtain than narcotics like OxyContin experts say..."];
    [transformData setDetailDescription:@"Heroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts sayHeroin is cheaper, easier to obtain than narcotics like OxyContin experts say"];
    [self.contentData addObject:transformData];
}

@end

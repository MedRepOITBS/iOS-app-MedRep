//
//  MRDashboardViewController.m
//  MedRep
//
//  Created by Hima Bindhu on 28/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRDashboardViewController.h"
#import "MRNotificationsViewController.h"
#import "SWRevealViewController.h"
#import "MRWebserviceHelper.h"
#import "MRAppointmentCollectionViewCell.h"
#import "MRNotificationsViewController.h"
#import "MRCommon.h"

@interface MRDashboardViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

//@property (weak, nonatomic) IBOutlet UILabel *emailCount;
//@property (weak, nonatomic) IBOutlet UILabel *notificationCount;
//@property (weak, nonatomic) IBOutlet UITableView *dashboardTableView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationHeightConstarint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionViewheightConstraint;
@property (weak, nonatomic) IBOutlet UIView *appointmentsConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *appointmentHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleViewTopConstraint;

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upMidOneBtnConstarint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upMidTwoBtnConstarint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downMidTwoBtnConstarint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downMidOneBtnConstarint;

@end

@implementation MRDashboardViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UINib *nib = [UINib nibWithNibName:@"MRAppointmentCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"AppointmentCollectionViewCell"];

    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self setupView];

    // Do any additional setup after loading the view from its nib.
}

- (void)setupView
{
    if ([MRCommon deviceHasThreePointFiveInchScreen])
    {
        self.notificationHeightConstarint.constant = 100;
        self.appointmentHeightConstraint.constant = 115;
        self.titleViewTopConstraint.constant = 25;
        self.optionViewheightConstraint.constant = 176;
        self.buttonHeightConstraint.constant = 88;
        self.buttonWidthConstraint.constant = 120;
    }
    else if ([MRCommon deviceHasFourInchScreen])
    {
        self.notificationHeightConstarint.constant = 115;
        self.appointmentHeightConstraint.constant = 135;
        self.titleViewTopConstraint.constant = 40;
        self.optionViewheightConstraint.constant = 214;
        self.buttonHeightConstraint.constant = 115;
        self.buttonWidthConstraint.constant = 110;
        self.upMidOneBtnConstarint.constant = 3.5;
        self.upMidTwoBtnConstarint.constant = 3.5;
        self.downMidOneBtnConstarint.constant = 3.5;
        self.downMidTwoBtnConstarint.constant = 3.5;
    }
    else if ([MRCommon deviceHasFourPointSevenInchScreen])
    {
        
    }
    else if ([MRCommon deviceHasFivePointFiveInchScreen])
    {
        
    }
    else if ([MRCommon isHD])
    {
        
    }

    [self updateViewConstraints];
}

//175, 230,265,300,400
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dashBoardButtonAction:(id)sender
{
    MRNotificationsViewController *notiFicationViewController = [[MRNotificationsViewController alloc] initWithNibName:@"MRNotificationsViewController" bundle:nil];
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return  10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier = @"AppointmentCollectionViewCell";
    
    MRAppointmentCollectionViewCell *cell = (MRAppointmentCollectionViewCell  *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end

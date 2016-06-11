//
//  MRNotificationInsiderViewController.m
//  MedRep
//
//  Created by MedRep Developer on 09/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRPharmaNotificationDetailsViewController.h"
#import "MPNotificationAlertViewController.h"
#import "SWRevealViewController.h"
#import "MPCallMedrepViewController.h"
#import "MRCompaignsDetailsViewController.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "NSDate+Utilities.h"
#import "MRAppControl.h"
#import "MRWebserviceHelper.h"
#import "MRDatabaseHelper.h"

@interface MRPharmaNotificationDetailsViewController ()<UIScrollViewDelegate, SWRevealViewControllerDelegate>
{
    SWRevealViewController *revealController;
}
@property (weak, nonatomic) IBOutlet UIView *tiltleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backbutton;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *drugNamelabel;
@property (weak, nonatomic) IBOutlet UILabel *companyNamelabel;
@property (weak, nonatomic) IBOutlet UIImageView *notifcationImage;
@property (weak, nonatomic) IBOutlet UILabel *contentHeaderLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UILabel *contentTitleLabel;

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (assign, nonatomic) NSInteger timer;
@property (assign, nonatomic) NSTimer *loopTimer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationImageWidthConstraint;
@property (nonatomic, assign) BOOL favourite;
@property (nonatomic, assign) CGFloat rating;
@property (nonatomic, assign) BOOL patientRecomended;
@property (nonatomic, assign) BOOL doctorRecomended;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (nonatomic, retain) NSMutableDictionary *noticationImages;
@property (nonatomic, retain) NSArray *detailsList;
@property (nonatomic, assign) NSInteger imagesCount;
@property (nonatomic, assign) NSInteger currentImageIndex;

@property (weak, nonatomic) IBOutlet UIScrollView *topScrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (weak, nonatomic) IBOutlet UIView *imageContentView;
@property (weak, nonatomic) IBOutlet UIImageView *topNotificationImage;

@end

@implementation MRPharmaNotificationDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.contentScrollView setZoomScale:1.0];
    [self.contentScrollView setMinimumZoomScale:0.5];
    [self.contentScrollView setMaximumZoomScale:5.0];

    self.noticationImages = [[NSMutableDictionary alloc] init];
    
    self.timer = 5;
    self.timerLabel.text = [NSString stringWithFormat:@"00:%02ld",(long)self.timer];
    
    self.rating = 0.0;
    self.patientRecomended = NO;
    self.doctorRecomended = NO;
    self.favourite = NO;

    revealController = [self revealViewController];
    revealController.delegate = self;
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    self.topView.hidden = YES;
    
    [self addSwipeGesture];
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    

    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    self.selectedNotification = [[MRAppControl sharedHelper] getNotificationByID:[[self.notificationDetails objectForKey:@"notificationId"] integerValue]];
    
//    [MRDatabaseHelper updateNotifiction:[self.notificationDetails objectForKey:@"notificationId"] userFavouriteSatus:NO userReadStatus:YES withSavedStatus:^(BOOL isScuccess) {
//        
//    }];

    if (self.selectedNotification)
    {
        self.contentHeaderLabel.text = [self.selectedNotification objectForKey:@"notificationDesc"];
        self.companyNamelabel.text = [self.selectedNotification objectForKey:@"companyName"];
        self.drugNamelabel.text = [self.notificationDetails objectForKey:@"detailTitle"];
        
        self.titleLabel.text = [self.selectedNotification objectForKey:@"companyName"];
        [MRCommon showActivityIndicator:@"Loading..."];
        self.detailsList = [self.notificationDetails objectForKey:@"notificationDetails"];
        [self loadImages];
    }
    self.loopTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];
    
    [self hideNavigationButton];
    self.imagesCount = 0;
    if (self.detailsList.count > 1)
    {
        [self showNavigationButton];
    }
    
    // Do any additional setup after loading the view from its nib.
    
}

- (void)addSwipeGesture
{
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandlerRight:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.imageContentView addGestureRecognizer:gestureRecognizer];
    
    UISwipeGestureRecognizer *lgestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandlerLeft:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.imageContentView addGestureRecognizer:lgestureRecognizer];
}

- (void)swipeHandlerRight:(id)sender {
    
    //Your ViewController
    [self leftButtonAction:nil];
    
}

- (void)swipeHandlerLeft:(id)sender {
    
    //Your ViewController
    [self rightButtonAction:nil];
    
}

- (void)loadImages
{
    [MRCommon getPharmaNotificationImageByID:[[[self.detailsList objectAtIndex:self.imagesCount] objectForKey:@"detailId"] integerValue] forImage:^(UIImage *image)
     {
         if (image)
         {
             [self.noticationImages setObject:image forKey:[[self.detailsList objectAtIndex:self.imagesCount] objectForKey:@"detailId"]];
             
             self.contentViewHeight.constant = self.topScrollView.frame.size.height + 130;
             self.contentViewWidth.constant =  self.topScrollView.frame.size.width;
             [self updateViewConstraints];

             
             if (self.imagesCount == 0)
             {
                 [self updateNotification:[[self.detailsList objectAtIndex:self.imagesCount] objectForKey:@"detailId"]];
                 self.currentImageIndex = 0;
             }
             
             self.imagesCount++;
             
             if (self.imagesCount < self.detailsList.count)
             {
                 [self loadImages];
             }
             else if (self.imagesCount == self.detailsList.count)
             {
                 [MRCommon stopActivityIndicator];
             }
         }
         else
         {
             [MRCommon stopActivityIndicator];
             self.notificationImageHeightConstraint.constant = 0;
             self.notificationImageWidthConstraint.constant = 0;
             self.notifcationImage.image = [UIImage imageNamed:@""];
             self.topNotificationImage.image = [UIImage imageNamed:@""];

         }
     }];
}


- (void)updateNotification:(NSNumber*)imageId
{
    UIImage *image = [self.noticationImages objectForKey:imageId];
    self.notificationImageHeightConstraint.constant = self.contentScrollView.frame.size.height;
    self.notificationImageWidthConstraint.constant = self.contentScrollView.frame.size.width;
    self.notifcationImage.image = image;
    self.topNotificationImage.image = image;
    self.contentTitleLabel.text = [[self.detailsList objectAtIndex:self.currentImageIndex] objectForKey:@"detailTitle"];
    self.contentHeaderLabel.text = [[self.detailsList objectAtIndex:self.currentImageIndex] objectForKey:@"detailDesc"];

    self.contentScrollView.contentSize = image.size;
    [self.view updateConstraints];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return (scrollView.tag == 2000) ? self.notifcationImage : nil;
}

- (void)updateTimerLabel
{
    self.timer--;
    self.timerLabel.text = [NSString stringWithFormat:@"00:%02ld",(long)self.timer];
    if (self.timer == 0)
    {
        [self.loopTimer invalidate];
        self.loopTimer = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonAction:(id)sender
{
    if (self.isFullScreenShown)
    {
        [self showhideFullScree:NO];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (IBAction)fullScreenButtonAction:(id)sender
{
    [self showhideFullScree:YES];
}

- (IBAction)callMedrepButtonAction:(id)sender
{
    [self loadCallMedrep];
//    NSMutableDictionary *notificationdict = [[NSMutableDictionary alloc] init];
//
//    [notificationdict setObject:[self.notificationDetails objectForKey:@"notificationId"] forKey:@"notificationId"];
//    [notificationdict setObject:@"Viewed"  forKey:@"viewStatus"];
//    NSString *fav = (self.favourite == YES) ? @"Y" : @"N";
//    [notificationdict setObject:fav  forKey:@"favourite"];
//    
//    [notificationdict setObject:[NSNumber numberWithFloat:self.rating]  forKey:@"rating"];
//     fav = (self.patientRecomended == YES) ? @"Y" : @"N";
//    [notificationdict setObject:fav  forKey:@"prescribe"];
//    
//    fav = (self.doctorRecomended == YES) ? @"Y" : @"N";
//    [notificationdict setObject:fav  forKey:@"recomend"];
//    [notificationdict setObject:[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMddhhmmss"]  forKey:@"viewedOn"];
//    [notificationdict setObject:@"1"  forKey:@"userNotificationId"];
//    [MRCommon showActivityIndicator:@"Sending..."];
//    [[MRWebserviceHelper sharedWebServiceHelper] updateNotification:notificationdict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
//        if (status)
//        {
//            [MRCommon stopActivityIndicator];
//            [self loadCallMedrep];
//        }
//        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
//        {
//            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
//             {
//                 [MRCommon stopActivityIndicator];
//                 [MRCommon savetokens:responce];
//                 [[MRWebserviceHelper sharedWebServiceHelper] updateNotification:notificationdict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
//                     
//                     if (status)
//                     {
//                         [self loadCallMedrep];
//                     }
//                 }];
//             }];
//        }
//        else
//        {
//            [self loadCallMedrep];
//        }
//        
//    }];
    
}

 - (void)loadCallMedrep
{
    MRCompaignsDetailsViewController *cappointment = [[MRCompaignsDetailsViewController alloc] initWithNibName:@"MRCompaignsDetailsViewController" bundle:nil];
    cappointment.titleText = [self.notificationDetails objectForKey:@"notificationName"];
    cappointment.notificationID =  [[self.notificationDetails objectForKey:@"notificationId"] integerValue];
    [self.navigationController pushViewController:cappointment animated:YES];
    [cappointment updateTitleLabel];
}

- (void)showNavigationButton
{
    self.rightButton.hidden = NO;
    self.leftButton.hidden  = NO;
}

- (void)hideNavigationButton
{
    self.rightButton.hidden = YES;
    self.leftButton.hidden  = YES;
}

- (IBAction)leftButtonAction:(id)sender
{
    if (self.currentImageIndex == self.detailsList.count -1)
    {
        self.currentImageIndex = -1;
    }
    
    self.currentImageIndex++;
    [self updateNotification:[[self.detailsList objectAtIndex:self.currentImageIndex] objectForKey:@"detailId"]];
}

- (IBAction)rightButtonAction:(id)sender
{
    if (self.currentImageIndex == 0)
    {
        self.currentImageIndex = self.detailsList.count;
    }
    self.currentImageIndex--;
    [self updateNotification:[[self.detailsList objectAtIndex:self.currentImageIndex] objectForKey:@"detailId"]];

}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (position == FrontViewPositionRight)
    {
        self.view.userInteractionEnabled = NO;
    }
    else if (position == FrontViewPositionLeft)
    {
        self.view.userInteractionEnabled = YES;
    }
}

- (void)showhideFullScree:(BOOL)isFullScreen
{
    self.isFullScreenShown = isFullScreen;
    if (isFullScreen)
    {
        [self.contentScrollView setZoomScale:1.0];
        [self.contentScrollView setMinimumZoomScale:0.5];
        [self.contentScrollView setMaximumZoomScale:5.0];

        self.topView.hidden = NO;
        self.footerView.hidden= YES;
        self.contentView.hidden = YES;
        self.imageConstarintViewConstaint.constant = -40;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
        self.fullscreenView.hidden = YES;
        self.drugNamelabel.hidden = YES;
        self.titleLabel.text = @"Product details";
    }
    else
    {
        self.topView.hidden = YES;
        self.footerView.hidden= NO;
        self.contentView.hidden = NO;
        self.imageConstarintViewConstaint.constant = 0;
        self.fullscreenView.hidden = NO;
        self.drugNamelabel.hidden = NO;
        self.titleLabel.text = [self.selectedNotification objectForKey:@"companyName"];
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                             style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
        
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
    
    [self updateViewConstraints];
}
@end

//
//  MRNotificationInsiderViewController.m
//  MedRep
//
//  Created by MedRep Developer on 09/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRNotificationInsiderViewController.h"
#import "MPNotificationAlertViewController.h"
#import "SWRevealViewController.h"
#import "MPCallMedrepViewController.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import "NSDate+Utilities.h"
#import "MRAppControl.h"
#import "MRWebserviceHelper.h"
#import "MRDatabaseHelper.h"
#import "MRNotifications.h"

@interface MRNotificationInsiderViewController ()<UIScrollViewDelegate, SWRevealViewControllerDelegate, UIAlertViewDelegate>
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
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *rHilightLabel;
@property (weak, nonatomic) IBOutlet UILabel *favHilightLabel;
@property (weak, nonatomic) IBOutlet UILabel *fedHilightLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonImageHorizontalSpace;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (assign, nonatomic) NSInteger timer;
@property (assign, nonatomic) NSTimer *loopTimer;
@property (weak, nonatomic) IBOutlet UIImageView *feedBackImage;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteImage;
@property (weak, nonatomic) IBOutlet UIView *fullscreenView;
@property (weak, nonatomic) IBOutlet UILabel *favoriteThisLabel;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;
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
@property (weak, nonatomic) IBOutlet UIImageView *reminderIcon;
@property (nonatomic, retain) MRNotifications *notification;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (weak, nonatomic) IBOutlet UIView *imageContentView;

@property (weak, nonatomic) IBOutlet UIView *fullScreenContentView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullScreenImageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullScreenImageViewWidth;
@property (weak, nonatomic) IBOutlet UIImageView *fullScreenNotificationImage;
@property (weak, nonatomic) IBOutlet UIScrollView *fullScreenScrollView;
@property (weak, nonatomic) IBOutlet UILabel *contentTitleLabel;

@end

@implementation MRNotificationInsiderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.contentScrollView setZoomScale:1.0];
    [self.contentScrollView setMinimumZoomScale:0.5];
    [self.contentScrollView setMaximumZoomScale:5.0];
    
    [self.fullScreenScrollView setZoomScale:1.0];
    [self.fullScreenScrollView setMinimumZoomScale:0.5];
    [self.fullScreenScrollView setMaximumZoomScale:5.0];


    self.noticationImages = [[NSMutableDictionary alloc] init];
    
    self.timer = 5;
    self.timerLabel.text = [NSString stringWithFormat:@"00:%02ld",(long)self.timer];
    self.favoriteThisLabel.textColor = [UIColor blackColor];
    self.feedbackLabel.textColor = [UIColor blackColor];
    
    self.rating = 0.0;
    self.patientRecomended = NO;
    self.doctorRecomended = NO;
    self.favourite = NO;
    [self addSwipeGesture];
    [self resetSelection];
    self.rHilightLabel.backgroundColor = kRGBCOLOR(22, 107, 170);
    revealController = [self revealViewController];
    revealController.delegate = self;
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    self.favoriteImage.image = [UIImage imageNamed:@"favorite.png"];
    self.feedBackImage.image = [UIImage imageNamed:@"feedback.png"];
    self.reminderIcon.image = [UIImage imageNamed:@"reminder.png"];
    
    NSArray *notificationTypeList = [[MRDataManger sharedManager] fetchObjectList:kNotificationsEntity predicate:[NSPredicate predicateWithFormat:@"notificationId == %@", [self.notificationDetails objectForKey:@"notificationId"]]];
    
    self.notification = notificationTypeList.firstObject;
    
    if ([self.notification.feedback boolValue])
    {
        self.feedBackImage.image = [UIImage imageNamed:@"feedbackSelected.png"];
    }
    
    if ([self.notification.favNotification boolValue])
    {
        self.favoriteImage.image = [UIImage imageNamed:@"favoriteSelected.png"];
    }
    
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    self.selectedNotification = [[MRAppControl sharedHelper] getNotificationByID:[[self.notificationDetails objectForKey:@"notificationId"] integerValue]];
    
    [MRDatabaseHelper updateNotifiction:[self.notificationDetails objectForKey:@"notificationId"] userFavouriteSatus:NO userReadStatus:YES withSavedStatus:^(BOOL isScuccess) {
        
    }];

    if (self.selectedNotification)
    {
        self.contentHeaderLabel.text = [self.selectedNotification objectForKey:@"notificationDesc"];
        self.contentTextView.text = [self.notificationDetails objectForKey:@"detailDesc"];
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
    [MRCommon getNotificationImageByID:[[[self.detailsList objectAtIndex:self.imagesCount] objectForKey:@"detailId"] integerValue] forImage:^(UIImage *image)
     {
         if (image)
         {
             [self.noticationImages setObject:image forKey:[[self.detailsList objectAtIndex:self.imagesCount] objectForKey:@"detailId"]];
             NSLog(@"%@",NSStringFromCGRect(self.contentScrollView.frame));
             self.contentViewHeight.constant = self.contentScrollView.frame.size.height + 130;
             self.contentViewWidth.constant =  self.contentScrollView.frame.size.width;
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
             self.notifcationImage.image = [UIImage imageNamed:@""];
             self.fullScreenNotificationImage.image = image;
         }
     }];
}

- (void)updateNotification:(NSNumber*)imageId
{
    UIImage *image = [self.noticationImages objectForKey:imageId];
    self.fullScreenNotificationImage.image = image;
    self.notifcationImage.image = image;
    self.contentTitleLabel.text = [[self.detailsList objectAtIndex:self.currentImageIndex] objectForKey:@"detailTitle"];
    self.contentHeaderLabel.text = [[self.detailsList objectAtIndex:self.currentImageIndex] objectForKey:@"detailDesc"];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView.tag == 2000)
    {
        return self.fullScreenNotificationImage;
    }
    
    return nil;
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
    if (!self.isFullScreen)
    {
        [self updateNotification];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self hideFullScreen];
    }
}

- (IBAction)fullScreenButtonAction:(id)sender
{
   if ( self.noticationImages.count == 0 )return;
    
    if (self.isFullScreen)
    {
        [self hideFullScreen];
    }
    else
    {
        [self showFullScreen];
    }
}

- (void)resetSelection
{
    self.rHilightLabel.backgroundColor = [UIColor clearColor];
    self.favHilightLabel.backgroundColor = [UIColor clearColor];
    self.fedHilightLabel.backgroundColor = [UIColor clearColor];
}

- (IBAction)downloadButtonAction:(id)sender
{
    viewController = [[MPNotificationAlertViewController alloc] initWithNibName:@"MPNotificationAlertViewController" bundle:nil];
    [self.view addSubview:viewController.view];
    
    [MRCommon addUpdateConstarintsTo:self.view withChildView:viewController.view];
    
    [viewController configureAlertWithAlertType:MRAlertTypeMessage withMessage:KDownloadConfirmationMSG withTitle:@"DOWNLOAD" withOKButtonAction:^(MPNotificationAlertViewController *alertView)
     {
         alertView.view.alpha = 1.0f;
         [UIView animateWithDuration:0.4
                               delay:0.0
                             options: UIViewAnimationOptionCurveEaseInOut
                          animations:^{
                              alertView.view.alpha = 0.0f;
                          } completion:^(BOOL finished) {
                              [alertView.view removeFromSuperview];
                              [alertView removeFromParentViewController];
                          }];
         
     } withCancelButtonAction:^(MPNotificationAlertViewController *alertView){
         alertView.view.alpha = 1.0f;
         [UIView animateWithDuration:0.4
                               delay:0.0
                             options: UIViewAnimationOptionCurveEaseInOut
                          animations:^{
                              alertView.view.alpha = 0.0f;
                          } completion:^(BOOL finished) {
                              [alertView.view removeFromSuperview];
                              [alertView removeFromParentViewController];
                          }];
     }];
    
    viewController.view.alpha = 0.0f;
    [UIView animateWithDuration:0.25f animations:^{
        viewController.view.alpha = 1.0f;
    }];
}

- (IBAction)callMedrepButtonAction:(id)sender
{
    NSMutableDictionary *notificationdict = [[NSMutableDictionary alloc] init];

    [notificationdict setObject:[self.notificationDetails objectForKey:@"notificationId"] forKey:@"notificationId"];
    [notificationdict setObject:@"Viewed"  forKey:@"viewStatus"];
    if (self.favourite == YES)
    {
        NSString *fav = @"Y";
        [notificationdict setObject:fav  forKey:@"favourite"];
    }
//
//    [notificationdict setObject:[NSNumber numberWithFloat:self.rating]  forKey:@"rating"];
//     fav = (self.patientRecomended == YES) ? @"Y" : @"N";
//    [notificationdict setObject:fav  forKey:@"prescribe"];
    
//    fav = (self.doctorRecomended == YES) ? @"Y" : @"N";
//    [notificationdict setObject:fav  forKey:@"recomend"];
    [notificationdict setObject:[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMddHHmmss"]  forKey:@"viewedOn"];
    [notificationdict setObject:[self.notificationDetails objectForKey:@"notificationId"]  forKey:@"userNotificationId"];
    [MRCommon showActivityIndicator:@"Sending..."];
    [[MRWebserviceHelper sharedWebServiceHelper] updateNotification:notificationdict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            [MRCommon stopActivityIndicator];
            [self loadCallMedrep];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon stopActivityIndicator];
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] updateNotification:notificationdict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     
                     if (status)
                     {
                         [self loadCallMedrep];
                     }
                 }];
             }];
        }
        else
        {
            [self loadCallMedrep];
        }
        
    }];
}

- (void)loadCallMedrep
{
    MPCallMedrepViewController *callMedrep = [[MPCallMedrepViewController alloc] initWithNibName:[MRCommon deviceHasThreePointFiveInchScreen] ? @"MPCallMedrepViewController_iPhone" : @"MPCallMedrepViewController" bundle:nil];
    callMedrep.isFromReschedule = NO;
    callMedrep.selectedNotification = self.selectedNotification;
    callMedrep.notificationDetails = self.notificationDetails;
    [self.navigationController pushViewController:callMedrep animated:YES];
}

- (IBAction)remindMeButtonAction:(id)sender
{
    [self resetSelection];
    self.rHilightLabel.hidden = NO;
    self.rHilightLabel.backgroundColor = kRGBCOLOR(22, 107, 170);

    viewController = [[MPNotificationAlertViewController alloc] initWithNibName:@"MPNotificationAlertViewController" bundle:nil];
    [self.view addSubview:viewController.view];
    
    [MRCommon addUpdateConstarintsTo:self.view withChildView:viewController.view];
    [viewController configureAlertWithAlertType:MRAlertTypeOptions withMessage:KDownloadConfirmationMSG withTitle:@"DOWNLOAD" withOKButtonAction:^(MPNotificationAlertViewController *alertView)
     {
         alertView.view.alpha = 1.0f;
         [self configureLocalNotification:alertView.locatlNotificationType];
         [UIView animateWithDuration:0.4
                               delay:0.0
                             options: UIViewAnimationOptionCurveEaseInOut
                          animations:^{
                              alertView.view.alpha = 0.0f;
                          } completion:^(BOOL finished) {
                              [alertView.view removeFromSuperview];
                              [alertView removeFromParentViewController];
                          }];
         
     } withCancelButtonAction:^(MPNotificationAlertViewController *alertView){
         alertView.view.alpha = 1.0f;
         self.reminderIcon.image = [UIImage imageNamed:@"reminder.png"];
         [UIView animateWithDuration:0.4
                               delay:0.0
                             options: UIViewAnimationOptionCurveEaseInOut
                          animations:^{
                              alertView.view.alpha = 0.0f;
                          } completion:^(BOOL finished) {
                              [alertView.view removeFromSuperview];
                              [alertView removeFromParentViewController];
                          }];
     }];
    
    viewController.view.alpha = 0.0f;
    [UIView animateWithDuration:0.25f animations:^{
        viewController.view.alpha = 1.0f;
    }];
}

- (void)configureLocalNotification:(NSInteger)notificationType
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    
    switch (notificationType) {
        case 1:
            localNotif.fireDate = [NSDate dateTomorrow];
            break;
        case 2:
            localNotif.fireDate = [NSDate nextWeek];
            break;
        case 3:
            localNotif.fireDate = [NSDate nextMonh];
            break;
     
        default:
            break;
    }
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = @"scdeule remider"; // add notification discription
    localNotif.alertAction = @"View";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    
    localNotif.applicationIconBadgeNumber = 1;
    localNotif.repeatInterval = 0;
    self.reminderIcon.image = [UIImage imageNamed:@"reminderSelected.png"];

    // this is for addectra info
    localNotif.userInfo = self.notificationDetails;
    
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}
- (IBAction)favoriteThisButtonAction:(id)sender
{
    //Selected
    [self resetSelection];
    self.favourite = YES;
    self.favoriteImage.image = [UIImage imageNamed:@"favoriteSelected.png"];
    self.favHilightLabel.backgroundColor = kRGBCOLOR(22, 107, 170);
    //self.favoriteThisLabel.textColor = [UIColor yellowColor];
    
    [MRDatabaseHelper updateNotifiction:[self.notificationDetails objectForKey:@"notificationId"] userFavouriteSatus:YES userReadStatus:YES withSavedStatus:^(BOOL isScuccess) {
        
    }];


}

- (void)submitFeedBack
{
    NSMutableDictionary *notificationdict = [[NSMutableDictionary alloc] init];
    
    [notificationdict setObject:[self.notificationDetails objectForKey:@"notificationId"] forKey:@"notificationId"];
    [notificationdict setObject:@"Viewed"  forKey:@"viewStatus"];
    NSString *fav = (self.favourite == YES) ? @"Y" : @"N";
    [notificationdict setObject:fav  forKey:@"favourite"];
    
    [notificationdict setObject:[NSNumber numberWithFloat:self.rating]  forKey:@"rating"];
    
    fav = (self.patientRecomended == YES) ? @"Y" : @"N";
    [notificationdict setObject:fav  forKey:@"prescribe"];
    fav = (self.doctorRecomended == YES) ? @"Y" : @"N";
    [notificationdict setObject:fav  forKey:@"recomend"];
    
    [notificationdict setObject:[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMddHHmmss"]  forKey:@"viewedOn"];
    
    [notificationdict setObject:[self.notificationDetails objectForKey:@"notificationId"]  forKey:@"userNotificationId"];
    
    [MRCommon showActivityIndicator:@"Sending..."];
    [[MRWebserviceHelper sharedWebServiceHelper] updateNotification:notificationdict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            [MRCommon stopActivityIndicator];
            [MRCommon showAlert:@"Feedback submitted successfully." delegate:nil];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce){
                 [MRCommon stopActivityIndicator];
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] updateNotification:notificationdict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                     if (status)
                     {
                         [MRCommon showAlert:@"Feedback submitted successfully." delegate:nil];
                     }
                 }];
             }];
        }
        else
        {
            [MRCommon stopActivityIndicator];
            [MRCommon showAlert:@"Faild to submitted the feedback." delegate:nil];
        }
    }];
}


- (void)updateNotification
{
    NSMutableDictionary *notificationdict = [[NSMutableDictionary alloc] init];
    
    [notificationdict setObject:[self.notificationDetails objectForKey:@"notificationId"] forKey:@"notificationId"];
    [notificationdict setObject:@"Viewed"  forKey:@"viewStatus"];
    
    if (self.favourite == YES)
    {
            NSString *fav = @"Y";
            [notificationdict setObject:fav  forKey:@"favourite"];
    }
    
    //[notificationdict setObject:[NSNumber numberWithFloat:self.rating]  forKey:@"rating"];
    
//    fav = @"";
//    [notificationdict setObject:fav  forKey:@"prescribe"];
//    fav = @"";
//    [notificationdict setObject:fav  forKey:@"recomend"];
    
    [notificationdict setObject:[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMddHHmmss"]  forKey:@"viewedOn"];
    
    [notificationdict setObject:[self.notificationDetails objectForKey:@"notificationId"]  forKey:@"userNotificationId"];
    
    [[MRWebserviceHelper sharedWebServiceHelper] updateNotification:notificationdict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce){
                [MRCommon stopActivityIndicator];
                [MRCommon savetokens:responce];
                [[MRWebserviceHelper sharedWebServiceHelper] updateNotification:notificationdict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                    if (status)
                    {
                    }
                }];
            }];
        }
        else
        {
            [MRCommon stopActivityIndicator];
            [MRCommon showAlert:@"Faild to update the notification." delegate:nil];
        }
    }];
}

- (IBAction)feedbackButtonAction:(id)sender
{
    if ([self.notification.feedback boolValue])
    {
        [MRCommon showConformationOKNoAlert:@"Feedback for this notifications is already submitted. Do you want give feedback again?" delegate:self withTag:999888];
    }
    else
    {
        [self sendfeedback];
    }
}

- (void)sendfeedback
{
    [self resetSelection];
    self.fedHilightLabel.backgroundColor = kRGBCOLOR(22, 107, 170);
    self.feedBackImage.image = [UIImage imageNamed:@"feedbackSelected.png"];
    //self.favoriteThisLabel.textColor = [UIColor yellowColor];
    
    viewController = [[MPNotificationAlertViewController alloc] initWithNibName:@"MPNotificationAlertViewController" bundle:nil];
    [self.view addSubview:viewController.view];
    
    [MRCommon addUpdateConstarintsTo:self.view withChildView:viewController.view];
    [viewController configureAlertWithAlertType:MRAlertTypeFeedBack withMessage:KDownloadConfirmationMSG withTitle:@"DOWNLOAD" withOKButtonAction:^(MPNotificationAlertViewController *alertView)
     {
         alertView.view.alpha = 1.0f;
         self.rating = alertView.rating;
         self.patientRecomended = alertView.patiantRecomended;
         self.doctorRecomended = alertView.doctorRecomended;
         [self submitFeedBack];
         
         [MRDatabaseHelper updateNotifictionFeedback:[self.notificationDetails objectForKey:@"notificationId"] userFeedback:YES withSavedStatus:^(BOOL isScuccess)
          {
              
          }];
         
         
         [UIView animateWithDuration:0.4
                               delay:0.0
                             options: UIViewAnimationOptionCurveEaseInOut
                          animations:^{
                              alertView.view.alpha = 0.0f;
                          } completion:^(BOOL finished) {
                              [alertView.view removeFromSuperview];
                              [alertView removeFromParentViewController];
                          }];
         
     } withCancelButtonAction:^(MPNotificationAlertViewController *alertView){
         self.feedBackImage.image = [UIImage imageNamed:@"feedback.png"];
         self.feedbackLabel.textColor = [UIColor blackColor];
         
         alertView.view.alpha = 1.0f;
         [UIView animateWithDuration:0.4
                               delay:0.0
                             options: UIViewAnimationOptionCurveEaseInOut
                          animations:^{
                              alertView.view.alpha = 0.0f;
                          } completion:^(BOOL finished) {
                              [alertView.view removeFromSuperview];
                              [alertView removeFromParentViewController];
                          }];
     }];
    
    viewController.view.alpha = 0.0f;
    [UIView animateWithDuration:0.25f animations:^{
        viewController.view.alpha = 1.0f;
    }];
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
    [self updateNotification];
    if (position == FrontViewPositionRight)
    {
        self.view.userInteractionEnabled = NO;
    }
    else if (position == FrontViewPositionLeft)
    {
        self.view.userInteractionEnabled = YES;
    }
}

- (void)showFullScreen
{
    [self.fullScreenScrollView setZoomScale:1.0];
    [self.fullScreenScrollView setMinimumZoomScale:0.5];
    [self.fullScreenScrollView setMaximumZoomScale:5.0];

    self.fullScreenContentView.hidden = NO;
    [self.view bringSubviewToFront:self.fullScreenContentView];
    self.isFullScreen = YES;
    self.contentView.hidden = YES;
    self.footerView.hidden = YES;
    self.drugNamelabel.hidden = YES;
    self.companyNamelabel.hidden = YES;
    self.fullscreenView.hidden = YES;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    self.fullScreenImageViewHeight.constant = self.fullScreenContentView.frame.size.height;
    self.fullScreenImageViewWidth.constant = self.fullScreenContentView.frame.size.width;
    self.titleLabel.text = @"Notification details";
    [self updateViewConstraints];
}

- (void)hideFullScreen
{
    self.fullScreenContentView.hidden = YES;
    [self.view sendSubviewToBack:self.fullScreenContentView];
    self.isFullScreen = NO;
    self.contentView.hidden = NO;
    self.footerView.hidden = NO;
    self.drugNamelabel.hidden = NO;
    self.companyNamelabel.hidden = NO;
    self.fullscreenView.hidden = NO;
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.titleLabel.text = [self.selectedNotification objectForKey:@"companyName"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 999888) {
        [self sendfeedback];
    }
}

@end

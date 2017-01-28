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

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface MRNotificationInsiderViewController ()<UIScrollViewDelegate,UIAlertViewDelegate, UIWebViewDelegate>

@property (nonatomic) AVPlayerViewController *av;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITextView *contentHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *rHilightLabel;
@property (weak, nonatomic) IBOutlet UILabel *favHilightLabel;
@property (weak, nonatomic) IBOutlet UILabel *fedHilightLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property (weak, nonatomic) IBOutlet UILabel *drugNameLabel;

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (strong, nonatomic) IBOutlet UIView *navViewExitFullScreen;

@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonImageHorizontalSpace;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (assign, nonatomic) NSInteger timer;
@property (assign, nonatomic) NSTimer *loopTimer;
@property (weak, nonatomic) IBOutlet UIImageView *feedBackImage;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteImage;
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
@property (nonatomic) NSDictionary *notificationDetails;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (weak, nonatomic) IBOutlet UIView *imageContentView;

@property (weak, nonatomic) IBOutlet UIView *fullScreenContentView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullScreenImageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullScreenImageViewWidth;
//@property (weak, nonatomic) IBOutlet UIImageView *fullScreenNotificationImage;
//@property (weak, nonatomic) IBOutlet UIImageView *notifcationImage;

@property (weak, nonatomic) IBOutlet UIWebView *notifcationImage;
@property (weak, nonatomic) IBOutlet UIWebView *fullScreenNotificationImage;

@property (weak, nonatomic) IBOutlet UIScrollView *fullScreenScrollView;
@property (weak, nonatomic) IBOutlet UILabel *contentTitleLabel;

@property (nonatomic, strong) NSString *remindMeValue;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeaderLabelHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTitleHeightConstraint;

@end

@implementation MRNotificationInsiderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.remindMeValue = @"";
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UITapGestureRecognizer *recoginzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenButtonAction:)];
    [recoginzer setNumberOfTapsRequired:1];
    [self.navView addGestureRecognizer:recoginzer];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
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
    
    self.favoriteImage.image = [UIImage imageNamed:@"favorite.png"];
    self.feedBackImage.image = [UIImage imageNamed:@"feedback.png"];
    self.reminderIcon.image = [UIImage imageNamed:@"reminder.png"];
    
    NSArray *notificationTypeList = [[MRDataManger sharedManager] fetchObjectList:kNotificationsEntity predicate:[NSPredicate predicateWithFormat:@"notificationId == %ld", self.notificationId.integerValue]];
    
    self.notification = notificationTypeList.firstObject;
    
    if ([self.notification.feedback boolValue])
    {
        self.feedBackImage.image = [UIImage imageNamed:@"feedbackSelected.png"];
    }
    
    if ([self.notification.favourite boolValue])
    {
        self.favoriteImage.image = [UIImage imageNamed:@"favoriteSelected.png"];
    }
    
    self.notificationDetails = [self.notification getNotificationDetails];
    
    if (self.notificationDetails)
    {
        self.drugNameLabel.text = [NSString stringWithFormat:@"\t%@",[self.notificationDetails objectForKey:@"detailTitle"]];
        
        self.navigationItem.title = self.notification.notificationName;
        [MRCommon showActivityIndicator:@"Loading..."];
        self.detailsList = @[self.notificationDetails];
        [self adjustHeightsWithContent];
        [self loadImages];
    }
    self.loopTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];
    
    self.imagesCount = 0;
    
    [self.notifcationImage setAllowsInlineMediaPlayback:YES];
    self.notifcationImage.mediaPlaybackRequiresUserAction = YES;
    
    [self.fullScreenNotificationImage setAllowsInlineMediaPlayback:YES];
    self.fullScreenNotificationImage.mediaPlaybackRequiresUserAction = YES;
    
    // Do any additional setup after loading the view from its nib.
    [self.notifcationImage setDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.av.player pause];
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
    NSDictionary *firstDetailObject = self.detailsList.firstObject;
    [MRCommon getNotificationImageByID:[[firstDetailObject objectForKey:@"detailId"] integerValue]
                              forImage:^(NSString *image)
     {
         if (image)
         {
             id value = [firstDetailObject objectForKey:@"detailId"];
             if (value != nil) {
                 NSNumber *tempValue = (NSNumber*)value;
                 [self.noticationImages setObject:image forKey:[NSString stringWithFormat:@"%ld",(long)tempValue.integerValue]];
                 
                 self.contentViewHeight.constant = self.contentScrollView.frame.size.height + 130;
                 self.contentViewWidth.constant =  self.contentScrollView.frame.size.width;
                 [self updateViewConstraints];
              
                 [self updateNotification:[firstDetailObject objectForKey:@"detailId"] andContentType:[firstDetailObject objectForKey:@"contentType"]];
             }
         }
         else
         {
             [MRCommon stopActivityIndicator];
//             self.notifcationImage.image = [UIImage imageNamed:@""];
//             self.fullScreenNotificationImage.image = image;
         }
     }];
}
    
- (BOOL)shouldLaunchAVPlayer:(NSString*)contentType {
    BOOL status = NO;
    
    if(contentType != nil &&
       ([contentType caseInsensitiveCompare:@"MP4"] == NSOrderedSame ||
        [contentType caseInsensitiveCompare:@"WMV"] == NSOrderedSame ||
        [contentType caseInsensitiveCompare:@"MP3"] == NSOrderedSame ||
        [contentType caseInsensitiveCompare:@"3GP"] == NSOrderedSame)) {
           status = NO;
       }
    
    return status;
}

- (void)updateNotification:(NSNumber*)imageId andContentType:(NSString*)contentType
{
    if (imageId != nil) {
        NSString *key = [NSString stringWithFormat:@"%ld",(long)imageId.integerValue];
        NSString *image = [self.noticationImages objectForKey:key];
        
        if ([self shouldLaunchAVPlayer:contentType]) {
            [self.notifcationImage setHidden:YES];
            
            self.av = [[AVPlayerViewController alloc] init];
            
            self.av.view.frame = self.notifcationImage.frame;
//            [self.av setShowsPlaybackControls:NO];
            
            AVPlayer *avPlayer = [AVPlayer playerWithURL:[NSURL URLWithString:image]];
            self.av.player = avPlayer;
            [avPlayer seekToTime:kCMTimeZero];
            [avPlayer pause];
            
            [self addChildViewController:self.av];
            [self.view addSubview:self.av.view];
            [self.av.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
            [self.av didMoveToParentViewController:self];
            [self.av.contentOverlayView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
            
        } else {
            [self.notifcationImage setHidden:NO];
            [self.notifcationImage loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:image]]];
        }
//        self.fullScreenNotificationImage.image = image;
//        self.notifcationImage.image = image;
    }
}

- (void)adjustHeightsWithContent {
    
    NSString *text = [[self.detailsList objectAtIndex:self.currentImageIndex] objectForKey:@"detailDesc"];
    
    if (text != nil && text.length > 0) {
        self.contentHeaderLabel.text = text;
        
        NSAttributedString *attributedText =
            [[NSAttributedString alloc] initWithString:self.contentHeaderLabel.text
                                        attributes:@{NSFontAttributeName: self.contentHeaderLabel.font}];
        
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){self.contentHeaderLabel.frame.size.width, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        
        CGFloat labelHeight = rect.size.height;
        
        if (labelHeight > 72) {
            labelHeight = 72;
        }
        
        self.contentHeaderLabelHeightConstraint.constant = labelHeight;
    }
    
    NSString *contentTitle = [[self.detailsList objectAtIndex:self.currentImageIndex] objectForKey:@"detailTitle"];
    
    if (contentTitle != nil && contentTitle.length > 0) {
        self.contentTitleLabel.text = contentTitle;
        
        NSAttributedString *contentTitleAttributedText =
                [[NSAttributedString alloc] initWithString:contentTitle
                                        attributes:@{NSFontAttributeName: self.contentTitleLabel.font}];
        
        CGRect contentTitleRect = [contentTitleAttributedText boundingRectWithSize:(CGSize){self.contentTitleLabel.frame.size.width, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        
        CGFloat contentTitleLabelHeight = contentTitleRect.size.height;
        
        if (contentTitleLabelHeight > 72) {
            contentTitleLabelHeight = 72;
        }
        
        self.contentTitleHeightConstraint.constant = contentTitleLabelHeight;
    }
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
        [self.av.player removeObserver:self forKeyPath:@"status" context:NULL];
        [self.av.contentOverlayView removeObserver:self forKeyPath:@"bounds" context:NULL];
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
    callMedrep.notificationDetails = [self.notification toDictionary];
    [self.navigationController pushViewController:callMedrep animated:YES];
}

- (IBAction)remindMeButtonAction:(id)sender
{
    [self resetSelection];
    self.rHilightLabel.hidden = NO;
    self.rHilightLabel.backgroundColor = kRGBCOLOR(22, 107, 170);

    viewController = [[MPNotificationAlertViewController alloc] initWithNibName:@"MPNotificationAlertViewController" bundle:nil];
    
    viewController.locatlNotificationType = [self reverseLocalNotification:self.remindMeValue];
    
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

- (NSInteger)reverseLocalNotification:(NSString*)remindMeValue
{
    NSInteger notificationType = 2;
    
    if (remindMeValue != nil && remindMeValue.length > 0) {
        if ([remindMeValue caseInsensitiveCompare:@"1h"] == NSOrderedSame) {
            notificationType = 1;
        } else if ([remindMeValue caseInsensitiveCompare:@"1w"] == NSOrderedSame) {
            notificationType = 3;
        } else if ([remindMeValue caseInsensitiveCompare:@"1m"] == NSOrderedSame) {
            notificationType = 4;
        }
    }
    
    return notificationType;
}

- (void)configureLocalNotification:(NSInteger)notificationType
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    
    switch (notificationType) {
        case 1:
            self.remindMeValue = @"1h";
            localNotif.fireDate = [NSDate dateWithHoursFromNow:1];
            break;
        case 2:
            self.remindMeValue = @"1d";
            localNotif.fireDate = [NSDate dateTomorrow];
            break;
        case 3:
            self.remindMeValue = @"1w";
            localNotif.fireDate = [NSDate nextWeek];
            break;
        case 4:
            self.remindMeValue = @"1m";
            localNotif.fireDate = [NSDate nextMonh];
            break;
     
        default:
            self.remindMeValue = @"";
            break;
    }
    localNotif.fireDate = [NSDate dateWithMinutesFromNow:notificationType];
    
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = [NSString stringWithFormat:@"Reminder: %@ - %@", self.notification.companyName, [self.notificationDetails objectOrNilForKey:@"detailTitle"]]; // add notification discription
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
    
    [notificationdict setObject:[NSNumber numberWithBool:self.favourite] forKey:@"favourite"];
    
    [notificationdict setObject:[NSNumber numberWithFloat:self.rating]  forKey:@"rating"];
    
    fav = (self.patientRecomended == YES) ? @"Y" : @"N";
    [notificationdict setObject:fav  forKey:@"prescribe"];
    fav = (self.doctorRecomended == YES) ? @"Y" : @"N";
    [notificationdict setObject:fav  forKey:@"recomend"];
    
    [notificationdict setObject:[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMddHHmmss"]  forKey:@"viewedOn"];
    
    [notificationdict setObject:[self.notificationDetails objectForKey:@"notificationId"]  forKey:@"userNotificationId"];
    [notificationdict setObject:[self.notificationDetails objectForKey:@"notificationId"]  forKey:@"notificationId"];
    
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
    
    [notificationdict setObject:[self.notificationDetails objectOrNilForKey:@"notificationId"] forKey:@"notificationId"];
    [notificationdict setObject:@"Viewed"  forKey:@"viewStatus"];
    
    [notificationdict setObject:[NSNumber numberWithBool:self.favourite] forKey:@"favourite"];
    
    if (self.remindMeValue != nil && self.remindMeValue.length > 0) {
        [notificationdict setObject:self.remindMeValue forKey:@"remindMe"];
    }
    
    NSNumber *loggedInDoctorId = [MRAppControl sharedHelper].userRegData[@"doctorId"];
    if (loggedInDoctorId != nil) {
        [notificationdict setObject:loggedInDoctorId forKey:@"doctorId"];
    }
    
    [notificationdict setObject:[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMddHHmmss"]  forKey:@"viewedOn"];
    
    [notificationdict setObject:[self.notificationDetails objectForKey:@"notificationId"]  forKey:@"userNotificationId"];
    
    [[MRWebserviceHelper sharedWebServiceHelper] updateNotification:notificationdict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
        if (status)
        {
            [self updateNotificationInStorage:notificationdict];
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce){
                [MRCommon stopActivityIndicator];
                [MRCommon savetokens:responce];
                [[MRWebserviceHelper sharedWebServiceHelper] updateNotification:notificationdict withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                    if (status)
                    {
                        [self updateNotificationInStorage:notificationdict];
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

- (void)updateNotificationInStorage:(NSDictionary*)notification {
   MRNotifications *currentNotification = [[MRDataManger sharedManager] fetchObject:kNotificationsEntity
                                    predicate:[NSPredicate predicateWithFormat:@"notificationId == %@", [notification objectOrNilForKey:@"notificationId"]]];
    
    currentNotification.viewStatus = [notification objectOrNilForKey:@"viewStatus"];
    currentNotification.favourite = [NSNumber numberWithBool:self.favourite];
    
    [currentNotification.managedObjectContext save:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshNotificationsDetails
                                                        object:nil];
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
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)leftButtonAction:(id)sender
{
    if (self.currentImageIndex == self.detailsList.count -1)
    {
        self.currentImageIndex = -1;
    }
    
    self.currentImageIndex++;
//    [self updateNotification:[[self.detailsList objectAtIndex:self.currentImageIndex] objectForKey:@"detailId"]];
}

- (IBAction)rightButtonAction:(id)sender
{
    if (self.currentImageIndex == 0)
    {
        self.currentImageIndex = self.detailsList.count;
    }
    self.currentImageIndex--;
//    [self updateNotification:[[self.detailsList objectAtIndex:self.currentImageIndex] objectForKey:@"detailId"]];

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
    NSDictionary *currentNotificationDetails = [self.detailsList objectAtIndex:self.currentImageIndex];
    NSNumber *imageId = [currentNotificationDetails objectForKey:@"detailId"];
    if (imageId != nil) {
        NSString *key = [NSString stringWithFormat:@"%ld",(long)imageId.integerValue];
        NSString *image = [self.noticationImages objectForKey:key];
        
        [self.fullScreenNotificationImage loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:image]]];
    }
    
    UITapGestureRecognizer *recoginzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenButtonAction:)];
    [recoginzer setNumberOfTapsRequired:1];
    [self.navViewExitFullScreen addGestureRecognizer:recoginzer];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navViewExitFullScreen];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self.fullScreenScrollView setZoomScale:1.0];
    [self.fullScreenScrollView setMinimumZoomScale:0.5];
    [self.fullScreenScrollView setMaximumZoomScale:5.0];

    self.fullScreenContentView.hidden = NO;
    [self.view bringSubviewToFront:self.fullScreenContentView];
    self.isFullScreen = YES;
    self.contentView.hidden = YES;
    self.footerView.hidden = YES;
    self.drugNameLabel.hidden = YES;
    self.navigationItem.hidesBackButton = YES;
    self.fullScreenImageViewHeight.constant = self.fullScreenContentView.frame.size.height;
    self.fullScreenImageViewWidth.constant = self.fullScreenContentView.frame.size.width;
    [self updateViewConstraints];
    
    NSString *contentType = [self.notificationDetails objectOrNilForKey:@"contentType"];
    if ([self shouldLaunchAVPlayer:contentType]) {
        [self.fullScreenNotificationImage setHidden:YES];
    } else {
        [self.fullScreenNotificationImage setHidden:NO];
    }
}

- (void)hideFullScreen
{
    UITapGestureRecognizer *recoginzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenButtonAction:)];
    [recoginzer setNumberOfTapsRequired:1];
    [self.navView addGestureRecognizer:recoginzer];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    self.fullScreenContentView.hidden = YES;
    [self.view sendSubviewToBack:self.fullScreenContentView];
    self.isFullScreen = NO;
    self.contentView.hidden = NO;
    self.footerView.hidden = NO;
    self.drugNameLabel.hidden = NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 999888) {
        [self sendfeedback];
    }
}

#pragma mark - UIWebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context {
    if (object == self.av.contentOverlayView) {
        if ([keyPath isEqualToString:@"bounds"]) {
            CGRect oldBounds = [change[NSKeyValueChangeOldKey] CGRectValue], newBounds = [change[NSKeyValueChangeNewKey] CGRectValue];
            BOOL wasFullscreen = CGRectEqualToRect(oldBounds, [UIScreen mainScreen].bounds), isFullscreen = CGRectEqualToRect(newBounds, [UIScreen mainScreen].bounds);
            if (isFullscreen && !wasFullscreen) {
                if (CGRectEqualToRect(oldBounds, CGRectMake(0, 0, newBounds.size.height, newBounds.size.width))) {
                    NSLog(@"rotated fullscreen");
                }
                else {
                    NSLog(@"entered fullscreen");
                    [self showFullScreen];
                }
            }
            else if (!isFullscreen && wasFullscreen) {
                NSLog(@"exited fullscreen");
                [self hideFullScreen];
            }
        }
    } else if (object == self.av.player) {
        if ([keyPath isEqualToString:@"status"]) {
            if ([object isKindOfClass:[AVPlayer class]]) {
                AVPlayer *player = (AVPlayer*)object;
                if (player != nil) {
                    AVPlayerItem *playerItem = player.currentItem;
                    NSLog(@"%ld",(long)playerItem.status);
                    [player play];
                }
            }
        }
    }
}

#pragma mark - AVPlayerViewControllerDelegate
- (void)playerViewController:(AVPlayerViewController *)playerViewController failedToStartPictureInPictureWithError:(NSError *)error {
    NSLog(@"%@",error.localizedDescription);
}

- (void)playerViewControllerDidStartPictureInPicture:(AVPlayerViewController *)playerViewController {
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)playerViewControllerWillStartPictureInPicture:(AVPlayerViewController *)playerViewController {
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

@end

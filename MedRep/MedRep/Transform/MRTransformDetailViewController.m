//
//  MRTransformDetailViewController.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRTransformDetailViewController.h"
#import "NotificationWebViewController.h"
#import "MPTransformData.h"
#import "MRShareViewController.h"
#import "AppDelegate.h"
#import "MRDatabaseHelper.h"
#import "MRContact.h"
#import "MRGroupPost.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface MRTransformDetailViewController (){
    AVPlayerViewController *av;
    __weak IBOutlet UIWebView *webView;
    __weak IBOutlet UIImageView *thumbnailImage;
    __weak IBOutlet UIView *separatorView;
    
    __weak IBOutlet UIButton *shareButton;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (strong, nonatomic) IBOutlet UIView *navView;
@end

@implementation MRTransformDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Detail";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    if (self.selectedContent != nil) {
        if (self.selectedContent.title != nil && self.selectedContent.title.length > 0) {
            _titleLbl.text = self.selectedContent.title;
        }
        
        if (self.selectedContent.detailDescription != nil) {
            _detailLbl.text = self.selectedContent.detailDescription;
        }
        
        if ([self.selectedContent.contentType isEqualToString:@"Pdf"]) {
            [thumbnailImage setHidden:YES];
            [separatorView setHidden:YES];
            [_detailLbl setHidden:YES];
            
            [webView setHidden:NO];
            
            NSURL *targetURL = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/104553173/sample.pdf"];
            NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
            [webView loadRequest:request];
        } else if ([self.selectedContent.contentType isEqualToString:@"Video"]) {
            
            [thumbnailImage setHidden:YES];
            [separatorView setHidden:YES];
            [_detailLbl setHidden:YES];
            
            av = [[AVPlayerViewController alloc] init];
            float startY = _titleLbl.frame.origin.y + _titleLbl.frame.size.height + 10;
            av.view.frame = CGRectMake(5, startY,
                                       self.view.frame.size.width - 10,
                                       _shareButton.frame.origin.y - (startY + 10));
            
            AVAsset *avAsset = [AVAsset assetWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/104553173/PK%20Song.mp4"]];
            AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
            AVPlayer *avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
            av.player = avPlayer;
            [avPlayer seekToTime:kCMTimeZero];
            [avPlayer pause];
            
            [self addChildViewController:av];
            [self.view addSubview:av.view];
            [av didMoveToParentViewController:self];
            [av.contentOverlayView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
            
//            [self setAVPlayerConstraints:av.view];

        }else { //if ([self.selectedContent.contentType isEqualToString:@"Image"]) {
            if (self.selectedContent.icon != nil && self.selectedContent.icon.length > 0) {
                _contentImage.image = [UIImage imageNamed:self.selectedContent.icon];
            }
        }
    }
}

- (void)setAVPlayerConstraints:(UIView*)view {
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeading
                                                                     multiplier:1.0 constant:5];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1.0 constant:5];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_shareButton
                                                                        attribute:NSLayoutAttributeTopMargin
                                                                       multiplier:1.0 constant:10];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                        attribute:NSLayoutAttributeTopMargin
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_titleLbl
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0 constant:0.0];
    
    [self.view addConstraints:@[leftConstraint, rightConstraint, bottomConstraint, topConstraint]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [av.contentOverlayView removeObserver:self forKeyPath:@"bounds" context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context {
    if (object == av.contentOverlayView) {
        if ([keyPath isEqualToString:@"bounds"]) {
            CGRect oldBounds = [change[NSKeyValueChangeOldKey] CGRectValue], newBounds = [change[NSKeyValueChangeNewKey] CGRectValue];
            BOOL wasFullscreen = CGRectEqualToRect(oldBounds, [UIScreen mainScreen].bounds), isFullscreen = CGRectEqualToRect(newBounds, [UIScreen mainScreen].bounds);
            if (isFullscreen && !wasFullscreen) {
                if (CGRectEqualToRect(oldBounds, CGRectMake(0, 0, newBounds.size.height, newBounds.size.width))) {
                    NSLog(@"rotated fullscreen");
                }
                else {
                    NSLog(@"entered fullscreen");
                    ((AppDelegate *)[UIApplication sharedApplication].delegate).enabledVideoRotation = YES;
                    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
                    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
                }
            }
            else if (!isFullscreen && wasFullscreen) {
                NSLog(@"exited fullscreen");
                ((AppDelegate *)[UIApplication sharedApplication].delegate).enabledVideoRotation = NO;
                NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
            }
        }
    }
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

- (void)postTheTopicToTheWall {
    NSArray *myContacts = [MRDatabaseHelper getContacts];
    myContacts = [myContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"self.name", @"Chris Martin"]];
    
    MRContact *contact = myContacts.firstObject;
    NSArray *posts = [contact.groupPosts allObjects];
    
    MRGroupPost *lastPost = posts.firstObject;
    NSLog(@"%ld", lastPost.groupPostId);
    
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"groupPostId" ascending:NO];
    posts = [posts sortedArrayUsingDescriptors:@[sort]];
    lastPost = posts.firstObject;
    
    NSLog(@"%ld", lastPost.groupPostId);
    
    NSMutableDictionary *post = [NSMutableDictionary new];
    post[@"id"] = [NSNumber numberWithInteger:lastPost.groupPostId + 1];
    post[@"postText"] = self.selectedContent.detailDescription;
    post[@"contactId"] = [NSNumber numberWithInt:1];
    post[@"comments"] = [NSNumber numberWithInt:0];
    post[@"likes"] = [NSNumber numberWithInt:0];
    post[@"shares"] = [NSNumber numberWithInt:0];
    [MRDatabaseHelper addGroupPosts:@[post]];
}

- (IBAction)shareAction:(UIButton *)sender {
    [self postTheTopicToTheWall];
    
    MRShareViewController* contactsViewCont = [[MRShareViewController alloc] initWithNibName:@"MRShareViewController" bundle:nil];
    contactsViewCont.isFromDetails = YES;
    [self.navigationController pushViewController:contactsViewCont animated:true];
}

- (IBAction)gotoWebAction:(id)sender {
    NotificationWebViewController *notiFicationViewController = [[NotificationWebViewController alloc] initWithNibName:@"NotificationWebViewController" bundle:nil];
    notiFicationViewController.isFromTransform = YES;
    if (self.selectedContent != nil && self.selectedContent.title != nil &&
        self.selectedContent.title.length > 0) {
        notiFicationViewController.headerTitle = self.selectedContent.title;
    }
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}

@end

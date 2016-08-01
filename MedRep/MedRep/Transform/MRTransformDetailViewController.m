//
//  MRTransformDetailViewController.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRTransformDetailViewController.h"
#import "NotificationWebViewController.h"
#import "MRShareViewController.h"
#import "AppDelegate.h"
#import "MRConstants.h"
#import "MRTransformPost.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface MRTransformDetailViewController () <UIWebViewDelegate>{
    AVPlayerViewController *av;
    __weak IBOutlet UIWebView *webView;
    __weak IBOutlet UIImageView *thumbnailImage;
    __weak IBOutlet UIView *separatorView;
    
    __weak IBOutlet UIButton *shareButton;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (strong, nonatomic) IBOutlet UIView *navView;

@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation MRTransformDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Detail";
    //[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    if (self.post != nil) {
        if (self.post.titleDescription != nil && self.post.titleDescription.length > 0) {
            _titleLbl.text = self.post.titleDescription;
        }
        
        if (self.post.detailedDescription != nil) {
            _detailLbl.text = self.post.detailedDescription;
        }
        
        if (self.post.contentType.integerValue == kTransformContentTypePDF) {
            [thumbnailImage setHidden:YES];
            [separatorView setHidden:YES];
            [_detailLbl setHidden:YES];
            
            [webView setDelegate:self];
            [webView setHidden:NO];
            
            NSURL *targetURL = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/104553173/sample.pdf"];
            NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
            [webView loadRequest:request];
        } else if (self.post.contentType.integerValue == kTransformContentTypeVideo) {
            
            [thumbnailImage setHidden:YES];
            [separatorView setHidden:YES];
            [_detailLbl setHidden:YES];
            
            av = [[AVPlayerViewController alloc] init];
            float startY = _titleLbl.frame.origin.y + _titleLbl.frame.size.height + 10;
            av.view.frame = CGRectMake(5, startY,
                                       self.view.frame.size.width - 10,
                                       shareButton.frame.origin.y - (startY + 10));
            
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
            if (self.post.url != nil && self.post.url.length > 0) {
                _contentImage.image = [UIImage imageNamed:self.post.url];
            } else {
                _contentImage.image = [UIImage imageNamed:@"Default"];
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
                                                                           toItem:shareButton
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

- (void)setActivityIndicatorConstriants {
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.0 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.0 constant:0];
    
    [self.view addConstraints:@[leftConstraint, rightConstraint]];
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
    //    NSArray *myContacts = [MRDatabaseHelper getContacts];
    //    myContacts = [myContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"self.name", @"Chris Martin"]];
    //
    //    MRContact *contact = myContacts.firstObject;
    //    NSArray *posts = [contact.groupPosts allObjects];
    //
    //    MRGroupPost *lastPost = posts.firstObject;
    //    NSLog(@"%ld", lastPost.groupPostId.longValue);
    //
    //    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"groupPostId" ascending:NO];
    //    posts = [posts sortedArrayUsingDescriptors:@[sort]];
    //    lastPost = posts.firstObject;
    //    NSLog(@"%ld", lastPost.groupPostId.longValue);
    
    [MRDatabaseHelper shareAnArticle:self.post];
}

- (IBAction)shareAction:(UIButton *)sender {
    //    [self postTheTopicToTheWall];
    [MRDatabaseHelper shareAnArticle:self.post];
    
    MRShareViewController* contactsViewCont = [[MRShareViewController alloc] initWithNibName:@"MRShareViewController" bundle:nil];
    [self.navigationController pushViewController:contactsViewCont animated:true];
}

- (IBAction)gotoWebAction:(id)sender {
    NotificationWebViewController *notiFicationViewController = [[NotificationWebViewController alloc] initWithNibName:@"NotificationWebViewController" bundle:nil];
    notiFicationViewController.isFromTransform = YES;
    if (self.post != nil && self.post.titleDescription != nil &&
        self.post.titleDescription.length > 0) {
        notiFicationViewController.headerTitle = self.post.titleDescription;
    }
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}

//Mark: WebView Delegat methods
- (void)webViewDidStartLoad:(UIWebView *)wView {
    if (self.activityIndicator == nil) {
        CGRect screen = webView.frame;
        self.activityIndicator = [[UIActivityIndicatorView alloc]
                                  initWithFrame:CGRectMake(screen.size.width/2 - 50, screen.size.height/2, 100, 100)];
        [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    }
    
    [self.view addSubview:self.activityIndicator];
    //    [self setActivityIndicatorConstriants];
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self endIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self endIndicator];
}

- (void)endIndicator {
    if (self.activityIndicator != nil) {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
    }
    self.activityIndicator = nil;
}

@end

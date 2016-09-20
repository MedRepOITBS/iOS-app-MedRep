//
//  MRShareDetailViewController.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/4/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRShareDetailViewController.h"
#import "MRShareDetailTableViewCell.h"
#import "MRCommon.h"

#import "MRGroupPost.h"
#import "MRDatabaseHelper.h"
#import "GroupPostChildTableViewCell.h"
#import "MrGroupChildPost.h"
#import "MRAppControl.h"
#import "MRSharePost.h"
#import "MRTransformPost.h"
#import "MRShareOptionsViewController.h"
#import "MRConstants.h"
#import "MRPostedReplies.h"
#import "KLCPopup.h"
#import "CommonBoxView.h"
#import "MRDataManger.h"
#import "NSDate+Utilities.h"
#import "MRDatabaseHelper.h"
#import "MRTransformViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface MRShareDetailViewController () <UITableViewDataSource, UITableViewDelegate, MRShareOptionsSelectionDelegate, UIWebViewDelegate, CommonBoxViewDelegate,
AVPlayerViewControllerDelegate, UIAlertViewDelegate> {
    
    AVPlayerViewController *av;
}

@property (weak, nonatomic) IBOutlet UITextView *detailDescriptionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailDescriptionHeightConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;

@property (weak, nonatomic) IBOutlet UIButton *takeMeToTransformButton;

@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;

@property (weak, nonatomic) IBOutlet UILabel *postedByProfileName;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewHeightConstraint;

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (nonatomic) NSArray *recentActivity;
@property (weak, nonatomic) IBOutlet UILabel *emptyMessage;
@property (weak, nonatomic) IBOutlet UITableView *activitiesTable;

@property (strong,nonatomic)NSDictionary *userdata;
@property (nonatomic) NSInteger userType;
@property (weak, nonatomic) IBOutlet UILabel *postedBY;

@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (weak, nonatomic) IBOutlet UILabel *commentsCount;
@property (weak, nonatomic) IBOutlet UILabel *sharesCount;
@property (weak, nonatomic) IBOutlet UIView *likesView;
@property (weak, nonatomic) IBOutlet UIView *commentsView;
@property (weak, nonatomic) IBOutlet UIView *sharesView;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong,nonatomic) KLCPopup *commentBoxKLCPopView;
@property (strong,nonatomic) CommonBoxView *commentBoxView;

@end

@implementation MRShareDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Detail";
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self.activitiesTable registerNib:[UINib nibWithNibName:@"MRShareDetailTableViewCell"
                               bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MRShareDetailTableViewCell"];

  
    
    self.titleView.text = self.post.titleDescription;
    
    // Initialization code
    UITapGestureRecognizer *likeTapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeButtonTapped:)];
    [self.likesView addGestureRecognizer:likeTapGestureRecognizer];
    
    UITapGestureRecognizer *shareTapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareButtonTapped:)];
    [self.sharesView addGestureRecognizer:shareTapGestureRecognizer];
    
    UITapGestureRecognizer *commentTapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentButtonTapped:)];
    [self.commentsView addGestureRecognizer:commentTapGestureRecognizer];
    
    [self setupUI];
    [self sortRecentActivities];
    _userdata = [MRAppControl sharedHelper].userRegData;
    
    
    _userType = [MRAppControl sharedHelper].userType;

    self.activitiesTable.estimatedRowHeight = 283;
    self.activitiesTable.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MRCommon applyNavigationBarStyling:self.navigationController];
    [self setEmptyMessage];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [av.contentOverlayView removeObserver:self forKeyPath:@"bounds" context:NULL];
}

- (void)setupUI {
    NSString *name = @"No Name";
    if (self.post.sharedByProfileName != nil) {
        name = self.post.sharedByProfileName;
    }
    self.postedByProfileName.text = name;
    
    if (self.post.displayPicture != nil && self.post.displayPicture.length > 0) {
        self.profilePicImageView.image = [UIImage imageNamed:@"person"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
           UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.post.displayPicture]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profilePicImageView.image = image;
            });
        });
    } else {
        self.profilePicImageView.image = [UIImage imageNamed:@"person"];
    }
    
    [self setupPreview];
    [self setCountInLabels];
}

- (void)setLikeImageData {
    NSString *likeImageName = @"Unlike";
    if (self.post.like != nil && self.post.like.boolValue) {
        likeImageName = @"Like";
    }
    
    self.likeImageView.image = [UIImage imageNamed:likeImageName];
    self.likeCount.text = [NSString stringWithFormat:@"%ld",self.post.likesCount.longValue];
}

- (void)setCountInLabels {
    
    [self setLikeImageData];
    
    self.sharesCount.text = [NSString stringWithFormat:@"%ld",self.post.shareCount.longValue];
    self.commentsCount.text = [NSString stringWithFormat:@"%ld",self.post.commentsCount.longValue];
    
    if (self.post.source != nil && self.post.source.length > 0) {
        self.postedBY.text = [NSString stringWithFormat:@"Posted By:%@", self.post.source];
        if (self.post.parentTransformPostId != nil && self.post.parentTransformPostId.longValue > 0) {
            [self.takeMeToTransformButton setHidden:NO];
        }
    } else {
        [self.postedBY setHidden:YES];
    }
    self.titleView.text = self.post.titleDescription;
}

- (void)setupPreview {
    if (self.post.contentType.integerValue == kTransformContentTypePDF) {
        [self.detailDescriptionTextView setHidden:YES];
        [self.previewImageView setHidden:YES];
        
        if (self.post.url != nil && self.post.url.length > 0) {
            [self.webView setDelegate:self];
            [self.webView setHidden:NO];
            
            NSURL *targetURL = [NSURL URLWithString:self.post.url];
            NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
            [self.webView loadRequest:request];
        }
    } else if (self.post.contentType.integerValue == kTransformContentTypeVideo) {
        [self.detailDescriptionTextView setHidden:YES];
        [self setupVideoPlayer];
        
    }else { //if ([self.selectedContent.contentType isEqualToString:@"Image"]) {
        if (self.post.url != nil && self.post.url.length > 0) {
            [self.detailDescriptionTextView setHidden:YES];
            self.webView.hidden = YES;
            self.previewImageView.hidden = NO;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.post.url]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.previewImageView.image = image;
                });
            });
            
            NSLog(@"%@",self.post.url);
        } else {
            self.webView.hidden = YES;
            self.previewImageView.hidden = YES;
            self.previewImageHeightConstraint.constant = 0;
            
            if (self.post.detail_desc != nil && self.post.detail_desc.length > 0) {
                [self.detailDescriptionTextView setHidden:NO];
                self.detailDescriptionHeightConstraint.constant = 140;
                
                [self.detailDescriptionTextView setText:self.post.detail_desc];
            } else {
                [self.detailDescriptionTextView setHidden:YES];
                self.detailDescriptionHeightConstraint.constant = 0;
            }
        }
    }
}

- (void)setupVideoPlayer {
    [self.previewImageView setHidden:YES];
    
    if (self.post.url != nil && self.post.url.length > 0) {
        
        NSLog(@"URL : %@", self.post.url);
        
        av = [[AVPlayerViewController alloc] init];
        
        av.view.frame = CGRectMake(self.previewImageView.frame.origin.x,
                                   self.previewImageView.frame.origin.y,
                                   self.previewImageView.frame.size.width,
                                   self.previewImageView.frame.size.height);
        
        AVPlayer *avPlayer = [AVPlayer playerWithURL:[NSURL URLWithString:self.post.url]];
        av.player = avPlayer;
        [avPlayer seekToTime:kCMTimeZero];
        [avPlayer pause];
        
        [self addChildViewController:av];
        [self.view addSubview:av.view];
        [av didMoveToParentViewController:self];
        [av.contentOverlayView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:av.view
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.view
                                                                          attribute:NSLayoutAttributeLeading
                                                                         multiplier:1.0 constant:10];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:av.view
                                                                           attribute:NSLayoutAttributeTrailing
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.view
                                                                           attribute:NSLayoutAttributeTrailing
                                                                          multiplier:1.0 constant:10];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:av.view
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.previewImageView
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1.0 constant:0];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:av.view
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.titleView
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.0 constant:20];
        
        [self.view addConstraints:@[leftConstraint, rightConstraint, heightConstraint, topConstraint]];
    }
}

- (void)backButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setEmptyMessage {
    if (self.recentActivity != nil && self.recentActivity.count > 0) {
        [self.emptyMessage setHidden:YES];
        [self.activitiesTable setHidden:NO];
        [self.activitiesTable reloadData];
    } else {
        [self.emptyMessage setHidden:NO];
        [self.activitiesTable setHidden:YES];
    }
}

// Table View Data Source & Delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = 44;
    MRPostedReplies *post = [self.recentActivity objectAtIndex:indexPath.row];
    
    if (post.fileUrl != nil && post.fileUrl.length > 0) {
        rowHeight += 146;
    }
    
    NSString *postText = @"Dummy Text";
    if (post.message != nil && post.message.length > 0) {
        postText = post.message;
    } else {
        if (postText == nil || postText.length == 0) {
            MRSharePost *sharePost = nil;
            if (post.parentSharePostId != nil) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"sharePostId", post.parentSharePostId.longValue];
                sharePost = [[MRDataManger sharedManager] fetchObject:kMRSharePost predicate:predicate];
            }
            if (sharePost != nil && sharePost.titleDescription != nil) {
                postText = sharePost.titleDescription;
            }
        }
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 600)];
    [label setNumberOfLines:0];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0]];
    label.text = postText;
    [label sizeToFit];
    
    rowHeight += label.frame.size.height;
    
    rowHeight += 30;
    
    return rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    
    if (self.recentActivity != nil) {
        rows = self.recentActivity.count;
    }
    
    return rows;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    
    if (self.recentActivity != nil && self.recentActivity.count > 0) {
        title = kRecentActivity;
    }
    
    return title;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupPostChildTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"groupChildCell"];
    if (cell == nil) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"GroupPostChildTableViewCell" owner:self options:nil];
        cell = (GroupPostChildTableViewCell *)[arr objectAtIndex:0];
    }
    
    MRPostedReplies *currentReply = [self.recentActivity objectAtIndex:indexPath.row];
    [cell fillCellWithData:currentReply andParentViewController:self];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}


- (void)likeButtonTapped:(UIGestureRecognizer*)gesture {
    NSInteger likeCount = self.post.likesCount.longValue;
    likeCount = likeCount + 1;
    
    MRSharePost *currentPost;
    if (self.post != nil) {
        currentPost = self.post;
    }
    
    BOOL like = true;
    if (currentPost.like != nil && currentPost.like.boolValue) {
        like = false;
    }
    
    [[MRWebserviceHelper sharedWebServiceHelper] updateLikes:3
                                                   likeCount:like
                                                   messageId:currentPost.sharePostId.longValue
                                                 withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                                                     NSInteger likeCount = 0;
                                                     if (currentPost.likesCount != nil) {
                                                         likeCount = currentPost.likesCount.longValue;
                                                     }
                                                     if (like) {
                                                         likeCount++;
                                                     } else {
                                                         likeCount--;
                                                     }
                                                     
                                                     self.post.likesCount = [NSNumber numberWithLong:likeCount];
                                                     self.post.like = [NSNumber numberWithBool:like];
                                                     
                                                     [self.post.managedObjectContext save:nil];
                                                     
                                                     [self setLikeImageData];
                                                 }];
    
}

- (void)shareButtonTapped:(UIGestureRecognizer*)gesture {
    MRShareOptionsViewController *shareOptionsVC = [[MRShareOptionsViewController alloc] initWithNibName:@"MRShareOptionsViewController" bundle:nil];
    [shareOptionsVC setDelegate:self];
    [shareOptionsVC setParentPost:self.post];
    [self.navigationController pushViewController:shareOptionsVC animated:YES];
}

- (void)commentButtonTapped:(UIGestureRecognizer*)gesture {
    [self setupCommentBox];
    [_commentBoxView setData:nil group:nil andSharedPost:self.post];
}

- (void)setupCommentBox {
    _commentBoxKLCPopView = [MRAppControl setupCommentBox:self];
    _commentBoxView = (CommonBoxView*)(_commentBoxKLCPopView.contentView);
}

- (void)commonBoxCancelButtonPressed {
    [_commentBoxKLCPopView dismissPresentingPopup];
}

- (void)commentPosted {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(refetchPost:)]) {
        [self.delegate refetchPost:self.indexPath];
    }
    
    [_commentBoxKLCPopView dismissPresentingPopup];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"sharePostId", self.post.sharePostId.longValue];
    self.post = [[MRDataManger sharedManager] fetchObject:kMRSharePost predicate:predicate];
    
    self.recentActivity = nil;
    if (self.post.postedReplies != nil && self.post.postedReplies.count > 0) {
        self.recentActivity = self.post.postedReplies.allObjects;
    }
    
    [self setCountInLabels];
    [self.activitiesTable reloadData];
}

- (void)commentPostedWithData:(NSString *)message andImageData:(NSData *)imageData
                withSharePost:(MRSharePost *)sharePost {
    [_commentBoxKLCPopView dismissPresentingPopup];
    
    NSString *messageType = @"Text";
    
    if (imageData != nil) {
        messageType = @"image";
    }
    
    NSMutableDictionary *postMessage = [NSMutableDictionary new];
    [postMessage setObject:[NSNumber numberWithInteger:4] forKey:@"postType"];
    [postMessage setObject:messageType forKey:@"message_type"];
    [postMessage setObject:message forKey:@"message"];
    
    if (imageData != nil) {
        [postMessage setObject:[MRAppControl getFileName] forKey:@"fileName"];
        
        NSString *jsonData = [imageData base64EncodedStringWithOptions:0];
        [postMessage setObject:jsonData forKey:@"fileData"];
    }
    
//    NSDictionary *dataDict = @{@"detail_desc" : message,
//                               @"title_desc" : @"",
//                               @"short_desc" : @"",
//                               @"topic_id" : [NSNumber numberWithLong:self.post.sharePostId.longValue],
//                               @"postMessage" : postMessage
//                               };
    
    NSDictionary *dataDict = @{@"topic_id" : [NSNumber numberWithLong:sharePost.sharePostId.longValue],
                               @"postMessage" : postMessage
                               };
    
    [MRDatabaseHelper postANewTopic:dataDict withHandler:^(id result) {
        [MRCommon showAlert:@"Comment posted successfully !!!" delegate:self withTag:1000];
    }];
}

- (void)sortRecentActivities {
    [MRDatabaseHelper fetchShareDetailsById:self.post.sharePostId.longValue
                                withHandler:^(id result) {
                                    self.recentActivity = [NSArray arrayWithArray:self.post.postedReplies.allObjects];
                                    
                                    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"postedOn" ascending:false];
                                    NSSortDescriptor *sortNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"message" ascending:true];
                                    self.recentActivity = [self.recentActivity sortedArrayUsingDescriptors:@[sortDescriptor, sortNameDescriptor]];
                                    
                                    [self setEmptyMessage];
                                    [self setCountInLabels];
                                }];
    
}

- (void)shareToSelected {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(refetchPost:)]) {
        [self.delegate refetchPost:self.indexPath];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"sharePostId", self.post.sharePostId.longValue];
    self.post = [[MRDataManger sharedManager] fetchObject:kMRSharePost predicate:predicate];
    [self sortRecentActivities];
    [self setCountInLabels];
    [self.activitiesTable reloadData];
}

//Mark: WebView Delegat methods
- (void)webViewDidStartLoad:(UIWebView *)wView {
    if (self.activityIndicator == nil) {
        CGRect screen = self.webView.frame;
        self.activityIndicator = [[UIActivityIndicatorView alloc]
                                  initWithFrame:CGRectMake(screen.size.width/2 - 50,
                                                           self.previewImageView.frame.size.height/2, 100, 100)];
        [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    }
    
    [self.view addSubview:self.activityIndicator];
    //    [self setActivityIndicatorConstriants];
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

-(void)commonBoxCameraGalleryButtonTapped{
    
    [self takePhoto:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)commonBoxCameraButtonTapped {
    [self takePhoto:UIImagePickerControllerSourceTypeCamera];
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

#pragma mark
#pragma CAMERA IMAGE CAPTURE

-(void)takePhoto:(UIImagePickerControllerSourceType)type {
    [_commentBoxKLCPopView setHidden:YES];
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = type;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [_commentBoxView setImageForShareImage:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [_commentBoxKLCPopView setHidden:NO];
    
    MRSharePost *sharePost = [_commentBoxView getSelectedPost];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [_commentBoxKLCPopView setHidden:NO];
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger tag = alertView.tag;
    
    if (tag == 1000) {
        [self sortRecentActivities];
    }
}

- (IBAction)takeMeToTransformButtonClicked:(id)sender {
    MRTransformViewController *notiFicationViewController = [[MRTransformViewController alloc] initWithNibName:@"MRTransformViewController" bundle:nil];
    [self.navigationController pushViewController:notiFicationViewController animated:NO];
}

@end

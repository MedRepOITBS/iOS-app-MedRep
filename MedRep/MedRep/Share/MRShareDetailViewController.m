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

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface MRShareDetailViewController () <UITableViewDataSource, UITableViewDelegate, MRShareOptionsSelectionDelegate, UIWebViewDelegate, CommonBoxViewDelegate> {
    
    AVPlayerViewController *av;
}

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

- (void)setupUI {
    [self setupPreview];
    [self setCountInLabels];
}

- (void)setCountInLabels {

    self.sharesCount.text = [NSString stringWithFormat:@"%ld",self.post.shareCount.longValue];
    self.commentsCount.text = [NSString stringWithFormat:@"%ld",self.post.commentsCount.longValue];
    self.likeCount.text = [NSString stringWithFormat:@"%ld",self.post.likesCount.longValue];
    
    self.postedBY.text = [NSString stringWithFormat:@"Posted By:%@", self.post.source];
    self.titleView.text = self.post.titleDescription;
}

- (void)setupPreview {
    if (self.post.contentType.integerValue == kTransformContentTypePDF) {
        [self.previewImageView setHidden:YES];
        
        [self.webView setDelegate:self];
        [self.webView setHidden:NO];
        
        NSURL *targetURL = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/104553173/sample.pdf"];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [self.webView loadRequest:request];
    } else if (self.post.contentType.integerValue == kTransformContentTypeVideo) {
        
        [self.previewImageView setHidden:YES];
        
        av = [[AVPlayerViewController alloc] init];
        av.view.frame = CGRectMake(self.previewImageView.frame.origin.x,
                                   self.previewImageView.frame.origin.y,
                                   self.previewImageView.frame.size.height,
                                   self.previewImageView.frame.size.height);
        
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
            self.previewImageView.image = [UIImage imageNamed:self.post.url];
            NSLog(@"%@",self.post.url);
        }
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
    } else {
        [self.emptyMessage setHidden:NO];
        [self.activitiesTable setHidden:YES];
    }
}

// Table View Data Source & Delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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
    cell.postText.text = currentReply.text;
    cell.profileNameLabel.text = currentReply.postedBy;
    cell.profilePic.image = [MRAppControl getRepliedByProfileImage:currentReply];
    if (currentReply.image !=nil) {
    cell.commentPic.image = [UIImage imageWithData:currentReply.image];    
    }
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    
    return 260;
    
}


- (void)likeButtonTapped:(UIGestureRecognizer*)gesture {
    NSInteger likeCount = self.post.likesCount.longValue;
    likeCount = likeCount + 1;
    self.post.likesCount = [NSNumber numberWithLong:likeCount];
    [self.post.managedObjectContext save:nil];
    
    self.likeCount.text = [NSString stringWithFormat:@"%ld",(long)likeCount];
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
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"commentBox" owner:self options:nil];
    
    _commentBoxView = (CommonBoxView *)[arr objectAtIndex:0];
    [_commentBoxView setDelegate:self];
    _commentBoxKLCPopView = [KLCPopup popupWithContentView:self.commentBoxView];
    [_commentBoxKLCPopView showWithLayout:KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutCenter)];
}

- (void)commonBoxCancelButtonPressed {
    [_commentBoxKLCPopView dismissPresentingPopup];
}

- (void)commentPosted {
    [_commentBoxKLCPopView dismissPresentingPopup];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", @"sharePostId", self.post.sharePostId.longValue];
    self.post = [[MRDataManger sharedManager] fetchObject:kMRSharePost predicate:predicate];
    
    [self setCountInLabels];
    [self.activitiesTable reloadData];
}

- (void)sortRecentActivities {
    self.recentActivity = [NSArray arrayWithArray:self.post.postedReplies.allObjects];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"postedOn" ascending:false];
    self.recentActivity = [self.recentActivity sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (void)shareToSelected {
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
    [_commentBoxKLCPopView dismiss:YES];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = type;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //    self.imageView.image = chosenImage;
    
    
    [_commentBoxView setImageForShareImage:chosenImage];
    MRSharePost *sharePost = [_commentBoxView getSelectedPost];
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [_commentBoxKLCPopView showWithLayout:KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutAboveCenter)];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

@end

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
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface MRTransformDetailViewController ()
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
            _imageHeight.constant = 350;
            
            //https://dl.dropboxusercontent.com/u/104553173/sample.pdf
            UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 60, _contentImage.frame.size.width, 350)];
            NSURL *targetURL = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/104553173/sample.pdf"];
            NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
            [webView loadRequest:request];
            webView.scalesPageToFit=YES;
            [self.view addSubview:webView];
        }else if ([self.selectedContent.contentType isEqualToString:@"Video"]) {
            _imageHeight.constant = 250;
            
            //https://dl.dropboxusercontent.com/u/104553173/PK%20Song.mp4
            AVPlayerViewController *av = [[AVPlayerViewController alloc] init];
            av.view.frame = _contentImage.frame;
            
            AVAsset *avAsset = [AVAsset assetWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/104553173/PK%20Song.mp4"]];
            AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
            AVPlayer *avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
            av.player = avPlayer;
            [avPlayer seekToTime:kCMTimeZero];
            [avPlayer pause];
            
            [self addChildViewController:av];
            [self.view addSubview:av.view];
            [av didMoveToParentViewController:self];
        }else { //if ([self.selectedContent.contentType isEqualToString:@"Image"]) {
            if (self.selectedContent.icon != nil && self.selectedContent.icon.length > 0) {
                _contentImage.image = [UIImage imageNamed:self.selectedContent.icon];
                _imageHeight.constant = 150;
            }
        }
    }
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

- (IBAction)shareAction:(UIButton *)sender {
    MRShareViewController* contactsViewCont = [[MRShareViewController alloc] initWithNibName:@"MRShareViewController" bundle:nil];
    contactsViewCont.isFromDetails = YES;
    [self.navigationController pushViewController:contactsViewCont animated:true];
}

- (IBAction)gotoWebAction:(id)sender {
    NotificationWebViewController *notiFicationViewController = [[NotificationWebViewController alloc] initWithNibName:@"NotificationWebViewController" bundle:nil];
    notiFicationViewController.isFromTransform = YES;
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}

@end

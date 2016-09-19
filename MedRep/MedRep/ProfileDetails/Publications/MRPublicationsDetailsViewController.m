//
//  MRPublicationsDetailsViewController.m
//  MedRep
//
//  Created by Vamsi Katragadda on 9/17/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRPublicationsDetailsViewController.h"
#import "MRCommon.h"
#import "MRPublications.h"

@interface MRPublicationsDetailsViewController () <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UITextView *publicationsTextView;
@property (weak, nonatomic) IBOutlet UILabel *publicationsDateLabel;
@property (weak, nonatomic) IBOutlet UIWebView *publicationsURLWebView;

@end

@implementation MRPublicationsDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title  = @"Publication Details";
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"]
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(backButtonTapped:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    if (self.publication != nil) {
        
        if (self.publication.articleName != nil && self.publication.articleName.length > 0) {
            self.navigationItem.title = self.publication.articleName;
        }
        
        NSString *value = @"";
        if (self.publication.publication != nil && self.publication.publication.length > 0) {
            value = self.publication.publication;
        }
        [self.publicationsTextView setText:value];
        
        value = @"";
        if (self.publication.year != nil && self.publication.year.length > 0) {
            value = self.publication.year;
        }
        [self.publicationsDateLabel setText:value];
        
        if (self.publication.url != nil && self.publication.url.length > 0) {
            NSURL *url = [NSURL URLWithString:self.publication.url];
            [self.publicationsURLWebView loadRequest:[NSURLRequest requestWithURL:url]];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MRCommon showActivityIndicator:@""];
}

-(void)backButtonTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MRCommon stopActivityIndicator];
    [self.publicationsURLWebView setBackgroundColor:[UIColor whiteColor]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102) {
        
        return;
    }
    
    if (error.code == NSURLErrorCancelled) {
        // ignore rapid repeated clicking (error code -999)
        return;
    }
    
    [MRCommon stopActivityIndicator];
    [MRCommon showAlert:@"Failed to load URL !!!" delegate:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

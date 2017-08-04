//
//  MRPHDownloadSurveyReportsViewController.m
//  MedRep
//
//  Created by Vamsi Katragadda on 12/20/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRPHDownloadSurveyReportsViewController.h"
#import "MRCommon.h"

@interface MRPHDownloadSurveyReportsViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIView *navView;

@property (nonatomic) NSString *filePath;

@end

@implementation MRPHDownloadSurveyReportsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getMenuNavigationButtonWithController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUI];
}

- (void)refreshWebView {
    // Now create Request for the file that was saved in your documents folder
    NSURL *url = [NSURL fileURLWithPath:self.filePath];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [self.webView setHidden:NO];
    [self.webView setUserInteractionEnabled:YES];
    [self.webView setDelegate:self];
    [self.webView loadRequest:requestObj];
}

- (void)updateUI {
    if (self.filePath != nil && self.filePath.length > 0) {
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.filePath];
        if (fileExists) {
            [self refreshWebView];
        } else {
            [self downloadReport];
        }
    } else {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        NSString *tempFilePath = [NSString stringWithFormat:@"%@_report.pdf", [self.survey objectForKey:@"surveyId"]];
        NSString *filePath = [docDir
                         stringByAppendingPathComponent:tempFilePath];
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (fileExists) {
            self.filePath = filePath;
            [self refreshWebView];
        } else {
            [self downloadReport];
        }
    }
}

- (void)downloadReport {
    [MRCommon showActivityIndicator:@"Downloading..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Get the PDF Data from the url in a NSData Object
        NSData *pdfData = [[NSData alloc] initWithContentsOfURL:[
                                                                 NSURL URLWithString:[self.survey objectForKey:@"reportUrl"]]];
        
        // Store the Data locally as PDF File
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        
        NSString *tempFilePath = [NSString stringWithFormat:@"%@_report.pdf", [self.survey objectForKey:@"surveyId"]];
        self.filePath = [docDir
                              stringByAppendingPathComponent:tempFilePath];
        [pdfData writeToFile:self.filePath atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MRCommon stopActivityIndicator];
            [self refreshWebView];
        });
    });
}

- (void)getMenuNavigationButtonWithController
{
    self.navigationItem.title = @"Survey Details";
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButton:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
}

- (IBAction)backButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

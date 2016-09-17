//
//  MRPublicationsDetailsViewController.m
//  MedRep
//
//  Created by Vamsi Katragadda on 9/17/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRPublicationsDetailsViewController.h"
#import "MRPublications.h"

@interface MRPublicationsDetailsViewController ()

@property (weak, nonatomic) IBOutlet UITextView *publicationsTextView;
@property (weak, nonatomic) IBOutlet UILabel *publicationsDateLabel;
@property (weak, nonatomic) IBOutlet UIWebView *publicationsURLWebView;

@end

@implementation MRPublicationsDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.publication != nil) {
        
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  PublicationsViewController.h
//  MedRep
//
//  Created by Namit Nayak on 7/19/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MRPublications;
@interface PublicationsViewController : UIViewController
@property (nonatomic,weak) IBOutlet UITextField *pulbicationsTextField;
@property (nonatomic,weak) IBOutlet UITextField *publicationArticleTextField;
@property (nonatomic,weak) IBOutlet UITextField *yearTextField;
@property (nonatomic,strong) NSString *fromScreen;
@property (nonatomic,strong) MRPublications *publications;
@end

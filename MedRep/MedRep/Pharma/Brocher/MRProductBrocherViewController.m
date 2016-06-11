//
//  MRProductBrocherViewController.m
//  
//
//  Created by MedRep Developer on 04/11/15.
//
//

#import "MRProductBrocherViewController.h"
#import "SWRevealViewController.h"
#import "MRConstants.h"
#import "MRCommon.h"
#import "MRWebserviceHelper.h"

@interface MRProductBrocherViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationImageWidthConstraint;
@property (nonatomic, retain) NSArray *detailsList;
@property (nonatomic, assign) NSInteger imagesCount;
@property (nonatomic, retain) NSMutableDictionary *noticationImages;
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@end

@implementation MRProductBrocherViewController

- (void)getMenuNavigationButtonWithController:(SWRevealViewController *)revealViewCont NavigationItem:(UINavigationItem *)navigationItem1
{
    SWRevealViewController *revealController = revealViewCont;
    
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    revealButtonItem.tintColor = [UIColor blackColor];
    navigationItem1.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)viewDidLoad {
    
    self.noticationImages = [[NSMutableDictionary alloc] init];

    [self getMenuNavigationButtonWithController:[self revealViewController] NavigationItem:self.navigationItem];
    [[MRWebserviceHelper sharedWebServiceHelper] getNotificationById:[NSString stringWithFormat:@"%ld",(long)self.notificationID] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
    {
        if (status)
        {
            self.detailsList = [responce objectForKey:@"notificationDetails"];
            if (self.detailsList.count > 0)
            {
                [self loadImages];
                
                if(self.detailsList.count == 1)
                {
                    [self hideNavigationButton];
                }
                else
                {
                    [self showNavigationButton];
                }
            }
            else
            {
                [self hideNavigationButton];
                self.imagesCount = 0;
            }
        }
        else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
        {
            [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
             {
                 [MRCommon savetokens:responce];
                 [[MRWebserviceHelper sharedWebServiceHelper] getNotificationById:[NSString stringWithFormat:@"%ld",(long)self.notificationID] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
                  {
                      if (status)
                      {
                          self.detailsList = [responce objectForKey:@"notificationDetails"];
                          if (self.detailsList.count > 0)
                          {
                              [self loadImages];
                              
                              if(self.detailsList.count == 1)
                              {
                                  [self hideNavigationButton];
                              }
                              else
                              {
                                  [self showNavigationButton];
                              }
                          }
                          else
                          {
                              [self hideNavigationButton];
                              self.imagesCount = 0;
                          }
                      }
                  }];
             }];
        }
    }];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)loadImages
{
    [MRCommon getNotificationImageByID:[[[self.detailsList objectAtIndex:self.imagesCount] objectForKey:@"detailId"] integerValue] forImage:^(UIImage *image)
     {
         if (image)
         {
             [self.noticationImages setObject:image forKey:[[self.detailsList objectAtIndex:self.imagesCount] objectForKey:@"detailId"]];
             
             if (self.imagesCount == 0)
             {
                 [self updateNotification:[[self.detailsList objectAtIndex:self.imagesCount] objectForKey:@"detailId"]];
                 self.currentImageIndex = 0;
             }
             
             self.imagesCount++;
             
             if (self.imagesCount < self.detailsList.count)
             {
                 [self loadImages];
             }
             else if (self.imagesCount == self.detailsList.count)
             {
                 [MRCommon stopActivityIndicator];
             }
         }
         else
         {
             [MRCommon stopActivityIndicator];
             self.notificationImageHeightConstraint.constant = 0;
             self.notificationImageWidthConstraint.constant = 0;
             self.productImageView.image = [UIImage imageNamed:@""];
         }
     }];

//    [MRCommon getNotificationImageByID:self.notificationID forImage:^(UIImage *image){
//         if (image)
//         {
//             self.notificationImageHeightConstraint.constant = image.size.height;
//             self.notificationImageWidthConstraint.constant = image.size.width;
//             self.productImageView.image = image;
//             self.scrollView.contentSize = image.size;
//             [self.view updateConstraints];
//         }
//         else
//         {
//             [MRCommon stopActivityIndicator];
//             self.notificationImageHeightConstraint.constant = 0;
//             self.notificationImageWidthConstraint.constant = 0;
//             self.productImageView.image = [UIImage imageNamed:@""];
//         }
//     }];
}

- (void)updateNotification:(NSNumber*)imageId
{
    UIImage *image = [self.noticationImages objectForKey:imageId];
    self.notificationImageHeightConstraint.constant = self.scrollView.frame.size.height;
    self.notificationImageWidthConstraint.constant = self.scrollView.frame.size.width;
    self.productImageView.image = image;
    self.scrollView.contentSize = image.size;
    [self.view updateConstraints];    [self.view updateConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
}

- (IBAction)leftButtonAction:(id)sender
{
    if (self.currentImageIndex == self.detailsList.count -1)
    {
        self.currentImageIndex = -1;
    }
    
    self.currentImageIndex++;
    [self updateNotification:[[self.detailsList objectAtIndex:self.currentImageIndex] objectForKey:@"detailId"]];
}

- (IBAction)rightButtonAction:(id)sender
{
    if (self.currentImageIndex == 0)
    {
        self.currentImageIndex = self.detailsList.count;
    }
    self.currentImageIndex--;
    [self updateNotification:[[self.detailsList objectAtIndex:self.currentImageIndex] objectForKey:@"detailId"]];
    
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

//
//  MRWelcomeViewController.m
//  MedRep
//
//  Created by MedRep Developer on 27/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRWelcomeViewController.h"
#import "MRLoginViewController.h"
#import "MRCommon.h"
#import "MRWebserviceHelper.h"
#import "MRConstants.h"
#import "MRAppControl.h"

@interface MRWelcomeViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *getStartedBtnBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileImageTopConstartint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *greatLabelConstarint;
@property (assign, nonatomic) BOOL isImageUploaded;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLable;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@end

@implementation MRWelcomeViewController

- (void)viewDidLoad
{
    [self setupUI];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)setupUI
{
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width /2;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImage.layer.borderWidth = 2.0;
    self.profileImage.clipsToBounds = YES;
    self.userNameLable.text = [NSString stringWithFormat:@"Dr. %@",[[MRAppControl sharedHelper].userRegData objectForKey:KFirstName]];
    if ([MRCommon isIPad])
    {
        self.logoTopConstraint.constant = 100;
        self.getStartedBtnBottomConstraint.constant = 40;
        self.profileImageTopConstartint.constant = 30;
        self.greatLabelConstarint.constant = 50;
    }
    else if ([MRCommon deviceHasThreePointFiveInchScreen])
    {
        self.logoTopConstraint.constant = 20;
        self.getStartedBtnBottomConstraint.constant = 20;
        self.profileImageTopConstartint.constant = 10;
    }
    else if ([MRCommon isiPhone5])
    {
    }
    else if ([MRCommon deviceHasFourPointSevenInchScreen])
    {
        self.logoTopConstraint.constant = 80;
        self.getStartedBtnBottomConstraint.constant = 40;
        self.profileImageTopConstartint.constant = 30;
        self.greatLabelConstarint.constant = 50;
    }
    else if ([MRCommon deviceHasFivePointFiveInchScreen])
    {
        self.logoTopConstraint.constant = 100;
        self.getStartedBtnBottomConstraint.constant = 40;
        self.profileImageTopConstartint.constant = 30;
        self.greatLabelConstarint.constant = 50;
    }
}

- (NSString*)getUsertype
{
    switch ([MRAppControl sharedHelper].userType)
    {
        case 2:
            return @"Dr";
            break;
            
        default:
            return @"Mr";
            break;
    }
    
    return @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)skipButtonAction:(id)sender
{
    [self loadHome];
//    MRLoginViewController *homeViewController = [[MRLoginViewController alloc] initWithNibName:@"MRLoginViewController" bundle:nil];
//    [self.navigationController pushViewController:homeViewController animated:YES];
}

- (IBAction)getStartedButtonAction:(id)sender
{
    if (self.isImageUploaded)
    {
        [self loadHome];
    }
    else
    {
        [MRCommon showAlert:@"Please upload ur image." delegate:nil];
    }
}

- (void)loadHome
{
    if (self.isFromSinUp) {
        MRLoginViewController *homeViewController = [[MRLoginViewController alloc] initWithNibName:@"MRLoginViewController" bundle:nil];
        homeViewController.isFromHome = NO;
        [self.navigationController pushViewController:homeViewController animated:YES];
    }
    else
    {
        [[MRAppControl sharedHelper] loadDashBoardOnLogin];
    }
}
- (IBAction)addPhotoButtonAction:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"MedRep" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Camera" otherButtonTitles:@"PhotoLibrary", nil];
        [actionsheet showInView:self.view];
    }
    else
    {
        UIImagePickerController *imagePickController=[[UIImagePickerController alloc] init];
        imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickController.allowsEditing = NO;
        imagePickController.delegate = self;
        [self presentViewController:imagePickController animated:YES completion:nil];
    }
   // [self pre];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2)
    {
        
    }
    else
    {
        UIImagePickerController *imagePickController=[[UIImagePickerController alloc] init];
        if (buttonIndex == 0)
        {
            imagePickController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else
        {
            imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        imagePickController.allowsEditing = NO;
        imagePickController.delegate = self;
        [self presentViewController:imagePickController animated:YES completion:nil];

    }
}
#pragma mark - Image Picker Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:NO completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    //NSLog(@"%@",chosenImage);
    
    self.profileImage.image = [MRCommon imageWithImage:chosenImage scaledToSize:CGSizeMake(200, 200)];
    [picker dismissViewControllerAnimated:NO completion:NULL];

    NSData *imageData = UIImageJPEGRepresentation([MRCommon imageWithImage:chosenImage scaledToSize:CGSizeMake(200, 200)], 1.0);
    [MRCommon showActivityIndicator:@"Uploading Profile Image..."];
    [[MRWebserviceHelper sharedWebServiceHelper] uploadDP:[NSDictionary dictionaryWithObjectsAndKeys:[imageData base64EncodedStringWithOptions:0],@"ImageData", nil] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
    {
        [MRCommon stopActivityIndicator];
        if (status)
        {
            self.isImageUploaded = YES;
        }
        else
        {
            self.isImageUploaded = NO;
        }
    }];
    
    [picker dismissViewControllerAnimated:NO completion:NULL];

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

@implementation UIImagePickerController (autoRotation)

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end



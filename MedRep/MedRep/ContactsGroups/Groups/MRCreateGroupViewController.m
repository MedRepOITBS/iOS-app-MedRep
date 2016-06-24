//
//  MRCreateGroupViewController.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/13/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRCreateGroupViewController.h"
#import "MRAppControl.h"
#import "MRWebserviceHelper.h"
#import "MRCommon.h"
#import "MRConstants.h"
#import <AVFoundation/AVFoundation.h>
#import "MRContactsViewController.h"

@interface MRCreateGroupViewController () <UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {
    UITextView *activeTxtView;
    NSData *groupIconData;
    BOOL isUpdateMode;
}

@property (weak, nonatomic) IBOutlet UITextView *txtShortDesc;
@property (weak, nonatomic) IBOutlet UITextView *txtLongDesc;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UITextView *txtName;
@property (weak, nonatomic) IBOutlet UIButton *createBtn;
@property (strong, nonatomic) IBOutlet UIView *navView;

@end

@implementation MRCreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Create Group";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [[self.txtName layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.txtName layer] setBorderWidth:1.0];
    [[self.txtName layer] setCornerRadius:5];
    
    [[self.txtLongDesc layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.txtLongDesc layer] setBorderWidth:1.0];
    [[self.txtLongDesc layer] setCornerRadius:5];
    
    [[self.txtShortDesc layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.txtShortDesc layer] setBorderWidth:1.0];
    [[self.txtShortDesc layer] setCornerRadius:5];
    
    [[self.imgView layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.imgView layer] setBorderWidth:1.0];
    [[self.imgView layer] setCornerRadius:5];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapped)];
    [_imgView addGestureRecognizer:tap];
    
    if (_group) {
        self.txtName.text = self.group.group_name;
        self.txtLongDesc.text = self.group.group_long_desc;
        self.txtShortDesc.text = self.group.group_short_desc;
        UIImage *theImage= [MRCommon getImageFromBase64Data:[self.group.group_img_data dataUsingEncoding:NSUTF8StringEncoding]];
        groupIconData = UIImageJPEGRepresentation(theImage, 1.0);
        self.imgView.image = theImage;
        isUpdateMode = YES;
        self.navigationItem.title = @"Update Group";
        [_createBtn setTitle:@"Update Group" forState:UIControlStateNormal];
    }else{
        isUpdateMode = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonAction{
    [activeTxtView resignFirstResponder];
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

-(void) imgTapped{
    [activeTxtView resignFirstResponder];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library", @"Camera", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)createGroup:(id)sender {
    [activeTxtView resignFirstResponder];
    
    if (!_txtName.text.length || !_txtShortDesc.text.length || !_txtLongDesc.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please fill all the fields!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    if (!groupIconData) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please select group icon!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    NSMutableDictionary *dictReq = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             _txtName.text,@"group_name",
                             _txtShortDesc.text, @"group_short_desc",
                             _txtLongDesc.text, @"group_long_desc",
                             [groupIconData base64EncodedStringWithOptions:0], @"group_img_data",
                             @"png",@"group_mimeType",
                             nil];
    
    if (isUpdateMode) {
        [MRCommon showActivityIndicator:@"Updating..."];
        
        [dictReq setValue:self.group.group_id forKey:@"group_id"];
        [[MRWebserviceHelper sharedWebServiceHelper] updateGroup:dictReq withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
            [MRCommon stopActivityIndicator];
            if (status)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Group updated!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                alert.tag = 11;
                [alert show];
                
                _txtName.text = @"";
                _txtLongDesc.text = @"";
                _txtShortDesc.text = @"";
                [_imgView setImage:[UIImage imageNamed:@"Group.png"]];
                groupIconData = nil;
            }
            else
            {
                NSArray *erros =  [details componentsSeparatedByString:@"-"];
                if (erros.count > 0)
                    [MRCommon showAlert:[erros lastObject] delegate:nil];
            }
        }];
    }else{
        [MRCommon showActivityIndicator:@"Creating..."];
        
        [[MRWebserviceHelper sharedWebServiceHelper] createGroup:dictReq withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
            [MRCommon stopActivityIndicator];
            if (status)
            {
                //[MRCommon showAlert:@"Group created!" delegate:nil];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Group created!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                alert.tag = 11;
                [alert show];
                
                _txtName.text = @"";
                _txtLongDesc.text = @"";
                _txtShortDesc.text = @"";
                [_imgView setImage:[UIImage imageNamed:@"Group.png"]];
                groupIconData = nil;
            }
            else
            {
                NSArray *erros =  [details componentsSeparatedByString:@"-"];
                if (erros.count > 0)
                    [MRCommon showAlert:[erros lastObject] delegate:nil];
            }
        }];
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 11) {
        for (UIViewController *vc in self.parentViewController.childViewControllers) {
            if ([vc isKindOfClass:[MRContactsViewController class]]) {
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    activeTxtView = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //photolibrary
        [self pickCameraWithLibrary:YES];
    }else if (buttonIndex == 1){
        [self pickCameraWithLibrary:NO];
    }
}

-(void)pickCameraWithLibrary:(BOOL)isLibrary{
    @try
    {
        if(isLibrary)
        {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [self presentViewController:picker animated:YES completion:nil];
        }
        else
        {
            [self openCameraPicker];
        }
    }
    @catch (NSException *exception) {
    }
}

-(void)showCamera{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Image Picker Controller Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *tmpImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    float newHeight = tmpImage.size.height / 3;
    float newWidth = tmpImage.size.width / 3;
    
    UIImage *theImage = [self imageWithImage:tmpImage convertToSize:CGSizeMake(newWidth, newHeight)];
    [_imgView setImage:theImage];
    
    groupIconData = UIImageJPEGRepresentation(theImage, 1.0);
}

-(void)openCameraPicker{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized)
        {
            [self showCamera];
            
        }
        else if(authStatus == AVAuthorizationStatusDenied)
        {
            // denied
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera access disabled" message:@"SYW Relay needs access to your camera. Please check your privacy settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else if(authStatus == AVAuthorizationStatusRestricted)
        {
            // restricted, normally won't happen
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera access disabled" message:@"SYW Relay needs access to your camera. Please check your privacy settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else if(authStatus == AVAuthorizationStatusNotDetermined)
        {
            // not determined?!
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
             {
                 if(granted)
                 {
                     [self showCamera];
                 }
                 else{
                     
                 }
             }];
        } else {
            // impossible, unknown authorization status
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Camera not present." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

@end

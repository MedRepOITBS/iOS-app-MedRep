//
//  MRProfileDetailsViewController.m
//  
//
//  Created by MedRep Developer on 12/12/15.
//
//

#import "MRProfileDetailsViewController.h"
#import "MRAppControl.h"
#import "MRConstants.h"
#import "MRCommon.h"
#import "MRRegistationViewController.h"
#import "MRRegistationTwoViewController.h"
#import "MRWebserviceHelper.h"
#import "addProfileItemsTableViewCell.h"
#import "ProfileAboutTableViewCell.h"
#import "ProfileBasicTableViewCell.h"
#import "CommonProfileSectionTableViewCell.h"
@interface MRProfileDetailsViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>


@property (assign, nonatomic) BOOL isImageUploaded;

@end

@implementation MRProfileDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupProfileData];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MRCommon showActivityIndicator:@""];
    if ([MRAppControl sharedHelper].userType == 1 || [MRAppControl sharedHelper].userType == 2)
    {
        [[MRWebserviceHelper sharedWebServiceHelper] getDoctorProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
         {
             [MRCommon stopActivityIndicator];
             if (status)
             {
                 [[MRAppControl sharedHelper] setUserDetails:responce];
             }
             else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
             {
                 [MRCommon showActivityIndicator:@""];
                 [[MRWebserviceHelper sharedWebServiceHelper] getDoctorProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
                  {
                      [MRCommon stopActivityIndicator];
                      if (status)
                      {
                          [[MRAppControl sharedHelper] setUserDetails:responce];
                      }
                  }];
             }
         }];
    }
    else if ([MRAppControl sharedHelper].userType == 3 || [MRAppControl sharedHelper].userType == 4)
    {
        [[MRWebserviceHelper sharedWebServiceHelper] getPharmaProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
         {
             [MRCommon stopActivityIndicator];
             if (status)
             {
                 [[MRAppControl sharedHelper] setUserDetails:responce];
             }
             else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
             {
                 [MRCommon showActivityIndicator:@""];
                 [[MRWebserviceHelper sharedWebServiceHelper] getPharmaProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
                  {
                      [MRCommon stopActivityIndicator];
                      if (status)
                      {
                          [[MRAppControl sharedHelper] setUserDetails:responce];
                      }
                  }];
             }
         }];
    }

    [self setupProfileData];
}

- (void)setupProfileData
{
   /*  self.profileNameLabel.text              = @"";

    self.mobileNumberLabel.text             = @"";
    self.AlternateMobileNumberLabel.text    = @"";
    self.emailLabel.text                    = @"";
    self.alternateEmailLabel.text           = @"";
    self.addressOneLabel.text               = @"";
    self.addressTwoLabel.text               = @"";
   */
    NSDictionary *userdata = [MRAppControl sharedHelper].userRegData;
    
    NSInteger userType = [MRAppControl sharedHelper].userType;
    
//    self.profileImageView.image = [MRCommon getImageFromBase64Data:[userdata objectForKey:KProfilePicture]];
    
    NSMutableArray *mArray = [userdata objectForKey:KMobileNumber];

//    self.profileNameLabel.text              = (userType == 2 || userType == 1) ? [NSString stringWithFormat:@"Dr. %@ %@", [userdata objectForKey:KFirstName],[userdata objectForKey:KLastName]] : [NSString stringWithFormat:@"Mr. %@ %@", [userdata objectForKey:KFirstName],[userdata objectForKey:KLastName]];
//    self.mobileNumberLabel.text             = (mArray.count >= 1) ? [mArray objectAtIndex:0] : @"";
//    self.AlternateMobileNumberLabel.text    = (mArray.count >= 2) ? [mArray objectAtIndex:1] : @"";
//    
    if(mArray.count >= 2 && ![[mArray objectAtIndex:1] isEqualToString:@""])
    {
//        self.AlternateMobileNumberLabel.text    =  [mArray objectAtIndex:1];
//        self.mobileNumberViewHeightConstraint.constant = 60;
//        self.alternateMobileTitleLabel.hidden = NO;
        [self updateViewConstraints];
    }
    else
    {
//        self.AlternateMobileNumberLabel.text    =  @"";
//        self.mobileNumberViewHeightConstraint.constant = 30;
//        self.alternateMobileTitleLabel.hidden = YES;
//        [self updateViewConstraints];
    }
    NSMutableArray *eArray = [userdata objectForKey:KEmail];

//    self.emailLabel.text                    = (eArray.count >= 1) ? [eArray objectAtIndex:0] : @"";
//    self.alternateEmailLabel.text           = (eArray.count >= 2) ? [eArray objectAtIndex:1] : @"";
    
    if(eArray.count >= 2 && ![[eArray objectAtIndex:1] isEqualToString:@""])
    {
//        self.alternateEmailLabel.text           = [eArray objectAtIndex:1];
//        self.alterNateEmailTitleLabel.hidden = NO;
//        self.alternateEmailViewHeightConstratint.constant = 60;
        [self updateViewConstraints];
    }
    else
    {
//        self.alterNateEmailTitleLabel.hidden = YES;
//        self.alternateEmailLabel.text           =  @"";
//        self.alternateEmailViewHeightConstratint.constant = 30;
        [self updateViewConstraints];
    }

    
//    self.addressOneLabel.text               = [[[userdata  objectForKey:KRegistarionStageTwo] objectAtIndex:0] objectForKey:KAddressOne];
    
    /*
     City = Hyded;
     State = telanganat;
     ZIPCode = 506559;
     */
//    self.addressTwoLabel.text               = [NSString stringWithFormat:@"%@, %@, %@, %@",[[[userdata  objectForKey:KRegistarionStageTwo] objectAtIndex:0] objectForKey:KAdresstwo], [[[userdata  objectForKey:KRegistarionStageTwo] objectAtIndex:0] objectForKey:@"city"],[[[userdata  objectForKey:KRegistarionStageTwo] objectAtIndex:0] objectForKey:@"State"],[[[userdata  objectForKey:KRegistarionStageTwo] objectAtIndex:0] objectForKey:@"ZIPCode"]];
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

- (IBAction)changeButtonAction:(id)sender
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

- (IBAction)profileEditButtonAction:(id)sender
{
    MRRegistationViewController *regViewController = [[MRRegistationViewController alloc] initWithNibName:@"MRRegistationViewController" bundle:nil];
    regViewController.isFromSinUp = NO;
    regViewController.isFromEditing = YES;
    [self.navigationController pushViewController:regViewController animated:YES];
}

- (IBAction)addressEditButtonAction:(id)sender
{
    MRRegistationTwoViewController *regTwoViewController = [[MRRegistationTwoViewController alloc] initWithNibName:@"MRRegistationTwoViewController" bundle:nil];
    regTwoViewController.isFromSinUp = self.isFromSinUp;
     regTwoViewController.isFromEditing = YES;
    regTwoViewController.registrationStage = 1;
    [self.navigationController pushViewController:regTwoViewController animated:YES];
}

- (IBAction)closeButtonAction:(id)sender
{
    [[MRAppControl sharedHelper] loadDashboardScreen];
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
    
//    self.profileImageView.image = [MRCommon imageWithImage:chosenImage scaledToSize:CGSizeMake(200, 200)];

    NSData *imageData = UIImageJPEGRepresentation([MRCommon imageWithImage:chosenImage scaledToSize:CGSizeMake(200, 200)], 1.0);
    [MRCommon showActivityIndicator:@"Uploading Profile Image..."];
    [[MRWebserviceHelper sharedWebServiceHelper] uploadDP:[NSDictionary dictionaryWithObjectsAndKeys:[imageData base64EncodedStringWithOptions:0],@"ImageData", nil] withHandler:^(BOOL status, NSString *details, NSDictionary *responce)
     {
         [MRCommon stopActivityIndicator];
         
         if (status)
         {
             self.isImageUploaded = YES;
             [[MRAppControl sharedHelper].userRegData setObject:[imageData base64EncodedDataWithOptions:0] forKey:KProfilePicture];
//             self.profileImageView.image = [MRCommon imageWithImage:chosenImage scaledToSize:CGSizeMake(200, 200)];
             [MRCommon showAlert:@"Profile Picture Updated Sucessfully" delegate:nil];
             
         }
         else
         {
             self.isImageUploaded = NO;
             [MRCommon showAlert:@"Failed to Update Profile Picture" delegate:nil];
         }
     }];
    
    [picker dismissViewControllerAnimated:NO completion:NULL];
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 14;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
     if (indexPath.row ==0 || indexPath.row == 1) {
        return 152;
    }else if((indexPath.row % 2) == 0 ){
        return 85;
    }
    return 40;
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

     switch (indexPath.row) {
         case 0:
         {
            ProfileBasicTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"ProfileBasicTableViewCell"] forIndexPath:indexPath];
             return cell;

             
         }
             break;
         case 1:
         {
             ProfileAboutTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"ProfileAboutTableViewCell"] forIndexPath:indexPath];
             return cell;
             
             
         }break;
        
         
         case 2 : case 4: case 6: case 8: case 10: case 12:
         {
             CommonProfileSectionTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"CommonProfileSectionTableViewCell"] forIndexPath:indexPath];
             return cell;
             
             
         }break;
             
         case 3: case 5: case 7: case 9: case 11 : case 13:
             
         {
             addProfileItemsTableViewCell  *cell = (addProfileItemsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"addProfileButton"];
             if (cell == nil) {
                 NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"addProfileItemsTableViewCell" owner:self options:nil];
                 cell = (addProfileItemsTableViewCell *)[arr objectAtIndex:0];
                 
             }
             return cell;
             
             
         }break;
         default:
             break;
     }
     
     // Configure the cell...
 
 return nil;
 }


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

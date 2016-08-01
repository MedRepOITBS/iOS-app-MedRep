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
#import "AddExperienceTableViewController.h"
#import "MRProfile.h"
#import "MRWorkExperience.h"
#import "EducationalQualifications.h"
#import "MRPublications.h"
#import "MRInterestArea.h"
#import "ExpericeFillUpTableViewCell.h"
#import "basicInfoTableViewCell.h"
#import "SWRevealViewController.h"
#import "AddEducationViewController.h"
#import "InterestViewController.h"
#import "UIImage+Helpers.h"

#import "PublicationsViewController.h"
@interface MRProfileDetailsViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate,CommonProfileSectionTableViewCellDelegate>


@property (assign, nonatomic) BOOL isImageUploaded;
@property (nonatomic,strong) NSMutableArray *commonSectionArray;
@property (nonatomic,strong) MRProfile *profileObj;


@end

@implementation MRProfileDetailsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSDictionary *userdata = [MRAppControl sharedHelper].userRegData;
    
    NSInteger userType = [MRAppControl sharedHelper].userType;
    
   self.navigationItem.title         = (userType == 2 || userType == 1) ? [NSString stringWithFormat:@"Dr. %@ %@", [userdata objectForKey:KFirstName],[userdata objectForKey:KLastName]] : [NSString stringWithFormat:@"Mr. %@ %@", [userdata objectForKey:KFirstName],[userdata objectForKey:KLastName]];
    
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName:[UIColor whiteColor],
                                                           NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0]
                                                           }];
    
    
    // shadowImage removes under navigation line
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.barTintColor = [MRCommon colorFromHexString:kStatusBarColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = false;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    SWRevealViewController *revealController = [self revealViewController];
    revealController.delegate = self;
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController
                                                                        action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    

    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"userLocal.png"]
                                                                         style:UIBarButtonItemStylePlain target:self
                                                                        action:@selector(editButtonTapped:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self setupProfileData];
    // Do any additional setup after loading the view from its nib.
}

-(void)editButtonTapped:(id)sender{
    
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [MRCommon showActivityIndicator:@""];
//    if ([MRAppControl sharedHelper].userType == 1 || [MRAppControl sharedHelper].userType == 2)
//    {
//        [[MRWebserviceHelper sharedWebServiceHelper] getDoctorProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
//         {
//             [MRCommon stopActivityIndicator];
//             if (status)
//             {
//                 [[MRAppControl sharedHelper] setUserDetails:responce];
//             }
//             else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
//             {
//                 [MRCommon showActivityIndicator:@""];
//                 [[MRWebserviceHelper sharedWebServiceHelper] getDoctorProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
//                  {
//                      [MRCommon stopActivityIndicator];
//                      if (status)
//                      {
//                          [[MRAppControl sharedHelper] setUserDetails:responce];
//                      }
//                  }];
//             }
//         }];
//    }
//    else if ([MRAppControl sharedHelper].userType == 3 || [MRAppControl sharedHelper].userType == 4)
//    {
//        [[MRWebserviceHelper sharedWebServiceHelper] getPharmaProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
//         {
//             [MRCommon stopActivityIndicator];
//             if (status)
//             {
//                 [[MRAppControl sharedHelper] setUserDetails:responce];
//             }
//             else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
//             {
//                 [MRCommon showActivityIndicator:@""];
//                 [[MRWebserviceHelper sharedWebServiceHelper] getPharmaProfileDetails:^(BOOL status, NSString *details, NSDictionary *responce)
//                  {
//                      [MRCommon stopActivityIndicator];
//                      if (status)
//                      {
//                          [[MRAppControl sharedHelper] setUserDetails:responce];
//                      }
//                  }];
//             }
//         }];
//    }

    [self setupProfileData];
}

- (void)setupProfileData
{
    
    _commonSectionArray = [NSMutableArray array];
    
    [_commonSectionArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Work Experience",@"title",@"+ Add Experience",@"Button",@"Add Details of your Work Experience and make it easier for colleagues to find you.",@"detail", nil]];
        [_commonSectionArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Interest Areas",@"title",@"+ Add Interest Area",@"Button",@"Add your Interest Area",@"detail", nil]];
        [_commonSectionArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Educational Qualifications",@"title",@"+ Add Qualification",@"Button",@"Add your Qualification",@"detail", nil]];
    [_commonSectionArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Publications",@"title",@"+ Add Publication",@"Button",@"Add a Publication and be recognised for your research",@"detail", nil]];
        [_commonSectionArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Awards",@"title",@"+ Add Award",@"Button",@"Add an Award",@"detail", nil]];
    [_commonSectionArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Memberships & Positions",@"title",@"+ Add Membership",@"Button",@"Add a Membership or Position",@"detail", nil]];
    
    
    
    
    
   
        // Create Dummy Data
        
//    NSArray * profileArr = [MRDatabaseHelper getProfileData];
//    if (profileArr.count == 0 || profileArr == nil) {
    
//        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Profile" ofType:@"json"];
//        NSData* data = [NSData dataWithContentsOfFile:filePath];
//        NSError *error;
//        NSDictionary* transformArticles = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
//        [MRDatabaseHelper addProfileData:transformArticles];
//    }

    
    [MRDatabaseHelper addProfileData:^(id result){
    _profileObj  = [result objectAtIndex:0];
        [self.tableView reloadData];

    }];
    
    
    
    

    
    
    
    
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


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    

NSDictionary *valNDict = [[self setStructureForTableView] objectAtIndex:indexPath.row];
    
NSString *valN = [valNDict objectForKey:@"type"];


 if ([valN isEqualToString:@"WORK_EXP_DETAIL"] || [valN isEqualToString:@"EDUCATION_QUAL_DETAIL"] || [valN isEqualToString:@"PUBLICATION_DETAIL"] || [valN isEqualToString:@"INTEREST_AREA_DETAIL"] ){

    return UITableViewCellEditingStyleDelete;

 }else
 {
    return UITableViewCellEditingStyleNone;
 }
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSDictionary *valNDict = [[self setStructureForTableView] objectAtIndex:indexPath.row];

        NSString *valN = [valNDict objectForKey:@"type"];
        if([valN isEqualToString:@"WORK_EXP_DETAIL"]){
            
            MRWorkExperience *exp = [valNDict objectForKey:@"object"];
            
            
        }else if([valN isEqualToString:@"EDUCATION_QUAL_DETAIL"] ){
            
            
        }else if ([valN isEqualToString:@"WORK_EXP_DETAIL"]){
            
            
        }else if([valN isEqualToString:@"PUBLICATION_DETAIL"]){
            
        }else if([valN isEqualToString:@"INTEREST_AREA_DETAIL"]){
            
            
        }
     
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self setStructureForTableView].count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *valNDict = [[self setStructureForTableView] objectAtIndex:indexPath.row];
    NSString *valN = [valNDict objectForKey:@"type"];
    
    if ([valN isEqualToString:@"PROFILE_BASIC"]) {
        return 152;
    }
    else  if ([valN isEqualToString:@"ABOUT"]){
        return 85;
    }
 
    else if([valN isEqualToString:@"WORK_EXP"]|| [valN isEqualToString:@"INTEREST_AREA"] || [valN isEqualToString:@"EDUCATION_QUAL"] || [valN isEqualToString:@"PUBLICATION"]) {
        
      return   [self heightAdjustOnBasisOfRecordsForType:valN];
//        heightAdjustOnBasisOfRecordsForType:(NSString *)type
    }
    else if([valN isEqualToString:@"ADD_BUTTON"]) {
        return 40;
    } else if ([valN isEqualToString:@"WORK_EXP_DETAIL"] || [valN isEqualToString:@"EDUCATION_QUAL_DETAIL"] ){
        return 95;
    }else if ([valN isEqualToString:@"PUBLICATION_DETAIL"] || [valN isEqualToString:@"INTEREST_AREA_DETAIL"] )
    {
        return 40;
    }
    
    return 40;
}

-(NSInteger)heightAdjustOnBasisOfRecordsForType:(NSString *)type{

    if (([type isEqualToString:@"INTEREST_AREA"] && _profileObj.interestArea.array.count >0 ) || ([type isEqualToString:@"WORK_EXP"] && _profileObj.workExperience.array.count >0)|| ([type isEqualToString:@"EDUCATION_QUAL"] && _profileObj.educationlQualification.array.count >0) || ([type isEqualToString:@"PUBLICATION"] && _profileObj.publications.array.count >0)) {
        return 64;
    }
    
    return 115;
}
-(NSArray*)setStructureForTableView{
    
    NSMutableArray *temp = [NSMutableArray array];
  
    
    [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"PROFILE_BASIC",@"type", nil]];
       [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"ABOUT",@"type", nil]];
    
    
    [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"WORK_EXP",@"type", nil]];
    
    
//    NSArray *workEXP = _profileObj.workExperience.array;
    [_profileObj.workExperience.array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        MRWorkExperience * workexp = (MRWorkExperience *)obj;
        [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"WORK_EXP_DETAIL",@"type",workexp,@"object" ,nil]];

       
        
    }];
   // [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"ADD_BUTTON",@"type", nil]];
    [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"INTEREST_AREA",@"type", nil]];

    
    [_profileObj.interestArea.array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MRInterestArea * workexp = (MRInterestArea *)obj;
        if (_profileObj.interestArea.array.count -1 == idx) {
            [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"INTEREST_AREA_DETAIL",@"type",workexp,@"object",@"YES",@"lastObj" ,nil]];
            
        }else{
            
            [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"INTEREST_AREA_DETAIL",@"type",workexp,@"object",@"NO",@"lastObj" ,nil]];
            
            
        }
    }];
    
    //[temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"ADD_BUTTON",@"type", nil]];

    [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"EDUCATION_QUAL",@"type", nil]];

    
    
    [_profileObj.educationlQualification.array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EducationalQualifications * workexp = (EducationalQualifications *)obj;
        [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"EDUCATION_QUAL_DETAIL",@"type",workexp,@"object" ,nil]];

        
    }];
   
    //[temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"ADD_BUTTON",@"type", nil]];
    [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"PUBLICATION",@"type", nil]];


    [_profileObj.publications.array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MRPublications * workexp = (MRPublications *)obj;
        [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"PUBLICATION_DETAIL",@"type",workexp,@"object" ,nil]];

        
    }];
   // [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"ADD_BUTTON",@"type", nil]];

 
    
    
    
    return temp;
}
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

     
     NSDictionary *valNDict = [[self setStructureForTableView] objectAtIndex:indexPath.row];
     NSString *valN = [valNDict objectForKey:@"type"];
     if ([valN isEqualToString:@"PROFILE_BASIC"]) {
         ProfileBasicTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"ProfileBasicTableViewCell"] forIndexPath:indexPath];
         NSDictionary *userdata = [MRAppControl sharedHelper].userRegData;
         
         
         NSInteger userType = [MRAppControl sharedHelper].userType;
         
         cell.userNameLbl.text         = _profileObj.designation;
         cell.userLocation.text = _profileObj.location;
         
         
         NSURL * imageURL = [NSURL URLWithString:[userdata objectForKey:KProfilePicture]];

         
         dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
         dispatch_async(queue, ^{
             NSData *data = [NSData dataWithContentsOfURL:imageURL];
             UIImage *image = [UIImage imageWithData:data];
             dispatch_async(dispatch_get_main_queue(), ^{
                cell.profileimageView.image = image;
             });  
         });
        
         
         return cell;
     } else if([valN isEqualToString:@"ABOUT"]) {
         ProfileAboutTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"ProfileAboutTableViewCell"] forIndexPath:indexPath];
         cell.specialityLbl.text = _profileObj.designation;
         
         return cell;

     }
     
     else if([valN isEqualToString:@"WORK_EXP"]|| [valN isEqualToString:@"INTEREST_AREA"] || [valN isEqualToString:@"EDUCATION_QUAL"] || [valN isEqualToString:@"PUBLICATION"]) {
         CommonProfileSectionTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"CommonProfileSectionTableViewCell"] forIndexPath:indexPath];
         
               [cell setCommonProfileDataForType:valN withUserProfileData:_profileObj];
         cell.delegate = self;
         return cell;
         
     }
    else if ([valN isEqualToString:@"WORK_EXP_DETAIL"] || [valN isEqualToString:@"EDUCATION_QUAL_DETAIL"] ){
         ExpericeFillUpTableViewCell * cell  =(ExpericeFillUpTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ExpericeFillUpTableViewCell"];
         if ([valN isEqualToString:@"WORK_EXP_DETAIL"]) {
             MRWorkExperience * obj  = [valNDict objectForKey:@"object"];
             
             cell.title.text = obj.designation;
             cell.dateDesc.text = [NSString stringWithFormat:@"%@ - %@",obj.fromDate,obj.toDate];
             cell.otherDesc.text = [NSString stringWithFormat:@"%@, %@",obj.hospital,obj.location];
             
             
         }else if([valN isEqualToString:@"EDUCATION_QUAL_DETAIL"]) {
             EducationalQualifications * obj  = [valNDict objectForKey:@"object"];
             
             cell.title.text = obj.course;
             cell.dateDesc.text = [NSString stringWithFormat:@"%@",obj.yearOfPassout    ];
             cell.otherDesc.text = [NSString stringWithFormat:@"From %@ with Aggregate %% %@",obj.collegeName,obj.aggregate];
             
             
         }
         return cell;
         
     }else if ([valN isEqualToString:@"PUBLICATION_DETAIL"] || [valN isEqualToString:@"INTEREST_AREA_DETAIL"] )
     {
         
         basicInfoTableViewCell *cell =(basicInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"basicInfoTableViewCell"];
         if ([valN isEqualToString:@"PUBLICATION_DETAIL"] ) {
             
             MRPublications * obj  = [valNDict objectForKey:@"object"];
             
             cell.titleOther.text = obj.articleName;
         }else {
             
             MRInterestArea * obj  = [valNDict objectForKey:@"object"];
             if ([[valNDict objectForKey:@"lastObj"] isEqualToString:@"YES"]) {
                 cell.viewLabel.hidden = YES;
             }
             cell.titleOther.text = obj.name;
         }
         
         return cell;
         
     }
     
     
     
     
     // Configure the cell...
 
 return nil;
 }

-(void)CommonProfileSectionTableViewCellDelegateForButtonPressed:(CommonProfileSectionTableViewCell *)cell withButtonType:(NSString *)buttonType{
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ProfileStoryboard" bundle:nil];
    
    if ([buttonType isEqualToString:@"WORK_EXP"]) {
        AddExperienceTableViewController *profViewController = [sb instantiateViewControllerWithIdentifier:@"AddExperienceTableViewController"];
        
        //                MRProfileDetailsViewController *profViewController = [[MRProfileDetailsViewController alloc] initWithNibName:@"AddExperienceTableViewController" bundle:nil];
        
        
        [self.navigationController pushViewController:profViewController  animated:YES];
        

    } else if ([buttonType isEqualToString:@"INTEREST_AREA"]){
//
        InterestViewController *profViewController = [sb instantiateViewControllerWithIdentifier:@"InterestViewController"];
        
         
        
        [self.navigationController pushViewController:profViewController  animated:YES];
        
    } else if ([buttonType isEqualToString:@"EDUCATION_QUAL"]){
        
        AddEducationViewController *educationViewController = (AddEducationViewController *)[sb instantiateViewControllerWithIdentifier:@"AddEducationViewController"];
        
        [self.navigationController pushViewController:educationViewController  animated:YES];
        
    }else if([buttonType isEqualToString:@"PUBLICATION"]){
        
        PublicationsViewController *profViewController = [sb instantiateViewControllerWithIdentifier:@"PublicationsViewController"];
        
        
        [self.navigationController pushViewController:profViewController  animated:YES];
        
    }
    
}

/*-(void)addProfileItemsTableViewCellDelegateForButtonPressed:(addProfileItemsTableViewCell *)cell;

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

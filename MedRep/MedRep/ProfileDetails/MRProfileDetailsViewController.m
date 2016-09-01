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
#import "EditLocationViewController.h"
#import "ContactInfoTableViewCell.h"
#import "AddressInfoTableViewCell.h"
#import "PublicationsViewController.h"
#import "ContactInfo+CoreDataProperties.h"
#import "AddressInfo+CoreDataProperties.h"
#import "EditContactInfoViewController.h"

@interface MRProfileDetailsViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate,ProfileBasicTableViewCellDelegate,CommonProfileSectionTableViewCellDelegate,ExpericeFillUpTableViewCellDelegate,basicInfoTableViewCellDelegate>

@property (assign, nonatomic) BOOL isImageUploaded;
@property (nonatomic,strong) NSMutableArray *commonSectionArray;
@property (nonatomic,strong) MRProfile *profileObj;
@property (nonatomic,strong) UIImage *profileImage;

@end

@implementation MRProfileDetailsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.showAsReadable = NO;
    }
    return self;
}

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
    
    UIBarButtonItem *revealButtonItem;
    if (self.showAsReadable) {
        revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(backButtonAction)];
    } else {
        SWRevealViewController *revealController = [self revealViewController];
        revealController.delegate = self;
        [revealController panGestureRecognizer];
        [revealController tapGestureRecognizer];
        
        revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController
                                                                    action:@selector(revealToggle:)];
    }
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"userLocal.png"]
                                                                         style:UIBarButtonItemStylePlain target:self
                                                                        action:@selector(editButtonTapped:)];
//    self.navigationItem.rightBarButtonItem = rightButtonItem;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
//    [self setupProfileData];
    // Do any additional setup after loading the view from its nib.
}

- (void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)editButtonTapped:(id)sender{
    
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshData)
                                                 name:kNotificationRefreshProfile                                               object:nil];
    
    [self setupProfileData];
}

- (void)refreshData {
    [self setupProfileData];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationRefreshProfile object:nil];
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
    
    
    [MRDatabaseHelper addProfileData:^(id result){
    _profileObj  = [result objectAtIndex:0];
        [self.tableView reloadData];

    }];
    
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
             [[MRAppControl sharedHelper].userRegData setObject:[responce objectForKey:@"result"] forKey:KProfilePicture];
//             self.profileImageView.image = [MRCommon imageWithImage:chosenImage scaledToSize:CGSizeMake(200, 200)];
             _profileImage = chosenImage;
             [self.tableView reloadData];
             [MRCommon showAlert:@"Profile Picture Updated Sucessfully" delegate:nil];
             [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshMenu
                                                                 object:self];
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

 
    return UITableViewCellEditingStyleNone;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    
    NSDictionary *valNDict = [[self setStructureForTableView] objectAtIndex:indexPath.row];
    
    NSString *valN = [valNDict objectForKey:@"type"];
    NSLog(@"NAMIT %@",valN);
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ProfileStoryboard" bundle:nil];
    if ([valN isEqualToString:@"WORK_EXP_DETAIL"]) {
        AddExperienceTableViewController *profViewController = [sb instantiateViewControllerWithIdentifier:@"AddExperienceTableViewController"];
        
        //                MRProfileDetailsViewController *profViewController = [[MRProfileDetailsViewController alloc] initWithNibName:@"AddExperienceTableViewController" bundle:nil];
        
        
        profViewController.fromScreen = @"UPDATE";
        profViewController.workExperience = (MRWorkExperience *)[valNDict objectForKey:@"object"];
        
        [self.navigationController pushViewController:profViewController  animated:YES];
        
        
    } else if ([valN isEqualToString:@"INTEREST_AREA_DETAIL"]){
        //
        InterestViewController *profViewController = [sb instantiateViewControllerWithIdentifier:@"InterestViewController"];
                profViewController.fromScreen = @"UPDATE";
        
        profViewController.interestAreaObj = (MRInterestArea *)[valNDict objectForKey:@"object"];
        
        [self.navigationController pushViewController:profViewController  animated:YES];
        
    } else if ([valN isEqualToString:@"EDUCATION_QUAL_DETAIL"]){
        
        AddEducationViewController *educationViewController = (AddEducationViewController *)[sb instantiateViewControllerWithIdentifier:@"AddEducationViewController"];
                educationViewController.fromScreen = @"UPDATE";
        
        
        educationViewController.educationQualObj = (EducationalQualifications *)[valNDict objectForKey:@"object"];
        
        [self.navigationController pushViewController:educationViewController  animated:YES];
        
    }else if([valN isEqualToString:@"PUBLICATION_DETAIL"]){
        
        PublicationsViewController *profViewController = [sb instantiateViewControllerWithIdentifier:@"PublicationsViewController"];
        
        profViewController.fromScreen = @"UPDATE";

        profViewController.publications = (MRPublications *)[valNDict objectForKey:@"object"];

        [self.navigationController pushViewController:profViewController  animated:YES];
        
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [MRCommon showActivityIndicator:@""];

        //add code here for when you hit delete
        NSDictionary *valNDict = [[self setStructureForTableView] objectAtIndex:indexPath.row];

        NSString *valN = [valNDict objectForKey:@"type"];
        if([valN isEqualToString:@"WORK_EXP_DETAIL"]){
            
            MRWorkExperience *exp = [valNDict objectForKey:@"object"];
            [MRDatabaseHelper deleteWorkExperienceFromTable:exp.id withHandler:^(id result) {
                _profileObj = nil;
                
                [MRDatabaseHelper addProfileData:^(id result){
                    _profileObj  = [result objectAtIndex:0];
                    [self.tableView reloadData];
                    [MRCommon stopActivityIndicator];
                    
                }];

            }];
            
        }else if([valN isEqualToString:@"EDUCATION_QUAL_DETAIL"] ){
            EducationalQualifications  *educQal = [valNDict objectForKey:@"object"];
            [MRDatabaseHelper deleteEducationQualificationFromTable:educQal.id withHandler:^(id result) {
                _profileObj = nil;
                
                [MRDatabaseHelper addProfileData:^(id result){
                    _profileObj  = [result objectAtIndex:0];
                    [self.tableView reloadData];
                    [MRCommon stopActivityIndicator];
                    
                }];

            }];


        }else if([valN isEqualToString:@"PUBLICATION_DETAIL"]){
         
            MRPublications *pub = [valNDict objectForKey:@"object"];
            [MRDatabaseHelper deletePublicationAreaFromTable:pub.id withHandler:^(id result) {
                _profileObj = nil;
                
                [MRDatabaseHelper addProfileData:^(id result){
                    _profileObj  = [result objectAtIndex:0];
                    [self.tableView reloadData];
                    [MRCommon stopActivityIndicator];
                    
                }];

            }];

            
        }else if([valN isEqualToString:@"INTEREST_AREA_DETAIL"]){
            
            MRInterestArea *interestAre = [valNDict objectForKey:@"object"];

            [MRDatabaseHelper deleteInterestAreaFromTable:interestAre.id withHandler:^(id result) {
                _profileObj = nil;
                
                [MRDatabaseHelper addProfileData:^(id result){
                    _profileObj  = [result objectAtIndex:0];
                    [self.tableView reloadData];
                    [MRCommon stopActivityIndicator];
                    
                }];

            }];

        }
        
    }
    
}
-(void)basicInfoTableViewCellDelegateForButtonPressed:(basicInfoTableViewCell *)cell withButtonType:(NSString *)buttonType{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self deleteProfileData:indexPath];
    
    
}

-(void)ExpericeFillUpTableViewCellDelegateForButtonPressed:(ExpericeFillUpTableViewCell *)cell withButtonType:(NSString *)buttonType{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self deleteProfileData:indexPath];
    

}
-(void)deleteProfileData:(NSIndexPath *)indexPath{
    
    [MRCommon showActivityIndicator:@""];
    
    //add code here for when you hit delete
    NSDictionary *valNDict = [[self setStructureForTableView] objectAtIndex:indexPath.row];
    
    NSString *valN = [valNDict objectForKey:@"type"];
    if([valN isEqualToString:@"WORK_EXP_DETAIL"]){
        
        MRWorkExperience *exp = [valNDict objectForKey:@"object"];
        [MRDatabaseHelper deleteWorkExperienceFromTable:exp.id withHandler:^(id result) {
            _profileObj = nil;
            
            [MRDatabaseHelper addProfileData:^(id result){
                _profileObj  = [result objectAtIndex:0];
                [self.tableView reloadData];
                [MRCommon stopActivityIndicator];
                
            }];
            
        }];
        
    }else if([valN isEqualToString:@"EDUCATION_QUAL_DETAIL"] ){
        EducationalQualifications  *educQal = [valNDict objectForKey:@"object"];
        [MRDatabaseHelper deleteEducationQualificationFromTable:educQal.id withHandler:^(id result) {
            _profileObj = nil;
            
            [MRDatabaseHelper addProfileData:^(id result){
                _profileObj  = [result objectAtIndex:0];
                [self.tableView reloadData];
                [MRCommon stopActivityIndicator];
                
            }];
            
        }];
        
        
    }else if([valN isEqualToString:@"PUBLICATION_DETAIL"]){
        
        MRPublications *pub = [valNDict objectForKey:@"object"];
        [MRDatabaseHelper deletePublicationAreaFromTable:pub.id withHandler:^(id result) {
            _profileObj = nil;
            
            [MRDatabaseHelper addProfileData:^(id result){
                _profileObj  = [result objectAtIndex:0];
                [self.tableView reloadData];
                [MRCommon stopActivityIndicator];
                
            }];
            
        }];
        
        
    }else if([valN isEqualToString:@"INTEREST_AREA_DETAIL"]){
        
        MRInterestArea *interestAre = [valNDict objectForKey:@"object"];
        
        [MRDatabaseHelper deleteInterestAreaFromTable:interestAre.id withHandler:^(id result) {
            _profileObj = nil;
            
            [MRDatabaseHelper addProfileData:^(id result){
                _profileObj  = [result objectAtIndex:0];
                [self.tableView reloadData];
                [MRCommon stopActivityIndicator];
                
            }];
            
        }];
        
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
   else if ([valN isEqualToString:@"CONTACT_INFO_DETAIL"]) {
        return 104;
    }
    else  if ([valN isEqualToString:@"ABOUT"]){
        return 60;
    } else if ([valN isEqualToString:@"ADDRESS_INFO_DETAIL"]) {
        return 128;
    }
    else if([valN isEqualToString:@"WORK_EXP"]|| [valN isEqualToString:@"INTEREST_AREA"] || [valN isEqualToString:@"EDUCATION_QUAL"] || [valN isEqualToString:@"PUBLICATION"] ||
            [valN isEqualToString:@"ADDRESS_INFO"] || [valN isEqualToString:@"CONTACT_INFO"]) {
      return   [self heightAdjustOnBasisOfRecordsForType:valN];
    }
    else if([valN isEqualToString:@"ADD_BUTTON"]) {
        return 40;
    } else if ([valN isEqualToString:@"WORK_EXP_DETAIL"] || [valN isEqualToString:@"EDUCATION_QUAL_DETAIL"]){
        return 95;
    }else if ([valN isEqualToString:@"PUBLICATION_DETAIL"] || [valN isEqualToString:@"INTEREST_AREA_DETAIL"] )
    {
        return 40;
    }
    
    return 40;
}

-(NSInteger)heightAdjustOnBasisOfRecordsForType:(NSString *)type{

    if (([type isEqualToString:@"INTEREST_AREA"] && _profileObj.interestArea.array.count >0 ) ||
        ([type isEqualToString:@"ADDRESS_INFO"] && _profileObj.addressInfo.array.count >0) ||
        ([type isEqualToString:@"WORK_EXP"] && _profileObj.workExperience.array.count >0) ||
        ([type isEqualToString:@"EDUCATION_QUAL"] && _profileObj.educationlQualification.array.count >0) || ([type isEqualToString:@"PUBLICATION"] && _profileObj.publications.array.count >0) ||
            ([type isEqualToString:@"CONTACT_INFO"] && _profileObj.contactInfo != nil)
        ) {
        return 64;
    }
    
    return 115;
}
-(NSArray*)setStructureForTableView{
    
    NSMutableArray *temp = [NSMutableArray array];
    
    [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"PROFILE_BASIC",@"type", nil]];
    [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"ABOUT",@"type", nil]];
    
    [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"CONTACT_INFO",@"type", nil]];
    if (_profileObj.contactInfo != nil) {
        [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"CONTACT_INFO_DETAIL",@"type",_profileObj.contactInfo,@"object",@"NO",@"lastObj" ,nil]];
    }
    
    [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"ADDRESS_INFO",@"type", nil]];
    
    [_profileObj.addressInfo.array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        AddressInfo * addressInfo = (AddressInfo *)obj;
        
        if (_profileObj.addressInfo.array.count-1 == idx){
            [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"ADDRESS_INFO_DETAIL",@"type",addressInfo,@"object",@"YES",@"lastObj" ,nil]];
            
        } else{
            [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"ADDRESS_INFO_DETAIL",@"type",addressInfo,@"object",@"NO",@"lastObj" ,nil]];
        }
    }];

    [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"WORK_EXP",@"type", nil]];
    
    [_profileObj.workExperience.array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        MRWorkExperience * workexp = (MRWorkExperience *)obj;
        
        if(_profileObj.workExperience.array.count-1 == idx){
            [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"WORK_EXP_DETAIL",@"type",workexp,@"object",@"YES",@"lastObj" ,nil]];
            
        }else{
            [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"WORK_EXP_DETAIL",@"type",workexp,@"object",@"NO",@"lastObj" ,nil]];
        }
    }];
   
    [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"INTEREST_AREA",@"type", nil]];

    
    [_profileObj.interestArea.array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MRInterestArea * workexp = (MRInterestArea *)obj;
        if (_profileObj.interestArea.array.count -1 == idx) {
            [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"INTEREST_AREA_DETAIL",@"type",workexp,@"object",@"YES",@"lastObj" ,nil]];
            
        }else{
            
            [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"INTEREST_AREA_DETAIL",@"type",workexp,@"object",@"NO",@"lastObj" ,nil]];
            
            
        }
    }];
    
    [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"EDUCATION_QUAL",@"type", nil]];

    [_profileObj.educationlQualification.array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EducationalQualifications * workexp = (EducationalQualifications *)obj;
        if (_profileObj.educationlQualification.array.count-1 == idx) {
           
            [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"EDUCATION_QUAL_DETAIL",@"type",workexp,@"object",@"YES",@"lastObj"  ,nil]];

        }else{
        
        [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"EDUCATION_QUAL_DETAIL",@"type",workexp,@"object",@"NO",@"lastObj"  ,nil]];
        }
        
    }];
   
    [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"PUBLICATION",@"type", nil]];

    [_profileObj.publications.array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MRPublications * workexp = (MRPublications *)obj;
        [temp addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"PUBLICATION_DETAIL",@"type",workexp,@"object" ,nil]];
    }];
  
    return temp;
}
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

     
     NSDictionary *valNDict = [[self setStructureForTableView] objectAtIndex:indexPath.row];
     NSString *valN = [valNDict objectForKey:@"type"];
     if ([valN isEqualToString:@"PROFILE_BASIC"]) {
         ProfileBasicTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"ProfileBasicTableViewCell"] forIndexPath:indexPath];
         NSDictionary *userdata = [MRAppControl sharedHelper].userRegData;
         cell.delegate = self;
         
         NSInteger userType = [MRAppControl sharedHelper].userType;
         
         cell.userNameLbl.text         = _profileObj.name;
         cell.userLocation.text = _profileObj.location;
         
         if (self.showAsReadable) {
             [cell.pencilBtn setHidden:NO];
             [cell.imageBtn setUserInteractionEnabled:NO];
         } else {
             [cell.pencilBtn setHidden:YES];
             [cell.imageBtn setUserInteractionEnabled:YES];
         }
         
         
//         if (_profileImage!=nil) {
//             cell.profileimageView.image = _profileImage;
//         }else{
         
             NSURL * imageURL = [NSURL URLWithString:[userdata objectForKey:KProfilePicture]];
             
             
             dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
             dispatch_async(queue, ^{
                 NSData *data = [NSData dataWithContentsOfURL:imageURL];
                 UIImage *image = [UIImage imageWithData:data];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     cell.profileimageView.image = image;
                 });  
             });
         //}
         
        
         
         return cell;
     } else if([valN isEqualToString:@"CONTACT_INFO_DETAIL"]){
         ContactInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"ContactInfoTableViewCell"] forIndexPath:indexPath];
         if (_profileObj.contactInfo) {
             if (_profileObj.contactInfo.alternateEmail != nil) {
                 cell.secondaryEmailLbl.text = _profileObj.contactInfo.alternateEmail;
             cell.secondaryEmailLbl.hidden = NO;
             }else{
                 cell.secondaryEmailLbl.hidden = YES;
             }
             cell.primaryEmailLbl.text = _profileObj.contactInfo.email;
             cell.primaryContactNumberLbl.text = _profileObj.contactInfo.mobileNo;
             if (_profileObj.contactInfo.phoneNo!=nil) {
                 cell.secondaryContactNumberLbl.text = _profileObj.contactInfo.phoneNo;
             }
             
         }
         return cell;
     } else if([valN isEqualToString:@"ADDRESS_INFO_DETAIL"]){
         AddressInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"AddressInfoTableViewCell"] forIndexPath:indexPath];
         
         AddressInfo *addressInfo = [valNDict valueForKey:@"object"];
         NSMutableArray *tempAddresses = [_profileObj.addressInfo mutableCopy];
         [tempAddresses removeLastObject];
         
         [cell setCellData:addressInfo contactInfo:_profileObj.contactInfo andParentViewController:self];
             
         if ([[valNDict objectForKey:@"lastObj"] isEqualToString:@"YES"]) {
             cell.viewLabel.hidden = YES;
         }
         
         if (_profileObj.addressInfo.array.count == 1) {
             // There is only one location at present
             cell.deleteAddressButtonWidthConstraint.constant = 0.0;
             cell.deleteAddressButtonTrailingConstraint.constant = 0.0;
             cell.editButtonTrailingConstraint.constant = 20.0;
         }
         
         if (self.showAsReadable) {
             [cell.deleteAddressButton setHidden:YES];
             [cell.editButton setHidden:YES];
         }
         
         return cell;
     } else if([valN isEqualToString:@"ABOUT"]) {
         ProfileAboutTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"ProfileAboutTableViewCell"] forIndexPath:indexPath];
         cell.specialityLbl.text = _profileObj.designation;
         
         return cell;

     }
     
     else if([valN isEqualToString:@"WORK_EXP"]|| [valN isEqualToString:@"INTEREST_AREA"] ||
             [valN isEqualToString:@"EDUCATION_QUAL"] || [valN isEqualToString:@"PUBLICATION"] ||
             [valN isEqualToString:@"ADDRESS_INFO"] || [valN isEqualToString:@"CONTACT_INFO"]) {
         CommonProfileSectionTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"CommonProfileSectionTableViewCell"] forIndexPath:indexPath];
         
        [cell setCommonProfileDataForType:valN withUserProfileData:_profileObj];
         cell.delegate = self;
         
         if ([valN isEqualToString:@"EDUCATION_QUAL"]) {
             [cell.indicatorImageView setImage:[UIImage imageNamed:@"EducationQualifications"]];
         } else if ([valN isEqualToString:@"INTEREST_AREA"]) {
             [cell.indicatorImageView setImage:[UIImage imageNamed:@"TherapeuticArea"]];
         } else if ([valN isEqualToString:@"CONTACT_INFO"]) {
             [cell.addButton setImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
         }
         
         if (self.showAsReadable) {
             [cell.addButton setHidden:YES];
         }
         
         return cell;
     }
    else if ([valN isEqualToString:@"WORK_EXP_DETAIL"] || [valN isEqualToString:@"EDUCATION_QUAL_DETAIL"] ){
         ExpericeFillUpTableViewCell * cell  =(ExpericeFillUpTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ExpericeFillUpTableViewCell"];
        cell.delegate = self;
        if ([[valNDict objectForKey:@"lastObj"] isEqualToString:@"YES"]) {
            cell.viewLabel.hidden = YES;
        }
         if ([valN isEqualToString:@"WORK_EXP_DETAIL"]) {
             MRWorkExperience * obj  = [valNDict objectForKey:@"object"];
             
             cell.title.text = obj.designation;
             cell.dateDesc.text = [NSString stringWithFormat:@"%@ - %@",obj.fromDate,obj.toDate];
             cell.otherDesc.text = [NSString stringWithFormat:@"%@, %@",obj.hospital,obj.location];
             
             
         }else if([valN isEqualToString:@"EDUCATION_QUAL_DETAIL"]) {
             EducationalQualifications * obj  = [valNDict objectForKey:@"object"];
             
             cell.title.text = obj.course;
             cell.dateDesc.text = [NSString stringWithFormat:@"%@",obj.yearOfPassout    ];
             cell.otherDesc.text = [NSString stringWithFormat:@"From %@ with Aggregate %@%%",obj.collegeName,obj.aggregate];
         }
        
        if (self.showAsReadable) {
            [cell.addButton setHidden:YES];
        }
         return cell;
         
     }else if ([valN isEqualToString:@"PUBLICATION_DETAIL"] || [valN isEqualToString:@"INTEREST_AREA_DETAIL"] )
     {
         
         basicInfoTableViewCell *cell =(basicInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"basicInfoTableViewCell"];
         cell.delegate = self;
         if ([valN isEqualToString:@"PUBLICATION_DETAIL"] ) {
             
             MRPublications * obj  = [valNDict objectForKey:@"object"];
             
             cell.titleOther.text = obj.articleName;
         }else {
             
             MRInterestArea * obj  = [valNDict objectForKey:@"object"];
             if ([[valNDict objectForKey:@"lastObj"] isEqualToString:@"YES"]) {
                 cell.viewLabel.hidden = YES;
             } else {
                 cell.viewLabel.hidden = NO;
             }
             cell.titleOther.text = obj.name;
         }
         
         if (self.showAsReadable) {
             [cell.addButton setHidden:YES];
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
        [self.navigationController pushViewController:profViewController  animated:YES];

    } else if ([buttonType isEqualToString:@"INTEREST_AREA"]){
        InterestViewController *profViewController = [sb instantiateViewControllerWithIdentifier:@"InterestViewController"];
        [self.navigationController pushViewController:profViewController  animated:YES];
        
    } else if ([buttonType isEqualToString:@"EDUCATION_QUAL"]){
        AddEducationViewController *educationViewController = (AddEducationViewController *)[sb instantiateViewControllerWithIdentifier:@"AddEducationViewController"];
        
        [self.navigationController pushViewController:educationViewController  animated:YES];
        
    } else if([buttonType isEqualToString:@"PUBLICATION"]){
        
        PublicationsViewController *profViewController = [sb instantiateViewControllerWithIdentifier:@"PublicationsViewController"];
        
        [self.navigationController pushViewController:profViewController  animated:YES];
    } else if([buttonType isEqualToString:@"CONTACT_INFO"]){
        
        EditContactInfoViewController *editContactVC = [EditContactInfoViewController new];
        [editContactVC setContactInfo:_profileObj.contactInfo];
        [self.navigationController pushViewController:editContactVC  animated:YES];
    } else if([buttonType isEqualToString:@"ADDRESS_INFO"]) {
        EditLocationViewController *editLocationVC = [EditLocationViewController new];
        [self.navigationController pushViewController:editLocationVC  animated:YES];
    }
}
-(void)ProfileBasicTableViewCellDelegateForButtonPressed:(ProfileBasicTableViewCell *)cell withButtonType:(NSString *)buttonType{
    UIActionSheet* popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take New Picture", @"Choose From Library", nil];
    
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [popupQuery showInView:self.view];
    NSLog(@"ProfileButtonTableViewCell");
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSInteger i = buttonIndex;
    
    switch(i) {
            
        case 0:
        {
            
            //Code for camera
            [self takePhoto:UIImagePickerControllerSourceTypeCamera];
        }
            break;
        case 1:
        {
            [self takePhoto:UIImagePickerControllerSourceTypePhotoLibrary];
        }
            
        default:
            // Do Nothing.........
            break;
            
    }
}
-(void)takePhoto:(UIImagePickerControllerSourceType)type {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = type;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
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

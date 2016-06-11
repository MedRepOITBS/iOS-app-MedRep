//
//  MRConstants.h
//  MedRep
//
//  Created by MedRep Developer on 10/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#ifdef DEBUG
#define MSAssert(condition) NSParameterAssert(condition)
#else
#define MSAssert(condition)
#endif

#ifdef DEBUG
#define MSLog(...) NSLog(__VA_ARGS__)
#else
#define MSLog(...)
#endif

#define MRDefaults  [NSUserDefaults standardUserDefaults]
// Sort order types.
typedef enum
{
    SORT_ORDER_NONE = 0,
    SORT_ORDER_ASCENDING,
    SORT_ORDER_DESCENDING
} SORT_ORDER;

#define kAppName                @"MedRep"

#define MPLocalizedString(key)      [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:@"InfoPlist"]
#define kUserRole                   [NSArray arrayWithObjects:@"Doctor",@"Company",@"Pharmarep",@"Patient",nil]
#define kUserTitle                  [NSArray arrayWithObjects:@"Dr",@"Dr",@"Mr",@"Mr",nil]
#define kUserQualification          [NSArray arrayWithObjects:@"Doctor",@"Doctor",@"",@"",nil]

#define kRGBCOLOR(R,G,B)        [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]

#define kRGBCOLORALPHA(R,G,B,A)        [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

#define kNetworkMessage         @"Unable to communicate with server internet access is required."
#define kResult                 @"Result"
#define kUserName               @"Username"
//#define kPassword               @"Password"
#define kResponce               @"Responce"

#define kRefreshToken           @"refreshToken"
#define kAuthenticationToken    @"AuthenticationToken"

#define KDoctorRegID            @"DoctorRegistrationID"
#define KFirstName              @"FirstName"
#define KLastName               @"LastName"
#define KMobileNumber           @"MobileNumber"
#define KEmail                  @"Email"
#define KProfilePicture         @"profilePicture"

#define KRegistarionStageTwo    @"RegistarionStageTwo"

#define KAddressOne             @"address1"
#define KAdresstwo              @"address2"
#define KState                  @"State"
#define KCity                   @"city"
#define KZIPCode                @"ZIPCode"
#define KTitle                  @"title"
#define KType                  @"type"
//#define kAreaWorkLocation       @"AreaWorkLocation"

#define KAreasCovered           @"coveredArea"
#define kManagerName            @"managerName"
#define kManagerEmail           @"managerEmail"
#define kManagerMobileNumber    @"managerMobileNumber"

#define KPassword               @"password"
//Appointment Scheduled  Successfully, Do you want to syn to Calander
#define KDownloadConfirmationMSG    @"Are you sure \n You want to \n download?"
#define KScheduleConfirmationMSG    @"Appointment Scheduled  Successfully\nDo you want to \n add this to your \n Calender?"
#define KAppointmentCompletedConfirmationMSG    @"Are you sure this appointment is completed?"
#define KAppointmentAcceptConfirmationMSG    @"Are you sure you want to Accept this Appointment?"

//#define KPaidServiceMSG    @"This is a paid feature.\nClick “Ok” and our team will contact u shortly…"

#define KPaidServiceMSG    @"Please email us your request at info@erfolglifesciences.com\n or\n info@medrep.in"

//Please email us your request at info@erfolglifesciences.com  or  info@medrep.in


#define kDashboardNotificationFromRegistartionScren     @"DashboardNotificationFromRegistartionScren"
#define kMedRepMeetingsNotification                     @"MedRepMeetingsNotification"


#define kShotMonthsArray            [NSArray arrayWithObjects:@"Jan",@"Feb",@"March",@"April",@"May",@"June",@"July",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec",nil]


#define kComingsoonMSG      @"This functionality is under development"//@"This feature is not available right now."//@"Coming soon…"

#define kCompanyAccessMSG      @"Please send a contact request to info@erfolglifesciences.com or info@medrep.in to gain access to the medrep application."//@"Coming soon…"


#define kNotificationFetchedDate    @"NotificationFetchedDate"



/*
 
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
 return 20;
 }
 
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 return 44.0;
 }
 - (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 NSString *CellIdentifier            = @"cellIdentifier";
 UITableViewCell *appointmentCell    = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 if (appointmentCell == nil)
 {
 appointmentCell     = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 appointmentCell.selectionStyle = UITableViewCellSelectionStyleNone;
 }
 
 appointmentCell.textLabel.text = @"therapeuticName";
 
 return appointmentCell;
 }
 
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 }

 */


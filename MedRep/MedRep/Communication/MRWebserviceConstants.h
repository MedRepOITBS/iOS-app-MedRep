//
//  MRWebserviceConstants.h
//  MedRep
//
//  Created by MedRep Developer on 10/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//


//#define kBaseURL        @"http://medreplb-84253066.ap-southeast-1.elb.amazonaws.com" //live

#define kBaseURL            @"http://45.114.142.241:8080/MedRepApplication"  //Appstore

//#define kBaseURL            @"http://183.82.106.234:8080/MedRepApplication" //test

//http://45.114.142.241:8080

//Update http://183.82.106.234:8080/MedRepApplication with http://medrep.in/

//Can you please replace medrep.in with medreplb-84253066.ap-southeast-1.elb.amazonaws.com like below.


//http://medreplb-84253066.ap-southeast-1.elb.amazonaws.com/preapi/masterdata/getTherapeuticAreaDetails


typedef enum kMRWebServiceType
{
    kMRWebServiceTypeNone = 0,
    kMRWebServiceTypeRefreshToken,
    kMRWebServiceTypeLogin,
    kMRWebServiceTypeSignUp,
    kMRWebServiceTypeSignUpRep,
    kMRWebServiceTypeUploadDP,
    kMRWebServiceTypeForgotPassword,
    kMRWebServiceTypeEmailVerification,
    kMRWebServiceTypeCreateAppointment,
    kMRWebServiceTypeUpdateAppointment,
    kMRWebServiceTypeGetMyAppointment,
    kMRWebServiceTypeGetMyNotifications,
    kMRWebServiceTypeGetDoctorProfile,
    kMRWebServiceTypeGetMyRole,
    kMRWebServiceTypeGetPharmaProfile,
    kMRWebServiceTypeUpdateMyDetails,
    kMRWebServiceTypeTherapeuticAreaDetails,
    kMRWebServiceTypeNotificationTypes,
    kMRWebServiceTypeRoles,
    kMRWebServiceTypeCompanyDetails,
    kMRWebServiceTypeNewSMSOTP,
    kMRWebServiceTypeVerifyMobileNo,
    kMRWebServiceTypeRecreateOTP,
    kMRWebServiceTypeGetOTP,
    kMRWebServiceTypeGetMyRepsDetails,
    kMRWebServiceTypeGetMyPendingSurveys,
    kMRWebServiceTypeMyRole,
    kMRWebServiceTypeGetMyNotificationContent,
    kMRWebServiceTypeupdateNotificationDetails,
    kMRWebServiceTypeUpdateDoctorDetails,
    kMRWebServiceTypeUpdatePharmaDetails,
    kMRWebServiceTypeGetMyNotificationsPharma,
    kMRWebServiceTypeGetMyDoctorsPharma,
    kMRWebServiceTypeGetMyPendingAppointmentPharma,
    kMRWebServiceTypeGetMyAppointmentPharma,
    kMRWebServiceTypeGetDoctorProfilePharma,
    kMRWebServiceTypeGetNotificationStats,
    kMRWebServiceTypeGetAppointmentsByNotificationId,
    kMRWebServiceTypeGetDoctorProfileByID,
    kMRWebServiceTypeGetNotificationActivityScore,
    kMRWebServiceTypeGetDoctorActivityScoreByID,
    kMRWebServiceTypeGetDoctorActivityScore,
    kMRWebServiceTypeGetMyCompanyDoctors,
    kMRWebServiceTypeGetMyTeam,
    kMRWebServiceTypeGetPharaRepProfileByID,
    kMRWebServiceTypeGetAppointmentsByRepID,
    kMRWebServiceTypeUpdateAppointmnet,
    kMRWebServiceTypeAcceptAppointmnet,
    kMRWebServiceTypeGetNotificationById,
    kMRWebServiceTypeGetMyCompany,
    kMRWebServiceTypeGetDoctorNotificationStatsById,
    kMRWebServiceTypeGetMyUpcomingAppointment,
    kMRWebServiceTypeGetMyCompletedAppointment,
    kMRWebServiceTypeGetMyMyTeamPendingAppointments,

} kMRWebServiceType;



/*
Sign In
http://183.82.106.234:8080/MedRepApplication/oauth/token?grant_type=password&client_id=restapp&client_secret=restapp&username=ashraf.umar&password=Test123
 
Refresh Token
http://183.82.106.234:8080/MedRepApplication/oauth/token?grant_type=refresh_token&client_id=restapp&client_secret=restapp&refresh_token=7ac7940a-d29d-4a4c-9a47-25a2167c8c49
 
Sign Up
http://183.82.106.234:8080/MedRepApplication/preapi/registration/signupDoctor
 
http://183.82.106.234:8080/MedRepApplication/preapi/registration/signupRep
 
UploadDP
http://183.82.106.234:8080/MedRepApplication/preapi/registration/uploadDP
 
GetOTP <<THIS IS JUST TEMP. Actual Message will be sent over SMS >>
http://183.82.106.234:8080/MedRepApplication/app/preapi/registration/getOTP/{token}
 
Email Verification
To Be Done
Phone No Verification
http://183.82.106.234:8080/MedRepApplication/preapi/registration/verifyMobileNo?token=79315&number=9971666956
 
Get My Details
http://183.82.106.234:8080/MedRepApplication/api/profile/getDoctorProfile?access_token=62fb897e-29a8-46bf-aa30-38f33252ae19
 
Update My Details
http://183.82.106.234:8080/MedRepApplication/api/profile/UpdateDoctorProfile?access_token=62fb897e-29a8-46bf-aa30-38f33252ae19
 */

/*
 http://183.82.106.234:8080/MedRepApplication/api/doctor/getMyAppointment/{startDate}?access_token=20e20067-2f67-4d22-b405-f8039cc9f1b6
 */

/*
 
 http://183.82.106.234:8080/MedRepApplication/api/doctor/getMyNotifications/{startDate}?access_token=4a0094a2-3560-4c66-b798-c6e73a3f1bf6
 >
 > in the start date i am passing value as 20150917 (YYYYMMDD) format, and below is the response i am getting.
 >
 > As you see, I am getting 2 notifications. 1st one has 2 notification details(Id 1, and 2) and second one has 3 of them (Id 3, 4 and 5).
 >
 > [
 >       {
 >       "notificationId": 1,
 >       "notificationDesc": "Test Description",
 >       "notificationName": null,
 >       "typeId": 1,
 >       "therapeuticId": "1",
 >       "companyId": "3",
 >       "updatedOn": null,
 >       "updatedBy": null,
 >       "createdOn": 1442431938000,
 >       "createdBy": null,
 >       "validUpto": null,
 >       "status": "NEW",
 >       "externalRef": "none",
 >       "companyName": null,
 >       "therapeuticName": null,
 >       "notificationDetails":       [
 >                   {
 >             "detailId": 1,
 >             "notificationId": 1,
 >             "detailTitle": null,
 >             "detailDesc": null,
 >             "contentType": "JPEG",
 >             "contentSeq": 1,
 >             "contentLocation": "/home/medrep/data/notifications/1/1/Cipla_1.png",
 >             "contentName": "Test"
 >          },
 >                   {
 >             "detailId": 2,
 >             "notificationId": 1,
 >             "detailTitle": null,
 >             "detailDesc": null,
 >             "contentType": "JPEG",
 >             "contentSeq": 2,
 >             "contentLocation": "/home/medrep/data/notifications/1/2/Cipla_2.png",
 >             "contentName": "Test"
 >          }
 >       ],
 >       "slide": null,
 >       "fileList": null
 >    },
 >       {
 >       "notificationId": 2,
 >       "notificationDesc": "Test Description 2",
 >       "notificationName": null,
 >       "typeId": 1,
 >       "therapeuticId": "1",
 >       "companyId": "2",
 >       "updatedOn": null,
 >       "updatedBy": null,
 >       "createdOn": 1442431938000,
 >       "createdBy": null,
 >       "validUpto": null,
 >       "status": "NEW",
 >       "externalRef": "none",
 >       "companyName": null,
 >       "therapeuticName": null,
 >       "notificationDetails":       [
 >                   {
 >             "detailId": 3,
 >             "notificationId": 2,
 >             "detailTitle": null,
 >             "detailDesc": null,
 >             "contentType": "JPEG",
 >             "contentSeq": 1,
 >             "contentLocation": "/home/medrep/data/notifications/2/3/Cipla_3.png",
 >             "contentName": "Test"
 >          },
 >                   {
 >             "detailId": 4,
 >             "notificationId": 2,
 >             "detailTitle": null,
 >             "detailDesc": null,
 >             "contentType": "JPEG",
 >             "contentSeq": 2,
 >             "contentLocation": "/home/medrep/data/notifications/2/4/Cipla_4.png",
 >             "contentName": "Test"
 >          },
 >                   {
 >             "detailId": 5,
 >             "notificationId": 2,
 >             "detailTitle": null,
 >             "detailDesc": null,
 >             "contentType": "JPEG",
 >             "contentSeq": 3,
 >             "contentLocation": "/home/medrep/data/notifications/2/5/Cipla_5.png",
 >             "contentName": "Test"
 >          }
 >       ],
 >       "slide": null,
 >       "fileList": null
 >    }
 > ]
 >
 
 */

//
//  MRWebserviceHelper.m
//  MedRep
//
//  Created by MedRep Developer on 10/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRWebserviceHelper.h"
#import "MRConstants.h"
#import "MRAppControl.h"
#import "MRCommon.h"
#import "NSDate+Utilities.h"

@interface MRWebserviceHelper ()

@property (nonatomic, strong) NSMutableURLRequest *lastServiceRequest;
@property (nonatomic, strong) NSString *lastServiceURLString;
@property (nonatomic, strong) completionHandler lastServiceCompletionhandler;

@end

@implementation MRWebserviceHelper

+ (MRWebserviceHelper*)sharedWebServiceHelper
{
    static dispatch_once_t once;
    static MRWebserviceHelper *sharedHelper;
    
    dispatch_once(&once, ^{
        sharedHelper = [[MRWebserviceHelper alloc] init];
    });
    return sharedHelper;
}

- (NSDictionary*)getJSonData:(NSString*)jsonResponce
{
     NSError *error = nil;
    return [NSJSONSerialization JSONObjectWithData:[jsonResponce dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
}

- (NSDictionary*)getValideteResponse:(NSString*)theResponse
{
    
    NSDictionary *responceDict = nil;
    
    if ([[self getJSonData:theResponse] isKindOfClass:[NSArray class]]) {
        responceDict = [NSDictionary dictionaryWithObjectsAndKeys:[self getJSonData:theResponse],kResponce, nil];
        
    } else {
        responceDict = [self getJSonData:theResponse];
    }
    return [responceDict dictionaryByReplacingNullsWithBlanks];

}

- (void)sendServiceRequest:(NSMutableURLRequest*)theRequest
               withHandler:(completionHandler)responceHandler
{
    MRAppControl *appController = [MRAppControl sharedHelper];
    BOOL isInternetAvailable = [appController internetCheck];
    
    if (isInternetAvailable == NO)
    {
        [MRCommon stopActivityIndicator];
        [MRCommon showAlert:kNetworkMessage delegate:nil];
        responceHandler(NO, nil,nil);
        return;
    }

    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *authSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURLSessionDataTask *dTask = [authSession dataTaskWithRequest:theRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        __block NSString *theResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ([data length] > 0 && error == 0 && [httpResponse statusCode] == 200)
        {

          __block NSDictionary *responceDict = [self getValideteResponse:theResponse];
            
            if ([theResponse rangeOfString:@"<HTML>"].location != NSNotFound ||
                [theResponse rangeOfString:@"<html>"].location != NSNotFound ||
                [theResponse rangeOfString:@"<head>"].location != NSNotFound ||
                [theResponse rangeOfString:@"</head>"].location != NSNotFound ||
                [theResponse rangeOfString:@"<faultcode>"].location != NSNotFound ||
                [theResponse rangeOfString:@"<FAULTCODE>"].location != NSNotFound || [[responceDict objectForKey:@"status"] isEqualToString:@"Error"])
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [MRCommon stopActivityIndicator];
                    if (self.serviceType != kMRWebServiceTypeRefreshToken)
                    {
                        [MRCommon showAlert:@"Failed to get a response from the server. Please try later." delegate:nil];
                    }
                    responceHandler(NO, theResponse, responceDict);
                }];
            }
            else
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if ([[responceDict objectForKey:@"status"] isEqualToString:@"Fail"])
                    {
                        [MRCommon stopActivityIndicator];
                        [MRCommon showAlert:[responceDict objectForKey:@"message"] delegate:nil];
                        responceHandler(NO, theResponse,responceDict);
                    }
                    else
                    {
                        responceHandler(YES, theResponse,responceDict);
                    }
                }];
            }
        }
        else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSString *theResponce = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSDictionary *responceDict = [self getValideteResponse:theResponse];
                if ([[responceDict objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
                {
                    responceHandler(NO, theResponce, responceDict);
                }
                else
                {
                  [MRCommon stopActivityIndicator];
                    if (self.serviceType != kMRWebServiceTypeRefreshToken && self.serviceType != kMRWebServiceTypeLogin)
                    {
                          [MRCommon showAlert:@"Failed to get a response from the server. Please try later." delegate:nil];
                    }
                  responceHandler(NO, theResponce, responceDict);
                }
            }];
        }
    }];
    
    [dTask resume];

}

- (void)userLogin:(NSString*)userName
       andPasword:(NSString*)password withHandler:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/oauth/token?grant_type=password&client_id=restapp&client_secret=restapp&username=%@&password=%@",kBaseURL,userName,password];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    
    // Setting post
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeLogin;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

- (void)refreshToken:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/oauth/token?grant_type=refresh_token&client_id=restapp&client_secret=restapp&refresh_token=%@",kBaseURL,[MRDefaults objectForKey:kRefreshToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeRefreshToken;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

#pragma mark ---- Master Services -------

// option screen
- (void)getRoles:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/preapi/masterdata/getRoles
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/preapi/masterdata/getRoles",kBaseURL];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeRoles;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

//notifications 2 , sort by screens
- (void)getTherapeuticAreaDetails:(completionHandler)responceHandler
{
    ////http://183.82.106.234:8080/MedRepApplication/preapi/masterdata/getTherapeuticAreaDetails
    //http://183.82.106.234:8080/MedRepApplication/preapi/masterdata/getTherapeuticAreaDetails
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/preapi/masterdata/getTherapeuticAreaDetails",kBaseURL];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeTherapeuticAreaDetails;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

- (void)getNotificationTypes:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/preapi/masterdata/getNotificationTypes
    
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/preapi/masterdata/getNotificationTypes",kBaseURL];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeNotificationTypes;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

- (void)getCompanyDetails:(completionHandler)responceHandler
{
   // http://183.82.106.234:8080/MedRepApplication/preapi/masterdata/getCompanyDetails
    
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/preapi/masterdata/getCompanyDetails",kBaseURL];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeCompanyDetails;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

- (void)verifyMobileNumber:(NSString*)mobileNumber
                   withOTP:(NSString*)mobileOTP
               withHandler:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/preapi/registration/verifyMobileNo?token=79315&number=9971666956
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/preapi/registration/verifyMobileNo?token=%@&number=%@",kBaseURL,mobileOTP,mobileNumber];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeVerifyMobileNo;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];

}

- (void)getNewSMSOTP:(NSString*)str withComplitionHandler:(completionHandler)responceHandler
{
    
    //http://183.82.106.234:8080/MedRepApplication/preapi/registration/getOTP/9020488567
    //http://183.82.106.234:8080/MedRepApplication/preapi/registration/getOTP/9247204720
    
    //str = @"9247204720"; //testing purpose
    
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/preapi/registration/getOTP/%@",kBaseURL,str];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeNewSMSOTP;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

// 1st stage reg screen
- (void)getVerifyMobileNo:(NSString*)str withComplitionHandler:(completionHandler)responceHandler
{
}

// Recreate password.
- (void)getRecreateOTP:(NSString*)str withComplitionHandler:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/preapi/registration/getNewSMSOTP/{token}
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/preapi/registration/getNewSMSOTP/%@/",kBaseURL,str];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeRecreateOTP;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}


/*
1.GET OTP:

http://183.82.106.234:8080/MedRepApplication/preapi/registration/getNewSMSOTP/9247204720

{"id":null,"otp":"34842","type":"MOBILE","verificationId":"9247204720","securityId":null,"status":"WAITING"}

2.Verification OTP:

http://183.82.106.234:8080/MedRepApplication/preapi/registration/verifyMobileNo?token=34842&number=9247204720

{"status":"OK","message":"Success"}

hit getOTP for verifing status
{"id":null,"otp":"34842","type":"MOBILE","verificationId":"9247204720","securityId":null,"status":"VERIFIED"}

3. Recreate OTP - forget password

http://183.82.106.234:8080/MedRepApplication/preapi/registration/getNewSMSOTP/ssr@gmail.com/
*/
- (void)getOTP:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/app/preapi/registration/getOTP/%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetOTP;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

- (void)getDoctorProfileDetails:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/api/profile/getDoctorProfile?access_token=62fb897e-29a8-46bf-aa30-38f33252ae19
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/profile/getDoctorProfile?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetDoctorProfile;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

- (void)getMyPendingSurveysDetails:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/api/doctor/getMyPendingSurveys?access_token=6ac9da4d
    //http://183.82.106.234:8080/MedRepApplication/api/doctor/getMyPendingSurveys?access_token=6ac9da4d-0835-4574-99d2-41c5a8069c66
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/doctor/getMyPendingSurveys?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyPendingSurveys;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

- (void)getMyRepsDetails:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/api/doctor/getMyReps?access_token=57d57a18-e46a-4568-b191-465e6f2fdfec
    
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/doctor/getMyReps?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyRepsDetails;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

- (void)sendSignUp:(NSDictionary*)userDetails
       withHandler:(completionHandler)responceHandler
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    /*
     
     accountNonExpired = 1;
     accountNonLocked = 1;
     alias = "<null>";
     alternateEmailId = "<null>";
     authorities =     (
     );
     credentialsNonExpired = 1;
     doctorId = 14;
     emailId = "rajesh.rallabandi008@gmail.com";
     enabled = 1;
     firstName = Doctor;
     lastName = Doctor;
     locations =     (
     {
     address1 = "Address 1";
     address2 = "Address 2";
     city = Gurgaon;
     country = "<null>";
     locationId = "<null>";
     state = AP;
     type = "<null>";
     zipcode = 123456;
     },
     {
     address1 = "Address 1";
     address2 = "Address 2";
     city = Gurgaon;
     country = "<null>";
     locationId = "<null>";
     state = AP;
     type = "<null>";
     zipcode = 123456;
     }
     );
     loginTime = "<null>";
     middleName = "";
     mobileNo = 9030917448;
     password = "<null>";
     phoneNo = "<null>";
     qualification = Doctor;
     registrationNumber = 123456789;
     registrationYear = 2014;
     roleId = 1;
     roleName = Admin;
     stateMedCouncil = XP;
     status = "<null>";
     therapeuticId = 1;
     therapeuticName = Demo;
     title = "Dr. ";
     userSecurityId = 15;
     username = "rajesh.rallabandi008@gmail.com";
     }
     */
    
    [dict setObject:[[userDetails objectForKey:KEmail] objectAtIndex:0] forKey:@"username"];
    [dict setObject:[userDetails objectForKey:KPassword]  forKey:@"password"];
    [dict setObject:[NSNull null]  forKey:@"loginTime"];
    [dict setObject:[NSNull null]  forKey:@"userSecurityId"];
    [dict setObject:[NSNull null]  forKey:@"status"];
    [dict setObject:[NSArray array]  forKey:@"authorities"];
    //"registrationNumber":
    //[dict setObject:[userDetails objectForKey:KDoctorRegID]  forKey:@"registrationNumber"];
    [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"accountNonExpired"];
    [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"accountNonLocked"];
    [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"credentialsNonExpired"];
    [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"enabled"];
    [dict setObject:[NSNumber numberWithInteger:[MRAppControl sharedHelper].userType] forKey:@"roleId"];
    [dict setObject:[MRCommon getRole:[MRAppControl sharedHelper].userType]  forKey:@"roleName"];
    [dict setObject:[userDetails objectForKey:KFirstName] forKey:@"firstName"];
    [dict setObject:[userDetails objectForKey:KLastName] forKey:@"lastName"];
    [dict setObject:[userDetails objectForKey:KLastName] forKey:@"middleName"];
    [dict setObject:[NSNull null]  forKey:@"alias"];
    [dict setObject:[MRCommon getTitle:[MRAppControl sharedHelper].userType] forKey:@"title"];
    [dict setObject:[[userDetails objectForKey:KMobileNumber] objectAtIndex:0] forKey:@"mobileNo"];
    
    if ([[userDetails objectForKey:KMobileNumber] objectAtIndex:1]) {
        [dict setObject:[[userDetails objectForKey:KMobileNumber] objectAtIndex:1] forKey:@"phoneNo"];
    }
    else {
        [dict setObject:[NSNull null] forKey:@"mobileNo"];
    }
    
    [dict setObject:[[userDetails objectForKey:KEmail] objectAtIndex:0] forKey:@"emailId"];
    if ([[userDetails objectForKey:KEmail] objectAtIndex:1]) {
        [dict setObject:[[userDetails objectForKey:KEmail] objectAtIndex:1] forKey:@"alternateEmailId"];
    }
    else{
        [dict setObject:[NSNull null] forKey:@"alternateEmailId"];
    }
    
    [dict setObject:[userDetails objectForKey:KDoctorRegID] forKey:@"registrationNumber"];
    [dict setObject:[MRCommon getQulification:[MRAppControl sharedHelper].userType] forKey:@"qualification"];

    [dict setObject:[NSString stringWithFormat:@"%ld",(long)[NSDate date].year] forKey:@"registrationYear"];
    [dict setObject:@"XP" forKey:@"stateMedCouncil"];
    [dict setObject:[userDetails objectForKey:@"therapeuticId"] forKey:@"therapeuticId"];

    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *regDetails = [userDetails objectForKey:KRegistarionStageTwo];
    
    for (NSDictionary *dict in  regDetails)
    {
        NSDictionary *dictObj = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"locationId",
                                 [dict objectForKey:KAddressOne], @"address1",
                                 [dict objectForKey:KAdresstwo], @"address2",
                                 [dict objectForKey:KCity],@"city",
                                 [dict objectForKey:KState],@"state",
                                 [NSNull null],@"country",
                                 [dict objectForKey:KZIPCode],@"zipcode",
                                 [dict objectForKey:KType],@"type",nil];
        
        [array addObject:dictObj];
    }
    
    [dict setObject:array forKey:@"locations"];
    
    
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/preapi/registration/signupDoctor",kBaseURL];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody: jsonData];
    self.serviceType = kMRWebServiceTypeSignUp;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

- (void)uploadDP:(NSDictionary*)DPdetails
     withHandler:(completionHandler)responceHandler
{    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNull null] forKey:@"dpId"];
    [dict setObject:[DPdetails objectForKey:@"ImageData"] forKey:@"data"];
    [dict setObject:@"JPEG" forKey:@"mimeType"];
    [dict setObject:[MRCommon getLoginEmail] forKey:@"loginId"];
    [dict setObject:[NSNull null] forKey:@"securityId"];
    
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/preapi/registration/uploadDP",kBaseURL];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody: jsonData];
    self.serviceType = kMRWebServiceTypeUploadDP;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

//http://183.82.106.234:8080/MedRepApplication/preapi/registration/forgotPassword
- (void)sendForgotPassword:(NSDictionary*)userDetails
               withHandler:(completionHandler)responceHandler
{
    //{"userName":"umar.ashraf@gmail.com", "otp":"12345", "newPassword":":P@ssword1", "confirmPassword":":P@ssword1", "verificationType":"SMS"}
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    [dict setObject:[userDetails objectForKey:@"userName"] forKey:@"userName"];
    [dict setObject:[userDetails objectForKey:@"otp"]  forKey:@"otp"];
    [dict setObject:[userDetails objectForKey:@"newPassword"]  forKey:@"newPassword"];
    [dict setObject:[userDetails objectForKey:@"confirmPassword"]  forKey:@"confirmPassword"];
    [dict setObject:[userDetails objectForKey:@"verificationType"]  forKey:@"verificationType"];
    
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/preapi/registration/forgotPassword",
                                 kBaseURL];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody: jsonData];
    self.serviceType = kMRWebServiceTypeForgotPassword;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

- (void)updateMyDetails:(NSDictionary*)userDetails
            withHandler:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/api/profile/updateDoctorProfile?access_token=62fb897e
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:[[userDetails objectForKey:KEmail] objectAtIndex:0] forKey:@"username"];
    //[dict setObject:[userDetails objectForKey:KPassword]  forKey:@"password"];
    [dict setObject:[NSNull null]  forKey:@"loginTime"];
    [dict setObject:[NSNull null]  forKey:@"userSecurityId"];
    [dict setObject:[NSNull null]  forKey:@"status"];
    [dict setObject:[NSArray array]  forKey:@"authorities"];
    [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"accountNonExpired"];
    [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"accountNonLocked"];
    [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"credentialsNonExpired"];
    [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"enabled"];
    [dict setObject:[NSNumber numberWithInteger:[MRAppControl sharedHelper].userType] forKey:@"roleId"];
    [dict setObject:[MRCommon getRole:[MRAppControl sharedHelper].userType]  forKey:@"roleName"];
    [dict setObject:[userDetails objectForKey:KFirstName] forKey:@"firstName"];
    [dict setObject:[userDetails objectForKey:KLastName] forKey:@"lastName"];
    [dict setObject:[userDetails objectForKey:KLastName] forKey:@"middleName"];
    [dict setObject:[NSNull null]  forKey:@"alias"];
    [dict setObject:[MRCommon getTitle:[MRAppControl sharedHelper].userType] forKey:@"title"];
    [dict setObject:[[userDetails objectForKey:KMobileNumber] objectAtIndex:0] forKey:@"mobileNo"];
    
    if ([[userDetails objectForKey:KMobileNumber] objectAtIndex:1]) {
        [dict setObject:[[userDetails objectForKey:KMobileNumber] objectAtIndex:1] forKey:@"phoneNo"];
    }
    else {
        [dict setObject:[NSNull null] forKey:@"mobileNo"];
    }
    
    [dict setObject:[[userDetails objectForKey:KEmail] objectAtIndex:0] forKey:@"emailId"];
    if ([[userDetails objectForKey:KEmail] objectAtIndex:1]) {
        [dict setObject:[[userDetails objectForKey:KEmail] objectAtIndex:1] forKey:@"alternateEmailId"];
    }
    else{
        [dict setObject:[NSNull null] forKey:@"alternateEmailId"];
    }
    
    [dict setObject:[userDetails objectForKey:KDoctorRegID] forKey:@"registrationNumber"];
    [dict setObject:[MRCommon getQulification:[MRAppControl sharedHelper].userType] forKey:@"qualification"];
    
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)[NSDate date].year] forKey:@"registrationYear"];
    [dict setObject:@"XP" forKey:@"stateMedCouncil"];
    [dict setObject:[userDetails objectForKey:@"therapeuticId"] forKey:@"therapeuticId"];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *regDetails = [userDetails objectForKey:KRegistarionStageTwo];
    
    for (NSDictionary *dict in  regDetails)
    {
        NSDictionary *dictObj = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"locationId",
                                 [dict objectForKey:KAddressOne], @"address1",
                                 [dict objectForKey:KAdresstwo], @"address2",
                                 [dict objectForKey:KCity],@"city",
                                 [dict objectForKey:KState],@"state",
                                 [NSNull null],@"country",
                                 [dict objectForKey:KZIPCode],@"zipcode",
                                 [dict objectForKey:KType],@"type",nil];
        
        [array addObject:dictObj];
    }
    
    [dict setObject:array forKey:@"locations"];
    
    //http://183.82.106.234:8080/MedRepApplication/api/profile/updateDoctorProfile?access_token=62fb897e
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/profile/updateDoctorProfile?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody: jsonData];
    self.serviceType = kMRWebServiceTypeUpdateDoctorDetails;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
    

}

- (void)updateSurveyStatus:(NSDictionary*)surveyDetails
               withHandler:(completionHandler)responceHandler
{
    
}

//call medRip
- (void)createNewAppointment:(NSDictionary*)appointmentDetails
                isFromUpdate:(BOOL)isFromCreate
                 withHandler:(completionHandler)responceHandler
{
    if (isFromCreate)
    {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[appointmentDetails objectForKey:@"notificationName"] forKey:@"title"]; // notificationName
        
        [dict setObject:[appointmentDetails objectForKey:@"notificationDesc"] forKey:@"appointmentDesc"];
        
        [dict setObject:[appointmentDetails objectForKey:@"notificationId"] forKey:@"notificationId"];
        [dict setObject:[appointmentDetails objectForKey:@"startDate"]  forKey:@"startDate"];
        [dict setObject:[appointmentDetails objectForKey:@"duration"]  forKey:@"duration"];
        [dict setObject:[appointmentDetails objectForKey:@"location"] forKey:@"location"];
        //[dict setObject:@"Feedback" forKey:@"feedback"];
        
        //[dict setObject:[[[MRAppControl sharedHelper] userRegData] objectForKey:KDoctorRegID] forKey:@"doctorId"];
        [dict setObject:@"Pending" forKey:@"status"]; //@"Pending"
        //[dict setObject:[appointmentDetails objectForKey:@"startDate"] forKey:@"createdOn"];
        
         NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/doctor/createAppointment?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        NSURL *url = [NSURL URLWithString:stringFormOfUrl];
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [urlRequest setTimeoutInterval:120];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [urlRequest setHTTPBody: jsonData];
        self.serviceType = isFromCreate ? kMRWebServiceTypeCreateAppointment : kMRWebServiceTypeUpdateAppointment;
        [self sendServiceRequest:urlRequest withHandler:responceHandler];
    }
    else
    {
        
        /*
         http://183.82.106.234:8080/MedRepApplication/api/doctor/updateAppointment?access_token=b1b71a47-f16d-47c6-9061-a9afa89ca333
         {
         "title": "null",
         "location": "Location1",
         "status": "Update",
         "notificationId": "1",
         "doctorId": "",
         "appointmentDesc": "No Description",
         "appointmentId": "1",
         "feedback": "Feedback",
         "startDate": "201510291000",
         "duration": "30"
         }
         */
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:[appointmentDetails objectForKey:@"title"] forKey:@"title"];
        [dict setObject:[appointmentDetails objectForKey:@"location"]  forKey:@"location"];
        [dict setObject:@"Update" forKey:@"status"];
        
        [dict setObject:[appointmentDetails objectForKey:@"notificationId"] forKey:@"notificationId"];
        [dict setObject:[appointmentDetails objectForKey:@"doctorId"] forKey:@"doctorId"];

        [dict setObject:[appointmentDetails objectForKey:@"appointmentDesc"] forKey:@"appointmentDesc"];
        [dict setObject:[appointmentDetails objectForKey:@"appointmentId"] forKey:@"appointmentId"];
        [dict setObject:[appointmentDetails objectForKey:@"feedback"] forKey:@"feedback"];

        [dict setObject:[appointmentDetails objectForKey:@"startDate"]  forKey:@"startDate"];
        [dict setObject:[appointmentDetails objectForKey:@"duration"]  forKey:@"duration"];
        
        
        NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/doctor/updateAppointment?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        NSURL *url = [NSURL URLWithString:stringFormOfUrl];
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [urlRequest setTimeoutInterval:120];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [urlRequest setHTTPBody: jsonData];
        self.serviceType = isFromCreate ? kMRWebServiceTypeCreateAppointment : kMRWebServiceTypeUpdateAppointment;
        [self sendServiceRequest:urlRequest withHandler:responceHandler];
    }
}

- (void)updateNotification:(NSDictionary*)notificationDetails
                         withHandler:(completionHandler)responceHandler
{
    //(http://183.82.106.234:8080/MedRepApplication/api/doctor/updateMyNotification?access_token=ab04ac82-6b19-492d-9e17-3e4fab387062) favour click
    /*
     {
     "notificationId": 9,
     "doctorId": 25,
     "viewStatus": "Pending",
     "favourite": "Y",
     "rating": "4.5",
     "prescribe":"Y",
     "recomend":"N",
     "viewedOn": "20150905011030",
     "userNotificationId": 1
     }
     */
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    
    [dict setObject:[notificationDetails objectForKey:@"notificationId"] forKey:@"notificationId"];
    //[dict setObject:[[[MRAppControl sharedHelper] userRegData] objectForKey:KDoctorRegID] forKey:@"doctorId"];
    [dict setObject:[notificationDetails objectForKey:@"viewStatus"]  forKey:@"viewStatus"];
    
    if ([notificationDetails objectForKey:@"favourite"])
    {
        [dict setObject:[notificationDetails objectForKey:@"favourite"]  forKey:@"favourite"];
    }
    
    if ([notificationDetails objectForKey:@"rating"]) {
        [dict setObject:[notificationDetails objectForKey:@"rating"]  forKey:@"rating"];
    }
    
    if ([notificationDetails objectForKey:@"prescribe"]) {
        [dict setObject:[notificationDetails objectForKey:@"prescribe"]  forKey:@"prescribe"];
    }
    
    if ([notificationDetails objectForKey:@"recomend"]) {
        [dict setObject:[notificationDetails objectForKey:@"recomend"]  forKey:@"recomend"];
    }
    
    [dict setObject:[notificationDetails objectForKey:@"viewedOn"]  forKey:@"viewedOn"];
    //[dict setObject:[notificationDetails objectForKey:@"userNotificationId"]  forKey:@"userNotificationId"];
    
    NSString *stringFormOfUrl =  [NSString stringWithFormat:@"%@/api/doctor/updateMyNotification?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody: jsonData];
    self.serviceType =  kMRWebServiceTypeupdateNotificationDetails;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];

}

- (void)getMyNotificationContent:(NSInteger)detailNotificationId
              withHandler:(completionHandler)responceHandler
{
   //http://183.82.106.234:8080/MedRepApplication/api/doctor/getMyNotificationContent/{detailNotificationId}?access_token=ab04ac82-6b19-492d-9e17-3e4fab387062
    
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/doctor/getMyNotificationContent/%ld?access_token=%@",kBaseURL,detailNotificationId,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyNotificationContent;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];

}

- (void)getMyAppointments:(NSString*)appointmentDate
             withHandler:(completionHandler)responceHandler
{
    
   // http://183.82.106.234:8080//MedRepApplication/api/doctor/getMyAppointment/20150101?access_token=8c4ccf50-f09a-495b-a8ef-be6c354fb07a
    //appointmentDate = @"20150101";
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/doctor/getMyAppointment/%@?access_token=%@",kBaseURL,appointmentDate,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyAppointment;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

//http://183.82.106.234:8080/MedRepApplication/api/doctor/getMyNotifications/{startDate}?access_token=4a0094a2-3560-4c66-b798-c6e73a3f1bf6
- (void)getMyNotifications:(NSString*)startDate
              withHandler:(completionHandler)responceHandler
{
   // http://183.82.106.234:8080/MedRepApplication/api/doctor/getMyNotifications/20150101?access_token=8c4ccf50-f09a-495b-a8ef-be6c354fb07a
    //startDate = @"20150101";
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/doctor/getMyNotifications/%@?access_token=%@",kBaseURL,startDate,[MRDefaults objectForKey:kAuthenticationToken]];
        
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyNotifications;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];

}


#pragma mark ------------------------------
#pragma mark -  Pharma Rep Services
#pragma mark ------------------------------

- (void)sendPharmaRepSignUp:(NSDictionary*)userDetails
                withHandler:(completionHandler)responceHandler
{
     //http://183.82.106.234:8080/MedRepApplication/preapi/registration/signupRep
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[userDetails objectForKey:KEmail] objectAtIndex:0] forKey:@"username"];
    [dict setObject:[userDetails objectForKey:KPassword]  forKey:@"password"];
    
    [dict setObject:[NSNumber numberWithInteger:[MRAppControl sharedHelper].userType] forKey:@"roleId"];
    [dict setObject:[MRCommon getRole:[MRAppControl sharedHelper].userType]  forKey:@"roleName"];
    
    [dict setObject:[userDetails objectForKey:KFirstName] forKey:@"firstName"];
    [dict setObject:[userDetails objectForKey:KLastName] forKey:@"lastName"];
    [dict setObject:[userDetails objectForKey:KLastName] forKey:@"middleName"];

    [dict setObject:[userDetails objectForKey:KFirstName]  forKey:@"alias"];
    [dict setObject:[MRCommon getTitle:[MRAppControl sharedHelper].userType] forKey:@"title"];
    
    [dict setObject:[[userDetails objectForKey:KMobileNumber] objectAtIndex:0] forKey:@"mobileNo"];
    if ([[userDetails objectForKey:KMobileNumber] objectAtIndex:1]) {
        [dict setObject:[[userDetails objectForKey:KMobileNumber] objectAtIndex:1] forKey:@"phoneNo"];
    }
    else {
        [dict setObject:[NSNull null] forKey:@"mobileNo"];
    }
    
    [dict setObject:[[userDetails objectForKey:KEmail] objectAtIndex:0] forKey:@"emailId"];
    if ([[userDetails objectForKey:KEmail] objectAtIndex:1]) {
        [dict setObject:[[userDetails objectForKey:KEmail] objectAtIndex:1] forKey:@"alternateEmailId"];
    }
    else{
        [dict setObject:[NSNull null] forKey:@"alternateEmailId"];
    }

    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *regDetails = [userDetails objectForKey:KRegistarionStageTwo];
    
    for (NSDictionary *dict in  regDetails)
    {
        NSDictionary *dictObj = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"locationId",
                                 [dict objectForKey:KAddressOne], @"address1",
                                 [dict objectForKey:KAdresstwo], @"address2",
                                 [dict objectForKey:KCity],@"city",
                                 [dict objectForKey:KState],@"state",
                                 [NSNull null],@"country",
                                 [dict objectForKey:KZIPCode],@"zipcode",
                                 [dict objectForKey:KType],@"type",nil];
        
        [array addObject:dictObj];
    }
    
    [dict setObject:array forKey:@"locations"];

    [dict setObject:[userDetails objectForKey:kManagerEmail]forKey:kManagerEmail];
    [dict setObject:[userDetails objectForKey:KDoctorRegID] forKey:@"companyId"];

    /*
    [dict setObject:[NSNull null]  forKey:@"loginTime"];
    [dict setObject:[NSNull null]  forKey:@"userSecurityId"];
    [dict setObject:[NSNull null]  forKey:@"status"];
    [dict setObject:[NSArray array]  forKey:@"authorities"];
    [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"accountNonExpired"];
    [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"accountNonLocked"];
    [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"credentialsNonExpired"];
    [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"enabled"];
    [dict setObject:[MRCommon getQulification:[MRAppControl sharedHelper].userType] forKey:@"qualification"];
    
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)[NSDate date].year] forKey:@"registrationYear"];
    [dict setObject:@"XP" forKey:@"stateMedCouncil"];
    [dict setObject:@"1" forKey:@"therapeuticId"];
    */
    
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/preapi/registration/signupRep",kBaseURL];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody: jsonData];
    self.serviceType = kMRWebServiceTypeSignUpRep;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

//http://183.82.106.234:8080/MedRepApplication/api/profile/getPharmaRepProfile

- (void)getPharmaProfileDetails:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/api/profile/getPharmaRepProfile?access_token=62fb897e-29a8-46bf-aa30-38f33252ae19
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/profile/getPharmaRepProfile?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetPharmaProfile;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

- (void)updateMyPharmaDetails:(NSDictionary*)userDetails
                  withHandler:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/api/profile/updatePharmaRepProfile?access_token=62fb897e-29a8-46bf-aa30-38f33252ae19
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[userDetails objectForKey:KEmail] objectAtIndex:0] forKey:@"username"];
    //[dict setObject:[userDetails objectForKey:KPassword]  forKey:@"password"];
    
    [dict setObject:[NSNumber numberWithInteger:[MRAppControl sharedHelper].userType] forKey:@"roleId"];
    [dict setObject:[MRCommon getRole:[MRAppControl sharedHelper].userType]  forKey:@"roleName"];
    
    [dict setObject:[userDetails objectForKey:KFirstName] forKey:@"firstName"];
    [dict setObject:[userDetails objectForKey:KLastName] forKey:@"lastName"];
    [dict setObject:[userDetails objectForKey:KLastName] forKey:@"middleName"];
    
    [dict setObject:[userDetails objectForKey:KFirstName]  forKey:@"alias"];
    [dict setObject:[MRCommon getTitle:[MRAppControl sharedHelper].userType] forKey:@"title"];
    
    [dict setObject:[[userDetails objectForKey:KMobileNumber] objectAtIndex:0] forKey:@"mobileNo"];
    if ([[userDetails objectForKey:KMobileNumber] objectAtIndex:1]) {
        [dict setObject:[[userDetails objectForKey:KMobileNumber] objectAtIndex:1] forKey:@"phoneNo"];
    }
    else {
        [dict setObject:[NSNull null] forKey:@"mobileNo"];
    }
    
    [dict setObject:[[userDetails objectForKey:KEmail] objectAtIndex:0] forKey:@"emailId"];
    if (([(NSArray*)[userDetails objectForKey:KEmail] count] > 1) && [[userDetails objectForKey:KEmail] objectAtIndex:1]) {
        [dict setObject:[[userDetails objectForKey:KEmail] objectAtIndex:1] forKey:@"alternateEmailId"];
    }
    else{
        [dict setObject:[NSNull null] forKey:@"alternateEmailId"];
    }
    
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *regDetails = [userDetails objectForKey:KRegistarionStageTwo];
    
    for (NSDictionary *dict in  regDetails)
    {
        NSDictionary *dictObj = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"locationId",
                                 [dict objectForKey:KAddressOne], @"address1",
                                 [dict objectForKey:KAdresstwo], @"address2",
                                 [dict objectForKey:KCity],@"city",
                                 [dict objectForKey:KState],@"state",
                                 [NSNull null],@"country",
                                 [dict objectForKey:KZIPCode],@"zipcode",
                                 [dict objectForKey:KType],@"type",nil];
        
        [array addObject:dictObj];
    }
    
    [dict setObject:array forKey:@"locations"];
    
    [dict setObject:[userDetails objectForKey:kManagerEmail]forKey:kManagerEmail];
    [dict setObject:[userDetails objectForKey:KDoctorRegID] forKey:@"companyId"];
    
    /*
     [dict setObject:[NSNull null]  forKey:@"loginTime"];
     [dict setObject:[NSNull null]  forKey:@"userSecurityId"];
     [dict setObject:[NSNull null]  forKey:@"status"];
     [dict setObject:[NSArray array]  forKey:@"authorities"];
     [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"accountNonExpired"];
     [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"accountNonLocked"];
     [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"credentialsNonExpired"];
     [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"enabled"];
     [dict setObject:[MRCommon getQulification:[MRAppControl sharedHelper].userType] forKey:@"qualification"];
     
     [dict setObject:[NSString stringWithFormat:@"%ld",(long)[NSDate date].year] forKey:@"registrationYear"];
     [dict setObject:@"XP" forKey:@"stateMedCouncil"];
     [dict setObject:@"1" forKey:@"therapeuticId"];
     */
    
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/profile/updatePharmaRepProfile?access_token=%@",kBaseURL, [MRDefaults objectForKey:kAuthenticationToken]];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody: jsonData];
    self.serviceType = kMRWebServiceTypeUpdatePharmaDetails;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

- (void)getMyRole:(completionHandler)responceHandler
{
    //kMRWebServiceTypeMyRole
    
    //http://183.82.106.234:8080/MedRepApplication/api/profile/getMyRole?access_token=6022923e-1f0f-42cb-9c12-1f6d32847dcb
    
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/profile/getMyRole?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyRole;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];

}

- (void)getPharmaNotifications:(NSString*)startDate
                   withHandler:(completionHandler)responceHandler
{
    // http://183.82.106.234:8080/MedRepApplication/api/pharmarep/getMyNotifications/{startDate}?access_token=ab04ac82-6b19-492d-9e17-3e4fab387062
    startDate = @"20150101";
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/pharmarep/getMyNotifications/%@?access_token=%@",kBaseURL,startDate,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyNotificationsPharma;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
    
}


- (void)getMyDoctorsForPharma:(completionHandler)responceHandler
{
    // http://183.82.106.234:8080/MedRepApplication/api/pharmarep/getMyDoctors?access_token=ab04ac82-6b19-492d-9e17-3e4fab387062
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/pharmarep/getMyDoctors?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyDoctorsPharma;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
    
}

- (void)updateMyNotificationForPharma:(NSDictionary*)notificationDetails
                  withHandler:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/api/pharmarep/updateMyNotification?access_token=ab04ac82-6b19-492d-9e17-3e4fab387062
    //{"notificationId":1,"doctorId":16,"viewStatus":"Y","favourite":"Y","feedback":"Very Good","viewedOn":"20150905011030","userNotificationId":1}
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
 
    [dict setObject:[notificationDetails objectForKey:@"notificationId"] forKey:@"notificationId"];
    [dict setObject:[notificationDetails objectForKey:@"doctorId"] forKey:@"doctorId"];
    [dict setObject:[notificationDetails objectForKey:@"viewStatus"] forKey:@"viewStatus"];
    [dict setObject:[notificationDetails objectForKey:@"favourite"] forKey:@"favourite"];
    [dict setObject:[notificationDetails objectForKey:@"feedback"] forKey:@"feedback"];
    [dict setObject:[notificationDetails objectForKey:@"viewedOn"] forKey:@"viewedOn"];
    [dict setObject:[notificationDetails objectForKey:@"userNotificationId"] forKey:@"userNotificationId"];

    
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/pharmarep/updateMyNotification?access_token=%@",kBaseURL, [MRDefaults objectForKey:kAuthenticationToken]];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody: jsonData];
    self.serviceType = kMRWebServiceTypeUpdatePharmaDetails;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

- (void)getMyPendingAppointmentForPharma:(completionHandler)responceHandler
{
    // http://183.82.106.234:8080/MedRepApplication/api/pharmarep/getMyPendingAppointment?access_token=ab04ac82-6b19-492d-9e17-3e4fab387062
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/pharmarep/getMyPendingAppointment?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyPendingAppointmentPharma;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
    
}

- (void)acceptAppointmentForPharma:(NSDictionary*)appointmentDetails
                          withHandler:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/api/pharmarep/acceptAppointment??access_token=60e6bfaa-0b61-42a4-92cd-3f71d3def6b2
    /*
     {
     "appointmentId": 1,
     "status": "Accept"
     }
     
     {
     "appointmentId": 1,
     "status": "Declined"
     }
     */
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:[appointmentDetails objectForKey:@"appointmentId"] forKey:@"appointmentId"];
    [dict setObject:[appointmentDetails objectForKey:@"status"] forKey:@"status"];

    
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/pharmarep/acceptAppointment?access_token=%@",kBaseURL, [MRDefaults objectForKey:kAuthenticationToken]];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody: jsonData];
    self.serviceType = kMRWebServiceTypeUpdatePharmaDetails;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

//http://183.82.106.234:8080/MedRepApplication/api/pharmarep/getMyAppointment?access_token=5be66382-f964-45d6-a07a-b36273675e91
- (void)getMyAppointmentForPharma:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/api/pharmarep/getMyAppointment?access_token=20e20067-2f67-4d22-b405-f8039cc9f1b6
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/pharmarep/getMyAppointment?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyAppointmentPharma;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

- (void)getDoctorProfileForPharma:(NSString*)token
                      withHandler:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/api/profile/getDoctorProfile/{token}?access_token=20e20067-2f67-4d22-b405-f8039cc9f1b6
    
    //http://183.82.106.234:8080/MedRepApplication/api/profile/getDoctorProfile/{token}?access_token=62fb897e-29a8-46bf-aa30-38f33252ae19
    

    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/profile/getDoctorProfile/%@?access_token=%@",kBaseURL,token,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetDoctorProfilePharma;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}
//http://183.82.106.234:8080/MedRepApplication/api/analytic/getNotificationStats/{notificationId}?access_token=20e20067-2f67-4d22-b405-f8039cc9f1b6

- (void)getNotificationStatsForPharma:(NSString*)notificationId
                                  withHandler:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/analytic/getNotificationStats/%@?access_token=%@",kBaseURL,notificationId,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetNotificationStats;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

//http://183.82.106.234:8080/MedRepApplication/api/analytic/getAppointmentsByNotificationId/{notificationId}?access_token=9f7a9cec-81a6-44a4-8ae6-


- (void)getAppointmentsByNotificationIdForPharma:(NSString*)notificationId
                          withHandler:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/analytic/getAppointmentsByNotificationId/%@?access_token=%@",kBaseURL,notificationId,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetAppointmentsByNotificationId;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

- (void)getDoctorProfileDetailsByID:(NSString*)doctorId
                    withHandler:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/api/profile/getDoctorProfile/{token}?access_token=20e20067-2f67-4d22-b405-f8039cc9f1b6
    
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/profile/getDoctorProfile/%@?access_token=%@",kBaseURL,doctorId,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetDoctorProfileByID;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

//http://183.82.106.234:8080/MedRepApplication/api/analytic/getNotificationActivityScore/{notificationId}?access_token=20e20067-2f67-4d22-b405-f8039cc9f1b

- (void)getNotificationActivityScoreForPharma:(NSString*)notificationId
                            withHandler:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/analytic/getNotificationActivityScore/%@?access_token=%@",kBaseURL,notificationId,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetNotificationActivityScore;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
    
}

////http://183.82.106.234:8080/MedRepApplication/api/analytic/getDoctorActivityScore/{doctorId}?access_token=20e20067-2f67-4d22-b405-f8039cc9f1b6
- (void)getDoctorActivityScoreForPharma:(NSString*)doctorId
                      withHandler:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/analytic/getDoctorActivityByCompany/%@?access_token=%@",kBaseURL,doctorId,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetDoctorActivityScoreByID;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

//http://183.82.106.234:8080/MedRepApplication/api/profile/getMyCompanyDoctors?access_token=63ea69ca-58ab-488d-952b-603bbcbdabdf
- (void)getMyCompanyDoctors:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/profile/getMyCompanyDoctors?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyCompanyDoctors;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

//http://183.82.106.234:8080/MedRepApplication/api/profile/getMyTeam?access_token=63ea69ca-58ab-488d-952b-603bbcbdabdf
- (void)getMyteam:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/profile/getMyTeam?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyTeam;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}
//http://183.82.106.234:8080/MedRepApplication/api/profile/getPharaRepProfile/{token}?access_token=63ea69ca-58ab-488d-952b-603bbcbdabdf

//http://183.82.106.234:8080/MedRepApplication/api/profile/getPharmaRepProfile/{token}?access_token=63ea69ca
- (void)getPharaRepProfile:(NSString*)pharmaId
                            withHandler:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/profile/getPharmaRepProfile/%@?access_token=%@",kBaseURL,pharmaId,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetPharaRepProfileByID;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}


//http://183.82.106.234:8080/MedRepApplication/api/pharmarep/getAppointmentsByRep/{repId}?access_token=20e20067-2f67-4d22-b405-f8039cc9f1b6
- (void)getAppointmentsByRep:(NSString*)pharmaId
               withHandler:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/pharmarep/getAppointmentsByRep/%@?access_token=%@",kBaseURL,pharmaId,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetAppointmentsByRepID;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

//

/*
 "appointmentId": 1,
 "feedback": "Testing Feed Back",
 "status": "Completed"
 */

- (void)updateAppointments:(NSDictionary*)userDetails
            withHandler:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/api/pharmarep/updateAppointment?access_token=dd3a82ba-2c5d-43d5-aeca-b0548aa81f5f
    //http://183.82.106.234:8080/MedRepApplication/api/doctor/updateAppointment?access_token=20e20067-2f67-4d22-b405-f8039cc9f1b6
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/pharmarep/updateAppointment?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
     NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:[userDetails objectForKey:@"appointmentId"] forKey:@"appointmentId"];
    [dict setObject:@"Completed" forKey:@"status"];
    [dict setObject:[userDetails objectForKey:@"feedback"] forKey:@"feedback"];

    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody: jsonData];
    self.serviceType = kMRWebServiceTypeUpdateAppointmnet;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

//http://183.82.106.234:8080/MedRepApplication/api/pharmarep/acceptAppointment??access_token=60e6bfaa-0b61-42a4-92cd-3f71d3def6b2

/*{
    "appointmentId": 1,
    "status": "Declined"
 
 {
 "appointmentId": 1,
 "status": "Accept"
 }
}*/

- (void)acceptAppointments:(NSDictionary*)appointmentDetails
               withHandler:(completionHandler)responceHandler
{
    //http://183.82.106.234:8080/MedRepApplication/api/pharmarep/acceptAppointment??access_token=60e6bfaa-0b61-42a4-92cd-3f71d3def6b2
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/pharmarep/acceptAppointment?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:[appointmentDetails objectForKey:@"appointmentId"] forKey:@"appointmentId"];
    [dict setObject:[appointmentDetails objectForKey:@"status"] forKey:@"status"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody: jsonData];
    self.serviceType = kMRWebServiceTypeAcceptAppointmnet;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}


//http://183.82.106.234:8080/MedRepApplication/api/pharmarep//getNotificationById/{notificationId}?access_token=ab04ac82-6b19-492d-9e17-3e4fab387062

- (void)getNotificationById:(NSString*)notificationID
                 withHandler:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/pharmarep/getNotificationById/%@?access_token=%@",kBaseURL,notificationID,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetNotificationById;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

// http://183.82.106.234:8080/MedRepApplication/api/pharmarep/getMyCompany?access_token=4680b6ad-124f-47d9-8450-36078b3ada55

- (void)getMyCompany:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/pharmarep/getMyCompany?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyCompany;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

//http://183.82.106.234:8080/MedRepApplication/api/analytic/getDoctorNotificationStats/{notificationId}?access_token=20e20067-2f67-4d22-b405-f8039cc9f1b6
- (void)getDoctorNotificationStatsById:(NSString*)notificationID
                withHandler:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/analytic/getDoctorNotificationStats/%@?access_token=%@",kBaseURL,notificationID,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetDoctorNotificationStatsById;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

//http://183.82.106.234:8080/MedRepApplication/api/analytic/getDoctorActivityScore?access_token=20e20067-2f67-4d22-b405-f8039cc9f1b6

//http://183.82.106.234:8080/MedRepApplication/api/analytic/getDoctorActivityByCompany/{doctorId}?access_token=20e20067
- (void)getDoctorActivityScore:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/analytic/getDoctorActivityScore?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetDoctorActivityScore;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

//http://183.82.106.234:8080/MedRepApplication/api/profile/getDoctorProfile/{token}?access_token=62fb897e-29a8-46bf-aa30-38f33252ae19


//http://183.82.106.234:8080/MedRepApplication/api/profile/getDoctorProfile/{token}?access_token=62fb897e-29a8-46bf-aa30-38f33252ae19


//http://183.82.106.234:8080/MedRepApplication/api/pharmarep/getMyCompany


//http://183.82.106.234:8080/MedRepApplication/api/pharmarep/getMyPendingAppointment?access_token=5717aa5f-5cac-4cca-af94-4da6ec434bf8

// This same as getMyPendingAppointmentForPharma
//- (void)getMyPendingAppointment:(completionHandler)responceHandler
//{
//    //api/pharmarep/getMyPendingAppointment?access_token=
//    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/pharmarep/getMyPendingAppointment?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
//    
//    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
//    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
//    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
//    [urlRequest setTimeoutInterval:120];
//    [urlRequest setHTTPMethod:@"GET"];
//    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
//    self.serviceType = kMRWebServiceTypeGetDoctorActivityScore;
//    [self sendServiceRequest:urlRequest withHandler:responceHandler];
//}


//http://183.82.106.234:8080/MedRepApplication/api/pharmarep/getMyUpcomingAppointment?access_token=8f3e5a25-848f-4ed3-a813-4c4008b0ac57

- (void)getMyUpcomingAppointment:(completionHandler)responceHandler
{
    //
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/pharmarep/getMyUpcomingAppointment?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];

    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyUpcomingAppointment;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}


//http://183.82.106.234:8080/MedRepApplication/api/pharmarep/getMyCompletedAppointment?access_token=cd15d783-6b59-46cd-a47a-369481eec2e7

- (void)getMyCompletedAppointment:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/pharmarep/getMyCompletedAppointment?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyCompletedAppointment;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}


//http://183.82.106.234:8080/MedRepApplication/api/pharmarep/getAppointmentsByRep/{repId}?access_token=20e20067-2f67-4d22-b405-f8039cc9f1b6

//http://183.82.106.234:8080/MedRepApplication/api/pharmarep/getMyTeamPendingAppointments?access_token=320ea4c7-ead4-4171-acf0-15d0ab1f7c36

- (void)getMyTeamPendingAppointments:(completionHandler)responceHandler
{
    NSString *stringFormOfUrl = [NSString stringWithFormat:@"%@/api/pharmarep/getMyTeamPendingAppointments?access_token=%@",kBaseURL,[MRDefaults objectForKey:kAuthenticationToken]];
    
    NSURL *url = [NSURL URLWithString:stringFormOfUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:120];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    self.serviceType = kMRWebServiceTypeGetMyMyTeamPendingAppointments;
    [self sendServiceRequest:urlRequest withHandler:responceHandler];
}

@end

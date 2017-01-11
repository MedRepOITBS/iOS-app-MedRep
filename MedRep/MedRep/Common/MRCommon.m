//
//  MRCommon.m
//  MedRep
//
//  Created by MedRep Developer on 10/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRCommon.h"
#import "SVProgressHUD.h"
#import "MRConstants.h"
#import "NSDate+Utilities.h"
#import "NSData+Base64Additions.h"
#import "MRAppControl.h"
#import "MRWebserviceConstants.h"
#import "MRDevEnvironmentConfig.h"
#import "MRGradientView.h"

@import EventKit;

@implementation MRCommon

+ (BOOL)getSwipeEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"SwipeEnabled"];
}

+ (void)setSwipeEnabled:(BOOL)isSwipe
{
    [[NSUserDefaults standardUserDefaults] setBool:isSwipe forKey:@"SwipeEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

///////////////////////////////////////////////////////////////////////
//// Purpose		: isIPad
//// Parameters		: nil
//// Return type	: BOOL
//// Comments		: nil
///////////////////////////////////////////////////////////////////////

+ (BOOL)isIPad
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

///////////////////////////////////////////////////////////////////////
//// Purpose		: isiPhone5
//// Parameters		: nil
//// Return type	: BOOL
//// Comments		: nil
///////////////////////////////////////////////////////////////////////

+ (BOOL)isiPhone5
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f)
        return YES;
    else
        return NO;
}

///////////////////////////////////////////////////////////////////////
//// Purpose		: Is my device is iPad?
//// Parameters		: Nil
//// Return type	: Nil
//// Comments		: Nil
///////////////////////////////////////////////////////////////////////
+ (BOOL) isHD
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

/********************************************************************************************
 @Method Name  : showActivityIndicator
 @Param        : nil
 @Return       : void
 @Description  : show spinning activity indicator
 ********************************************************************************************/
+ (void) showActivityIndicator:(NSString *)message
{
    if (message == (id)[NSNull null] || message.length == 0 )
    {
        [SVProgressHUD show];
    }
    else
    {
        [SVProgressHUD showWithStatus:message];
    }
}

/********************************************************************************************
 @Method Name  : stopActivityIndicatorForWebView
 @Param        : nil
 @Return       : void
 @Description  : Stop activity indicator
 ********************************************************************************************/
+ (void) stopActivityIndicator
{
    [SVProgressHUD dismiss];
}


+ (BOOL) isStringEmpty:(NSString*) aString
{
    if (NO == [aString isKindOfClass:[NSString class]]) return NO;
    BOOL isSuccess = NO;
    
    NSString *newString = [aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([newString isEqual:@""] || nil == newString)
    {
        isSuccess = YES;
    }
    
    return isSuccess;
}

///////////////////////////////////////////////////////////////////////
//// Purpose            : Show alert message box..
//// Parameters         : (NSString*)message; (id)delegate
//// Return type        : void
//// Comments           : None
///////////////////////////////////////////////////////////////////////
+ (void)showAlert:(NSString*)message delegate:(id)delegate
{
    if (NO == [message isEqualToString:@""] && nil != message)
    {
        UIAlertView *alertView  = [[UIAlertView alloc] init];
        alertView.title         = kAppName;
        alertView.message       = message;
        if (delegate!= nil)
        {
            alertView.delegate  = delegate;
        }
        [alertView addButtonWithTitle:MPLocalizedString(@"ALERT_OK")];
        [alertView show];
    }
}

+ (void)showAlert:(NSString*)message delegate:(id)delegate withTag:(NSInteger)tag
{
    if (NO == [message isEqualToString:@""] && nil != message)
    {
        UIAlertView *alertView  = [[UIAlertView alloc] init];
        alertView.title         = kAppName;
        alertView.message       = message;
        alertView.tag           = tag;
        if (delegate!= nil)
        {
            alertView.delegate  = delegate;
        }
        [alertView addButtonWithTitle:MPLocalizedString(@"ALERT_OK")];
        [alertView show];
    }
}

///////////////////////////////////////////////////////////////////////
//// Purpose            : Show alert message box..
//// Parameters         : (NSString*)message; (id)delegate
//// Return type        : void
//// Comments           : None
///////////////////////////////////////////////////////////////////////
+ (void)showConformationAlert:(NSString*)message delegate:(id)delegate withTag:(NSInteger)tag
{
    if (NO == [message isEqualToString:@""] && nil != message)
    {
        UIAlertView *alertView  = [[UIAlertView alloc] init];
        alertView.title         = kAppName;
        alertView.message       = message;
        alertView.tag           = tag;
        if (delegate!= nil)
        {
            alertView.delegate  = delegate;
        }
        [alertView addButtonWithTitle:MPLocalizedString(@"ALERT_CANCEL")];
        [alertView addButtonWithTitle:MPLocalizedString(@"ALERT_OK")];
        [alertView show];
    }
}

///////////////////////////////////////////////////////////////////////
//// Purpose            : Show alert message box..
//// Parameters         : (NSString*)message; (id)delegate
//// Return type        : void
//// Comments           : None
///////////////////////////////////////////////////////////////////////
+ (void)showConformationOKNoAlert:(NSString*)message delegate:(id)delegate withTag:(NSInteger)tag
{
    if (NO == [message isEqualToString:@""] && nil != message)
    {
        UIAlertView *alertView  = [[UIAlertView alloc] init];
        alertView.title         = kAppName;
        alertView.message       = message;
        alertView.tag           = tag;
        if (delegate!= nil)
        {
            alertView.delegate  = delegate;
        }
        [alertView addButtonWithTitle:MPLocalizedString(@"ALERT_NO")];
        [alertView addButtonWithTitle:MPLocalizedString(@"ALERT_YES")];
        [alertView show];
    }
}

+ (BOOL)deviceHasThreePointFiveInchScreen
{
    return ([self deviceHasScreenWithIdiom:UIUserInterfaceIdiomPhone scale:2.0 height:480.0] || [self deviceHasScreenWithIdiom:UIUserInterfaceIdiomPhone scale:1.0 height:480.0]);
}

+ (BOOL)deviceHasFourInchScreen
{
    return [self deviceHasScreenWithIdiom:UIUserInterfaceIdiomPhone scale:2.0 height:568.0];
}

+ (BOOL) deviceHasFourPointSevenInchScreen
{
    return [self deviceHasScreenWithIdiom:UIUserInterfaceIdiomPhone scale:2.0 height:667.0];
}

+ (BOOL) deviceHasFivePointFiveInchScreen
{
    return [self deviceHasScreenWithIdiom:UIUserInterfaceIdiomPhone scale:3.0 height:736.0];
}


+(NSInteger)getMonthIndexForShortName:(NSString *)shortAbbreviation{
    __block NSInteger monthIndex = -1;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSArray *dfShortMonthSymbols =  [df shortMonthSymbols];
    [dfShortMonthSymbols enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *monthName = obj;
        
        if ([shortAbbreviation isEqualToString:monthName]) {
            monthIndex = idx;
            
            *stop = TRUE;
        }
        
        
    }];
    
    return monthIndex+1;
}
+ (BOOL) deviceHasScreenWithIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom scale:(CGFloat)scale height:(CGFloat)height
{
    CGRect mainScreenBounds = [[UIScreen mainScreen] bounds];
    CGFloat mainScreenHeight;
    
    if ([MRCommon operatingSystemVersionLessThan:@"8.0"])
    {
        mainScreenHeight = mainScreenBounds.size.height;
    }
    else
    {
        UIDeviceOrientation orientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
        mainScreenHeight = (UIDeviceOrientationIsLandscape(orientation)) ? mainScreenBounds.size.width : mainScreenBounds.size.height;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == userInterfaceIdiom && [[UIScreen mainScreen] scale] == scale && mainScreenHeight == height)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (NSString*)nibNameForDevice:(NSString*)nibName
{
    if ([MRCommon deviceHasThreePointFiveInchScreen] ||
        [MRCommon deviceHasFourInchScreen] ||
        [MRCommon deviceHasFourPointSevenInchScreen] ||
        [MRCommon deviceHasFivePointFiveInchScreen])
    {
        return [NSString stringWithFormat:@"%@_iPhone", nibName]; 
    }
    else if ([MRCommon isHD])
    {
        return [NSString stringWithFormat:@"%@_iPad", nibName];
    }
    return nibName;
}

+ (NSString *) currentOperatingSystemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (BOOL) operatingSystemVersionLessThanOrEqualTo:(NSString *)operatingSystemVersionToCompare
{
    return ([[self currentOperatingSystemVersion] compare: operatingSystemVersionToCompare options:NSNumericSearch] != NSOrderedDescending);
}

+ (BOOL) operatingSystemVersionLessThan:(NSString *)operatingSystemVersionToCompare
{
    return ([[self currentOperatingSystemVersion] compare: operatingSystemVersionToCompare options:NSNumericSearch] == NSOrderedAscending);
}

+ (void)savetokens:(NSDictionary*)tokenDetails
{
    [MRDefaults setObject: [tokenDetails objectForKey:@"value"] forKey:kAuthenticationToken];
    [MRDefaults setObject: [[tokenDetails objectForKey:@"refreshToken"] objectForKey:@"value"] forKey:kRefreshToken];
    [MRDefaults synchronize];
}

+ (void)removedTokens
{
    [MRDefaults removeObjectForKey:kAuthenticationToken];
    [MRDefaults removeObjectForKey:kRefreshToken];
    [MRDefaults synchronize];
}


+ (void)setLoginEmail:(NSString*)email
{
    [MRDefaults setObject:email forKey:@"LoginUserEmail"];
    [MRDefaults synchronize];
}

+ (NSString*)getLoginEmail
{
    return [MRDefaults objectForKey:@"LoginUserEmail"];
}

+ (void)setUserPhoneNumber:(NSString*)mobileNumber
{
    [MRDefaults setObject:mobileNumber forKey:KMobileNumber];
    [MRDefaults synchronize];
}

+ (NSString*)getUserPhoneNumber
{
    return [MRDefaults objectForKey:KMobileNumber];
}

+ (void)setUserType:(NSInteger)userType
{
    [MRDefaults setObject:[NSNumber numberWithInteger:userType] forKey:@"UserType"];
    [MRDefaults synchronize];
}

+ (NSInteger)getUserType
{
    return [[MRDefaults objectForKey:@"UserType"] integerValue];
}


+ (NSString*)getRole:(NSInteger)roleType
{
    return [kUserRole objectAtIndex:roleType - 1];
}

+ (NSString*)getTitle:(NSInteger)roleType
{
    return [kUserTitle objectAtIndex:roleType - 1];
}

+ (NSString*)getQulification:(NSInteger)roleType
{
    return [kUserQualification objectAtIndex:roleType - 1];
}

+ (void)addUpdateConstarintsTo:(UIView*)parentView withChildView:(UIView*)childView
{
    /*
     UIView *redView = [[UIView alloc] initWithFrame:self.view.bounds];
     redView.backgroundColor = [UIColor redColor];
     [self.view addSubview:redView]
     */
    
    childView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:parentView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
    
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeLeading
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:parentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
    
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeTrailing
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:parentView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f]];
    
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:parentView attribute:NSLayoutAttributeTop
                                                          multiplier:1.0f constant:0.0f]];
}

//	Purpose         : scales an image and returns image
//	Parameter       : (uiimage*)image,(cgsize)newsize
//	Return type     : UIImage
//	Comments        : Nil.
+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage*)getImageFromBase64Data:(NSData*)data
{
    if (nil != data)
    {
        NSData *thedata = [[NSData alloc] initWithBase64EncodedData:data options:0];
        
        if (nil == thedata)
        {
            NSString *str = @"";
            if ([data isKindOfClass:[NSString class]]) {
                str = (NSString*)data;
            }else{
                str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            thedata = [NSData decodeBase64ForString:str];
        }
        
         return [UIImage imageWithData:thedata];
    }

    return nil;
}

//  Purpose     :   This function will return a string of date fron a given NSDate
//  Parameter   :   (NSDate*)date
//  Return type :   NSString of date
//  Comments    :   Nil.
+ (NSString*)stringFromDate:(NSDate*)date withDateFormate:(NSString*)formatter
{
    // NSLog(@"%@ === %@",[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMdd"],[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMddhhmmss"]);
    NSDateFormatter *dateformat    = [[NSDateFormatter alloc]init];
    [dateformat setDateFormat:formatter];
    [dateformat setLocale:[NSLocale currentLocale]];
    NSString *resultantDate        = [dateformat stringFromDate:date];
    return  resultantDate;
}

//  Purpose     :   This function will return a string of date fron a given NSDate
//  Parameter   :   (NSDate*)date
//  Return type :   NSString of date
//  Comments    :   Nil.
+ (NSDate*)dateFromstring:(NSString*)strdate withDateFormate:(NSString*)formatter
{
    // NSLog(@"%@ === %@",[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMdd"],[MRCommon stringFromDate:[NSDate date] withDateFormate:@"YYYYMMddhhmmss"]);
    NSDateFormatter *dateformat    = [[NSDateFormatter alloc]init];
    [dateformat setDateFormat:formatter];
    [dateformat setLocale:[NSLocale currentLocale]];
    NSDate *resultantDate        = [dateformat dateFromString:strdate];
    return  resultantDate;
}


+ (BOOL)validateEmailWithString:(NSString*)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (void)syncEventInCalenderAlongWithEventTitle:(NSString *)eventTitle
                               withDescription:(NSString *)eventDesc
                               withDuration:(NSInteger)eventDuration
                                     eventDate:(NSDate *)eventDate
                                   withHandler:(void (^)(void))eventSync
{
    EKEventStore *store = [[EKEventStore alloc] init];
    
    __block EKEvent *event = nil;
    if([store respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        // iOS 6
        [store requestAccessToEntityType:EKEntityTypeEvent
                              completion:^(BOOL granted, NSError *error) {
                                  if (granted)
                                  {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          
                                          event = [EKEvent eventWithEventStore:store];
                                          event.title = eventTitle;
                                          event.location = eventDesc;
                                          
                                          NSDate *eventDay = eventDate;
                                          event.startDate = eventDate;
                                    
                                          eventDay = [eventDay dateByAddingTimeInterval:eventDuration*60];
                                          event.endDate = eventDay;
                                          
                                          [event setCalendar:[store defaultCalendarForNewEvents]];
                                          NSError *err = nil;
                                          [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
                                          eventSync ();
                                      });
                                  }
                                  else
                                  {
                                      eventSync ();
                                  }
                              }];
    }
}

+ (UIColor*)getColorForIndex:(NSInteger)index
{
    NSInteger selectedIndex = index % 12;
    UIColor *selectedColor = [UIColor blackColor];
    switch (selectedIndex) {
        case 0:
            selectedColor = [UIColor yellowColor];
            break;
        case 1:
            selectedColor = [UIColor lightGrayColor];
            break;
        case 2:
            selectedColor = [UIColor greenColor];
            break;
        case 3:
            selectedColor = [UIColor blueColor];
            break;
        case 4:
            selectedColor = [UIColor darkGrayColor];
            break;
        case 5:
            selectedColor = [UIColor redColor];
            break;
        case 6:
            selectedColor = [UIColor cyanColor];
            break;
        case 7:
            selectedColor = [UIColor grayColor];
            break;
        case 8:
            selectedColor = [UIColor magentaColor];
            break;
        case 9:
            selectedColor = [UIColor orangeColor];
            break;
        case 10:
            selectedColor = [UIColor purpleColor];
            break;
        case 11:
            selectedColor = [UIColor brownColor];
            break;
        default:
            selectedColor = [UIColor blackColor];
            break;
    }
    
    return selectedColor;
}

+ (void)parseNotificationMessage:(NSDictionary*)responce
                        forImage:(void (^)(NSString *image))donloadedImage{
    if (responce != nil) {
        NSString *contentLocation = [responce objectOrNilForKey:@"contentLocation"];
        if (contentLocation != nil && contentLocation.length > 0) {
            /*
            dispatch_queue_t queue = dispatch_queue_create("com.medrep", 0);
            
            dispatch_async(queue,
                           ^{
                               if ([[MRAppControl sharedHelper] internetCheck])
                               {
                                    NSURL *url = [[NSURL alloc] initWithString:contentLocation];
                                    NSData *mydata = [[NSData alloc] initWithContentsOfURL:url];
                                    
                                    if (mydata != nil)
                                    {
                                        UIImage *tempImg = [[UIImage alloc] initWithData:mydata];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [MRCommon stopActivityIndicator];
                                            donloadedImage (tempImg);
                                        });
                                    }
                                    else
                                    {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [MRCommon stopActivityIndicator];
                                            donloadedImage (nil);
                                        });
                                    }
                               } else {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [MRCommon stopActivityIndicator];
                                       donloadedImage(nil);
                                   });
                               }
                           });
             */
            [MRCommon stopActivityIndicator];
            donloadedImage(contentLocation);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MRCommon stopActivityIndicator];
                donloadedImage(nil);
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MRCommon stopActivityIndicator];
            donloadedImage(nil);
        });
    }
}

+ (void)parseNotificationContent:(NSInteger)notificationID
                          status:(BOOL)status responce:(NSDictionary*)responce
                        forImage:(void (^)(NSString *image))donloadedImage {
    if (status)
    {
        [MRCommon parseNotificationMessage:responce forImage:donloadedImage];
    }
    else if ([[responce objectForKey:@"oauth2ErrorCode"] isEqualToString:@"invalid_token"])
    {
        [[MRWebserviceHelper sharedWebServiceHelper] refreshToken:^(BOOL status, NSString *details, NSDictionary *responce)
         {
             [MRCommon savetokens:responce];
             [[MRWebserviceHelper sharedWebServiceHelper] getMyNotificationContent:notificationID
                                                                       withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                                                                           [MRCommon parseNotificationContent:notificationID
                                                                                                       status:status responce:responce
                                                                                                     forImage:donloadedImage];
                                                                       }];
         }];
    }
    else
    {
        [MRCommon stopActivityIndicator];
        donloadedImage(nil);
    }
}

+ (void)getNotificationImageByID:(NSInteger)notificationID forImage:(void (^)(NSString *image))donloadedImage
{
    [[MRWebserviceHelper sharedWebServiceHelper] getMyNotificationContent:notificationID
                                                              withHandler:^(BOOL status, NSString *details, NSDictionary *responce) {
                                                                  [MRCommon parseNotificationContent:notificationID
                                                                                              status:status responce:responce
                                                                   forImage:donloadedImage];
                                                              }];
    /*
     NSString *imageurl  = [NSString stringWithFormat:@"%@/doctor/getMyNotificationContent/%ld?token=%@",kBaseWebURL,notificationID,[MRDefaults objectForKey:kAuthenticationToken]];
    
    dispatch_queue_t queue = dispatch_queue_create("com.medrep", 0);
    dispatch_queue_t main = dispatch_get_main_queue();
    
    //  do the long running work in bg async queue
    // within that, call to update UI on main thread.
    dispatch_async(queue,
                   ^{
                       if(!imageurl)
                       {
                           donloadedImage (nil);
                           return;
                       }
                       
                       if ([[MRAppControl sharedHelper] internetCheck])
                       {
                           NSURL *url = [[NSURL alloc] initWithString:imageurl];
                           NSData *mydata = [[NSData alloc] initWithContentsOfURL:url];
                           
                           
                           if (mydata != nil)
                           {
                               UIImage *tempImg = [[UIImage alloc] initWithData:mydata];
                               dispatch_async(main, ^{
                                   donloadedImage (tempImg);
                               });
                               
                           }
                           else
                           {
                               donloadedImage (nil);
                           }
                           
                       }
                       else
                       {
                           donloadedImage (nil);
                       }
                   });
     */
}

+ (void)getPharmaNotificationImageByID:(NSInteger)notificationID forImage:(void (^)(UIImage *image))donloadedImage
{
    NSString *imageurl  = [NSString stringWithFormat:@"%@/api/pharmarep/getMyNotificationContent/%ld?access_token=%@",kBaseURL,notificationID,[MRDefaults objectForKey:kAuthenticationToken]];
    
    dispatch_queue_t queue = dispatch_queue_create("com.medrep", 0);
    dispatch_queue_t main = dispatch_get_main_queue();
    
    //  do the long running work in bg async queue
    // within that, call to update UI on main thread.
    dispatch_async(queue,
                   ^{
                       if(!imageurl)
                       {
                           donloadedImage (nil);
                           return;
                       }
                       
                       if ([[MRAppControl sharedHelper] internetCheck])
                       {
                           NSURL *url = [[NSURL alloc] initWithString:imageurl];
                           NSData *mydata = [[NSData alloc] initWithContentsOfURL:url];
                           
                           
                           if (mydata != nil)
                           {
                               UIImage *tempImg = [[UIImage alloc] initWithData:mydata];
                               dispatch_async(main, ^{
                                   donloadedImage (tempImg);
                               });
                               
                           }
                           else
                           {
                               donloadedImage (nil);
                           }
                           
                       }
                       else
                       {
                           donloadedImage (nil);
                       }
                   });
}

+ (NSString*)getUpperCaseLetter:(NSString*)notificationName
{
    if (![MRCommon isStringEmpty:notificationName] && notificationName.length > 0)
    {
        return [[notificationName substringToIndex:1] uppercaseString];
    }
    return @"M";
}

+ (NSData*)archiveDictionaryToData:(NSDictionary*)detailsDict forKey:(NSString*)key
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:detailsDict forKey:key];
    [archiver finishEncoding];
    return data;
}

+ (NSDictionary*)unArchiveDataToDictionary:(NSData*)theData forKey:(NSString*)key
{
    NSData *data = [[NSMutableData alloc] initWithData:theData];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *theDictionary=[unarchiver decodeObjectForKey:key];
    [unarchiver finishDecoding];
    return (nil == theDictionary) ? [NSDictionary dictionary] : theDictionary;
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

+ (UIView*)createTabBarView:(UIView*)parentView {
    UIView *tabBarView = [[NSBundle mainBundle] loadNibNamed:@"MRCustomTabBar" owner:self
                                                  options:nil].firstObject;
    [tabBarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [parentView addSubview:tabBarView];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:tabBarView
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:parentView
                                                                      attribute:NSLayoutAttributeLeading
                                                                     multiplier:1.0 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:tabBarView
                                                                      attribute:NSLayoutAttributeTrailing
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:parentView
                                                                      attribute:NSLayoutAttributeTrailing
                                                                     multiplier:1.0 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:tabBarView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:parentView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:tabBarView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:1.0 constant:50.0];
    
    [parentView addConstraints:@[leftConstraint, rightConstraint, bottomConstraint, heightConstraint]];
    return tabBarView;
}

+ (void)applyNavigationBarStyling:(UINavigationController*)navigationController {
    [MRCommon applyNavigationBarStyling:navigationController andBarColor:kStatusBarColor];
}

+ (void)applyNavigationBarStyling:(UINavigationController*)navigationController
                    andBarColor:(NSString*)barColor {

    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                            NSForegroundColorAttributeName:[UIColor whiteColor],
                                            NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0]
                                            }];
    
    
    // shadowImage removes under navigation line
    navigationController.navigationBar.shadowImage = [UIImage new];
    navigationController.navigationBar.barTintColor = [MRCommon colorFromHexString:barColor];
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    navigationController.navigationBar.translucent = false;
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    
//    // Set Navigation Bar as gradient
//    CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
//    CGFloat navHeight = navigationController.navigationBar.frame.size.height;
//    
//    CGRect bounds = [UIScreen mainScreen].bounds;
//    CGFloat width = bounds.size.width;
//    
//    UIView *gradImage = [[MRGradientView alloc] initWithFrame:CGRectMake(0, 0, width, statusHeight + navHeight)];
//    
//    UIGraphicsBeginImageContext(gradImage.frame.size);
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    [gradImage.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIGraphicsEndImageContext();
//    [navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

+ (NSString*)stringWithRelativeWordsForDate:(NSDate*)date {
    NSString *dateString = @"";
    if (date != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDoesRelativeDateFormatting:YES];
        dateString = [dateFormatter stringFromDate:date];
    }
    return dateString;
}

+ (NSString*)convertDateToString:(NSDate*)date andFormat:(NSString*)dateFormat {
    NSString *dateString = @"";
    
    if (date != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:dateFormat];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:kStandardTimeZone]];
        dateString = [dateFormatter stringFromDate:date];
    }
    
    return dateString;
}

@end

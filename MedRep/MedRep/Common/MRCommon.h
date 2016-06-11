//
//  MRCommon.h
//  MedRep
//
//  Created by MedRep Developer on 10/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface MRCommon : NSObject
{
    
}

+ (BOOL) getSwipeEnabled;

+ (void) setSwipeEnabled:(BOOL)isSwipe;

+ (BOOL) isIPad;

+ (BOOL) isiPhone5;

+ (BOOL) isHD;

+ (void) showActivityIndicator:(NSString *)message;

+ (void) stopActivityIndicator;

+ (BOOL) isStringEmpty:(NSString*) aString;

+ (void) showAlert:(NSString*)message delegate:(id)delegate;

+ (void) showAlert:(NSString*)message delegate:(id)delegate withTag:(NSInteger)tag;

+ (void)showConformationOKNoAlert:(NSString*)message delegate:(id)delegate withTag:(NSInteger)tag;


+ (BOOL) deviceHasThreePointFiveInchScreen;

+ (BOOL) deviceHasFourInchScreen;

+ (BOOL) deviceHasFourPointSevenInchScreen;

+ (BOOL) deviceHasFivePointFiveInchScreen;

+ (NSString *) currentOperatingSystemVersion;

+ (BOOL) operatingSystemVersionLessThanOrEqualTo:(NSString *)operatingSystemVersionToCompare;

+ (BOOL) operatingSystemVersionLessThan:(NSString *)operatingSystemVersionToCompare;

+ (void) savetokens:(NSDictionary*)tokenDetails;

+ (NSString*)nibNameForDevice:(NSString*)nibName;

+ (NSString*)getRole:(NSInteger)roleType;

+ (NSString*)getTitle:(NSInteger)roleType;

+ (NSString*)getQulification:(NSInteger)roleType;

+ (void)setLoginEmail:(NSString*)email;

+ (NSString*)getLoginEmail;

+ (void)setUserPhoneNumber:(NSString*)email;

+ (NSString*)getUserPhoneNumber;

+ (void)addUpdateConstarintsTo:(UIView*)myParentView withChildView:(UIView*)myChildView;

+ (NSString*)stringFromDate:(NSDate*)date withDateFormate:(NSString*)formatter;

+ (BOOL)validateEmailWithString:(NSString*)checkString;

+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)newSize;

+ (UIImage*)getImageFromBase64Data:(NSData*)data;

+ (void)removedTokens;

+ (void)setUserType:(NSInteger)userType;

+ (NSInteger)getUserType;

+ (void)syncEventInCalenderAlongWithEventTitle:(NSString *)eventTitle
                               withDescription:(NSString *)eventDesc
                                  withDuration:(NSInteger)eventDuration
                                     eventDate:(NSDate *)eventDate
                                   withHandler:(void (^)(void))eventSync;

+ (NSDate*)dateFromstring:(NSString*)strdate withDateFormate:(NSString*)formatter;

+ (UIColor*)getColorForIndex:(NSInteger)index;

+ (void)getNotificationImageByID:(NSInteger)notificationID
                       forImage:(void (^)(UIImage *image))donloadedImage;

+ (NSString*)getUpperCaseLetter:(NSString*)notificationName;

+ (NSData*)archiveDictionaryToData:(NSDictionary*)detailsDict forKey:(NSString*)key;

+ (NSDictionary*)unArchiveDataToDictionary:(NSData*)theData forKey:(NSString*)key;

+ (void)getPharmaNotificationImageByID:(NSInteger)notificationID
                              forImage:(void (^)(UIImage *image))donloadedImage;
@end

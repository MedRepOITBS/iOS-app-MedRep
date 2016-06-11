//
//  MRCompanyDetails.h
//  MedRep
//
//  Created by MedRep Developer on 03/10/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MRCompanyDetails : NSManagedObject

@property (nonatomic, retain) NSNumber * companyId;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSString * companyDesc;
@property (nonatomic, retain) NSString * contactName;
@property (nonatomic, retain) NSString * contactNo;
@property (nonatomic, retain) NSData * displayPicture;
@property (nonatomic, retain) NSData * location;
@property (nonatomic, retain) NSString * status;

@end

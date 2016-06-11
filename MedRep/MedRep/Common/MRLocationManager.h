//
//  MRLocationManager.h
//  
//
//  Created by MedRep Developer on 04/02/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MRLocationManager : NSObject<CLLocationManagerDelegate>

// Get singleton instance of this class.
+ (MRLocationManager *)sharedManager;

- (void)getCurrentLocation:(void (^)(CLLocation *location))completionHandler;

- (CLPlacemark*)getPlacemark;
@end

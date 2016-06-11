//
//  MRLocationManager.m
//  
//
//  Created by MedRep Developer on 04/02/16.
//
//

#import "MRLocationManager.h"

typedef void (^COMPLETION_HANDLER)(CLLocation *location);

@interface MRLocationManager ()
{
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (atomic, retain) CLLocation *currentLocation;
@property (atomic, copy) COMPLETION_HANDLER responseHander;
@property (atomic, assign) BOOL isAnalyticsNeeded;

@end

@implementation MRLocationManager

#pragma mark - Public Methods

// Get singleton instance of this class.
+ (MRLocationManager *)sharedManager
{
    static dispatch_once_t once;
    static MRLocationManager * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

// Initialize method.
- (id)init
{
    self = [super init];
    if(self)
    {
        [self CurrentLocationIdentifier];
    }
    return self;
}


- (void)getCurrentLocation:(void (^)(CLLocation *location))completionHandler
{
    if(![CLLocationManager locationServicesEnabled])
    {
        completionHandler(nil);
        return;
    }
    
    self.responseHander = completionHandler;
    [self startLocationService];
}

#pragma mark - Private Methods

- (void)CurrentLocationIdentifier
{
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    //self.locationManager.distanceFilter = 100.0f;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    geocoder = [[CLGeocoder alloc] init];
    
}

- (void) startLocationService
{
    [self.locationManager startUpdatingLocation];
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    switch (status)
    {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            [self.locationManager startUpdatingLocation];
            break;
        }
        case kCLAuthorizationStatusNotDetermined:
        {
            if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            {
                [self.locationManager requestWhenInUseAuthorization];
            }
            else
            {
                // [self.locationManager startUpdatingLocation];
            }
            break;
        }
        default:
            break;
    }
}

- (BOOL) isAccessAuthorized
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    switch (status)
    {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            return YES;
        }
            
        default:
        {
            return NO;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
//    NSLog(@"didUpdateToLocation: %@", newLocation);
//    CLLocation *currentLocation = newLocation;
//    
//    if (currentLocation != nil) {
//        [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
//        [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
//    }
    
    // Stop Location Manager
    [self.locationManager stopUpdatingLocation];
//    NSLog(@"Resolving the Address");
//    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
//        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
//        if (error == nil && [placemarks count] > 0) {
//            placemark = [placemarks lastObject];
//            NSLog(@" %@ ", [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
//                            placemark.subThoroughfare, placemark.thoroughfare,
//                            placemark.postalCode, placemark.locality,
//                            placemark.administrativeArea,
//                            placemark.country]);
//        } else {
//            NSLog(@"%@", error.debugDescription);
//        }
//    } ];
    
    if(self.responseHander)
    {
        self.responseHander(newLocation);
        self.responseHander = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    //NSLog(@"didUpdateToLocation: %@", [locations firstObject]);
    CLLocation *currentLocation = [locations firstObject];
    
    if (currentLocation != nil) {
//        [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
//        [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    
    // Stop Location Manager
    [self.locationManager stopUpdatingLocation];
//    NSLog(@"Resolving the Address");
//    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
//        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
//        if (error == nil && [placemarks count] > 0) {
//            placemark = [placemarks lastObject];
//            NSLog(@" %@ ", [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
//                            placemark.subThoroughfare, placemark.thoroughfare,
//                            placemark.postalCode, placemark.locality,
//                            placemark.administrativeArea,
//                            placemark.country]);
//        } else {
//            NSLog(@"%@", error.debugDescription);
//        }
//    } ];
//    
    [self.locationManager stopUpdatingLocation];
    if(self.responseHander)
    {
        self.responseHander([locations objectAtIndex:0]);
        self.responseHander = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    //NSLog(@"%@", error.description);
    [self.locationManager stopUpdatingLocation];
    if(self.responseHander)
    {
        self.responseHander(nil);
        self.responseHander = nil;
    }
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self.locationManager startUpdatingLocation];
    
    switch (status)
    {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            [self.locationManager startUpdatingLocation];
            break;
        }
            
        case kCLAuthorizationStatusDenied:
        {
            break;
        }
            
        default:
        {
            break;
        }
    }
}

- (CLPlacemark*)getPlacemark
{
    return placemark;
}
@end

//
//  MRViewAppointmnetViewController.h
//  
//
//  Created by MedRep Developer on 04/11/15.
//
//

#import <UIKit/UIKit.h>

@interface MRViewRepAppointmnetViewController : UIViewController

@property (retain, nonatomic) NSDictionary *appointmnetDetails;
@property (assign, nonatomic) BOOL isCompletedAppointmnet;
@property (assign, nonatomic) BOOL isPendingAppointmnet;
@end

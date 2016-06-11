//
//  MRViewAppointmnetViewController.h
//  
//
//  Created by MedRep Developer on 04/11/15.
//
//

#import <UIKit/UIKit.h>

@interface MRViewAppointmnetViewController : UIViewController

@property (retain, nonatomic) NSDictionary *appointmnetDetails;
@property (assign, nonatomic) BOOL isCompletedAppointmnet;
@property (assign, nonatomic) BOOL isPendingAppointmnet;
@property (weak, nonatomic) IBOutlet UIButton *acceptAppointmnetBtn;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@end

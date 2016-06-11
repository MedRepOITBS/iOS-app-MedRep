//
//  MRMedRepDetailsViewController.h
//  
//
//  Created by MedRep Developer on 03/11/15.
//
//

#import <UIKit/UIKit.h>

@interface MRMedRepDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *detailsTable;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIButton *viewAppointmentButton;
@property (strong, nonatomic) IBOutlet UIView *navView;
@property (nonatomic, retain) NSDictionary *doctorDetalsDictionlay;

@end

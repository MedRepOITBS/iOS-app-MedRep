//
//  MRPHSurveyDetailsPendingDoctorTableViewCell.h
//  MedRep
//
//  Created by Vamsi Katragadda on 12/19/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRPHSurveyPendingList;
@class MRPHSurveyDetailsViewController;

@interface MRPHSurveyDetailsPendingDoctorTableViewCell : UITableViewCell

- (void)setData:(MRPHSurveyPendingList*)doctorDetails
andParentViewController:(MRPHSurveyDetailsViewController*)viewController;

@end

//
//  MRDRActivityTableViewCell.h
//  
//
//  Created by MedRep Developer on 14/12/15.
//
//

#import <UIKit/UIKit.h>

@interface MRDRActivityTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *companyImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyName;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;

@end

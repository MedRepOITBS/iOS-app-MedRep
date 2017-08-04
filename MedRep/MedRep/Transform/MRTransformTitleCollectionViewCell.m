//
//  MRTransformTitleCollectionViewCell.m
//  MedRep
//
//  Created by Vamsi Katragadda on 6/14/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRTransformTitleCollectionViewCell.h"
#import "MRCommon.h"
@interface MRTransformTitleCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *title;

@end

@implementation MRTransformTitleCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setHeading:(NSString*)title {
    self.title.text = title;
}

- (void)setCorners {
   
    [self.title setBackgroundColor:[MRCommon colorFromHexString:@"#2BF6C0"]];
    [self.title.layer setCornerRadius:5.0];
    [self.title setClipsToBounds:true];
}

- (void)clearCorners {
    [self.title setBackgroundColor:[MRCommon colorFromHexString:@"#20B18A"]];
    [self.title.layer setCornerRadius:0];
}

@end

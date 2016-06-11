//
//  CommonBoxView.h
//  MedRep
//
//  Created by Namit Nayak on 6/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CommonBoxViewDelegate;
@class MRContact,MRGroup;
@interface CommonBoxView : UIView <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *personImageView;
@property (weak, nonatomic) IBOutlet UILabel *personNameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *hintCameraLbl;

@property (weak, nonatomic) IBOutlet UIView *commentParentView;
@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;
@property (nonatomic,weak) id<CommonBoxViewDelegate> delegate;

- (void)setContact:(MRContact*)contact;
- (void)setGroup:(MRGroup*)group;
- (IBAction)cameraBtnTapped:(id)sender;
- (IBAction)okButtonTapped:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;
-(void)setImageForShareImage:(UIImage *)image;
-(void)setData;
@end

@protocol CommonBoxViewDelegate <NSObject>
@optional

-(void)commonBoxCameraButtonTapped;
-(void)commonBoxOkButtonPressed;
-(void)commonBoxCancelButtonPressed;


@end
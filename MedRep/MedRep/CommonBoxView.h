//
//  CommonBoxView.h
//  MedRep
//
//  Created by Namit Nayak on 6/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CommonBoxViewDelegate;

@class MRContact, MRGroup, MRSharePost;

@interface CommonBoxView : UIView <UITextViewDelegate>

@property (nonatomic,weak) id<CommonBoxViewDelegate> delegate;

-(void)setData:(MRContact*)contact group:(MRGroup*)group andSharedPost:(MRSharePost*)sharePost;

@end

@protocol CommonBoxViewDelegate <NSObject>
@optional

-(void)commonBoxCameraButtonTapped;
-(void)commonBoxOkButtonPressedWithData:(NSDictionary *)dictData withIndexPath:(NSIndexPath *)indexPath;
-(void)commonBoxCancelButtonPressed;

- (void)commentPosted;

@end
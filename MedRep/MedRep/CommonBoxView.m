//
//  CommonBoxView.m
//  MedRep
//
//  Created by Namit Nayak on 6/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "CommonBoxView.h"
#import "MRContact.h"
#import "MRGroup.h"
#import "MRAppControl.h"


@interface CommonBoxView()
@property (strong, nonatomic) MRContact* mainContact;
@property (strong, nonatomic) MRGroup* mainGroup;
@property (nonatomic)BOOL isPhotoDone;
@property (strong,nonatomic) NSIndexPath *cellIndexPath;
@end
@implementation CommonBoxView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setCameraElementVisibilty:(BOOL)isVisible {
    
    _cameraBtn.hidden = isVisible;
    _hintCameraLbl.hidden= isVisible;
    
}
- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    
    [txtView resignFirstResponder];
    return NO;
}
-(void)setImageForShareImage:(UIImage *)image{
    _shareImageView.hidden = NO;
    _isPhotoDone = YES;
    _shareImageView.image = image;
    [self setCameraElementVisibilty:YES];
}
- (void)setContact:(MRContact*)contact {
    self.mainContact = contact;
}

- (void)setGroup:(MRGroup*)group {
    self.mainGroup = group;
    
}
-(id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame])
    {
        
    }
    return self;
}
-(void)setData:(NSIndexPath *)indexPath{
    NSString *combinedTitle = @"";
    _cellIndexPath = indexPath;
    
    if (self.mainGroup) {
        combinedTitle = self.mainGroup.group_name;
    }
    if (self.mainContact) {
        if (![combinedTitle isEqualToString:@""]) {
            combinedTitle = [NSString stringWithFormat:@"%@ | %@",combinedTitle,
                             [MRAppControl getContactName:self.mainContact]];
        
        }else{
            
            combinedTitle = [MRAppControl getContactName:self.mainContact];
            self.personImageView.image = [MRAppControl getContactImage:self.mainContact];
        }
    }
    
    self.personNameLbl.text = combinedTitle;
    
}
- (IBAction)cameraBtnTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(commonBoxCameraButtonTapped)]){
        [self.delegate commonBoxCameraButtonTapped];
        
    }

}

- (IBAction)okButtonTapped:(id)sender {

    if ([self.delegate respondsToSelector:@selector(commonBoxOkButtonPressedWithData:withIndexPath:)]){
         NSDictionary *myDict;
        if (!_isPhotoDone) {
           myDict = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"profile_pic",self.commentTextView.text,@"postText" ,nil];
        }else{
            myDict = [NSDictionary dictionaryWithObjectsAndKeys:self.shareImageView.image,@"profile_pic",self.commentTextView.text,@"postText" ,nil];
        }
      
        
        [self.delegate commonBoxOkButtonPressedWithData:myDict withIndexPath:_cellIndexPath];
        
    }
  
    
}

- (IBAction)cancelButtonTapped:(id)sender {


}
@end

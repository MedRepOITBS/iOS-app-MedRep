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



@interface CommonBoxView()
@property (strong, nonatomic) MRContact* mainContact;
@property (strong, nonatomic) MRGroup* mainGroup;

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
-(void)setData{
    NSString *combinedTitle = @"";
    
    if (self.mainGroup) {
        combinedTitle = self.mainGroup.name;
    }
    if (self.mainContact) {
        if (![combinedTitle isEqualToString:@""]) {
            combinedTitle = [NSString stringWithFormat:@"%@ | %@",combinedTitle,self.mainContact.name];
        
        }else{
            
            combinedTitle = [NSString stringWithFormat:@"%@",self.mainContact.name];
            
                self.personImageView.image = [UIImage imageNamed:self.mainContact.profilePic];
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

}

- (IBAction)cancelButtonTapped:(id)sender {


}
@end

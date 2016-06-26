//
//  MRTabView.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/20/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRTabView.h"

@implementation MRTabView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)connectButtonTapped:(id)sender {
    self.connectView = sender;
    
    ((UITapGestureRecognizer *)self.connectView).view.backgroundColor = [UIColor colorWithRed:26/255.0 green:133/255.0 blue:213/255.0 alpha:1];
    [self setClearBG:self.transformView];
    [self setClearBG:self.shareView];
    [self setClearBG:self.serveView];
    
    if ([self.delegate respondsToSelector:@selector(connectButtonTapped)]) {
        [self.delegate connectButtonTapped];
    }
}

- (IBAction)transformButtonTapped:(id)sender {
    self.transformView = sender;
    
    ((UITapGestureRecognizer *)self.transformView).view.backgroundColor = [UIColor colorWithRed:26/255.0 green:133/255.0 blue:213/255.0 alpha:1];
    [self setClearBG:self.connectView];
    [self setClearBG:self.shareView];
    [self setClearBG:self.serveView];
    
    if ([self.delegate respondsToSelector:@selector(transformButtonTapped)]) {
        [self.delegate transformButtonTapped];
    }
}

- (IBAction)shareButtonTapped:(id)sender {
    self.shareView = sender;
    
    ((UITapGestureRecognizer *)self.shareView).view.backgroundColor = [UIColor colorWithRed:26/255.0 green:133/255.0 blue:213/255.0 alpha:1];
    [self setClearBG:self.transformView];
    [self setClearBG:self.connectView];
    [self setClearBG:self.serveView];
    
    if ([self.delegate respondsToSelector:@selector(shareButtonTapped)]) {
        [self.delegate shareButtonTapped];
    }
}

- (IBAction)serveButtonTapped:(id)sender {
    self.serveView = sender;
    
    ((UITapGestureRecognizer *)self.serveView).view.backgroundColor = [UIColor colorWithRed:26/255.0 green:133/255.0 blue:213/255.0 alpha:1];
    [self setClearBG:self.transformView];
    [self setClearBG:self.shareView];
    [self setClearBG:self.connectView];
    
    if ([self.delegate respondsToSelector:@selector(serveButtonTapped)]) {
        [self.delegate serveButtonTapped];
    }
}

-(void) setClearBG:(id)sender{
    if ([sender isKindOfClass:[UIView class]]) {
        ((UIView *)sender).backgroundColor = [UIColor clearColor];
    }else if([sender isKindOfClass:[UITapGestureRecognizer class]]){
        ((UITapGestureRecognizer *)sender).view.backgroundColor = [UIColor clearColor];
    }
}

@end

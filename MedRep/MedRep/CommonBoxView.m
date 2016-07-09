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
#import "MRSharePost.h"
#import "MRAppControl.h"
#import "MRDatabaseHelper.h"

@interface CommonBoxView() <UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *noPreviewMessage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profilePicWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profilePicPreviewConstant;

@property (weak, nonatomic) IBOutlet UIImageView *personImageView;
@property (weak, nonatomic) IBOutlet UILabel *personNameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *hintCameraLbl;

@property (weak, nonatomic) IBOutlet UIView *commentParentView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIView *galleryView;

@property (strong, nonatomic) MRContact* mainContact;
@property (strong, nonatomic) MRGroup* mainGroup;
@property (strong, nonatomic) MRSharePost* sharePost;

@property (nonatomic)BOOL isPhotoDone;
@property (strong,nonatomic) NSIndexPath *cellIndexPath;
@property (nonatomic) BOOL isPhotoSelected;
- (IBAction)okButtonTapped:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;

@end

@implementation CommonBoxView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.profilePicWidthConstraint.constant = 0;
    self.profilePicPreviewConstant.constant = 0;
    
    [self.shareImageView.layer setCornerRadius:5.0];
    [self.shareImageView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.shareImageView.layer setBorderWidth:1.0f];
    [self.shareImageView setHidden:true];
    
    [self.commentTextView.layer setCornerRadius:2.0];
    [self.commentTextView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.commentTextView.layer setBorderWidth:2.0f];
    
    UITapGestureRecognizer *cameraGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(cameraBtnTapped)];
    [self.cameraView addGestureRecognizer:cameraGestureRecognizer];
    
    UITapGestureRecognizer *galleryGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(galleryBtnTapped)];
    [self.galleryView addGestureRecognizer:galleryGestureRecognizer];
}

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    
    [txtView resignFirstResponder];
    return NO;
}

-(id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame])
    {
        
    }
    return self;
}
-(MRSharePost *)getSelectedPost{
    
    return self.sharePost;
}
- (void)setData:(MRContact*)contact group:(MRGroup*)group andSharedPost:(MRSharePost*)sharePost {
    if (sharePost != nil) {
        NSLog(@"sharePost id = %ld",sharePost.sharePostId.longValue);
    }
    
    self.mainContact = contact;
    self.mainGroup = group;
    self.sharePost = sharePost;
    _isPhotoSelected = NO;
    NSString *title = @"";
    
    if (self.mainContact != nil) {
        title = [MRAppControl getContactName:self.mainContact];
        self.profilePicPreviewConstant.constant = 5;
        self.profilePicWidthConstraint.constant = 40;
        
        self.personImageView.image = [MRAppControl getContactImage:self.mainContact];
    } else if (self.mainGroup != nil) {
        title = self.mainGroup.group_name;
        self.profilePicPreviewConstant.constant = 5;
        self.profilePicWidthConstraint.constant = 40;
        
        self.personImageView.image = [MRAppControl getGroupImage:self.mainGroup];
    } else {
        title = @"New Post";
    }
    
    self.personNameLbl.text = title;
}

- (void)galleryBtnTapped {
    if (self.delegate != nil  && [self.delegate respondsToSelector:@selector(commonBoxCameraGalleryButtonTapped)]) {
        
        [self.delegate commonBoxCameraGalleryButtonTapped];
    }
    
}

- (void)cameraBtnTapped {
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = YES;
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    if (self.delegate != nil  && [self.delegate respondsToSelector:@selector(commonBoxCameraButtonTapped)]) {
        
        [self.delegate commonBoxCameraButtonTapped];
    }
    
    
    
}

- (IBAction)okButtonTapped:(id)sender {
    if (self.sharePost != nil) {
        if (!_isPhotoSelected) {
            [MRDatabaseHelper addCommentToAPost:self.sharePost text:self.commentTextView.text
                                    contentData:nil contactId:0 groupId:0
                             updateCommentCount:true andUpdateShareCount:false];
        } else {
            [MRDatabaseHelper addCommentToAPost:self.sharePost text:self.commentTextView.text
                                    contentData:UIImagePNGRepresentation(self.shareImageView.image)
                                      contactId:0 groupId:0
                             updateCommentCount:true andUpdateShareCount:false];
            
        }
        
        if (self.delegate != nil &&
            [self.delegate respondsToSelector:@selector(commentPosted)]) {
            [self.delegate commentPosted];
        }
    } else if (self.mainContact != nil) {
        
    }
}

- (IBAction)cancelButtonTapped:(id)sender {
    if (self.delegate != nil &&
        [self.delegate respondsToSelector:@selector(commonBoxCancelButtonPressed)]) {
        [self.delegate commonBoxCancelButtonPressed];
    }
}
-(void)setImageForShareImage:(UIImage *)image{
    if (image!=nil) {
        _isPhotoSelected = true;
    }
    _noPreviewMessage.hidden = YES;
    _shareImageView.hidden = NO;
    self.shareImageView.image = image;
}
@end

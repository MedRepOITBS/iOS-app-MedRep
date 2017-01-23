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
#import "MRConstants.h"

@interface CommonBoxView() <UIImagePickerControllerDelegate,UITextViewDelegate >

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *noPreviewMessage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profilePicWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profilePicPreviewConstant;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property (weak, nonatomic) IBOutlet UIImageView *personImageView;
@property (weak, nonatomic) IBOutlet UILabel *personNameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;
//@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *hintCameraLbl;

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIView *galleryView;

@property (strong, nonatomic) MRContact* mainContact;
@property (strong, nonatomic) MRGroup* mainGroup;
@property (strong, nonatomic) MRSharePost* sharePost;

@property (nonatomic) NSString *message;

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
    [self.shareImageView setHidden:false];
    
    [self.commentTextView.layer setCornerRadius:2.0];
    [self.commentTextView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.commentTextView.layer setBorderWidth:2.0f];
    
    UITapGestureRecognizer *cameraGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(cameraBtnTapped)];
    [self.cameraView addGestureRecognizer:cameraGestureRecognizer];
    
    UITapGestureRecognizer *galleryGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(galleryBtnTapped)];
    [self.galleryView addGestureRecognizer:galleryGestureRecognizer];
    
    // Add Tool bar to text view
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.superview.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(closeOnKeyboardPressed:)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneOnKeyboardPressed:)],
                           nil];
    [numberToolbar sizeToFit];
    self.commentTextView.inputAccessoryView = numberToolbar;
    
    [self.okButton setEnabled:NO];
}

- (void)closeOnKeyboardPressed:(id)sender {
    self.commentTextView.text = self.message;
    [self.commentTextView resignFirstResponder];
}

- (void)doneOnKeyboardPressed:(id)sender {
    self.message = self.commentTextView.text;
    [self.commentTextView resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.superview setFrame:CGRectMake(self.superview.frame.origin.x,
                                       self.superview.frame.origin.y - 200,
                                       self.superview.frame.size.width,
                                       self.superview.frame.size.height)];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text != nil && textView.text.length > 0) {
        [self.okButton setEnabled:YES];
        [self.okButton setBackgroundColor:[MRCommon colorFromHexString:@"#14C39C"]];
    } else {
        if (_isPhotoSelected == false) {
            [self.okButton setEnabled:NO];
            [self.okButton setBackgroundColor:[UIColor lightGrayColor]];
        }
    }
    [self.superview setFrame:CGRectMake(self.superview.frame.origin.x,
                                        self.superview.frame.origin.y + 200,
                                        self.superview.frame.size.width,
                                        self.superview.frame.size.height)];
}

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
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
        
        [MRAppControl getContactImage:self.mainContact andImageView:self.personImageView];
    } else if (self.mainGroup != nil) {
        title = self.mainGroup.group_name;
        self.profilePicPreviewConstant.constant = 5;
        self.profilePicWidthConstraint.constant = 40;
        
        [MRAppControl getGroupImage:self.mainGroup andImageView:self.personImageView];
    } else {
        title = @"New Post";
    }
    
    self.personNameLbl.text = title;
}

- (void)galleryBtnTapped {
    [self.commentTextView resignFirstResponder];
    
    if (self.delegate != nil  && [self.delegate respondsToSelector:@selector(commonBoxCameraGalleryButtonTapped)]) {
        
        [self.delegate commonBoxCameraGalleryButtonTapped];
    }
    
}

- (void)cameraBtnTapped {
    [self.commentTextView resignFirstResponder];
    
    if (self.delegate != nil  && [self.delegate respondsToSelector:@selector(commonBoxCameraButtonTapped)]) {
        [self.delegate commonBoxCameraButtonTapped];
    }
}

- (IBAction)okButtonTapped:(id)sender {
    if (self.mainContact != nil) {
        
    } else {
        if (self.delegate != nil &&
            [self.delegate respondsToSelector:@selector(commentPostedWithData:andImageData:withSharePost:)]) {
            NSData *imageData = nil;
            if (self.isPhotoDone || self.isPhotoSelected) {
                imageData = UIImagePNGRepresentation(self.shareImageView.image);
            }
            [self.delegate commentPostedWithData:self.commentTextView.text andImageData:imageData
             withSharePost:self.sharePost];
        }
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
    [self.okButton setEnabled:YES];
    [self.okButton setBackgroundColor:[MRCommon colorFromHexString:@"#14C39C"]];
}

@end

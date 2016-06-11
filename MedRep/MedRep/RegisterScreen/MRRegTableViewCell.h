//
//  MRRegTableViewCell.h
//  MedRep
//
//  Created by MedRep Developer on 24/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    MRCellTypeNone,
    MRCellTypeNumeric ,
    MRCellTypeAlphabets,
    MRCellTypeAlphaNumeric
    
}MRRegCellType;

@class MRRegTableViewCell;

@protocol MRRegTableViewCellDelagte <NSObject>

- (void)mOneButtonActionDelegate:(MRRegTableViewCell*)cell;
- (void)mTwoButtonActionDelegate:(MRRegTableViewCell*)cell;
- (void)areaWorkLocationButtonActionDelegate:(MRRegTableViewCell*)cell;
- (void)inputTextFieldBeginEditingDelegate:(MRRegTableViewCell*)cell;
- (void)inputTextFieldEndEditingDelegate:(MRRegTableViewCell*)cell;

@optional

- (void)mOneTextFieldDelegate:(MRRegTableViewCell*)cell;
- (void)mTwoTextFieldDelegate:(MRRegTableViewCell*)cell;
- (void)showCompanyList:(MRRegTableViewCell*)cell
         forCompanyName:(void (^)(NSString *companyName))seletecName;


@end

@interface MRRegTableViewCell : UITableViewCell<UITextFieldDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UIView *singleInputCell;
@property (weak, nonatomic) IBOutlet UIView *multipleInputCell;
@property (weak, nonatomic) IBOutlet UIView *singleInputCellTwo;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UIImageView *dropDownImage;
@property (weak, nonatomic) IBOutlet UITextField *mOneTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *mTwoTextField;
@property (weak, nonatomic) IBOutlet UIButton *mOneButton;
@property (weak, nonatomic) IBOutlet UIButton *mTwoButton;
@property (weak, nonatomic) IBOutlet UITextField *areaLocationTextField;
@property (weak, nonatomic) IBOutlet UIButton *areaWorkLocation;
@property (assign, nonatomic) id<MRRegTableViewCellDelagte> delegate;
@property (assign, nonatomic) MRRegCellType cellType;
@property (assign, nonatomic) NSInteger rowNumber;
@property (assign, nonatomic) NSInteger sectionNumber;
@property (assign, nonatomic) NSInteger regType;
@property (assign, nonatomic) BOOL isUserPesronalDetails;

- (void)configureSingleInput:(BOOL)isSingleInput;
- (IBAction)mOneButtonAction:(id)sender;
- (IBAction)mTwoButtonAction:(id)sender;
- (IBAction)workLocationButtonAction:(UIButton *)sender;
- (void)configureAreaInput:(BOOL)isSingleInput;

@end

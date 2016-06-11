//
//  MRRegTableViewCell.m
//  MedRep
//
//  Created by MedRep Developer on 24/08/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRRegTableViewCell.h"
#import "MRCommon.h"

@implementation MRRegTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureSingleInput:(BOOL)isSingleInput
{
    self.singleInputCellTwo.hidden = YES;
    if (isSingleInput)
    {
        self.multipleInputCell.hidden = YES;
        self.singleInputCell.hidden = NO;
    }
    else
    {
        self.multipleInputCell.hidden = NO;
        self.singleInputCell.hidden = YES;
    }
}

- (void)configureAreaInput:(BOOL)isSingleInput
{
    self.multipleInputCell.hidden = YES;
    self.singleInputCell.hidden = YES;
    self.singleInputCellTwo.hidden = NO;
  
}

- (IBAction)mOneButtonAction:(id)sender
{
    [self.mOneTextFiled becomeFirstResponder];
//    if (self.delegate && [self.delegate respondsToSelector:@selector(mOneButtonActionDelegate:)])
//    {
//        [self.delegate mOneButtonActionDelegate:self];
//    }
}

- (IBAction)mTwoButtonAction:(id)sender
{
    [self.mTwoTextField becomeFirstResponder];
//    if (self.delegate && [self.delegate respondsToSelector:@selector(mTwoButtonActionDelegate:)])
//    {
//        [self.delegate mTwoButtonActionDelegate:self];
//    }
}

- (IBAction)workLocationButtonAction:(UIButton *)sender
{
    if (self.rowNumber == 0 && self.sectionNumber == 0)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(showCompanyList: forCompanyName:)])
        {
            [self.delegate showCompanyList:self forCompanyName:^(NSString *companyName) {
                self.areaLocationTextField.text = companyName;
            }];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(areaWorkLocationButtonActionDelegate:)])
        {
            [self.delegate areaWorkLocationButtonActionDelegate:self];
        }

    }
    else
    {
        [self.areaLocationTextField becomeFirstResponder];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputTextFieldBeginEditingDelegate:)])
    {
        [self.delegate inputTextFieldBeginEditingDelegate:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 100)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputTextFieldEndEditingDelegate:)])
        {
            [self.delegate inputTextFieldEndEditingDelegate:self];
        }
    }
    else if(textField.tag == 101)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mOneButtonActionDelegate:)])
        {
            [self.delegate mOneButtonActionDelegate:self];
        }
    }
    else if(textField.tag == 102)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mTwoButtonActionDelegate:)])
        {
            [self.delegate mTwoButtonActionDelegate:self];
        }
    }
    else if(textField.tag == 103)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(areaWorkLocationButtonActionDelegate:)])
        {
            [self.delegate areaWorkLocationButtonActionDelegate:self];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
      if([MRCommon isStringEmpty:string]) return YES;
    
    switch (self.cellType) {
        case MRCellTypeNumeric:
        {
            unichar lastCharacter = [string characterAtIndex:0];

            if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:lastCharacter])
            {
                if ( (self.rowNumber == 0 || self.rowNumber == 3 || self.rowNumber == 4 ) && self.isUserPesronalDetails)
                    return (textField.text.length <= 9) ? YES : NO;
                else if (self.rowNumber == 0 && self.isUserPesronalDetails) {
                    return YES;
                }
                else if (self.rowNumber == 3)
                    return (textField.text.length <= 5) ? YES : NO;
                else if (self.rowNumber == 2 && textField.text.length <= 9)
                    return YES;
            }
            else
            {
                return NO;
            }
 
        }
            break;
        case MRCellTypeAlphabets:
        {
            unichar lastCharacter = [string characterAtIndex:0];
            if (self.sectionNumber == 2 && self.rowNumber == 0)
            {
                if ([[NSCharacterSet letterCharacterSet] characterIsMember:lastCharacter] && textField.text.length <= 19) return YES;
                else
                    return NO;

            }
            else
            {
                if ([[NSCharacterSet letterCharacterSet] characterIsMember:lastCharacter]) return YES;
            }
        }
            break;
        case MRCellTypeAlphaNumeric:
        {
            unichar lastCharacter = [string characterAtIndex:0];
            if ([[NSCharacterSet alphanumericCharacterSet] characterIsMember:lastCharacter]) return YES;

        }
            break;
        case MRCellTypeNone:
        {
            return YES;
        }
            break;
        default:
            break;
    }
    return NO;
}
@end

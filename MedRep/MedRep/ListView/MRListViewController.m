//
//  MRListViewController.m
//  MedRep
//
//  Created by MedRep Developer on 20/09/15.
//  Copyright (c) 2015 MedRep. All rights reserved.
//

#import "MRListViewController.h"
#import "MRCommon.h"
#import "MRConstants.h"

#define KAddress1               @"address1"
#define KAddress2               @"address2"



@interface MRListViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation MRListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        
        self.isFromCallMedrep = NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.isFromCallMedrep) ? self.listItems.count + 1 : self.listItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier            = @"cellIdentifier";
    UITableViewCell *appointmentCell    = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (appointmentCell == nil)
    {
        appointmentCell     = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        appointmentCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (self.listType)
    {
        case MRListVIewTypeTherapetic:
           appointmentCell.textLabel.text = [[self.listItems objectAtIndex:indexPath.row] objectForKey:@"therapeuticName"];
            break;
        case MRListVIewTypeAddress:
        {
            appointmentCell.textLabel.text = (self.isFromCallMedrep && self.listItems.count == indexPath.row) ? @"Current Location": [self getAddressString:[self.listItems objectAtIndex:indexPath.row]];
            appointmentCell.textLabel.numberOfLines = 0;
            appointmentCell.textLabel.adjustsFontSizeToFitWidth = YES;
            appointmentCell.textLabel.minimumScaleFactor = 0.5;
        }
            break;
        case MRListVIewTypeCompanyList:
            appointmentCell.textLabel.text = [[self.listItems objectAtIndex:indexPath.row] objectForKey:@"companyName"];
            break;
        case   MRListVIewTypeNotificationTherapetic:
            appointmentCell.textLabel.text = [self.listItems objectAtIndex:indexPath.row];
\
            break;
        case MRListVIewTypeNone:
        default:
            break;
    }
    
    return appointmentCell;
}


- (NSString*)getAddressString:(NSDictionary*)address
{
    if (self.isFromCallMedrep)
    {
        if ([MRCommon isStringEmpty:[address objectForKey:KAddressOne]] && [MRCommon isStringEmpty:[address objectForKey:KAdresstwo]])
        {
            return @"";
        }
        else if (![MRCommon isStringEmpty:[address objectForKey:KAddressOne]] && ![MRCommon isStringEmpty:[address objectForKey:KAdresstwo]] && ![MRCommon isStringEmpty:[address objectForKey:KCity]])
        {
            return [NSString stringWithFormat:@"%@, %@, %@", [address objectForKey:KAddressOne],[address objectForKey:KAdresstwo],[address objectForKey:KCity]];
        }
        else if (![MRCommon isStringEmpty:[address objectForKey:KAddressOne]] && ![MRCommon isStringEmpty:[address objectForKey:KAdresstwo]])
        {
            return [NSString stringWithFormat:@"%@, %@", [address objectForKey:KAddressOne],[address objectForKey:KAdresstwo]];
        }
        else if (![MRCommon isStringEmpty:[address objectForKey:KAdresstwo]])
        {
            return [NSString stringWithFormat:@"%@",[address objectForKey:KAdresstwo]];
        }
        else if (![MRCommon isStringEmpty:[address objectForKey:KAddressOne]])
        {
            return [NSString stringWithFormat:@"%@", [address objectForKey:KAddressOne]];
        } 
    }
    else
    {
        if ([MRCommon isStringEmpty:[address objectForKey:KAddress1]] && [MRCommon isStringEmpty:[address objectForKey:KAddress2]])
        {
            return @"";
        }
        else if (![MRCommon isStringEmpty:[address objectForKey:KAddress1]] && ![MRCommon isStringEmpty:[address objectForKey:KAddress2]] && ![MRCommon isStringEmpty:[address objectForKey:KCity]])
        {
            return [NSString stringWithFormat:@"%@, %@, %@", [address objectForKey:KAddress1],[address objectForKey:KAddress2],[address objectForKey:KCity]];
        }
        else if (![MRCommon isStringEmpty:[address objectForKey:KAddress1]] && ![MRCommon isStringEmpty:[address objectForKey:KAddress2]])
        {
            return [NSString stringWithFormat:@"%@, %@", [address objectForKey:KAddress1],[address objectForKey:KAddress2]];
        }
        else if (![MRCommon isStringEmpty:[address objectForKey:KAddress2]])
        {
            return [NSString stringWithFormat:@"%@",[address objectForKey:KAddress2]];
        }
        else if (![MRCommon isStringEmpty:[address objectForKey:KAddress1]])
        {
            return [NSString stringWithFormat:@"%@", [address objectForKey:KAddress1]];
        }
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedListItem:)])
    {
        if (self.listType == MRListVIewTypeNotificationTherapetic)
        {
            [self.delegate selectedListItem:[NSDictionary dictionaryWithObject:[self.listItems objectAtIndex:indexPath.row] forKey:@"therapeuticName"]];
        }
        else
        {
            [self.delegate selectedListItem:(self.isFromCallMedrep && self.listItems.count == indexPath.row) ? @"Current Location" : [self.listItems objectAtIndex:indexPath.row]];
        }
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissPopoverController)])
    {
        [self.delegate dismissPopoverController];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

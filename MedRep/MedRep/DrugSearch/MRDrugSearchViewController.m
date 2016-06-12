//
//  MRDrugSearchViewController.m
//  MedRep
//
//  Created by Yerramreddy, Dinesh (Contractor) on 6/11/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRDrugSearchViewController.h"
#import "MRDrugDetailViewController.h"

@interface MRDrugSearchViewController () <UIScrollViewDelegate, UITextFieldDelegate> {
    NSMutableArray *resultarray;
    NSDictionary *selectedDrug;
}

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *selectedName;
@property (weak, nonatomic) IBOutlet UILabel *selectedDesc;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *selectedQty;
@property (weak, nonatomic) IBOutlet UITextField *searchTxt;

- (IBAction)rightMove:(id)sender;
- (IBAction)leftMove:(id)sender;

@end

@implementation MRDrugSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Search for Drugs";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    //dummy data
    resultarray = [NSMutableArray array];
    NSDictionary *d1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Trycin",@"title",@"Trycin-Tabs.jpg",@"image",@"Tablet is a medium-hard, sugary confection from Scotland. Tablet is usually made from sugar, condensed milk, and butter, which is boiled to a soft-ball stage and allowed to crystallize. It is often flavoured with vanilla or whisky, and sometimes has nut pieces in it.",@"description",@"5 mg",@"qty",nil];
    [resultarray addObject:d1];
    d1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Calshell",@"title",@"CALSHELL.jpg",@"image",@"Tablet is a medium-hard, sugary confection from Scotland. Tablet is usually made from sugar, condensed milk, and butter, which is boiled to a soft-ball stage and allowed to crystallize. It is often flavoured with vanilla or whisky, and sometimes has nut pieces in it.",@"description",@"15 mg",@"qty",nil];
    [resultarray addObject:d1];
    d1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Selvit",@"title",@"selvit.jpeg",@"image",@"Tablet is a medium-hard, sugary confection from Scotland. Tablet is usually made from sugar, condensed milk, and butter, which is boiled to a soft-ball stage and allowed to crystallize. It is often flavoured with vanilla or whisky, and sometimes has nut pieces in it.",@"description",@"10 mg",@"qty",nil];
    [resultarray addObject:d1];
    d1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Paracetamol",@"title",@"Paracetamol.jpg",@"image",@"Tablet is a medium-hard, sugary confection from Scotland. Tablet is usually made from sugar, condensed milk, and butter, which is boiled to a soft-ball stage and allowed to crystallize. It is often flavoured with vanilla or whisky, and sometimes has nut pieces in it.",@"description",@"20 mg",@"qty",nil];
    [resultarray addObject:d1];
    //end of dummy data
    
    int xOffset = 0;
    for(int index=0; index < [resultarray count]; index++)
    {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset,10,100, 110)];
        img.image = [UIImage imageNamed:[resultarray objectAtIndex:index][@"image"]];
        img.tag = index;
        img.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapped:)];
        [img addGestureRecognizer:tap];
        
        [_scrollView addSubview:img];
        xOffset+=110;
    }
    _scrollView.contentSize = CGSizeMake(xOffset,110);
    
    [self mapData:[resultarray objectAtIndex:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)backButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rightMove:(id)sender {
    [_scrollView setContentOffset:CGPointMake(120, 0) animated:YES];
}

- (IBAction)leftMove:(id)sender {
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)showDetail:(id)sender {
    MRDrugDetailViewController *notiFicationViewController = [[MRDrugDetailViewController alloc] initWithNibName:@"MRDrugDetailViewController" bundle:nil];
    notiFicationViewController.selectedDict = selectedDrug;
    [self.navigationController pushViewController:notiFicationViewController animated:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)imgTapped:(UITapGestureRecognizer *)img{
    [self mapData:[resultarray objectAtIndex:img.view.tag]];
}

-(void) mapData:(NSDictionary *)dict{
    selectedDrug = dict;
    _selectedImage.image = [UIImage imageNamed:dict[@"image"]];
    _selectedName.text = dict[@"title"];
    _selectedDesc.text = dict[@"description"];
    _selectedQty.text = dict[@"qty"];
}

@end

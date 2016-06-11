////
////  MRCollectionView.m
////  MedRep
////
////  Created by Vivekan Arther Subaharan on 5/11/16.
////  Copyright © 2016 MedRep. All rights reserved.
////
//
//#import "MRCollectionView.h"
//#import "MRContactCollectionCell.h"
//
//@interface MRCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
//
//@property (weak, nonatomic) IBOutlet UILabel* connectionsLabel;
//@property (strong, nonatomic) NSArray* menuOptions;
//@property (strong, nonatomic)  NSArray* dataList;
//
//@end
//
//@implementation MRCollectionView
//
///*
//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}
//*/
//
//- (id)initWithCoder:(NSCoder *)aDecoder {
//        if ((self = [super initWithCoder:aDecoder])) {
//
//        }
//    return self;
//}
//
//- (void)setData:(NSArray*)data headerText:(NSString*)headerText menuOptions {
//    self.dataList = data;
//    self.connectionsLabel.text = headerText;
//}
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//    [self.collectionView registerNib:[UINib nibWithNibName:@"MRContactCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"contactCell"];
//    if (self.tag == 1) {
//        self.connectionsLabel.text = @"My Connections";
//    } else {
//        self.connectionsLabel.text = @"All Connections";
//    }
//}
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return 1;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return self.dataList.count;
//}
//
//// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    MRContactCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"contactCell" forIndexPath:indexPath];
//    [cell setData:[self.dataList objectAtIndex:indexPath.row]];
//    return cell;
//}
//
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(self.bounds.size.width/2 - 2, 50);
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 4; // This is the minimum inter item spacing, can be more
//}
//
//@end

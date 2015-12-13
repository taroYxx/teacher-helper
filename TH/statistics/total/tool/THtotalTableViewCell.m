//
//  THtotalTableViewCell.m
//  TH
//
//  Created by Taro on 15/12/12.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import "THtotalTableViewCell.h"

@implementation THtotalTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectarray = [NSArray array];
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    [flowlayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2+2, screenW, self.frame.size.height/2-2) collectionViewLayout:flowlayout];
   
    [collectionView registerClass:[UICollectionViewCell class]forCellWithReuseIdentifier:@"collect"];
    collectionView.backgroundColor = XColor(134, 134, 134, 1);
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    self.studentName = [[UILabel alloc] initWithFrame:CGRectMake(screenW/3, 0, screenW/3, 22)];
    [self addSubview:self.studentName];
    self.studentId = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenW/3, 22)];
    [self addSubview:self.studentId];
    self.latetime = [[UILabel alloc] initWithFrame:CGRectMake(screenW*2/3, 0, screenW/3, 22)];
    [self addSubview:self.latetime];
    
   
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 17;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath

{
    
    UICollectionViewCell * cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"collect" forIndexPath:indexPath];
    [cell sizeToFit];
    cell.tag = indexPath.row;
    cell.backgroundColor = [UIColor whiteColor];
    for (int i = 0; i<self.selectarray.count; i++) {
        NSNumber *number = self.selectarray[i];
        int test = number.intValue;
        if (cell.tag == test) {
            self.cellbackcolor = [UIColor redColor];
            cell.backgroundColor = XColor(208, 208, 208, 1);

        }
    }
    
    return cell;
    
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
     return CGSizeMake((screenW-16)/17,20);
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
     return 0.9;
}

@end

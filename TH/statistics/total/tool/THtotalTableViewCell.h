//
//  THtotalTableViewCell.h
//  TH
//
//  Created by Taro on 15/12/12.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THtotalTableViewCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic , strong) UICollectionView * collectionView;
@property (nonatomic , strong) UIColor *cellbackcolor;
@property (nonatomic , strong) NSArray * selectarray;
@property (nonatomic , strong) UILabel * studentName;
@property (nonatomic , strong) UILabel * studentId;
@property (nonatomic , strong) UILabel * latetime;



@end

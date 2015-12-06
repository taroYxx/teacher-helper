//
//  THFillCheckViewController.h
//  TH
//
//  Created by Taro on 15/11/26.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol THFillCheckViewControllerDelegate <NSObject>

- (void)sendValue:(NSDictionary *)dict;

@end


@interface THFillCheckViewController : UIViewController
@property (nonatomic , strong) NSNumber * courseId;
@property (nonatomic , strong) NSNumber * weekOrdinal;
@property (nonatomic , weak) id<THFillCheckViewControllerDelegate> delegate;



@end

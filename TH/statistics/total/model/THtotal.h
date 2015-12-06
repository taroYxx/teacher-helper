//
//  THtotal.h
//  TH
//
//  Created by Taro on 15/12/3.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THtotal : NSObject
@property (nonatomic , strong) NSNumber * late;
@property (nonatomic , strong) NSNumber * appear;
@property (nonatomic , strong) NSNumber * absence;
@property (nonatomic , strong) NSNumber * studentId;
@property (nonatomic , strong) NSNumber * leave;
@property (nonatomic , strong) NSNumber * classNo;
@property (nonatomic , strong) NSString * major;
@property (nonatomic , strong) NSString * name;
@property (nonatomic , strong) NSNumber * studentNo;
@property (nonatomic , strong) NSString * grades;


- (instancetype)initWithDic:(NSDictionary *)dic;
+ (instancetype)totalWithDic:(NSDictionary *)dic;
@end

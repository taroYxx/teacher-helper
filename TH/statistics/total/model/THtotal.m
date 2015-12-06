//
//  THtotal.m
//  TH
//
//  Created by Taro on 15/12/3.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import "THtotal.h"

@implementation THtotal
- (instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.late = dic[@"late"];
        self.appear = dic[@"appear"];
        self.absence = dic[@"absence"];
        self.studentId = dic[@"studentId"];
        self.leave = dic[@"leave"];
        self.name = dic[@"name"];
        self.studentNo = dic[@"studentNo"];
        
        //        [self setValuesForKeysWithDictionary: dic];
    }
    return self;
}
+ (instancetype)totalWithDic:(NSDictionary *)dic{
    return [[self alloc] initWithDic:dic];
}
@end

//
//  THdetailStudent.m
//  TH
//
//  Created by Taro on 15/12/5.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import "THdetailStudent.h"

@implementation THdetailStudent
- (instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.studentName = dic[@"studentName"];
        self.studentId = dic[@"studentId"];
        self.latetime = dic[@"lateTime"];
        self.arrive = dic[@"arrive"];
        //        [self setValuesForKeysWithDictionary: dic];
    }
    return self;
}
+ (instancetype)detailWithDic:(NSDictionary *)dic{
    return [[self alloc] initWithDic:dic];
}
@end

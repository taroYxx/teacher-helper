//
//  THAddStudentTool.h
//  TH
//
//  Created by Taro on 15/11/27.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import <Foundation/Foundation.h>

@class THStudent;

@interface THAddStudentTool : NSObject

+ (void)addAbsence:(THStudent *)student;
+ (void)addLeave:(THStudent *)student;
+ (void)addArrive:(THStudent *)student;
@end

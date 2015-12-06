//
//  THAddStudentTool.m
//  TH
//
//  Created by Taro on 15/11/27.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import "THAddStudentTool.h"
#import <FMDB/FMDatabase.h>
#import "THStudent.h"

@implementation THAddStudentTool
static FMDatabase *_db;

+ (void)initialize{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"student.sqlite"];
    _db = [FMDatabase databaseWithPath:path];
    [_db open];
    
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_absence (number integer PRIMARY KEY, studentId integer ,studentName text , lateTimes integer );"];
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_leave (number interger PRIMARY KEY, studentId integer ,studentName text , lateTimes integer );"];
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_arrive (number interger PRIMARY KEY, studentId integer ,studentName text , lateTimes integer );"];
    
    
}

+ (void)addAbsence:(THStudent *)student{
    [_db executeUpdateWithFormat:@"INSERT INTO t_absence(studentId, studentName, lateTimes) VALUES (%@, %@, %@);", student.studentId, student.name, student.lateTimes];
}
+ (void)addLeave:(THStudent *)student{
    [_db executeUpdateWithFormat:@"INSERT INTO t_leave(studentId, studentName, lateTimes) VALUES (%@, %@, %@);", student.studentId, student.name, student.lateTimes];

}
+ (void)addArrive:(THStudent *)student{
    [_db executeUpdateWithFormat:@"INSERT INTO t_arrive(studentId, studentName, lateTimes) VALUES (%@, %@, %@);", student.studentId, student.name, student.lateTimes];

}

@end

//
//  THFillCheckViewController.m
//  TH
//
//  Created by Taro on 15/11/26.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import "THFillCheckViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "THStudent.h"
#import "THRollCallViewController.h"
#import <FMDB/FMDatabase.h>




@interface THFillCheckViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic , weak) UITableView * absenceList;
@property (nonatomic , strong) NSMutableArray * model;
@property (nonatomic , strong) NSMutableSet * setArrive;
@property (nonatomic , strong) NSMutableSet * setLeave;
@property (nonatomic , strong) NSMutableSet * setLate;
@property (nonatomic , strong) FMDatabase * db;




@end

@implementation THFillCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = XColor(221, 221, 221, 1);
    // Do any additional setup after loading the view.
    THLog(@"%@",_courseId);
    _setArrive = [[NSMutableSet alloc] init];
    _setLeave = [[NSMutableSet alloc] init];
    _setLate = [[NSMutableSet alloc] init];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"student.sqlite"];
    _db = [FMDatabase databaseWithPath:path];
    [_db open];
    
   [self getDataFromServers:^(NSMutableArray *array) {
       _model = [NSMutableArray array];
       for (NSDictionary *dict in array) {
           THStudent *student = [THStudent studentWithDic:dict];
           [_model addObject:student];
       }
       [self initAbsenceList];
   }];
}


- (void)initAbsenceList{
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenW, self.view.frame.size.height)];
    
    _absenceList = tableView;
    _absenceList.delegate = self;
    _absenceList.dataSource = self;
    [self.view addSubview:_absenceList];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _model.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *ID = [NSString stringWithFormat:@"cell%ld",indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackArrow"]];
        icon.frame = CGRectMake(screenW-10-20, (cell.frame.size.height-15)/2, 10, 15);
        cell.accessoryView = icon;
        THStudent *student = _model[indexPath.row];
        cell.textLabel.text = student.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",student.studentNo];
        cell.imageView.image = [UIImage imageNamed:@"red_status"];
        cell.imageView.frame = CGRectMake(0, 0, screenW - cell.imageView.image.size.width, cell.imageView.image.size.height);
        
    }
    
    return cell;
}
//设置侧滑
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    THStudent *student = _model[indexPath.row];
    UITableViewRowAction *arrive = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"已到" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        cell.imageView.image = [UIImage imageNamed:@"green_status"];
        [tableView setEditing:NO];
        [_setArrive addObject:student.studentId];
        [_setLeave removeObject:student.studentId];
        [_setLate removeObject:student.studentId];
        NSDictionary *dict = @{
                               @"arrive" : _setArrive,
                               @"leave" : _setLeave,
                               @"late" : _setLate
                               };
        
        [_delegate sendValue:dict];
        [_db executeUpdate:[NSString stringWithFormat:@"UPDATE class_%@ SET absence = 0,leave = 0,arrive = 1,later=0 WHERE studentId = %@;",self.courseId,student.studentNo]];
        
    }];
    arrive.backgroundColor = XColor(79, 220, 101, 1);
    UITableViewRowAction *leave = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"请假" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        cell.imageView.image = [UIImage imageNamed:@"blue_status"];
        [tableView setEditing:NO];
        [_setArrive removeObject:student.studentId];
        [_setLeave addObject:student.studentId];
        [_setLate removeObject:student.studentId];
        NSDictionary *dict = @{
                               @"arrive" : _setArrive,
                               @"leave" : _setLeave,
                               @"late" : _setLate
                               };
        
        [_delegate sendValue:dict];
         [_db executeUpdate:[NSString stringWithFormat:@"UPDATE class_%@ SET absence = 0,leave = 1,later = 0, arrive = 0 WHERE studentId = %@;",self.courseId,student.studentNo]];
    }];
    leave.backgroundColor = XColor(58, 185, 218, 1);
    UITableViewRowAction *later = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"迟到" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        cell.imageView.image = [UIImage imageNamed:@"yellow_status"];
        [tableView setEditing:NO];
        [_setArrive removeObject:student.studentId];
        [_setLeave removeObject:student.studentId];
        [_setLate addObject:student.studentId];
        NSDictionary *dict = @{
                               @"arrive" : _setArrive,
                               @"leave" : _setLeave,
                               @"late" : _setLate
                               };
         [_db executeUpdate:[NSString stringWithFormat:@"UPDATE class_%@ SET absence = 0,leave = 0,later =1, arrive = 0 WHERE studentId = %@;",self.courseId,student.studentNo]];
        [_delegate sendValue:dict];
    }];
    later.backgroundColor = XColor(254, 204, 43, 1);
    UITableViewRowAction *cancel = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"撤销" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        cell.imageView.image = [UIImage imageNamed:@"red_status"];
        [tableView setEditing:NO];
        [_setArrive removeObject:student.studentId];
        [_setLeave removeObject:student.studentId];
        [_setLate removeObject:student.studentId];
        NSDictionary *dict = @{
                               @"arrive" : _setArrive,
                               @"leave" : _setLeave,
                               @"late" : _setLate
                               };
         [_db executeUpdate:[NSString stringWithFormat:@"UPDATE class_%@ SET absence = 1,leave = 0,later = 0,arrive = 0 WHERE studentId = %@;",self.courseId,student.studentNo]];
         [_delegate sendValue:dict];
    }];

   
    return @[cancel,later,leave,arrive];
    
}



- (void)getDataFromServers:(void(^)(NSMutableArray  * array))success{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    NSDictionary *requestData = @{
                                  @"courseId" : _courseId,
                                  @"weekOrdinal" : _weekOrdinal
                                  };
    [manager POST:@"http://115.29.50.42/demo/special_offer/" parameters:requestData success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSMutableArray *array = responseObject[@"class"];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (success) {
                success(array);
            }
        }];
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        THLog(@"%@",error);
    }];

    
}




@end

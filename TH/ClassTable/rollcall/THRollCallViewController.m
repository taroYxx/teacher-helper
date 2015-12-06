//
//  THRollCallViewController.m
//  TH
//
//  Created by Taro on 15/11/26.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import "THRollCallViewController.h"
#import "THFillCheckViewController.h"
#import "THDetailOfRollcallViewController.h"
#import "THStudent.h"
#import <AFNetworking/AFNetworking.h>
#import <FMDB/FMDatabase.h>
#import "MBProgressHUD+YXX.h"
#import <MBProgressHUD/MBProgressHUD.h>





@interface THRollCallViewController ()<UITableViewDataSource,UITableViewDelegate,THFillCheckViewControllerDelegate>
@property (nonatomic , weak) UISegmentedControl * segment;
@property (nonatomic , weak) UIButton * submitBtn;
@property (nonatomic , strong) THFillCheckViewController * fillcheck;
@property (nonatomic , strong) THDetailOfRollcallViewController * detail;
@property (nonatomic , weak) UITableView * nameList;
@property (nonatomic , strong) NSArray * recommend;
@property (nonatomic , strong) NSArray * normal;
@property (nonatomic , strong) NSMutableArray * modelRec;
@property (nonatomic , strong) NSMutableArray * modelNor;
@property (nonatomic , strong) NSMutableSet * absenceSet;
@property (nonatomic , strong) NSMutableSet * leaveSet;
@property (nonatomic , assign) NSInteger subBtnTag;

@property (nonatomic , strong) NSArray * arriveArray;
@property (nonatomic , strong) NSArray * leaveArray;
@property (nonatomic , strong) NSArray * lateArray;
@property (nonatomic , strong) FMDatabase * db;






@end

@implementation THRollCallViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
            self.hidesBottomBarWhenPushed = YES;
       
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [MBProgressHUD showMessage:@"加载中" toView:self.view];
    self.view.backgroundColor = XColor(241, 241, 241, 1);
    _modelNor = [[NSMutableArray alloc] init];
    _modelRec = [[NSMutableArray alloc] init];
    _arriveArray = [[NSArray alloc] init];
    _leaveArray = [[NSArray alloc] init];
    _lateArray = [[NSArray alloc] init];
    
    
    _submitBtn = 0;
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"student.sqlite"];
    _db = [FMDatabase databaseWithPath:path];
    

    [_db open];
    
        
        [_db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS class_%@ (number integer PRIMARY KEY, studentId integer UNIQUE ,studentName text , lateTimes integer ,absence integer , leave integer , later integer , arrive integer );",self.courseId]];

    
    
//       [_db executeUpdateWithFormat:@"INSERT INTO t_absence(studentId, studentName, lateTimes) VALUES (%@, %@, %@);", student.studentId, student.name, student.lateTimes];
   
    _absenceSet = [[NSMutableSet alloc] init];
    _leaveSet = [[NSMutableSet alloc] init];
    [self addSegmentAndSubmitBtn];
    [self getDataFromServe:^(NSMutableArray *array) {
        _recommend = [array valueForKey:@"recommend"];
        _normal = [array valueForKey:@"normal"];
        NSMutableArray *studentArray = [NSMutableArray array];
        for (id addObject in _recommend) {
            [studentArray addObject:addObject];
        }
        for (id addobject in _normal ) {
            [studentArray addObject:addobject];
        }
        
        for (int i = 0; i < studentArray.count; i++) {
            NSNumber *studentNo = [[studentArray objectAtIndex:i] valueForKey:@"studentNo"];
            NSString *name = [[studentArray objectAtIndex:i] valueForKey:@"name"];
            NSNumber *latetime = [[studentArray objectAtIndex:i] valueForKey:@"lateTimes"];
            NSString *string = [NSString stringWithFormat:@"INSERT INTO class_%@ (studentId, studentName, lateTimes, absence ,leave, later,arrive) VALUES (%@, '%@' ,%@, 0, 0, 0,0)",self.courseId,studentNo,name,latetime];
            [_db executeUpdate:string];
        }
        for (NSDictionary *dict in _recommend) {
            THStudent *student = [THStudent studentWithDic:dict];
            [_modelRec addObject:student];
        }
        for (NSDictionary *dict in _normal) {
            THStudent *student = [THStudent studentWithDic:dict];
            [_modelNor addObject:student];
        }
        [self addNameAndTitleOfClass];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
}


- (void)addNameAndTitleOfClass{
    UILabel *titleOfClass = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, screenW, 43)];
    titleOfClass.text = @"应用与写作";
    [titleOfClass setTextAlignment:NSTextAlignmentCenter];
    titleOfClass.backgroundColor = XColor(228, 228, 228, 1);
    [self.view addSubview:titleOfClass];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64+43, screenW, screenH-107) style:UITableViewStyleGrouped];
    _nameList = tableView;
    _nameList.delegate = self;
    _nameList.dataSource =self;
    [self.view addSubview:_nameList];
    
}



- (void)addSegmentAndSubmitBtn{
    NSArray *segmentTitle = @[@"点名",@"详情",@"补签"];
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:segmentTitle];
    _segment = seg;
    [_segment setTintColor:XColor(208, 85, 90, 1)];
    [_segment setBackgroundColor:[UIColor whiteColor]];
    self.navigationItem.titleView = _segment;
    self.navigationItem.titleView.frame = CGRectMake(0, 0, 180, 22.2);
    _segment.selectedSegmentIndex = 0;
    [_segment addTarget:self action:@selector(didSelectSegment:) forControlEvents:UIControlEventValueChanged];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _submitBtn = button;
    _submitBtn.frame = CGRectMake(0, 0, 60, 40);
    [_submitBtn setTitle:@"提交点名" forState:UIControlStateNormal];
    [_submitBtn setTintColor:XColor(208, 85, 90, 1)];
    _submitBtn.tag = 0;//默认提交点名
    [_submitBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sub = [[UIBarButtonItem alloc] initWithCustomView:_submitBtn];
    self.navigationItem.rightBarButtonItem = sub;
}

- (void)didSelectSegment:(UISegmentedControl *)sender{
    if (sender.selectedSegmentIndex == 0) {
        _subBtnTag = 0;
        _fillcheck.view.hidden = YES;
        _detail.view.hidden = YES;
        _submitBtn.hidden = NO;
          [_submitBtn setTitle:@"提交点名" forState:UIControlStateNormal];
    }else if(sender.selectedSegmentIndex == 1){
        if (!_detail) {
            _detail = [[THDetailOfRollcallViewController alloc] init];
            _detail.courseId = self.courseId;
            _detail.view.frame = CGRectMake(0, 64+43, screenW, screenH-64-43);
            [self.view addSubview:_detail.view];
            
        }
        _detail.view.hidden = NO;
        _fillcheck.view.hidden = YES;
        _submitBtn.hidden = YES;
    }else if(sender.selectedSegmentIndex == 2){
        _detail.view.hidden = YES;
        _submitBtn.hidden = NO;
        _subBtnTag = 1;
        if (!_fillcheck)
        {
           
           [_submitBtn setTitle:@"提交补签" forState:UIControlStateNormal];
            _fillcheck = [[THFillCheckViewController alloc] init];
            [_fillcheck setDelegate:self];
            _fillcheck.courseId = _courseId;
            _fillcheck.weekOrdinal = _weekOrdinal;
            _fillcheck.view.frame = CGRectMake(0, 64+43, screenW, screenH-64-43);
            [self.view addSubview:_fillcheck.view];
        }
        _fillcheck.view.hidden = NO;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return _modelRec.count;
    }else if(section == 1){
        return _modelNor.count;
    }
    return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"系统推荐点名";
    }else{
        return @"其他";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *ID = [NSString stringWithFormat:@"cell%ld",indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_status"]];
        icon.frame = CGRectMake(screenW-10-30, (cell.frame.size.height-30)/2, 30, 30);
        cell.accessoryView = icon;
        UILabel *numberOfabsence = [[UILabel alloc] initWithFrame:CGRectMake(screenW-40-120, 22, 80, 13)];
        numberOfabsence.font = [UIFont systemFontOfSize:15];
        numberOfabsence.adjustsFontSizeToFitWidth = YES;
        numberOfabsence.textColor = XColor(207, 85, 89, 1);
        [cell addSubview:numberOfabsence];
        
        
        UILabel *numberOfThisClass = [[UILabel alloc] initWithFrame:CGRectMake(screenW-40-120, 2, 80, 13)];
        numberOfThisClass.font = [UIFont systemFontOfSize:15];
        numberOfThisClass.adjustsFontSizeToFitWidth = YES;
        numberOfThisClass.textColor = XColor(207, 85, 89, 1);
        [cell addSubview:numberOfThisClass];
        
        
        if (indexPath.section == 0) {
        
            THStudent *student = _modelRec[indexPath.row];
            numberOfabsence.text = [NSString stringWithFormat:@"缺勤次数 :%@",student.lateTimes];
            cell.textLabel.text = student.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",student.studentNo];
            numberOfThisClass.text = [NSString stringWithFormat:@"本课缺勤 :%@",student.lateTimesAtThisClass];
            
            
        }else{
            THStudent *student = _modelNor[indexPath.row];
            numberOfabsence.text = [NSString stringWithFormat:@"缺勤次数 :%@",student.lateTimes];
            cell.textLabel.text = student.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",student.studentNo];
             numberOfThisClass.text = [NSString stringWithFormat:@"本课缺勤 :%@",student.lateTimesAtThisClass];
                                             
                                         }

    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_status"]];
    icon.frame = CGRectMake(screenW-10-30, (cell.frame.size.height-30)/2, 30, 30);
    cell.accessoryView = icon;
    NSArray *array = [NSArray array];
    if (indexPath.section == 0 ) {
        array = _modelRec;
    }else{
        array = _modelNor;
    }
    THStudent *student = array[indexPath.row];
    [_absenceSet addObject:student.studentId];
    [_leaveSet removeObject:student.studentId];
    THLog(@"%@",_absenceSet);
    [_db executeUpdate:[NSString stringWithFormat:@"UPDATE class_%@ SET absence = 1,leave = 0 WHERE studentId = %@;",self.courseId,student.studentNo]];
    
    
  
    
    
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//8.0需要先调用这个方法
}

- (NSArray <UITableViewRowAction*>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *absence = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"缺席" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_status"]];
        icon.frame = CGRectMake(screenW-10-30, (cell.frame.size.height-30)/2, 30, 30);
        cell.accessoryView = icon;
        NSArray *array = [NSArray array];
        if (indexPath.section == 0 ) {
            array = _modelRec;
        }else{
            array = _modelNor;
        }
        THStudent *student = array[indexPath.row];
        [_absenceSet addObject:student.studentId];
        [_leaveSet removeObject:student.studentId];
        THLog(@"%@",_absenceSet);
        [_db executeUpdate:[NSString stringWithFormat:@"UPDATE class_%@ SET absence = 1, leave = 0 WHERE studentId = %@;",self.courseId,student.studentNo]];
        [tableView setEditing:NO];
    }];
    absence.backgroundColor = XColor(208, 85, 90, 1);
    
    UITableViewRowAction *leave = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"请假" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue_status"]];
        icon.frame = CGRectMake(screenW-10-30, (cell.frame.size.height-30)/2, 30, 30);
        cell.accessoryView = icon;
        [tableView setEditing:NO];
        NSArray *array = [NSArray array];
        if (indexPath.section == 0 ) {
            array = _modelRec;
        }else{
            array = _modelNor;
        }
        THStudent *student = array[indexPath.row];
        [_absenceSet removeObject:student.studentId];
        [_leaveSet addObject:student.studentId];
          [_db executeUpdate:[NSString stringWithFormat:@"UPDATE class_%@ SET leave = 1, absence = 0 WHERE studentId = %@;",self.courseId,student.studentNo]];
        THLog(@"%@",_leaveSet);

        
    }];
    leave.backgroundColor = XColor(64, 186, 217, 1);
    UITableViewRowAction *cancel = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"撤销"handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_status"]];
        icon.frame = CGRectMake(screenW-10-30, (cell.frame.size.height-30)/2, 30, 30);
        cell.accessoryView = icon;
        NSArray *array = [NSArray array];
        if (indexPath.section == 0 ) {
            array = _modelRec;
        }else{
            array = _modelNor;
        }
        THStudent *student = array[indexPath.row];
        [_absenceSet removeObject:student.studentId];
        [_leaveSet removeObject:student.studentId];
        [_db executeUpdate:[NSString stringWithFormat:@"UPDATE class_%@ SET leave = 0, absence = 0 WHERE studentId = %@;",self.courseId,student.studentNo]];
        [tableView setEditing:NO];
    }];
    return @[cancel,leave,absence];
    
}





//网络请求
- (void)getDataFromServe:(void(^)( NSMutableArray  * array))success{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/test_create_test/?courseId=%@",host,version,self.courseId];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
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

- (void)submit{
    if (_subBtnTag == 0) {
        //添加已到数据
        NSString *string = [NSString stringWithFormat:@"UPDATE class_%@ SET arrive = 1 WHERE absence = 0 and leave = 0",self.courseId];
        [_db executeUpdate:string];
        [_db close];
        //提交点名
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
        NSArray *absence = [_absenceSet allObjects];
        NSArray *leave = [_leaveSet allObjects];
        THLog(@"absense%@",absence);
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];

        NSDictionary *dict = @{
                               @"studentIdForAbsence" :absence,
                               @"courseId" : _courseId,
                               @"studentIdForLeave" :leave,
                               @"studentIdForLate" :@[]
                               };
        NSString *url = [NSString stringWithFormat:@"%@/%@/absence_record/",host,version];
        [manager POST:url parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            THLog(@"%@",responseObject[@"status"]);
            NSNumber *status = responseObject[@"status"];
            if ([status integerValue] == 1) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"提交成功！" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIView *view = [[UIView alloc] init];
                    view.frame = CGRectMake(0, 64+43, screenW, screenH-64-43);
                    view.backgroundColor = XColor(0, 0, 0, 0.6);
                    [self.view addSubview:view];
                    _detail = [[THDetailOfRollcallViewController alloc] init];
                    _detail.courseId = self.courseId;
                    _detail.view.frame = CGRectMake(0, 64+43, screenW, screenH-64-43);
                    [self.view addSubview:_detail.view];
                    _segment.selectedSegmentIndex = 1;
              
                }];
                [alert addAction:confirm];
                [self presentViewController:alert animated:YES completion:nil]; 
               
                
               
                
            }else{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"提交不能为空" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
                [alertView show];
                
            }
            
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            THLog(@"%@",error);
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"请确定网络是否连接" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [alertView show];
            
        }];
        
        
    }else if(_subBtnTag == 1){
        //提交补签
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        NSDictionary *dict = @{
                               @"courseId" : _courseId,
                               @"weekOrdinal" : _weekOrdinal,
                               @"studentIdForMiss" :_arriveArray,
                               @"studentIdForLeave" :_leaveArray,
                               @"studentIdForLate" :_lateArray
                               };
        NSString *url = [NSString stringWithFormat:@"%@/%@/record_again/",host,version];
        [manager POST:url parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            THLog(@"%@",responseObject[@"status"]);
            NSNumber *status = responseObject[@"status"];
            if ([status integerValue] == 1) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"提交成功！" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [alert addAction:confirm];
                [self presentViewController:alert animated:YES completion:nil];
            }else{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"提交失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
                [alertView show];
                
            }
            
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            THLog(@"%@",error);
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"请确定网络是否连接" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [alertView show];
            
        }];
        
    }
    
    
}
- (void)sendValue:(NSDictionary *)dict{
    _arriveArray = [dict[@"arrive"] allObjects];
    _leaveArray = [dict[@"leave"] allObjects];
    _lateArray = [dict[@"late"] allObjects];
    
      THLog(@"%@--%@--%@",_arriveArray, _leaveArray , _lateArray);
    
}



@end

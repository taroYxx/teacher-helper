//
//  THDetailOfRollcallViewController.m
//  TH
//
//  Created by Taro on 15/11/26.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import "THDetailOfRollcallViewController.h"
#import "XYPieChart.h"
#import <FMDB/FMDatabase.h>
#import "THdetailStudent.h"
@interface THDetailOfRollcallViewController ()<XYPieChartDataSource,XYPieChartDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic , strong) XYPieChart * pieChart;
@property (nonatomic , strong) NSMutableArray * slices;
@property (nonatomic , strong) NSMutableArray * colorOfSlice;
@property (nonatomic , strong) NSMutableArray * nameOfSlice;
@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic , strong) NSMutableArray * absenceModel;
@property (nonatomic , strong) NSMutableArray * leaveModel;
@property (nonatomic , strong) NSMutableArray * arriveModel;
@property (nonatomic , strong) NSMutableArray * laterModel;
@property (nonatomic , strong) NSArray * modelArray;
@property (nonatomic , weak) UITableView * tableView;
@property (nonatomic , strong) NSArray * icon;
@property (nonatomic , strong) UIImage * selectIcon;


@end

@implementation THDetailOfRollcallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self getdateFromDatebase];
    [self addXYpieChart];
    [self addButton];
    [self addTableView];
    self.icon = @[[UIImage imageNamed:@"red_status"],[UIImage imageNamed:@"blue_status"],[UIImage imageNamed:@"yellow_status"],[UIImage imageNamed:@"green_status"]];
    self.selectIcon = [UIImage imageNamed:@"red_status"];
}

- (void)getdateFromDatebase{
    self.absenceModel = [NSMutableArray array];
    self.leaveModel = [NSMutableArray array];
    self.arriveModel = [NSMutableArray array];
    self.laterModel = [NSMutableArray array];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"student.sqlite"];
    _db = [FMDatabase databaseWithPath:path];
    [_db open];

    NSArray *array = @[@"absence",@"leave",@"later",@"arrive"];
    NSArray *status = @[_absenceModel,_leaveModel,_laterModel,_arriveModel];
    for (int i = 0; i < 4; i++) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM class_%@ WHERE %@ = 1",self.courseId,[array objectAtIndex:i]];
        FMResultSet *set = [self.db executeQuery:sql];
        while ([set next]) {
            NSString *studentId = [set stringForColumn:@"studentId"];
            NSString *studentName = [set stringForColumn:@"studentName"];
            NSString *lateTime = [set stringForColumn:@"lateTimes"];
            NSString *arrive = [set stringForColumn:@"arrive"];
            NSDictionary *dict = @{
                                   @"studentId" : studentId,
                                   @"studentName" : studentName,
                                   @"lateTime" :lateTime,
                                   @"arrive" : arrive
                                   };
            THdetailStudent *student = [THdetailStudent detailWithDic:dict];
            [[status objectAtIndex:i] addObject:student];
           
         
        }
    }
    [_db close];
    
    float ab = _absenceModel.count;
    float le = _leaveModel.count;
    float la = _laterModel.count;
    float ar = _arriveModel.count;
    float sum = ab+le+la+ar;
    NSNumber *absence = @(ab/sum*360);
    NSNumber *leave = @(le/sum*360);
    NSNumber *later = @(la/sum*360);
    NSNumber *arrive = @(ar/sum*360);
    _slices = [NSMutableArray arrayWithObjects:absence,leave,later,arrive, nil];
    self.modelArray = [NSArray array];
    self.modelArray = _absenceModel;
    
}

- (void)addXYpieChart{
    self.pieChart = [[XYPieChart alloc] init];
    self.pieChart.delegate = self;
    self.pieChart.dataSource = self;
    [self.pieChart setStartPieAngle:M_PI];
    [self.pieChart setAnimationSpeed:1.0];
    CGFloat R  = (screenH/2-64-43)/2-5;
    [self.pieChart setPieRadius:R];//饼图半径
    [self.pieChart setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:20]];
    [self.pieChart setLabelRadius:R-20];//数据标签出现的位置
    [self.pieChart setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [self.pieChart setPieCenter:CGPointMake(screenW/2, (screenH/2-64-43)/2)];
    [self.pieChart setLabelShadowColor:[UIColor blackColor]];
    //    [self.pieChart setShowPercentage:NO];
    
    _nameOfSlice = [NSMutableArray arrayWithObjects:@"缺席",@"请假",@"迟到",@"已到",nil];
    self.colorOfSlice =[NSMutableArray arrayWithObjects:
                         XColor(208, 85, 90, 2),
                         XColor(64, 186, 217, 1),
                         XColor(255, 204, 43, 1),
                         XColor(85, 219, 105, 1),
                         nil];
    [self.pieChart reloadData];
    [self.view addSubview:self.pieChart];

}

//绘图
- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    
    return self.slices.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[self.slices objectAtIndex:index] integerValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [self.colorOfSlice objectAtIndex:(index % self.colorOfSlice.count)];
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index{
    return [self.nameOfSlice objectAtIndex:index];
}


- (void)addButton{
    NSArray *array = @[_absenceModel,_leaveModel,_laterModel,_arriveModel];
        NSArray *bgViewName = @[@"re",@"blu",@"yel",@"gre"];
    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.tag = i;
        button.frame = CGRectMake(screenW/4 * i,screenH/2-64-44, screenW/4, 44);
        button.backgroundColor = XColor(226, 226, 226, 1);
        [button setTitle:_nameOfSlice[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(transitTableView:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bgViewName[i]]];
        imageview.frame = CGRectMake(screenW/4 * 2/3+5, 13, 20, 20);
        [button addSubview:imageview];
        UILabel *lable = [[UILabel alloc] init];
        lable.frame = CGRectMake(screenW/4 * 2/3, 0, screenW/4 * 1/3, 44);
        NSArray *ary = [array objectAtIndex:i];
        lable.text = [NSString stringWithFormat:@"%ld",ary.count];
        lable.font = [UIFont systemFontOfSize:12.0];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.textColor = [UIColor whiteColor];
        [button addSubview:lable];
        }
    for (int i = 1; i < 4; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(screenW/4*i,screenH/2-64-44+2, 2, 40)];
        view.backgroundColor = XColor(165, 165, 165, 1);
        [self.view addSubview:view];
    }
    
}

- (void)addTableView{
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, screenH/2-64, screenW, screenH-screenH/2-64)];
    _tableView = tableview;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.modelArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell" ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
   
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    THdetailStudent *student = _modelArray[indexPath.row];
    cell.textLabel.text = student.studentName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",student.studentId];
    UIImageView *icon = [[UIImageView alloc] init];
    icon.frame = CGRectMake(screenW-10-30, (cell.frame.size.height-30)/2, 30, 30);
    cell.accessoryView = icon;
    icon.image = self.selectIcon;
    
    
    return cell;
}

- (void)transitTableView:(UIButton *)btn{
    
    NSArray *array = @[_absenceModel,_leaveModel,_laterModel,_arriveModel];
    self.modelArray = [array objectAtIndex:btn.tag];
    self.selectIcon = [self.icon objectAtIndex:btn.tag];
    [self.tableView reloadData];
}



@end

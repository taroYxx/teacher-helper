//
//  THTotalViewController.m
//  TH
//
//  Created by Taro on 15/12/3.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import "THTotalViewController.h"
#import "THHomeworkViewController.h"
#import "XYPieChart.h"
#import <AFNetworking/AFNetworking.h>
#import "THtotal.h"
#import "MBProgressHUD+YXX.h"
#import <MBProgressHUD/MBProgressHUD.h>


@interface THTotalViewController ()<XYPieChartDataSource,XYPieChartDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic , weak) UISegmentedControl* segment;
@property (nonatomic , strong) THHomeworkViewController * homework;

@property (nonatomic , strong) XYPieChart * piechart;
@property (nonatomic , strong) NSArray * slice;
@property (nonatomic , strong) NSArray * nameOfSlice;
@property (nonatomic , strong) NSArray * colorOfSlice;

@property (nonatomic , strong) NSNumber * absenceProportion;
@property (nonatomic , strong) NSNumber * lateProportion;
@property (nonatomic , strong) NSNumber * leaveProportion;
@property (nonatomic , strong) NSNumber * appearProportion;

@property (nonatomic , strong) NSArray * tableViewData;
@property (nonatomic , strong) NSArray * selectArray;


@property (nonatomic , weak) UITableView * tableview;


@property (nonatomic , strong) NSMutableArray * studentModel;



@end

@implementation THTotalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MBProgressHUD showMessage:@"加载中" toView:self.view];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addview];
    self.studentModel = [NSMutableArray array];
    self.tableViewData = [NSArray array];
    self.selectArray = [NSArray array];
    [self getDataFromServe:^(NSDictionary *dictionary) {
        THLog(@"%@",dictionary);
        self.absenceProportion = dictionary[@"absenceProportion"];
        self.lateProportion = dictionary[@"lateProportion"];
        self.appearProportion = dictionary[@"appearProportion"];
        self.leaveProportion = dictionary[@"leaveProportion"];
        NSArray *studentArray = dictionary[@"history"][@"all"];
        NSArray *absenceArray = dictionary[@"history"][@"absence"];
        NSArray *lateArray = dictionary[@"history"][@"late"];
        NSArray *leaveArray = dictionary[@"history"][@"leave"];
        NSArray *totalData = @[studentArray,absenceArray,leaveArray,lateArray];
        
        NSMutableArray *allmodel = [NSMutableArray array];
        NSMutableArray *absencemodel = [NSMutableArray array];
        NSMutableArray *leavemodel = [NSMutableArray array];
        NSMutableArray *latemodel = [NSMutableArray array];
        NSArray *totalmodel = @[allmodel,absencemodel,leavemodel,latemodel];
        for (int i = 0;i < totalData.count ; i++) {
            NSArray *array = [totalData objectAtIndex:i];
            NSMutableArray *model = [totalmodel objectAtIndex:i];
            for (NSDictionary *dict in array) {
                THtotal *total = [THtotal totalWithDic:dict];
                [model addObject:total];
            }
        }
        _tableViewData = totalmodel;
        _selectArray = totalmodel[0];
        [self addXYchart];
        [self addtableview];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];
    
}



- (instancetype)init{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)addview{
    NSArray *segmentTitle = @[@"考勤",@"作业"];
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:segmentTitle];
    _segment = segment;
    _segment.frame = CGRectMake(0, 0, 120, 22.2);
    _segment.selectedSegmentIndex = 0;
    self.navigationItem.titleView = _segment;
    [_segment addTarget:self action:@selector(didSelectSegment:) forControlEvents:UIControlEventValueChanged];
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = CGRectMake(0, 64, screenW, 43);
    lable.text = self.courseName;
    lable.backgroundColor = XColor(226, 226, 226, 1);
    [lable setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:lable];
}
- (void)addXYchart{
    self.piechart = [[XYPieChart alloc] init];
    self.piechart.dataSource = self;
    self.piechart.delegate = self;
    _slice = [NSArray arrayWithObjects:_absenceProportion,_leaveProportion,_lateProportion,_appearProportion,nil];
    _nameOfSlice = @[@"总体",@"缺勤",@"请假",@"迟到"];
    [self.piechart setStartPieAngle:M_PI];
    [self.piechart setAnimationSpeed:1.0];
    [self.piechart setPieCenter:CGPointMake(screenW/2, (screenH/2-64-43)/2+108)];
    [self.piechart setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:20]];
    CGFloat R  = (screenH/2-64-43)/2-5;
    [self.piechart setPieRadius:R];
    [self.piechart setLabelRadius:R-20];
    [self.piechart setShowPercentage:YES];
    [self.piechart setShowLabel:YES];
    [self.piechart setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [self.piechart setLabelShadowColor:[UIColor blackColor]];
    self.colorOfSlice = [NSArray arrayWithObjects:XColor(207, 85, 89, 1),XColor(247, 198, 42, 1),XColor(64, 185, 216, 1),XColor(84, 217, 105, 1),nil];
    [self.piechart reloadData];
    [self.view addSubview:self.piechart];
    
    
    NSArray *bgViewName = @[@"gre",@"re",@"blu",@"yel"];
    
    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.tag = i;
        button.frame = CGRectMake(screenW/4 * i,screenH/2, screenW/4, 44);
        button.backgroundColor = XColor(226, 226, 226, 1);
        [button setTitle:_nameOfSlice[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(changeTableViewDate:)forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        
        
        UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bgViewName[i]]];
        imageview.frame = CGRectMake(screenW/4 * 2/3+5, 13, 22, 22);
        [button addSubview:imageview];
        
        
        UILabel *lable = [[UILabel alloc] init];
        lable.frame = CGRectMake(screenW/4 * 2/3+9, 0, screenW/4 * 1/3, 44);
        NSArray *Arr = [self.tableViewData objectAtIndex:i];
        lable.text = [NSString stringWithFormat:@"%ld",Arr.count];
        lable.font = [UIFont systemFontOfSize:12.0];
        lable.textColor = [UIColor whiteColor];
        [button addSubview:lable];
    }
    
}
- (void)changeTableViewDate:(UIButton *)button{
    THLog(@"%ld",button.tag);
    THLog(@"%@",[_tableViewData objectAtIndex:button.tag]);
    _selectArray = [_tableViewData objectAtIndex:button.tag];
    [self.tableview reloadData];
}

- (void)addtableview{
    UITableView *tableView = [[UITableView alloc] init];
    _tableview = tableView;
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.frame = CGRectMake(0, screenH/2+44, screenW, screenH/2-44);
    [self.view addSubview:_tableview];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _selectArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *ID = [NSString stringWithFormat:@"cell%ld",indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        
    }
    THtotal *total = _selectArray[indexPath.row];
    cell.textLabel.text = total.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",total.studentNo];
    return cell;
}


- (void)didSelectSegment:(UISegmentedControl *)sender{
        sender = _segment;
        if (sender.selectedSegmentIndex == 0) {
        self.view.hidden = NO;
        _homework.view.hidden = YES;
        }else if(sender.selectedSegmentIndex == 1){
        if (!_homework)
        {
            _homework = [[THHomeworkViewController alloc] init];
            _homework.view.frame = CGRectMake(0, 64+43, screenW, screenH-64-43);
            [self.view addSubview:_homework.view];
            THLog(@"ads");
        }
            _homework.view.hidden = NO;
           
        }
}

- (void)getDataFromServe:(void(^)(NSDictionary *dictionary))success{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    NSString *url = [NSString stringWithFormat:@"%@/%@/get_history/",host,version];
    NSDictionary *body = @{
                           @"courseId" : _courseId
                           };
     manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:url parameters:body success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        THLog(@"%@",responseObject);
        NSDictionary *dict = responseObject;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (success) {
                success(dict);
            }
        }];
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        THLog(@"%@",error);
    }];

}

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart

{
    
    
    
    return self.slice.count;
    
}



- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index

{
    
    return [[self.slice objectAtIndex:index] floatValue];
    
}



- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index

{
    
    return [self.colorOfSlice objectAtIndex:(index % self.colorOfSlice.count)];
    
}



- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index{
    
    return [self.nameOfSlice objectAtIndex:index];
    
}
@end

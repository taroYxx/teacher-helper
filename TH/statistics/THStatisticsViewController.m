//
//  THStatisticsViewController.m
//  TH
//
//  Created by Taro on 15/11/25.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import "THStatisticsViewController.h"
#import "THTotalViewController.h"
#import "THClass.h"

@interface THStatisticsViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic , strong) NSMutableArray * model;

@end

@implementation THStatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    THLog(@"%@",self.classList);
    [self dictToModel];
    [self addView];
    
}

- (void)addView{
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, screenW, 49)];
    lable.text = @"选择课程";
    lable.backgroundColor = XColor(228, 228, 228, 1);
    [lable setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:lable];
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 64+49, screenW, screenH-64-49) ];
    _tableView = tableview;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = XColor(241, 241, 241, 1);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
       
    
    
}

- (void)dictToModel{
    _model = [NSMutableArray array];
    for (NSDictionary *dict in _classList) {
        THClass *class = [THClass classWithDic:dict];
        [_model addObject:class];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.classList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 42,screenW , 2);
        view.backgroundColor = XColor(108, 108, 108, 1);
        [cell addSubview:view];
        THClass *class = _model[indexPath.row];
        cell.textLabel.text = class.courseName;
        NSArray *week = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
      
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@",[week objectAtIndex:class.week.intValue],class.lessonPeriod];
        
        cell.imageView.image = [UIImage imageNamed:@"pencil"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    THTotalViewController *total = [[THTotalViewController alloc] init];
    THClass *class = _model[indexPath.row];
    total.courseName = class.courseName;
    total.courseId = class.courseId;
    [self.navigationController pushViewController:total animated:YES];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
    back.title = @"返回";
    [self.navigationController.navigationBar setTintColor:XColor(209, 84, 87, 1)];
    self.navigationItem.backBarButtonItem = back;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    });
}




@end

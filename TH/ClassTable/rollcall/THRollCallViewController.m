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

@interface THRollCallViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic , strong) UISegmentedControl * segment;
@property (nonatomic , strong) UIButton * submitBtn;
@property (nonatomic , strong) THFillCheckViewController * fillcheck;
@property (nonatomic , strong) THDetailOfRollcallViewController * detail;
@property (nonatomic , strong) UITableView * nameList;
@end

@implementation THRollCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = XColor(241, 241, 241, 1);
    self.tabBarController.tabBar.hidden = YES;
    [self addSegmentAndSubmitBtn];
    [self addNameAndTitleOfClass];
    
}


- (void)addNameAndTitleOfClass{
    UILabel *titleOfClass = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, screenW, 43)];
    titleOfClass.text = @"应用与写作";
    [titleOfClass setTextAlignment:NSTextAlignmentCenter];
    titleOfClass.backgroundColor = XColor(228, 228, 228, 1);
    [self.view addSubview:titleOfClass];
    
    _nameList = [[UITableView alloc] initWithFrame:CGRectMake(0, 64+43, screenW, screenH-107) style:UITableViewStyleGrouped];
    
    _nameList.delegate = self;
    _nameList.dataSource =self;
    [self.view addSubview:_nameList];
    
}



- (void)addSegmentAndSubmitBtn{
    NSArray *segmentTitle = @[@"点名",@"详情",@"补签"];
    _segment = [[UISegmentedControl alloc] initWithItems:segmentTitle];
    [_segment setTintColor:XColor(208, 85, 90, 1)];
    [_segment setBackgroundColor:[UIColor whiteColor]];
    self.navigationItem.titleView = _segment;
    self.navigationItem.titleView.frame = CGRectMake(0, 0, 180, 22.2);
    _segment.selectedSegmentIndex = 0;
    [_segment addTarget:self action:@selector(didSelectSegment:) forControlEvents:UIControlEventValueChanged];
    
    
    _submitBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _submitBtn.frame = CGRectMake(0, 0, 60, 40);
    [_submitBtn setTitle:@"提交点名" forState:UIControlStateNormal];
    [_submitBtn setTintColor:XColor(208, 85, 90, 1)];
//    _submitTag = 0;//默认提交点名
//    [_submitBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sub = [[UIBarButtonItem alloc] initWithCustomView:_submitBtn];
    self.navigationItem.rightBarButtonItem = sub;
}

- (void)didSelectSegment:(UISegmentedControl *)sender{
    if (sender.selectedSegmentIndex == 0) {
        _fillcheck.view.hidden = YES;
        _detail.view.hidden = YES;
    }else if(sender.selectedSegmentIndex == 1){
        if (!_detail) {
            _detail = [[THDetailOfRollcallViewController alloc] init];
            _detail.view.frame = CGRectMake(0, 64+43, screenW, screenH-64-43);
            [self.view addSubview:_detail.view];

        }
        _detail.view.hidden = NO;
        _fillcheck.view.hidden = YES;
    }else if(sender.selectedSegmentIndex == 2){
        _detail.view.hidden = YES;
        if (!_fillcheck) {
            _fillcheck = [[THFillCheckViewController alloc] init];
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
    return 4;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"系统推荐点名";
    }else{
        return @"其他";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green"]];
        icon.frame = CGRectMake(screenW-10-30, (cell.frame.size.height-30)/2, 30, 30);
        [cell addSubview:icon];
        UILabel *numberOfabsence = [[UILabel alloc] initWithFrame:CGRectMake(screenW-40-100, 20, 80, 13)];
        numberOfabsence.text = @"缺勤次数：10";
        numberOfabsence.font = [UIFont systemFontOfSize:15];
        numberOfabsence.adjustsFontSizeToFitWidth = YES;
        numberOfabsence.textColor = XColor(207, 85, 89, 1);
        
        [cell addSubview:numberOfabsence];
        
        cell.textLabel.text = @"俞祥祥";
        cell.detailTextLabel.text = @"11084229";
    }
    return cell;
}

// 设置侧滑选项
//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    return YES;
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//8.0需要先调用这个方法
}

- (NSArray <UITableViewRowAction*>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *absence = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"缺席" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [tableView setEditing:NO];
    }];
    absence.backgroundColor = XColor(208, 85, 90, 1);
    
    UITableViewRowAction *leave = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"请假" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        
        [tableView setEditing:NO];
        
    }];
    leave.backgroundColor = XColor(64, 186, 217, 1);
    UITableViewRowAction *cancel = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"撤销"handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        
       [tableView setEditing:NO];
    }];
    return @[cancel,leave,absence];
    
}


//隐藏tabbar
- (void)viewWillDisappear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
    
}

@end

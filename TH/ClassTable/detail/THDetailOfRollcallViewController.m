//
//  THDetailOfRollcallViewController.m
//  TH
//
//  Created by Taro on 15/11/26.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import "THDetailOfRollcallViewController.h"
#import "XYPieChart.h"
@interface THDetailOfRollcallViewController ()<XYPieChartDataSource,XYPieChartDelegate>
@property (nonatomic , strong) XYPieChart * pieChart;
@property (nonatomic , strong) NSMutableArray * slices;
@property (nonatomic , strong) NSMutableArray * colorOfSlice;
@property (nonatomic , strong) NSMutableArray * nameOfSlice;
@end

@implementation THDetailOfRollcallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addXYpieChart];
}

- (void)addXYpieChart{
    self.pieChart = [[XYPieChart alloc] init];
    self.pieChart.delegate = self;
    self.pieChart.dataSource = self;
    [self.pieChart setStartPieAngle:M_PI];
    [self.pieChart setAnimationSpeed:1.0];
    [self.pieChart setPieRadius:screenH/5];//饼图半径
    [self.pieChart setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:20]];
    [self.pieChart setLabelRadius:screenH/6-20];//数据标签出现的位置
    [self.pieChart setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [self.pieChart setPieCenter:CGPointMake(screenW/2, self.view.frame.size.height/5+10)];
    [self.pieChart setLabelShadowColor:[UIColor blackColor]];
    //    [self.pieChart setShowPercentage:NO];
    _slices = [NSMutableArray arrayWithObjects:@60,@60,@60,@60, nil];
    _nameOfSlice = [NSMutableArray arrayWithObjects:@"缺席",@"请假",@"迟到",@"已到",nil];
    self.colorOfSlice =[NSMutableArray arrayWithObjects:
                         [UIColor colorWithRed:246/255.0 green:155/255.0 blue:0/255.0 alpha:1],
                         [UIColor colorWithRed:129/255.0 green:195/255.0 blue:29/255.0 alpha:1],
                         [UIColor colorWithRed:62/255.0 green:173/255.0 blue:219/255.0 alpha:1],
                         [UIColor colorWithRed:229/255.0 green:66/255.0 blue:115/255.0 alpha:1],
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


@end

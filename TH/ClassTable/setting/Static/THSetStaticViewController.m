//
//  THSetStaticViewController.m
//  Teacher-Help
//
//  Created by Taro on 15/11/20.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import "THSetStaticViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface THSetStaticViewController ()
@property (nonatomic , weak) UISlider * slider;
@property (nonatomic , weak) UILabel * label;

@end

@implementation THSetStaticViewController
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
    self.view.backgroundColor = [UIColor whiteColor];
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(35, 160, screenW-70, 20)];
    [slider setTintColor:XColor(208, 86, 90, 1)];
    [self.view addSubview:slider];
    [slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    _slider = slider;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(screenW/2-50, 64+44, 100, 44)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"0%";
    [self.view addSubview:label];
    _label = label;
    
    UILabel *reminder = [[UILabel alloc] init];
    reminder.frame = CGRectMake(15, 64, screenW, 44);
    reminder.text = @"请设置平时作业分占平时分的百分比：";
    [self.view addSubview:reminder];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(35, 200, screenW-70, 44)];
    [button setTitle:@"提交" forState:UIControlStateNormal];
    button.backgroundColor = XColor(208, 86, 90, 1);
    [button addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

}
- (void)submit{
    
    
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    NSString *url = [NSString stringWithFormat:@"%@/%@/course_homework_per/",host,version];
    
    //存在百分比没有精确的问题
    NSDictionary *dict = @{
                           @"courseId" : @1,
                           @"homeworkPer" : [NSNumber numberWithFloat:_slider.value]
                           };
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        THLog(@"%@",responseObject);
        NSNumber *status = responseObject[@"status"];
        if (status.intValue == 1) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"提交成功！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
            [alert addAction:confirm];
            [self presentViewController:alert animated:YES completion:nil];

        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        THLog(@"%@",error);
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"系统信息" message:@"网络连接有问题" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [alertView show];
    }];
    
}

- (void)sliderValueChange:(id)sender{
    UISlider *control = (UISlider *)sender;
    if (control == _slider) {
        float value = control.value;
        _label.text = [NSString stringWithFormat:@"%0.0f %%",value*100];
        THLog(@"%f",value);
    }
}

@end

//
//  THClassTableViewController.m
//  TH
//
//  Created by Taro on 15/11/22.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import "THClassTableViewController.h"
#import "THRollCallViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "THSettingTableViewController.h"
#import "THStatisticsViewController.h"
#import "THClass.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MBProgressHUD+YXX.h"

@interface THClassTableViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic , strong) UIScrollView * classlist;
@property (nonatomic , strong) UIButton * btnSelect;
@property (nonatomic , strong) UIButton * btn;
@property (nonatomic , strong) UIView * btnSeletView;
@property (nonatomic , strong) UITableView * weekTable;
@property (nonatomic , assign) NSInteger week;
@property (nonatomic , strong) NSMutableArray * everyWeek;
@property (nonatomic , strong) NSMutableDictionary * day;
@property (nonatomic , strong) NSMutableArray * allday;

@end

@implementation THClassTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MBProgressHUD showMessage:@"载入中" toView:self.view];
    [self getCurrentDay];
    [self initWeekBtn];
    [self initClasslist];
    
 
    self.view.backgroundColor = [UIColor whiteColor];
    UINavigationController *nav = [self.tabBarController.viewControllers objectAtIndex:2];
    THSettingTableViewController *setting = [[THSettingTableViewController alloc] init];
    setting = [nav.viewControllers objectAtIndex:0];
    setting.name = self.name;
    setting.teacherNO = self.teacherNO;
    [self getClassTable:^(NSArray *array) {
        //星期判断
        NSArray *result = array;
        NSMutableArray *total = [[NSMutableArray alloc] init];
        for (int a = 0; a < 7; a++) {
            NSMutableArray *preweek = [[NSMutableArray alloc] init];
            for (int i = 0; i < result.count; i++) {
                NSDictionary *dict = [result objectAtIndex:i];
                if ([dict[@"week"]integerValue] == a) {
                    [preweek addObject:dict];
                }
            }
            [total addObject:preweek];
        }
        //上下午判断
        _allday = [NSMutableArray array];
        for (int i = 0; i < total.count; i++) {
            NSArray *everyday = [total objectAtIndex:i];
            NSMutableArray *morning = [[NSMutableArray alloc] init];
            NSMutableArray *afternoon = [[NSMutableArray alloc] init];
            NSMutableArray *evening = [[NSMutableArray alloc] init];
            for (int a = 0; a < everyday.count; a++) {
                NSDictionary *timeseparate = [everyday objectAtIndex:a];
                //取一门课判断上下午
                THClass *class = [THClass classWithDic:timeseparate];
                NSInteger time = [timeseparate[@"time"] integerValue];
                if (time == 0) {
                    [morning addObject:class];
                }else if (time == 1){
                    [afternoon addObject:class];
                }else if (time == 2){
                    [evening addObject:class];
                }
            }
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:morning forKey:@"morning"];
            [dict setValue:afternoon forKey:@"afternoon"];
            [dict setValue:evening forKey:@"evening"];
            [_allday addObject:dict];

        }
        [self addTableOfWeek];
       
        UINavigationController *nav = [self.tabBarController.viewControllers objectAtIndex:1];
        THStatisticsViewController *statistic = [nav.viewControllers objectAtIndex:0];
        statistic.classList = array;
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];

}

- (void)initClasslist{
    
    if (!_classlist) {
        _classlist = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 43+64,screenW,screenH-43-64)];
        _classlist.backgroundColor = XColor(241, 241, 241, 1);
        _classlist.pagingEnabled = YES;
        _classlist.contentSize = CGSizeMake(7*screenW, 0);
        _classlist.delegate = self;
        [self.classlist setContentOffset:CGPointMake(screenW*_week, 0)];
        [self.view addSubview:_classlist];
        
    }

}
- (void)initWeekBtn{
    if (!_btn) {
        NSArray *week = @[@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
        _btnSeletView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, screenW/7, 43)];
        _btnSeletView.transform = CGAffineTransformMakeTranslation(screenW/7*_week, 0);
        _btnSeletView.backgroundColor = XColor(188, 188, 188, 1);
        [self.view addSubview:_btnSeletView];

        for (int i = 0; i < 7; i++) {
            _btn = [[UIButton alloc] init];
            _btn.tag = i;
            _btn.frame = CGRectMake(i*screenW/7, 64, screenW/7, 43);
            _btn.backgroundColor = XColor(226, 226, 226, 0.6);
            [_btn setTitle:week[i] forState:UIControlStateNormal];
            [_btn setTitleColor:XColor(209, 84, 87, 1) forState:UIControlStateNormal];
            [_btn addTarget:self action:@selector(btnToScrollView:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_btn];
        }
   
    }
}

- (void)btnToScrollView:(UIButton *)sender{
    CGFloat x = sender.tag*screenW;
    [self.classlist setContentOffset:CGPointMake(x, 0)];
    [UIView animateWithDuration:0.1 animations:^{
        _btnSeletView.transform = CGAffineTransformMakeTranslation(screenW/7*sender.tag, 0);
    
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
 
    int btn_num = _classlist.contentOffset.x/screenW;
    [UIView animateWithDuration:0.1 animations:^{
        _btnSeletView.transform = CGAffineTransformMakeTranslation(screenW/7*btn_num, 0);
    }];
    
    
}

- (void)addTableOfWeek{
    for (int i = 0; i < 7; i++) {
        _weekTable = [[UITableView alloc] initWithFrame:CGRectMake(screenW*i,0 ,self.classlist.bounds.size.width, self.classlist.bounds.size.height) style:UITableViewStyleGrouped];
        _weekTable.dataSource = self;
        _weekTable.delegate = self;
        _weekTable.tag = i;
        [self.classlist addSubview:_weekTable];

    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
//    for (int i = 0; i < 7; i++) {
//        NSDictionary *dict = [_allday objectAtIndex:i];
//        if (tableView.tag == i) {
//            if (section == 0) {
//                NSArray *morning = dict[@"morning"];
//                return morning.count;
//                THLog(@"asd");
//            }else if(section == 1){
//                NSArray *afternoon = dict[@"afternoon"];
//                return afternoon.count;
//            }else if(section == 2){
//                NSArray *evening = dict[@"evening"];
//                return evening.count;
//            }
//            
//        }
//    }
    THLog(@"%@",_allday);
    if (section == 0) {
        for (int i = 0; i < 7; i++) {
            if (tableView.tag == i) {
                NSDictionary *dict = [_allday objectAtIndex:i];
                
                NSArray *morning = dict[@"morning"];
                return morning.count;
            }
        }
    }else if(section == 1){
        for (int i = 0; i < 7; i++) {
            if (tableView.tag == i) {
                NSDictionary *dict = [_allday objectAtIndex:i];
                NSArray *afternoon = dict[@"afternoon"];
                return afternoon.count;
            }
        }

    }else if(section == 2){
        for (int i = 0; i < 7; i++) {
            if (tableView.tag == i) {
                
                NSDictionary *dict = [_allday objectAtIndex:i];
                NSArray *evening = dict[@"evening"];
                return evening.count;
            
            }
        }
        return 3;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"上午";
    }else if(section == 1){
        return @"下午";
    }else{
        return @"晚上";
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 31.0;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 69.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(16, 11.8, screenW/2, 22)];
        name.font = [UIFont systemFontOfSize:16];
        [cell addSubview:name];
        UILabel *timeOfClass = [[UILabel alloc] initWithFrame:CGRectMake(16, 40.6, 50, 20)];
        timeOfClass.font = [UIFont systemFontOfSize:13.8];
        timeOfClass.adjustsFontSizeToFitWidth = YES;
        [cell addSubview:timeOfClass];
        UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(screenW/2+10, 40.6, screenW/2-10, 16)];
        location.font = [UIFont systemFontOfSize:11.4];
        location.textColor = XColor(138, 138, 138, 1);
//        location.adjustsFontSizeToFitWidth = YES;
        [cell addSubview:location];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        for (int i = 0; i < 7; i ++) {
            if (tableView.tag == i) {
                NSDictionary *classOfDay = [_allday objectAtIndex:i];
                if (indexPath.section == 0) {
                    NSArray *array = classOfDay[@"morning"];
                    THClass *class = array[indexPath.row];
                    name.text = class.courseName;
                    cell.tag = [class.courseId integerValue];
                    timeOfClass.text =[NSString stringWithFormat:@"%@节",class.lessonPeriod];
                    location.text = class.venue;
                }
                else if (indexPath.section == 1) {
                    NSArray *array = classOfDay[@"afternoon"];
                   THClass *class = array[indexPath.row];
                    name.text = class.courseName;
                    cell.tag = [class.courseId integerValue];
                    timeOfClass.text = [NSString stringWithFormat:@"%@节",class.lessonPeriod];
                    location.text = class.venue;
                }
                else if (indexPath.section == 2){
                    NSArray *array = classOfDay[@"evening"];
                    THClass *class = array[indexPath.row];
                    name.text = class.courseName;
                    timeOfClass.text = [NSString stringWithFormat:@"%@节",class.lessonPeriod];
                    location.text = class.venue;
                    cell.tag = [class.courseId integerValue];
                }
            }
        }
        
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    THRollCallViewController *rollcall = [[THRollCallViewController alloc] init];
    rollcall.cookie = _cookie;
//    rollcall.courseId = @5;
    rollcall.weekOrdinal = @10;
    [self.navigationController pushViewController:rollcall animated:YES];
  //设置返回按钮
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    THLog(@"%ld",cell.tag);
    rollcall.courseId = [[NSNumber alloc] initWithInteger:cell.tag];
    [self.navigationController.navigationBar setTintColor:XColor(209, 84, 87, 1)];
    self.navigationItem.backBarButtonItem = backItem;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    });
}

- (NSInteger)getCurrentDay{
    //获得当前星期几
    NSDate *date = [NSDate date];
//    //IOS7
//    //    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    //ios8
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [calendar setTimeZone:timeZone];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    //    NSInteger unitFlags = NSYearCalendarUnit |
//    //    NSMonthCalendarUnit |
//    //    NSDayCalendarUnit |
//    //    NSWeekdayCalendarUnit |
//    //    NSHourCalendarUnit |
//    //    NSMinuteCalendarUnit |
//    //    NSSecondCalendarUnit;
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitWeekday;
    comps = [calendar components:unitFlags fromDate:date];
    NSInteger week = [comps weekday];
    _week = week;
    if (_week == 1) {
        _week = 6;
    }else if (_week == 2){
        _week = 0;
    }else{
        _week = _week-2;
    }
    return _week;
}




- (void)getClassTable:(void(^)( NSArray *array))success{

    NSString *url = [NSString stringWithFormat:@"%@/%@/course_names/",host,version];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSArray *result = responseObject[@"courses"];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (success) {
                success(result);
            }
        }];
    
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        THLog(@"%@",error);
    }];
    
}





@end

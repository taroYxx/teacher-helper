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

@interface THClassTableViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic , strong) UIScrollView * classlist;
@property (nonatomic , strong) UIButton * btnSelect;
@property (nonatomic , strong) UIButton * btn;
@property (nonatomic , strong) UIView * btnSeletView;
@property (nonatomic , strong) UITableView * weekTable;

@end

@implementation THClassTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initClasslist];
    [self initWeekBtn];
    [self addTableOfWeek];
    [self getClassTable:^(NSMutableDictionary *dictionary) {
//        THLog(@"%@",dictionary);
    }];
}

- (void)initClasslist{
    
    if (!_classlist) {
        _classlist = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 43+64,screenW,screenH-43-64)];
        _classlist.backgroundColor = XColor(241, 241, 241, 1);
        _classlist.pagingEnabled = YES;
        _classlist.contentSize = CGSizeMake(7*screenW, 0);
        _classlist.delegate = self;
        [self.view addSubview:_classlist];
        _btnSeletView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, screenW/7, 43)];
        _btnSeletView.backgroundColor = XColor(188, 188, 188, 1);
        [self.view addSubview:_btnSeletView];
        
    }

}
- (void)initWeekBtn{
    if (!_btn) {
        NSArray *week = @[@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
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
    _weekTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.classlist.bounds.size.width, self.classlist.bounds.size.height) style:UITableViewStyleGrouped];
    _weekTable.dataSource = self;
    _weekTable.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.classlist addSubview:_weekTable];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"上午";
    }else{
        return @"下午";
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
        name.text = @"应用与写作";
        name.font = [UIFont systemFontOfSize:16];
        [cell addSubview:name];
        
        UILabel *timeOfClass = [[UILabel alloc] initWithFrame:CGRectMake(16, 40.6, 50, 20)];
        timeOfClass.text = @"3-4节";
        timeOfClass.font = [UIFont systemFontOfSize:13.8];
        [cell addSubview:timeOfClass];
        
        UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(screenW/2+10, 40.6, screenW/2-10, 16)];
        location.text = @"12教研北楼303";
        location.font = [UIFont systemFontOfSize:11.4];
        location.textColor = XColor(138, 138, 138, 1);
        [cell addSubview:location];
        
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    THRollCallViewController *rollcall = [[THRollCallViewController alloc] init];
    [self.navigationController pushViewController:rollcall animated:YES];
  //设置返回按钮
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    [self.navigationController.navigationBar setTintColor:XColor(209, 84, 87, 1)];
    self.navigationItem.backBarButtonItem = backItem;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    });
}

- (void)getClassTable:(void(^)( NSMutableDictionary *dictionary))success{
    
//    NSURL* URL = [NSURL URLWithString:@"http://120.26.83.51/demo/get_course/"];
//    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL cachePolicy:1 timeoutInterval:2.0f];
//    request.HTTPMethod = @"GET";
//    [request addValue:_cookie forHTTPHeaderField:@"Cookie"];
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//        id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
//        NSMutableDictionary *array = result;
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            if (success) {
//                success(array);
//            }
//        }];
//    }];
    NSString *url = [NSString stringWithFormat:@"http://%@/%@/get_course",host,version];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        THLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        THLog(@"%@",error);
    }];
}





@end

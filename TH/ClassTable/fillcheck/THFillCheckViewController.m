//
//  THFillCheckViewController.m
//  TH
//
//  Created by Taro on 15/11/26.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import "THFillCheckViewController.h"

@interface THFillCheckViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic , strong) UITableView * absenceList;
@end

@implementation THFillCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    // Do any additional setup after loading the view.
    [self initAbsenceList];
}


- (void)initAbsenceList{
    _absenceList = [[UITableView alloc] initWithFrame:self.view.frame];
    _absenceList.delegate = self;
    _absenceList.dataSource = self;
    [self.view addSubview:_absenceList];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.textLabel.text = @"杨浩楠";
    }
    
    return cell;
}



@end

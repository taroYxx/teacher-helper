//
//  THTabbarViewController.m
//  Teacher-Help
//
//  Created by Taro on 15/10/21.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import "THTabbarViewController.h"
#import "THClassTableViewController.h"
#import "THSettingTableViewController.h"
#import "THStatisticsViewController.h"


@interface THTabbarViewController ()

@end

@implementation THTabbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    THClassTableViewController *classtable = [[THClassTableViewController alloc] init];
    [self addchildVc:classtable title:@"课堂点名" image:@"class" selectedImage:@"class_select"];
    THStatisticsViewController *statistics = [[THStatisticsViewController alloc] init];
    [self addchildVc:statistics title:@"统计成绩" image:@"statistics" selectedImage:@"statistics_select"];
    THSettingTableViewController *setting = [[THSettingTableViewController alloc] init];
    [self addchildVc:setting title:@"个人设置" image:@"setting" selectedImage:@"setting_select"];
//    THHomeworkViewController *work = [[THHomeworkViewController alloc] init];
//    [self addchildVc:work title:@"作业" image:@"home" selectedImage:@"home_select"];

    
}

- (void)addchildVc:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectImage{
    if (!selectImage) {
        selectImage = image;
    }
    childVc.title = title;
    childVc.tabBarItem.image = [UIImage imageNamed:image];
    //使用原图，不渲染
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [childVc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} forState:UIControlStateNormal];
    [childVc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:XColor(209, 84, 87, 1)} forState:UIControlStateSelected];
//    [self addChildViewController:[[UINavigationController alloc] initWithRootViewController:childVc]];
//    self.navigationController.navigationBar.barTintColor = XColor(64, 185, 216, 1);
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childVc];
    nav.navigationBar.barTintColor = [UIColor whiteColor];
    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:XColor(209, 84, 87, 1),NSForegroundColorAttributeName,nil]];
    
    [self addChildViewController:nav];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

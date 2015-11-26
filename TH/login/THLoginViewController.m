//
//  THLoginViewController.m
//  Teacher-Help
//
//  Created by Taro on 15/10/22.
//  Copyright © 2015年 Taro. All rights reserved.
//

#import "THLoginViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MBProgressHUD+YXX.h"
#import "THTabbarViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "THClassTableViewController.h"



@interface THLoginViewController ()<UITextFieldDelegate>
@property (nonatomic , weak) UITextField *username;
@property (nonatomic , weak) UITextField *password;
@property (nonatomic , weak) UIButton *loginbtn;
@property (nonatomic , weak) UIView *iconbg;
@property (nonatomic , weak) UIView *textbg;
@end

@implementation THLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIImage *iconimage = [UIImage imageNamed:@"icon"];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:iconimage];
    icon.frame = CGRectMake((screenW-screenH/3)/2, 20, screenH/3, screenH/3);
    [self.view addSubview:icon];
    
    
    UITextField *username = [[UITextField alloc] init];
    username.delegate = self;
    username.placeholder = @"学工号";
    username.borderStyle = UITextBorderStyleRoundedRect;
    username.clearButtonMode = UITextFieldViewModeAlways;
    username.returnKeyType = UIReturnKeyNext;
    self.username = username;
    UITextField *password = [[UITextField alloc] init];
    password.placeholder = @"数字杭电密码";
    password.delegate = self;
    password.borderStyle = UITextBorderStyleRoundedRect;
    password.clearButtonMode = UITextFieldViewModeAlways;
    password.secureTextEntry = YES;
    self.password = password;
    username.translatesAutoresizingMaskIntoConstraints = NO;
    password.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:username];
    [self.view addSubview:password];
    
    UIButton *loginbtn = [[UIButton alloc] init];
    [loginbtn setTitle:@"登入" forState:UIControlStateNormal];
    loginbtn.translatesAutoresizingMaskIntoConstraints = NO;
    loginbtn.backgroundColor = XColor(64, 185, 216, 1);
    [loginbtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginbtn];
    loginbtn.enabled = YES;
    self.loginbtn = loginbtn;
    //设置自动布局
    
    NSArray *usernameX = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[username]-20-|" options:0 metrics:nil views:@{@"username" : username}];
    [self.view addConstraints:usernameX];
    NSArray *usernameY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[icon]-20-[username(40)]-10-[password(40)]-10-[loginbtn(40)]" options:0 metrics:nil views:@{@"icon" : icon, @"username" : username, @"password" : password, @"loginbtn" : loginbtn}];
    [self.view addConstraints:usernameY];
    NSArray *passwordX = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[password]-20-|" options:0 metrics:nil views:@{@"password" : password}];
    [self.view addConstraints:passwordX];
    NSArray *loginbtnX = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[loginbtn]-20-|" options:0 metrics:nil views:@{@"loginbtn" : loginbtn}];
    [self.view addConstraints:loginbtnX];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardStartMove:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [center addObserver:self selector:@selector(btnchange) name:UITextFieldTextDidChangeNotification object:self.username];
    [center addObserver:self selector:@selector(btnchange) name:UITextFieldTextDidChangeNotification object:self.password];
}

- (void)login{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [MBProgressHUD showMessage:@"正在登入" toView:self.view];
   
//    NSURL *url = [NSURL URLWithString:urlStr];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setURL:url];
//    [request setHTTPMethod:@"POST"];
//    [request addValue:[NSString stringWithFormat:@"text/html"] forHTTPHeaderField:@"Content-Type"];
//    NSMutableData *postBody = [NSMutableData data];
//    [postBody ]
    
    
    
    
    
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    NSDictionary* bodyParameters = @{
                                     @"username":self.username.text,
                                     @"password":self.password.text,

                                     };
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
     NSString *urlStr = [NSString stringWithFormat:@"http://%@/%@/teacher_login/",host,version];
    [manager POST:urlStr parameters:bodyParameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        THLog(@"%@",responseObject);
        THLog(@"%@",[operation.response allHeaderFields][@"set-Cookie"]);
        NSNumber *status = responseObject[@"status"];
        if (status.intValue == 1) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            THTabbarViewController *tab = [[THTabbarViewController alloc] init];
            THClassTableViewController *main = [[THClassTableViewController alloc] init];
            UINavigationController *nav = [tab.viewControllers objectAtIndex:0];
            main = [nav.viewControllers objectAtIndex:0];
            main.cookie = [operation.response allHeaderFields][@"set-Cookie"];
//            THLog(@"login%@",main.cookie);
            window.rootViewController = tab;
        }else if (status.intValue == 3){
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"系统信息" message:@"用户不存在或密码不存在" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [alertView show];
            
        }else if (status.intValue == 2){
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"系统信息" message:@"该用户没有权限访问" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [alertView show];
            
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"系统信息" message:@"网络连接错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [alertView show];
        }
//
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        THLog(@"%@",error);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"系统信息" message:@"网络连接错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [alertView show];
    }];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        UIWindow *window = [UIApplication sharedApplication].keyWindow;
//        THTabbarViewController *tab = [[THTabbarViewController alloc] init];
//        window.rootViewController = tab;
//    });
}

- (void)keyboardStartMove:(NSNotification *)note{
    CGRect keyboardframe = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat transformY = keyboardframe.origin.y - screenH;
    CGFloat loginbtnY = screenH-(self.loginbtn.frame.origin.y + self.loginbtn.frame.size.height);
    CGFloat keyboardY = screenH - keyboardframe.origin.y;
    if (keyboardY >= loginbtnY) {
        CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, transformY/2);
        }];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    self.username.text = @"40686";
    self.password.text = @"cjh40686";
}

- (void)btnchange{
    self.loginbtn.enabled = (self.username.text.length && self.password.text.length);
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

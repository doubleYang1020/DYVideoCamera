//
//  RootTabrTableViewController.m
//  DYVideoCamera
//
//  Created by huyangyang on 2017/6/20.
//  Copyright © 2017年 huyangyang. All rights reserved.
//

#import "RootTabrTableViewController.h"
#import "ViewController.h"
#import "RTRootNavigationController.h"
#import "VideoListViewController.h"
#import "UserHomeViewController.h"
#import "VideoRecordViewController.h"

@interface RootTabrTableViewController ()

@end

@implementation RootTabrTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//        CGRect tabFrame = self.tabBar.frame;
//        tabFrame.size.height = 60;
//        tabFrame.origin.y = self.view.frame.size.height - 60;
//        self.tabBar.frame = tabFrame;
    
    

    
    [self SetUi];
    [self setupTabBarBackgroundImage];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

//自定义TabBar高度
- (void)viewWillLayoutSubviews {
//    
//    CGRect tabFrame = self.tabBar.frame;
//    tabFrame.size.height = 60;
//    tabFrame.origin.y = self.view.frame.size.height - 60;
//    self.tabBar.frame = tabFrame;
    
}

-(void)SetUi{
    
    
    RTRootNavigationController *VideoListNav = [[RTRootNavigationController alloc] initWithRootViewController:VideoListViewController.new];
    
//    PushStremViewController *Push =[[PushStremViewController alloc]init];
    
    UINavigationController *PushNav =[[UINavigationController alloc]initWithRootViewController:ViewController.new];
    
    
//    MeViewController *Mine =[[MeViewController alloc]init];
    
    RTRootNavigationController *MineNav =[[RTRootNavigationController alloc]initWithRootViewController:UserHomeViewController.new];
    
    self.viewControllers = @[VideoListNav,PushNav,MineNav];
    
    NSArray *array = self.viewControllers;
    
    NSArray *SimagesArray = @[@"tab_live_p", @"tab_room_p", @"tab_me_p"];
    
    
    NSArray *imagesArray = @[@"tab_live", @"tab_room", @"tab_me"];
    
    for (int i = 0; i < array.count ; i++) {
        
        UIViewController *vc= array[i];
        
        vc.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[[UIImage imageNamed:imagesArray[i]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed: SimagesArray[i]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(8, 0, -8, 0);
    }
    
    UIButton* centerBtn = [[UIButton alloc] init];
    [centerBtn addTarget:self action:@selector(clickCenterBtn) forControlEvents:UIControlEventTouchUpInside];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    centerBtn.frame = CGRectMake(screenWidth/2 -30 , 0, 60, 60);
    [self.tabBar addSubview:centerBtn];
    
    
    
}
- (void)clickCenterBtn{
    NSLog(@"clickCenterBtn");
   RTRootNavigationController *MineNav =[[RTRootNavigationController alloc]initWithRootViewControllerNoWrapping:VideoRecordViewController.new];
    [self.selectedViewController presentViewController:MineNav animated:YES completion:^{
        
    }];
}



- (void)setupTabBarBackgroundImage {
    
    //    //隐藏阴影线
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    [self.tabBar setShadowImage:[UIImage new]];
    UIImage *image = [UIImage imageNamed:@"tab_bg"];
    
    CGFloat top = 40; // 顶端盖高度
    CGFloat bottom = 40 ; // 底端盖高度
    CGFloat left = 100; // 左端盖宽度
    CGFloat right = 100; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    
    // 指定为拉伸模式，伸缩后重新赋值
    UIImage *TabBgImage = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    
    self.tabBar.backgroundImage = TabBgImage;
    self.tabBar.shadowImage = [UIImage new];
    
    [self.tabBar setClipsToBounds:YES];
    
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

//
//  VideoRecordViewController.m
//  iShow
//
//  Created by 胡阳阳 on 17/3/8.
//
//

#import "VideoRecordViewController.h"
#import "VideoCameraView.h"
#import "RTRootNavigationController.h"
@interface VideoRecordViewController ()<VideoCameraDelegate>


@property (nonatomic ,strong) UITextField* configWidth;
@property (nonatomic ,strong) UITextField* configHight;
@property (nonatomic ,strong) UITextField* configBit;
@property (nonatomic ,strong) UITextField* configFrameRate;
@property (nonatomic ,strong) UIButton* okBtn;

@end

@implementation VideoRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
 


    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
//    if (_configWidth == nil) {
//        _configWidth = [[UITextField alloc] init];
//        _configWidth.keyboardType = UIKeyboardTypeNumberPad;
//        _configWidth.borderStyle = UITextBorderStyleRoundedRect;
//        _configWidth.textAlignment = NSTextAlignmentCenter;
//        _configWidth.placeholder = @"width:720";
//        [self.view addSubview:_configWidth];
//        [_configWidth mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.view).offset(64);
//            make.centerX.equalTo(self.view);
//            make.width.equalTo(@(200));
//        }];
//        
//        _configHight = [[UITextField alloc] init];
//        _configHight.keyboardType = UIKeyboardTypeNumberPad;
//        _configHight.borderStyle = UITextBorderStyleRoundedRect;
//        _configHight.textAlignment = NSTextAlignmentCenter;
//        _configHight.placeholder = @"hight:1280";
//        [self.view addSubview:_configHight];
//        [_configHight mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_configWidth.mas_bottom).offset(20);
//            make.centerX.equalTo(self.view);
//            make.width.equalTo(@(200));
//        }];
//        
//        _configBit = [[UITextField alloc] init];
//        _configBit.keyboardType = UIKeyboardTypeNumberPad;
//        _configBit.borderStyle = UITextBorderStyleRoundedRect;
//        _configBit.textAlignment = NSTextAlignmentCenter;
//        _configBit.placeholder = @"bit:2000000";
//        [self.view addSubview:_configBit];
//        [_configBit mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_configHight.mas_bottom).offset(20);
//            make.centerX.equalTo(self.view);
//            make.width.equalTo(@(200));
//        }];
//        
//        _configFrameRate = [[UITextField alloc] init];
//        _configFrameRate.keyboardType = UIKeyboardTypeNumberPad;
//        _configFrameRate.borderStyle = UITextBorderStyleRoundedRect;
//        _configFrameRate.textAlignment = NSTextAlignmentCenter;
//        _configFrameRate.placeholder = @"fps:30";
//        [self.view addSubview:_configFrameRate];
//        [_configFrameRate mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_configBit.mas_bottom).offset(20);
//            make.centerX.equalTo(self.view);
//            make.width.equalTo(@(200));
//        }];
//        
//        _okBtn = [[UIButton alloc] init];
//        //    _okBtn.titleLabel.text = @"OK";
//        _okBtn.backgroundColor = [UIColor greenColor];
//        [_okBtn setTitle:@"OK" forState:UIControlStateNormal];
//        [_okBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [_okBtn addTarget:self action:@selector(clickOKBtn) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:_okBtn];
//        [_okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_configFrameRate.mas_bottom).offset(20);
//            make.centerX.equalTo(self.view);
//            make.width.equalTo(@(200));
//        }];
//        
//        UIButton* backBtn = [[UIButton alloc] init];
//        //    _okBtn.titleLabel.text = @"OK";
//        backBtn.backgroundColor = [UIColor greenColor];
//        [backBtn setTitle:@"back" forState:UIControlStateNormal];
//        [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [backBtn addTarget:self action:@selector(clickBackHome) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:backBtn];
//        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_okBtn.mas_bottom).offset(20);
//            make.centerX.equalTo(self.view);
//            make.width.equalTo(@(200));
//        }];
//
//    }
    
    [self clickOKBtn];
    
}
-(void)clickBackHome
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:kTabBarHiddenNONotification object:self];
    [self.navigationController popViewControllerAnimated:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(void)clickOKBtn
{
//    [_configBit resignFirstResponder];
//    [_configWidth resignFirstResponder];
//    [_configHight resignFirstResponder];
    int width,hight,bit,framRate;
//    if (_configWidth.text.length>0&&_configHight.text.length>0) {
//        //        [NSNumber numberWithInt:5]
//        width = [_configWidth.text intValue];
//        hight = [_configHight.text intValue];
//    }
//    else
    {
        width = 720;
        hight = 1280;
    }
//    if (_configBit.text.length>0) {
//        bit = [_configBit.text intValue];
//    }
//    else
    {
        bit = 2500000;
    }
//    if (_configFrameRate.text.length>0) {
//        framRate = [_configFrameRate.text intValue];
//    }
//    else
    {
        framRate = 30;
    }
    bool needNewVideoCamera = YES;
    for (UIView* subView in self.view.subviews) {
        if ([subView isKindOfClass:[VideoCameraView class]]) {
            needNewVideoCamera = NO;
        }
    }
    if (needNewVideoCamera) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        CGRect frame = [[UIScreen mainScreen] bounds];
        VideoCameraView* videoCameraView = [[VideoCameraView alloc] initWithFrame:frame];
      videoCameraView.delegate = self;
        NSLog(@"new VideoCameraView");
        videoCameraView.width = [NSNumber numberWithInteger:width];
        videoCameraView.hight = [NSNumber numberWithInteger:hight];
        videoCameraView.bit = [NSNumber numberWithInteger:bit];
        videoCameraView.frameRate = [NSNumber numberWithInteger:framRate];
        
        typeof(self) __weak weakself = self;
        videoCameraView.backToHomeBlock = ^(){
//            [[NSNotificationCenter defaultCenter] postNotificationName:kTabBarHiddenNONotification object:self];
//            [weakself.navigationController popViewControllerAnimated:NO];
          [weakself.navigationController dismissViewControllerAnimated:NO completion:nil];
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            NSLog(@"clickBackToHomg2");
        };
        [self.view addSubview:videoCameraView];
    }
}

//-(void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)presentCor:(UIViewController *)cor
{
  [self presentViewController:cor animated:YES completion:nil];
}

-(void)pushCor:(UIViewController *)cor
{
  [self.rt_navigationController pushViewController:cor animated:YES complete:nil];
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}
-(void)dealloc
{
    NSLog(@"%@释放了",self.class);
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

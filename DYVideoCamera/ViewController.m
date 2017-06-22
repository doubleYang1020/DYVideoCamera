//
//  ViewController.m
//  DYVideoCamera
//
//  Created by huyangyang on 2017/6/20.
//  Copyright © 2017年 huyangyang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self dismissViewControllerAnimated:YES completion:nil];
//    });
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


@end

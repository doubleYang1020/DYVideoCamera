//
//  DYVideoNavViewController.m
//  DYVideoModule
//
//  Created by huyangyang on 2017/11/28.
//

#import "DYVideoNavViewController.h"
#import "DYVMConstants+Private.h"

@interface DYVideoNavViewController ()

@end

@implementation DYVideoNavViewController

- (void)dealloc {
    Log(@"DYVideoNavViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.barTintColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0)  blue:(255/255.0) alpha:0.0];
    self.navigationBar.tintColor = [UIColor blackColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a litDYe preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

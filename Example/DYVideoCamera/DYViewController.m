//
//  DYViewController.m
//  DYVideoCamera
//
//  Created by doubleYang1020 on 08/23/2019.
//  Copyright (c) 2019 doubleYang1020. All rights reserved.
//

#import "DYViewController.h"
#import "DYVideoModule.h"
#import "VideoModuleDataSourceMock.h"
@interface DYViewController ()
@property (strong, nonatomic) VideoModuleDataSourceMock* videoModuleDataSource;
@end

@implementation DYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.videoModuleDataSource = [[VideoModuleDataSourceMock alloc] init];
//    [self buttonAction:NULL];


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (IBAction)buttonAction:(id)sender {
    
    DYVideoRecoderViewController *vc = [[DYVideoRecoderViewController alloc] init];
    [vc setVideoModelDataSource:self.videoModuleDataSource];
    DYVideoNavViewController* nav = [[DYVideoNavViewController alloc] initWithRootViewController:vc];
    self.videoModuleDataSource.holder = nav;
    [self presentViewController:nav animated:true completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end

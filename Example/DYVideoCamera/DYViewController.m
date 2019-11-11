//
//  DYViewController.m
//  DYVideoCamera
//
//  Created by doubleYang1020 on 08/23/2019.
//  Copyright (c) 2019 doubleYang1020. All rights reserved.
//

#import "DYViewController.h"

#import "VideoListDelegate.h"
#import "DYVideoListKit.h"
#import "DYSingleObject.h"
@interface DYViewController ()
@property (strong, nonatomic) id<DYVideoListDelegate> videoModuleDataSource;
@end

@implementation DYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.videoModuleDataSource = [[VideoListDelegate alloc] init];
    [DYSingleObject sharedInstance].videoModelDataSource = self.videoModuleDataSource;
    [DYVideoListKit showClassName];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end

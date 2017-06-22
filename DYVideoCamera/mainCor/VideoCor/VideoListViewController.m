//
//  VideoListViewController.m
//  DYVideoCamera
//
//  Created by huyangyang on 2017/6/20.
//  Copyright © 2017年 huyangyang. All rights reserved.
//

#import "VideoListViewController.h"
#import "VideoDataModel.h"
#import "ViewController.h"
#import "RTRootNavigationController.h"
#import "HomeVideoCollectionViewCell.h"
#import "PlayVideoViewController.h"
#import "MJRefresh.h"
#import "YCAutoHideOrShowTon.h"

#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define ScreenWidth [UIScreen mainScreen].bounds.size.width

#define kCollectionViewVideoCellIdentifier @"kHomepageVideoCellIdentifier"
@interface VideoListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, retain) UICollectionView *videoCollectionView;//热拍
@property (nonatomic, strong) NSMutableArray* videoDataAry;
YCAutoHideOrShowTonProperty
@end

@implementation VideoListViewController

YCAutoHideOrShowTonMethod(self.navigationController.navigationBar, self.tabBarController.tabBar)

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"视频推荐";
    
    [VideoDataModel getHomePageVideoDataWithBlock:^(NSArray *dateAry, NSError *error) {
        NSLog(@"xxx");
    }];
    
    float collectionViewH = ScreenHeight-50;
    
    UICollectionViewFlowLayout* videoFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [videoFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//垂直滚动
    UICollectionView *videocollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,ScreenHeight ) collectionViewLayout:videoFlowLayout];
    videocollectionView.alwaysBounceVertical = YES;//当不够一屏的话也能滑动
    videocollectionView.delegate = self;
    videocollectionView.dataSource = self;
    [videocollectionView setBackgroundColor:[UIColor whiteColor]];
    [videocollectionView registerClass:[HomeVideoCollectionViewCell class] forCellWithReuseIdentifier:kCollectionViewVideoCellIdentifier];
    self.videoCollectionView = videocollectionView;
    [self.view addSubview:self.videoCollectionView];
    self.videoCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshVideoData)];
    self.videoCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(addVideoData)];
    
    [VideoDataModel getHomePageVideoDataWithBlock:^(NSArray *dateAry, NSError *error) {
        if (!error) {
            _videoDataAry = [NSMutableArray arrayWithArray:dateAry];
            [self.videoCollectionView reloadData];
        }else{
            
        }
    }];

    
    
    self.hidesBottomBarWhenPushed = YES;
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.rt_navigationController pushViewController:ViewController.new animated:YES complete:^(BOOL finished) {
//            
//        }];
//    });
    // Do any additional setup after loading the view.
}

-(void)refreshVideoData
{
    
    [VideoDataModel getHomePageVideoDataWithBlock:^(NSArray *dateAry, NSError *error) {
        if (!error) {
            _videoDataAry = [NSMutableArray arrayWithArray:dateAry];
            [self.videoCollectionView.mj_header endRefreshing];
            [self.videoCollectionView reloadData];
        }else{
            [self.videoCollectionView.mj_header endRefreshing];
        }
    }];
}
-(void)addVideoData
{
    
    [VideoDataModel getHomePageVideoDataWithBlock:^(NSArray *dateAry, NSError *error) {
        if (!error) {
            //            _videoDataAry = [NSMutableArray arrayWithArray:dateAry];
            [_videoDataAry addObjectsFromArray:dateAry];
            [self.videoCollectionView.mj_footer endRefreshing];
            [self.videoCollectionView reloadData];
        }else{
            [self.videoCollectionView.mj_footer endRefreshing];
        }
    }];
    
}


#pragma mark UICollectionViewDataSource {
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//定义展示的UICollectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return _videoDataAry.count;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = kCollectionViewVideoCellIdentifier;
    HomeVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier1 forIndexPath:indexPath];
    cell.DataModel = [_videoDataAry objectAtIndex:indexPath.row];
    return cell;
}
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//
//}
//返回头headerView的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeZero;
}
//定义每个item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(ScreenWidth/2 - 2, (ScreenWidth/2 - 2)*1.6);
}
//定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{

    return UIEdgeInsetsMake(0.0,2.0,0.0,2.0);
}
//每个item之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;

}
//每个section中不同的行之间的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{

    return 0.0f;
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    self.hidesBottomBarWhenPushed = YES;
    PlayVideoViewController* cor = [[PlayVideoViewController alloc] init];
    cor.whenBackIsNeedhiddenBottomBar = YES;
    cor.DataModel = _videoDataAry[indexPath.row];
    [self.rt_navigationController pushViewController:cor animated:YES complete:^(BOOL finished) {
        
    }];
    self.hidesBottomBarWhenPushed = NO;

}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = false;
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

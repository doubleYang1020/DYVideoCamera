//
//  UserHomeViewController.m
//  DYVideoCamera
//
//  Created by huyangyang on 2017/6/20.
//  Copyright © 2017年 huyangyang. All rights reserved.
//

#import "UserHomeViewController.h"
#import "VideoDataModel.h"
#import "ZFPlayer.h"


#import "SDImageCache.h"
#import "masonry.h"
#import "UIImageView+WebCache.h"
#import "VideoLisetCell.h"

#import "YCAutoHideOrShowTon.h"

@interface UserHomeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray* VideoMutableAry;
@property (nonatomic,strong) UITableView* mainTableView;

@property (nonatomic, strong) ZFPlayerView        *playerView;
@property (nonatomic, strong) ZFPlayerControlView *controlView;

@property (nonatomic,strong) NSIndexPath* lastPath;
@property (nonatomic,strong) NSIndexPath* nowPath;
YCAutoHideOrShowTonProperty
@end

@implementation UserHomeViewController
YCAutoHideOrShowTonMethod(self.navigationController.navigationBar, self.tabBarController.tabBar)
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人主页";
    self.view.backgroundColor = [UIColor yellowColor];
  
  _mainTableView = [[UITableView alloc] init];
  _mainTableView.pagingEnabled = YES;
  _mainTableView.showsVerticalScrollIndicator = NO;
  _mainTableView.delegate = self;
  _mainTableView.dataSource = self;
  _mainTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
  [self.view addSubview:_mainTableView];
  [_mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.top.equalTo(self.view);
    make.bottom.equalTo(self.view)/*.offset(-44)*/;
    //        make.bottom.equalTo(self.view).offset(60);
  }];

  
  [VideoDataModel getHomePageVideoDataWithBlock:^(NSArray *dateAry, NSError *error) {
    self.VideoMutableAry = [NSMutableArray arrayWithArray:dateAry];
    [_mainTableView reloadData];
    
  }];
    // Do any additional setup after loading the view.
}
-(void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [_playerView pause];
  
  NSLog(@"viewDidDisappear");
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _VideoMutableAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *cellID = @"VideoLisetCell";
  VideoLisetCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
  if (nil == cell) {
    cell = [[VideoLisetCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    NSLog(@"第%ld次创建",(long)indexPath.row);
  }
  __block VideoDataModel* commentDataModel = _VideoMutableAry[indexPath.row];
  cell.DataModel = commentDataModel;
  __block NSIndexPath *weakIndexPath = indexPath;
  __block VideoLisetCell *weakCell     = cell;
  __weak typeof(self)  weakSelf      = self;
  
  cell.playBlock = ^(UIButton *btn){
    

    // 取出字典中的第一视频URL
    NSURL *videoURL = [NSURL URLWithString:commentDataModel.video_url];
    
    ZFPlayerModel *playerModel = [[ZFPlayerModel alloc] init];
    playerModel.videoURL         = videoURL;
    playerModel.placeholderImageURLString = commentDataModel.cover_url;
    playerModel.scrollView       = weakSelf.mainTableView;
    playerModel.indexPath        = weakIndexPath;

    // player的父视图tag
    playerModel.fatherViewTag    = weakCell.coverImgView.tag;
    
    // 设置播放控制层和model
    [weakSelf.playerView playerControlView:nil playerModel:playerModel];
    // 自动播放
    [weakSelf.playerView autoPlayTheVideo];
  };
  
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
//  CommentDataModel* commentDataModel = _commentsMutableAry[indexPath.row];
  //    if ([commentDataModel.selfUID intValue] == [AppDelegate appDelegate].appDelegatePlatformUserStructure.platformUserId) {
  //        NSLog(@"点击自己的评论");
  //        [_commentsTextField resignFirstResponder];
  //    }else
  //    {
  //        _commentsTextField.placeholder = [NSString stringWithFormat:@"@%@:",commentDataModel.selfNickName];
  //        _placeholderStr = [NSString stringWithFormat:@"@%@: ",commentDataModel.selfNickName];
  //        [_commentsTextField becomeFirstResponder];
  //    }
  
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [UIScreen mainScreen].bounds.size.height;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//  [self hideOrHiddenNavBar:scrollView];
//  self.lastY = nil;
//  self.originY = nil;

  
  NSArray *visiblePaths = [_mainTableView indexPathsForVisibleRows];
  if (visiblePaths.count == 1) {
    _nowPath = visiblePaths.firstObject;
    if (_lastPath.row == _nowPath.row) {
      return ;
    }
    _lastPath = _nowPath;
    VideoLisetCell* cell = [_mainTableView cellForRowAtIndexPath:visiblePaths.firstObject];
    [cell play:nil];
  }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
  if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
    return NO;
  }
  
  return  YES;
}


- (ZFPlayerView *)playerView {
  if (!_playerView) {
    _playerView = [ZFPlayerView sharedPlayerView];
//    _playerView.delegate = self;
    // 当cell播放视频由全屏变为小屏时候，不回到中间位置
    _playerView.cellPlayerOnCenter = NO;
    
    [_playerView autoPlayTheVideo];
    // 当cell划出屏幕的时候停止播放
    _playerView.stopPlayWhileCellNotVisable = YES;
    //（可选设置）可以设置视频的填充模式，默认为（等比例填充，直到一个维度到达区域边界）
    // _playerView.playerLayerGravity = ZFPlayerLayerGravityResizeAspect;
    // 静音
    // _playerView.mute = YES;
  }
  return _playerView;
}

- (ZFPlayerControlView *)controlView {
  if (!_controlView) {
    _controlView = [[ZFPlayerControlView alloc] init];
  }
  return _controlView;
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

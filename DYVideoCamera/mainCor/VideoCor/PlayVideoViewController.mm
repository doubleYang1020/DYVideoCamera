//
//  PlayVideoViewController.m
//  iShow
//
//  Created by 胡阳阳 on 17/2/24.
//
//

#import "PlayVideoViewController.h"
#import "RTRootNavigationController.h"
#import "VideoCommentsTableViewCell.h"
#import "WMPlayer.h"
#import "SDImageCache.h"
#import "SDImageCache.h"
#import "MJRefresh.h"
#import "MBProgressHUD.h"
#import <CommonCrypto/CommonCryptor.h>
#import <Security/SecRandom.h>
#import "UIImageView+WebCache.h"
#import <AVFoundation/AVFoundation.h>

#define MAX_STARWORDS_LENGTH 50

#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface CommentsData : NSObject
@property (nonatomic,strong) NSString* nickName;
@property (nonatomic,strong) NSString* contentText;
@property (nonatomic,strong) NSString* time;


@end
@implementation CommentsData

@end
@interface PlayVideoViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate>
{
    MBProgressHUD* HUD;
}

@property (nonatomic,strong) UITableView* mainTableView;
@property (nonatomic,strong) WMPlayer* wmPlayer;


@property (nonatomic,strong) UIView* commentsTextFieldBar;

@property (nonatomic,strong) UITextField* commentsTextField;

@property (nonatomic,strong) UIButton* sendCommentsBtn;

@property (nonatomic,strong) UIVisualEffectView *visualEffectView;

@property (nonatomic,strong) NSMutableArray* commentsMutableAry;

@property (nonatomic, strong) UIImageView* iconImgeView;


@property (nonatomic, strong) UIImageView* zhanImgView;

@property (nonatomic, strong) NSString* placeholderStr;

@property (nonatomic, strong) UILabel *shareLabel,*zhanLabel,*commentLabel;

@property (nonatomic, assign) BOOL isZhan;

@property (nonatomic, assign) int comtentPageIndex;
@end

@implementation PlayVideoViewController
-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
//    [self.rt_navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _commentsMutableAry = [NSMutableArray array];
    [self initcommentS];
    [self createTableView];
    _comtentPageIndex = 1;
    [self createCustomNavBar];
    [self createCommentsTextFieldBar];
    [self initUMSharePage];
    
    [self.view setNeedsLayout]; //更新视图
    [self.view layoutIfNeeded];
    
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishPlayer) name:WMPlayerFinishedPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickOneWMPlayer) name:WMPlayerSingleTapNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrameNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.mainTableView reloadData];
    // Do any additional setup after loading the view.
}
- (void) initcommentS
{
    CommentDataModel* data1 = [CommentDataModel new];
    data1.selfNickName = @"Lithpie";
    data1.createdTime = @"1天前";
    data1.content = @"30万听众，41评论。这里的都是些不善言谈的人。";
    data1.faceurl = @"http://p3.pstatp.com/live/100x100/1946001175da6c6f38a7.jpg"/*[[NSBundle mainBundle] pathForResource:@"usericon01" ofType:@"png"]*/;
    [_commentsMutableAry insertObject:data1 atIndex:0];
    
    CommentDataModel* data2 = [CommentDataModel new];
    data2.selfNickName = @"匠子烤又";
    data2.createdTime = @"8小时前";
    data2.content = @"时常在想，如果我未曾来到这个城市，会去哪里。如果我还在记忆中的那个小城，是否会找份清闲的工作，或开个不热闹的小店。下雨的时候撑着伞，走过那条上学必经落满梧桐的街。打开我房间的抽屉，朋友写的信，卡带，女同学编的手链。人是孤独的动物，却孤独不过百年。";
    data2.faceurl = @"http://p1.pstatp.com/live/100x100/26da000097202289e858.jpg"/*[[NSBundle mainBundle] pathForResource:@"usericon01" ofType:@"png"]*/;
    [_commentsMutableAry insertObject:data2 atIndex:0];
    
    CommentDataModel* data3 = [CommentDataModel new];
    data3.selfNickName = @"想不到昵称l";
    data3.createdTime = @"4小时前";
    data3.content = @"我愿我行我素。不愿涂脂抹粉，招摇过市。我也不愿意生活在这不安的，忙乱的，神经质的世界中。宁可或立或坐沉思着，任听这大千世界的风雨🍃";
    data3.faceurl = @"http://p1.pstatp.com/live/100x100/26d90002772cc1565907.jpg"/*[[NSBundle mainBundle] pathForResource:@"usericon01" ofType:@"png"]*/;
    [_commentsMutableAry insertObject:data3 atIndex:0];
    
    CommentDataModel* data4 = [CommentDataModel new];
    data4.selfNickName = @"unkira";
    data4.createdTime = @"1小时前";
    data4.content = @"其实我有时候觉得，这个世界是不存在的，是我想象出来的。每次想到就会觉得很孤单，还是假装它存在吧。";
    data4.faceurl = @"http://p3.pstatp.com/live/100x100/123f0004e4375f8f63be.jpg"/*[[NSBundle mainBundle] pathForResource:@"usericon01" ofType:@"png"]*/;
    [_commentsMutableAry insertObject:data4 atIndex:0];
}

-(void)viewDidAppear:(BOOL)animated
{
//    [VideoDataModel isPointedWithDyID:_DataModel.dyid ForHandelBlock:^(int errorCode, BOOL isPoint) {
//        NSLog(@"是否点赞过。%@ and code:%d",isPoint?@"YES":@"NO",errorCode);
//        if (errorCode == 0) {
//            _isZhan = isPoint;
//            if (isPoint) {
//                _zhanImgView.image = [UIImage imageNamed:@"xgzhanSelected"];
//            }else
//            {
//                
//            }
//        }
//    }];
    
//    [VideoDataModel toTheServersPlayCountWithdynamicID:[_DataModel.dyid intValue] ForHandelBlock:^(int errorCode) {
//        if(errorCode == 0){
//            NSLog(@"视频播放次数+1回报成功");
//        }else
//        {
//            NSLog(@"视频播放次数+1回报成功%d",errorCode);
//        }
//    }];
//    
    [super viewDidAppear:animated];
    
    //东西写viewDidAppear的下面出现问题：页面关闭太快，会导致子线程出现通知慢
}

- (void)createTableView{
    _mainTableView = [[UITableView alloc] init];
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
    // 为了让tableView自适应高度设置如下两个属性
    _mainTableView.estimatedRowHeight = 30;
    _mainTableView.rowHeight = UITableViewAutomaticDimension;
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    headerView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Actiondo:)];
    tapGesture.delegate = self;
    [_mainTableView addGestureRecognizer:tapGesture];
    _mainTableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshCommentsData)];
    _mainTableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(addCommentsData)];
    
    UIImageView* wmPlayerBgImgView = [[UIImageView alloc] init];
    wmPlayerBgImgView.contentMode = UIViewContentModeScaleAspectFit;
    [wmPlayerBgImgView setClipsToBounds:YES];
    [headerView addSubview:wmPlayerBgImgView];
    [wmPlayerBgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(headerView);
    }];
    [wmPlayerBgImgView sd_setImageWithURL:[NSURL URLWithString:_DataModel.cover_url] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"usericon02" ofType:@"png"]]];
    
    
    _mainTableView.tableHeaderView = headerView;
    _wmPlayer  = [[WMPlayer alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) videoURLStr:_DataModel.video_url];
    [headerView addSubview:_wmPlayer];
    _wmPlayer.closeBtn.hidden = YES;
    _wmPlayer.bottomView.hidden = YES;
    _wmPlayer.fullScreenBtn.hidden = YES;
    _wmPlayer.backgroundColor = [UIColor clearColor];
    [_wmPlayer play];
    

    
    
    
    UILabel* titleLabel = [[UILabel alloc] init];
//    titleLabel.backgroundColor = [UIColor grayColor];
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:13.5];
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(headerView).offset(70);
        make.left.equalTo(headerView).offset(10);
        make.width.equalTo(@(140));
    }];
//    titleLabel.text = _DataModel.title;
    [self toSetUpThree_dimensionalShadows:titleLabel andString:_DataModel.title];
    
    UIView* headerViewBottomBar = [[UIView alloc] init];
    headerViewBottomBar.backgroundColor = [UIColor clearColor];
    [headerView addSubview:headerViewBottomBar];
    [headerViewBottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(headerView);
        make.height.equalTo(@(44));
    }];
    
    
    UIImageView* commentImgView = [[UIImageView alloc] init];
    commentImgView.image = [UIImage imageNamed:@"comment"];
    commentImgView.userInteractionEnabled = YES;
    [headerViewBottomBar addSubview:commentImgView];
    [commentImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerViewBottomBar);
        make.centerX.equalTo(headerViewBottomBar);
        make.width.height.equalTo(@(24));
    }];
    UITapGestureRecognizer* tapGesturecommentImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickcommentImgView)];
    [commentImgView addGestureRecognizer:tapGesturecommentImg];
    _commentLabel = [[UILabel alloc] init];
    _commentLabel.textColor = [UIColor whiteColor];
    _commentLabel.textAlignment = NSTextAlignmentLeft;
    _commentLabel.font = [UIFont systemFontOfSize:11];
    _commentLabel.text = _DataModel.comment_count;
    [headerViewBottomBar addSubview:_commentLabel];
    [_commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(commentImgView);
        make.left.equalTo(commentImgView.mas_right).offset(2);
    }];
    
    _shareLabel = [[UILabel alloc] init];
    _shareLabel.textColor = [UIColor whiteColor];
    _shareLabel.textAlignment = NSTextAlignmentRight;
    _shareLabel.font = [UIFont systemFontOfSize:11];
    _shareLabel.text = _DataModel.share_count;
    [headerViewBottomBar addSubview:_shareLabel];
    [_shareLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headerViewBottomBar).offset(-20);
        make.centerY.equalTo(commentImgView);
    }];
    
    UIImageView* shareImgView = [[UIImageView alloc] init];
    shareImgView.image = [UIImage imageNamed:@"xgshare"];
    shareImgView.userInteractionEnabled = YES;
    [headerViewBottomBar addSubview:shareImgView];
    [shareImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(commentImgView);
        make.right.equalTo(_shareLabel.mas_left).offset(-2);
        make.width.height.equalTo(@(24));
    }];
    UITapGestureRecognizer* tapGestureShareImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickShare3rdBtn)];
    [shareImgView addGestureRecognizer:tapGestureShareImg];
    
    
    _zhanImgView = [[UIImageView alloc] init];
    _zhanImgView.image = [UIImage imageNamed:@"xgzhan"];
    _zhanImgView.userInteractionEnabled = YES;
    [headerViewBottomBar addSubview:_zhanImgView];
    [_zhanImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(commentImgView);
        make.centerX.equalTo(headerViewBottomBar).offset(ScreenWidth/4-24);
        make.width.height.equalTo(@(24));
    }];
    _isZhan = NO;
    UITapGestureRecognizer* tapGestureZhanImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickZhanBtn)];
    [_zhanImgView addGestureRecognizer:tapGestureZhanImg];
    
    _zhanLabel = [[UILabel alloc] init];
    _zhanLabel.textColor = [UIColor whiteColor];
    _zhanLabel.textAlignment = NSTextAlignmentLeft;
    _zhanLabel.font = [UIFont systemFontOfSize:11];
    _zhanLabel.text = _DataModel.digg_count;
    [headerViewBottomBar addSubview:_zhanLabel];
    [_zhanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_zhanImgView.mas_right).offset(2);
        make.centerY.equalTo(commentImgView);
    }];
    
    UIView* writeBgView = [[UIView alloc] init];
    writeBgView.backgroundColor = [UIColor whiteColor];
    writeBgView.alpha = .3;
    [headerViewBottomBar addSubview:writeBgView];
    [writeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerViewBottomBar);
        make.height.equalTo(@(24));
        make.width.equalTo(@(ScreenWidth/2 - 20 -12));
        make.left.equalTo(headerViewBottomBar).offset(10);
        
    }];
//    [[AppDelegate appDelegate].cmImageSize setViewsRounded:writeBgView cornerRadiusValue:12 borderWidthValue:0 borderColorWidthValue:[UIColor whiteColor]];
    writeBgView.layer.masksToBounds = true;
    writeBgView.layer.cornerRadius = 12;
    
    UITapGestureRecognizer* tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showkeyboard)];
    [writeBgView addGestureRecognizer:tapGesture2];

    
    UILabel* writeComment = [[UILabel alloc] init];
    writeComment.textColor = [UIColor whiteColor];
    writeComment.textAlignment = NSTextAlignmentLeft;
    writeComment.font = [UIFont systemFontOfSize:11];
    writeComment.text = @"😊写评论...";
    [headerViewBottomBar addSubview:writeComment];
    [writeComment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(commentImgView);
        make.left.equalTo(writeBgView).offset(5);
    }];
    
    

    
    


    

}
- (void)createCustomNavBar{
    UIView* myNavBar = [[UIView alloc] init];
    myNavBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:myNavBar];
    [myNavBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(64));
    }];
    
    //实现模糊效果
    UIBlurEffect *blurEffrct =[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    //毛玻璃视图
    _visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffrct];
    _visualEffectView.alpha = 0;
    [myNavBar addSubview:_visualEffectView];
    
    [_visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.top.bottom.equalTo(myNavBar);
    }];
    

    
    _iconImgeView = [[UIImageView alloc] init];
    _iconImgeView.contentMode = UIViewContentModeScaleAspectFill;
    [_iconImgeView setClipsToBounds:YES];
    [myNavBar addSubview:_iconImgeView];
    [_iconImgeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(myNavBar).offset(5);
        make.left.equalTo(myNavBar).offset(10);
        make.height.width.equalTo(@(30));
    }];
    [_iconImgeView sd_setImageWithURL:[NSURL URLWithString:_DataModel.avatar_thumb] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"usericon02" ofType:@"png"]]];
//    [[AppDelegate appDelegate].cmImageSize setImagesRounded:_iconImgeView cornerRadiusValue:15 borderWidthValue:0 borderColorWidthValue:[UIColor whiteColor]];
    _iconImgeView.layer.masksToBounds = true;
    _iconImgeView.layer.cornerRadius = 15;
    
    UIButton* backBtn = [[UIButton alloc] init];
    [backBtn setImage:[UIImage imageNamed:@"xgback"] forState:UIControlStateNormal];
    [myNavBar addSubview:backBtn];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_iconImgeView);
        make.right.equalTo(myNavBar).offset(-20);
        make.width.height.equalTo(@(30));
    }];
    
    UIButton* jubaoBtn = [[UIButton alloc] init];
//    if ([_DataModel.AuthorUid intValue] == [AppDelegate appDelegate].appDelegatePlatformUserStructure.platformUserId) {
//        [jubaoBtn setImage:[UIImage imageNamed:@"HSDeleteIcon"] forState:UIControlStateNormal];
//    }else
//    {
//        [jubaoBtn setImage:[UIImage imageNamed:@"xgjubao"] forState:UIControlStateNormal];
//    }
    [myNavBar addSubview:jubaoBtn];
    jubaoBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [jubaoBtn addTarget:self action:@selector(clickJubaoBtn) forControlEvents:UIControlEventTouchUpInside];
    [jubaoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_iconImgeView);
        make.right.equalTo(backBtn.mas_left).offset(-10);
        make.width.height.equalTo(@(30));
    }];
    
    UILabel* nickNameLabel = [[UILabel alloc] init];
    nickNameLabel.textAlignment = NSTextAlignmentCenter;
    nickNameLabel.textColor = [UIColor whiteColor];
    nickNameLabel.font = [UIFont systemFontOfSize:12];
    [myNavBar addSubview:nickNameLabel];
    [nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iconImgeView);
        make.left.equalTo(_iconImgeView.mas_right).offset(8);
        make.right.lessThanOrEqualTo(jubaoBtn.mas_left).offset(-3);
    }];
//    nickNameLabel.text = _DataModel.nickname;
    [self toSetUpThree_dimensionalShadows:nickNameLabel andString:_DataModel.nickname];
    
    UILabel* fireTipLabel = [[UILabel alloc] init];
    fireTipLabel.textAlignment = NSTextAlignmentCenter;
    fireTipLabel.textColor = [UIColor whiteColor];
    fireTipLabel.font = [UIFont systemFontOfSize:12];
    [myNavBar addSubview:fireTipLabel];
    [fireTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_iconImgeView.mas_bottom);
        make.left.equalTo(_iconImgeView.mas_right).offset(8);
    }];
    [self toSetUpThree_dimensionalShadows:fireTipLabel andString:_DataModel.stats_tips];
//    fireTipLabel.text = _DataModel.stats_tips;
}
-(void)toSetUpThree_dimensionalShadows:(UILabel*)Label andString:(NSString*)str
{
    if (str == nil || str == NULL) {
        str = @"";
    }
    if ([str isKindOfClass:[NSNull class]]) {
        str = @"";
    }
    if (!(str.length >0)) {
        str = @"";
    }
    NSShadow *shadow = [[NSShadow alloc]init];
    shadow.shadowBlurRadius = 0.5;
    shadow.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    shadow.shadowOffset = CGSizeMake(0, .6);
    NSMutableAttributedString* labelAttribute = [[NSMutableAttributedString alloc]initWithString:str];
    [labelAttribute addAttributes:@{NSStrokeColorAttributeName:[UIColor whiteColor],NSStrokeWidthAttributeName:@(-0.4),NSShadowAttributeName:shadow} range:NSMakeRange(0, labelAttribute.length)];
    [Label setAttributedText:labelAttribute];
}

-(void)createCommentsTextFieldBar
{
    _commentsTextFieldBar = [[UIView alloc] init];
    _commentsTextFieldBar.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_commentsTextFieldBar];
    [_commentsTextFieldBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(44));
        make.bottom.equalTo(self.view).offset(44);
    }];
    
    _sendCommentsBtn = [[UIButton alloc] init];
    [_sendCommentsBtn setTitle:@"发送" forState:UIControlStateNormal];
    [_sendCommentsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendCommentsBtn setBackgroundColor:[UIColor grayColor]];
    [_sendCommentsBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_sendCommentsBtn addTarget:self action:@selector(ClicksendCommentsBtn) forControlEvents:UIControlEventTouchUpInside];
    [_commentsTextFieldBar addSubview:_sendCommentsBtn];
    _sendCommentsBtn.enabled = NO;
    [_sendCommentsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_commentsTextFieldBar).offset(-20);
        make.bottom.equalTo(_commentsTextFieldBar).offset(-8);
        make.top.equalTo(_commentsTextFieldBar).offset(8);
        make.width.equalTo(@(80));
    }];
//    [[AppDelegate appDelegate].cmImageSize setButtonsRounded:_sendCommentsBtn cornerRadiusValue:13 borderWidthValue:0 borderColorWidthValue:[UIColor clearColor]];
    _sendCommentsBtn.layer.masksToBounds = true;
    _sendCommentsBtn.layer.cornerRadius = 13;
    
    
    _commentsTextField = [[UITextField alloc] init];
    _commentsTextField.returnKeyType = UIReturnKeyDone;
//    _commentsTextField.borderStyle = UITextBorderStyleNone;
    _commentsTextField.borderStyle = UITextBorderStyleRoundedRect;
//    _commentsTextField.returnKeyType = UIReturnKeySend;
    _commentsTextField.backgroundColor = [UIColor clearColor];
    _commentsTextField.font = [UIFont systemFontOfSize:15];
    _commentsTextField.placeholder = @"😊写评论";
    _commentsTextField.delegate = self;
    _commentsTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_commentsTextFieldBar addSubview:_commentsTextField];
    [_commentsTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(_commentsTextFieldBar).offset(8);
        make.bottom.equalTo(_commentsTextFieldBar).offset(-8);
        make.right.equalTo(_sendCommentsBtn.mas_left).offset(-8);
    }];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification" object:_commentsTextField];
}

-(void)initUMSharePage{
//    _sharebgBar = [[UMShareBar alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 200)];
//    _sharebgBar.delegete = self;
//    [self.view addSubview:_sharebgBar];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _commentsMutableAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"VideoCommentsCellID";
    VideoCommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (nil == cell) {
        cell = [[VideoCommentsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        NSLog(@"第%ld次创建",(long)indexPath.row);
    }
    CommentDataModel* commentDataModel = _commentsMutableAry[indexPath.row];
    cell.nickeNameLabel.text = commentDataModel.selfNickName;
    cell.commentLabel.text = commentDataModel.content;
    cell.timeLabel.text = commentDataModel.createdTime;
    [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:commentDataModel.faceurl] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"usericon02" ofType:@"png"]]];
    
//    CommentsData* commentDataModel = _commentsMutableAry[indexPath.row];
//    cell.nickeNameLabel.text = commentDataModel.nickName;
//    cell.commentLabel.text = commentDataModel.contentText;
//    cell.timeLabel.text = commentDataModel.time;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    CommentDataModel* commentDataModel = _commentsMutableAry[indexPath.row];
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
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
// 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
        }

        return  YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_commentsTextField resignFirstResponder];
    
    [UIView animateWithDuration:0.2 animations:^{
//        _sharebgBar.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 200);
    }];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
        float y = scrollView.contentOffset.y;
   
    if (y>=0 && y<=44) {
         NSLog(@"scrollViewDidScroll andcontentOfyValue:%f",y);
        [_commentsTextFieldBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(44-y);
        }];
        [_mainTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-y);
        }];
        [self.view layoutIfNeeded];
        
    }
    if (y < 0) {
        [_commentsTextFieldBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(44);
        }];
        [_mainTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(0);
        }];
        [self.view layoutIfNeeded];

    }
    if (y> 44) {
        [_commentsTextFieldBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(0);
        }];
        [_mainTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-44);
        }];
        [self.view layoutIfNeeded];
    }
        float alphaValue = (y/ScreenHeight);
        _visualEffectView.alpha = alphaValue;
}
- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification {
    
    // 获取键盘基本信息（动画时长与键盘高度）
    NSDictionary *userInfo = [notification userInfo];
    
    if (!userInfo) {
        return;
    }
    
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到鍵盤的高度
    CGFloat keyboardDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 修改下边距约束
    [_commentsTextFieldBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-kbSize.height);
    }];
    
    // 更新约束
    [UIView animateWithDuration:keyboardDuration animations:^{
        [self.view layoutIfNeeded];

    }];
    
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    // 获得键盘动画时长
    NSDictionary *userInfo   = [notification userInfo];
    if (!userInfo) {
        return;
    }
    CGFloat keyboardDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 修改为以前的约束（距下边距0）
    [_commentsTextFieldBar mas_updateConstraints:^(MASConstraintMaker *make) {
        if (_mainTableView.contentOffset.y > 44) {
            make.bottom.equalTo(self.view).offset(0);
        }
        else
        {
            make.bottom.equalTo(self.view).offset(44 - _mainTableView.contentOffset.y);
        }
        
    }];
    
    // 更新约束
    [UIView animateWithDuration:keyboardDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    _commentsTextField.placeholder = @"😊写评论";
    _placeholderStr = @"";
}
-(void)textFieldDidBeginEditing:(UITextField*)textField
{
    NSLog(@"textFieldDidBeginEditing111111111111");
    [_mainTableView setContentOffset:_mainTableView.contentOffset animated:YES];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger length = textField.text.length - range.length + string.length;
    if (length > 0) {
        _sendCommentsBtn.enabled = YES;

        _sendCommentsBtn.backgroundColor = [UIColor colorWithRed:255/256.0f green:70/256.0f blue:95/256.0f alpha:1.0];
        
    } else {
        _sendCommentsBtn.enabled = NO;
        
        _sendCommentsBtn.backgroundColor = [UIColor grayColor];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}
-(void)clickJubaoBtn
{
//    type_base_id_int uid = [AppDelegate appDelegate].appDelegatePlatformUserStructure.platformUserId;
//    if ([_DataModel.AuthorUid intValue] == uid) {
//        LiveAlertView* alert = [[LiveAlertView alloc] init];
//        NSString* title = [NSString stringWithFormat:@"确定删除该视频"];
//        NSMutableAttributedString* blueStr = [[NSMutableAttributedString alloc] initWithString:title];
//        alert.contentLabel.attributedText = blueStr;
//        alert.alpha = 0.8 ;
//        [alert showTitle:title confirmTitle:@"取消" cancelTitle:@"删除" confirm:^{
//            
//        } cancel:^{
//            
//            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES ];
//            HUD.labelText = @"视频删除中...";
//            [VideoDataModel deleteVideoDynamicWithDyID:_DataModel.dyid ForHandelBlock:^(int errorCode) {
//                if (errorCode == 0) {
//                    HUD.labelText = @"删除成功";
////                    [HUD hide:YES afterDelay:1.0];
//                    
//                    if (_whenBackIsNeedhiddenBottomBar) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshHomeDynamicList" object:self];
//                    }else
//                    {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMyDynamicList" object:self];
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshHomeDynamicList" object:self];
//                    }
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        [self clickBackBtn];
//                    });
//                }else
//                {
//                    HUD.labelText = [NSString stringWithFormat:@"删除失败%d",errorCode];
////                    [HUD hide:YES afterDelay:1.0];
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        [self clickBackBtn];
//                    });
//                }
//            }];
//        }];
//        
//
//    }else
//    {
//        if(uid < 0) {
//            [[AppDelegate appDelegate].appViewService appNeedLoginTips];
//            return;
//        }
//        UIActionSheet *reportActionSheet = [[UIActionSheet alloc]initWithTitle:@"举报类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"欺诈骗钱",@"色情暴力", nil];
//        //
//        if ([AppDelegate appDelegate].appDelegatePlatformUserStructure.platformUserId != 0) {
//            [reportActionSheet showInView:self.view];
//        }
//    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if(buttonIndex == 0 || buttonIndex == 1)
//    {
//        if([[AppDelegate appDelegate] thirdNetworkNotReportStateDetection])
//        {
//           [[AppDelegate appDelegate] appDontCoverLoadingViewShowForContext:@"举报成功；我们会尽快核实，谢谢" ForTypeShow:2 ForChangeFrameSizeType:0 ForFrameFlg:YES ForCancelTime:1.0];
//        }
//        else
//        {
//            [[AppDelegate appDelegate] appDontCoverLoadingViewShowForContext:@"举报失败；网络不稳定，请先检查网络" ForTypeShow:1 ForChangeFrameSizeType:0 ForFrameFlg:YES ForCancelTime:2.0];
//        }
//    }
}
-(void)clickBackBtn
{
//    [[UIApplication sharedApplication] setStatusBarHidden:false];
    [self releaseWMPlayer];
//    [_barView timerInval];
//    if (_whenBackIsNeedhiddenBottomBar) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kTabBarHiddenNONotification object:self];
//    }
    [self.navigationController popViewControllerAnimated:YES];

}
-(void) finishPlayer
{

    [_wmPlayer play];
}
-(void)clickOneWMPlayer
{
    [self Actiondo:nil];
}
-(void)releaseWMPlayer{
    [_wmPlayer.player.currentItem cancelPendingSeeks];
    [_wmPlayer.player.currentItem.asset cancelLoading];
    [_wmPlayer pause];
    
    //移除观察者
    [_wmPlayer.currentItem removeObserver:_wmPlayer forKeyPath:@"status"];
    
    [_wmPlayer removeFromSuperview];
    [_wmPlayer.playerLayer removeFromSuperlayer];
    [_wmPlayer.player replaceCurrentItemWithPlayerItem:nil];
    _wmPlayer.player = nil;
    _wmPlayer.currentItem = nil;
    //释放定时器，否侧不会调用WMPlayer中的dealloc方法
    [_wmPlayer.autoDismissTimer invalidate];
    _wmPlayer.autoDismissTimer = nil;
    [_wmPlayer.durationTimer invalidate];
    _wmPlayer.durationTimer = nil;
    
    _wmPlayer.playOrPauseBtn = nil;
    _wmPlayer.playerLayer = nil;
    _wmPlayer = nil;
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
//    
//}
-(void)clickcommentImgView
{
    
    
    if (_commentsMutableAry.count == 0) {
        [_mainTableView setContentOffset:CGPointMake(0,  44) animated:YES];
    }else if (_commentsMutableAry.count == 1)
    {
        if (_mainTableView.contentOffset.y<44) {
            [_mainTableView setContentOffset:CGPointMake(0,  44) animated:NO];
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [_mainTableView scrollToRowAtIndexPath:scrollIndexPath
                                  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }else
        {
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [_mainTableView scrollToRowAtIndexPath:scrollIndexPath
                                  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
    }else if (_commentsMutableAry.count == 2)
    {
        if (_mainTableView.contentOffset.y<44) {
            [_mainTableView setContentOffset:CGPointMake(0,  44) animated:NO];
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [_mainTableView scrollToRowAtIndexPath:scrollIndexPath
                                  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }else
        {
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [_mainTableView scrollToRowAtIndexPath:scrollIndexPath
                                  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }else if (_commentsMutableAry.count == 3)
    {
        if (_mainTableView.contentOffset.y<44) {
            [_mainTableView setContentOffset:CGPointMake(0,  44) animated:NO];
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
            [_mainTableView scrollToRowAtIndexPath:scrollIndexPath
                                  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }else
        {
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
            [_mainTableView scrollToRowAtIndexPath:scrollIndexPath
                                  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }else if (_commentsMutableAry.count == 4)
    {
        if (_mainTableView.contentOffset.y<44) {
            [_mainTableView setContentOffset:CGPointMake(0,  44) animated:NO];
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
            [_mainTableView scrollToRowAtIndexPath:scrollIndexPath
                                  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }else
        {
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
            [_mainTableView scrollToRowAtIndexPath:scrollIndexPath
                                  atScrollPosition:UITableViewScrollPositionBottom animated:YES];

        }
    }else
    {
        [_mainTableView setContentOffset:CGPointMake(0, ScreenHeight - 64) animated:YES];
    }
//    [_mainTableView setContentOffset:CGPointMake(0, ScreenHeight - 64) animated:YES];
}
-(void)showkeyboard
{
    
    [_commentsTextField becomeFirstResponder];
}
-(void)Actiondo:(id)sender{
    [_commentsTextField resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
//        _sharebgBar.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 200);
    }];
}
-(void)clickShare3rdBtn
{
    [UIView animateWithDuration:0.2 animations:^{
//        _sharebgBar.frame = CGRectMake(0, ScreenHeight - 200, ScreenWidth, 200);
    }];


}
-(void)clickZhanBtn
{
//    if (!_isZhan) {
//        [VideoDataModel clickZhanWithAuthorUid:[_DataModel.AuthorUid intValue] AnddynamicID:[_DataModel.dyid intValue] :^(int errorCode) {
//            NSLog(@"点赞结果code：%d",errorCode);
//        }];
//        _zhanImgView.image = [UIImage imageNamed:@"xgzhanSelected"];
//        int zhanCount = [_zhanLabel.text intValue];
//        _zhanLabel.text = [NSString stringWithFormat:@"%d",++zhanCount];
//        _isZhan = YES;
//    }
    
    
    
}
-(void)ClicksendCommentsBtn
{
    
    NSLog(@"发送%@",_commentsTextField.text);
    if ([self isEmpty:_commentsTextField.text]) {
        return;
    }
    NSString* newContentStr;
    if (_placeholderStr.length>0) {
        newContentStr = [_placeholderStr stringByAppendingString:_commentsTextField.text];
    }else
    {
        newContentStr = _commentsTextField.text;
    }
    
    CommentDataModel* data = [CommentDataModel new];
    data.selfNickName = @"阳眼的熊🐻";
//    data.selfUID = [NSString stringWithFormat:@"%d",[AppDelegate appDelegate].appDelegatePlatformUserStructure.platformUserId];
    data.createdTime = @"刚刚";
    data.content = newContentStr;
//    data.faceurl = [[AppDelegate appDelegate].appViewService getHeadImagePathForIconIdex:0 forUserId:[AppDelegate appDelegate].appDelegatePlatformUserStructure.platformUserId forSizeType:2];
    data.faceurl = @"http://p3.pstatp.com/live/100x100/21690003e9cf762985e3.jpg"/*[[NSBundle mainBundle] pathForResource:@"usericon01" ofType:@"png"]*/;
    [_commentsMutableAry insertObject:data atIndex:0];
//    [_mainTableView reloadData];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [indexPaths addObject: indexPath];
    [_mainTableView beginUpdates];
    [_mainTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [_mainTableView endUpdates];
    
    
//    PriaseSendStructure* info = [[PriaseSendStructure alloc] init];
//    info.content = newContentStr;
//    info.iconIndex = 0;
//    info.uid = [AppDelegate appDelegate].appDelegatePlatformUserStructure.platformUserId;
//    [_barView createTowBarrageForPriaseSendStructure:info];
//
//
//    
//    [VideoDataModel sendCommentWidtDyamicID:_DataModel.dyid AndReferUID:nil AndFromNickName:[[AppDelegate appDelegate].cmCommonMethod urlEncodedString:[AppDelegate appDelegate].appDelegatePlatformUserStructure.platformUserNicknameString] AndContent:[[AppDelegate appDelegate].cmCommonMethod urlEncodedString:newContentStr] ForHandelBlock:^(int errorCode) {
//    }];
    
    [_commentsTextField setText:@""];
    [_commentsTextField resignFirstResponder];
    _sendCommentsBtn.enabled = NO;
    _sendCommentsBtn.backgroundColor = [UIColor grayColor];
    
    int commentCount = [_commentLabel.text intValue];
    _commentLabel.text = [NSString stringWithFormat:@"%d",++commentCount];
}
- (BOOL) isEmpty:(NSString *) str {
    if (!str) {
         return true;
    }
    else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}

-(void)hiddenShare:(UIButton*)btn{
    NSLog(@"%s", __func__);
    [UIView animateWithDuration:0.2 animations:^{
//        _sharebgBar.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 200);
    }];
}

#pragma mark 小视频分享
- (void)functionBtnClick:(UIButton *)btn {
    //
//    [UIView animateWithDuration:0.2 animations:^{
////        _sharebgBar.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 200);
//    }];
//    int shareCont = [_shareLabel.text intValue];
//    _shareLabel.text = [NSString stringWithFormat:@"%d",++shareCont];
//    //
//    [VideoDataModel clickShareWithAuthorUid:[_DataModel.AuthorUid intValue] AnddynamicID:[_DataModel.dyid intValue] :^(int errorCode) {
//        
//    }];
//    //
//    [[AppDelegate appDelegate] AppDelegateToShareSmallWithFollowuid:[AppDelegate appDelegate].appDelegatePlatformUserStructure.platformUserId forDYID:[_DataModel.dyid longLongValue] forNickName:_DataModel.nickname forShareImage:_iconImgeView.image forType:(int)btn.tag forEventType:1];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)refreshCommentsData
{
    
    [_mainTableView.header endRefreshing];
//    _comtentPageIndex = 1;
//    [CommentDataModel getCommentDataWithBlockWithDynamicID:_DataModel.dyid forFlag:0 AndPage:[NSString stringWithFormat:@"%d",_comtentPageIndex] ForHandelBlock:^(NSArray *dateAry, int code) {
//        if (code == 0) {
//            _commentsMutableAry = [NSMutableArray arrayWithArray:dateAry];
//            [_mainTableView reloadData];
//            [_mainTableView.header endRefreshing];
//            //
//            for (CommentDataModel* data in dateAry) {
//                PriaseSendStructure* info = [[PriaseSendStructure alloc] init];
//                info.content = data.content;
//                info.iconIndex = [data.iconIndex intValue];
//                info.uid = [data.selfUID intValue];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [_barView createTowBarrageForPriaseSendStructure:info];
//                });
//            }
//        }
//        else
//        {
//            [_mainTableView.header endRefreshing];
//        }
//    }];
    
}
-(void)addCommentsData
{
    [_mainTableView.footer endRefreshing];
//    _comtentPageIndex = _comtentPageIndex+1;
//    [CommentDataModel getCommentDataWithBlockWithDynamicID:_DataModel.dyid forFlag:0 AndPage:[NSString stringWithFormat:@"%d",_comtentPageIndex] ForHandelBlock:^(NSArray *dateAry, int code) {
//        if (code == 0 && dateAry && dateAry.count > 0) {
//            [_commentsMutableAry addObjectsFromArray:dateAry];
//            [_mainTableView.footer endRefreshing];
//            [_mainTableView reloadData];
//            
//            for (CommentDataModel* data in dateAry) {
//                PriaseSendStructure* info = [[PriaseSendStructure alloc] init];
//                info.content = data.content;
//                info.iconIndex = [data.iconIndex intValue];
//                info.uid = [data.selfUID intValue];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [_barView createTowBarrageForPriaseSendStructure:info];
//                });
//            }
//        }else
//        {
//             [_mainTableView.footer endRefreshing];
//        }
//        
//    }];
}
#pragma mark - Notification Method
-(void)textFieldEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > MAX_STARWORDS_LENGTH)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:MAX_STARWORDS_LENGTH];
            if (rangeIndex.length == 1)
            {
                textField.text = [toBeString substringToIndex:MAX_STARWORDS_LENGTH];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MAX_STARWORDS_LENGTH)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}
-(void)notCloseCor
{
    [[UIApplication sharedApplication] setStatusBarHidden:false];
    [self releaseWMPlayer];
//    [_barView timerInval];
//    if (_whenBackIsNeedhiddenBottomBar) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kTabBarHiddenNONotification object:self];
//    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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

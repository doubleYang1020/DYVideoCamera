//
//  DYOnlineMusicLibraryViewController.m
//  DYVideoModule
//
//  Created by huyangyang on 2017/11/23.
//

#import "DYOnlineMusicLibraryViewController.h"
#import <Masonry/Masonry.h>
#import "DYVMConstants+Private.h"
#import "Lottie.h"
//#import <KSYMediaPlayer/KSYMediaPlayer.h>
#import <KSYHTTPCache/KSYHTTPProxyService.h>
#import <KSYHTTPCache/HTTPCacheDefines.h>
#import <KSYHTTPCache/KSYFileDownloader.h>

@interface DYOnlineItemCollectionViewCell ()
@property (nonatomic, strong) UIImageView* iconImageView;
@property (nonatomic, strong) UILabel* TitleLable;
@end

@implementation DYOnlineItemCollectionViewCell

- (void) awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.contentView).offset(12);
            make.width.height.equalTo(@32);
        }];
        
        _TitleLable = [[UILabel alloc] init];
        _TitleLable.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10.5];
        _TitleLable.textColor = [UIColor colorWithRed:97.0/255.0 green:97.0/255.0 blue:97.0/255.0 alpha:1.0];
        _TitleLable.textAlignment = NSTextAlignmentCenter;
        [_iconImageView addSubview:_TitleLable];
        [_TitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).offset(-12);
        }];
    }
    return self;
}
@end

typedef void(^clickPlayOrSuspendedBtnBlock)(void);
@interface DYOnlineMusicLibraryCell ()
@property (nonatomic , copy) clickPlayOrSuspendedBtnBlock playOrSuspendedBlock;

@property (nonatomic ,strong) UILabel* nameLabel;
@property (nonatomic ,strong) UILabel* infoLabel;
@property (nonatomic ,strong) UIButton* playOrSuspendedBtn;
@property (nonatomic ,strong) LOTAnimationView* playlottieView;
@property (nonatomic ,strong) LOTAnimationView* LodinglottieView;
@property (nonatomic ,strong) UIView* gradientView;
@property (nonatomic ,strong) CAGradientLayer* gradientLayer;
@property (nonatomic ,strong) CALayer* lineLayer;

@end

@implementation DYOnlineMusicLibraryCell
- (void) awakeFromNib {
    [super awakeFromNib];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpUI];
    }
    return self;
}
-(void)setUpUI{
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.gradientView = [[UIView alloc] init];
    _gradientView.frame = CGRectMake(0, 0, [DYVMConstants screenWidth], 60);
    _gradientView.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1];
    [_gradientView setUserInteractionEnabled:false];
    [_gradientView setHidden:true];
    [self.contentView addSubview:_gradientView];
    
    _gradientLayer = [[CAGradientLayer alloc] init];
    _gradientLayer.frame = CGRectMake(0, 0, 0, 60);
    [_gradientView.layer addSublayer:_gradientLayer];
    _gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:62.0/255.0 green:232.0/255.0 blue:144.0/255.0 alpha:1.0].CGColor,
                             (__bridge id) [UIColor colorWithRed:25.0/255.0 green:238.0/255.0 blue:210.0/255.0 alpha:1.0].CGColor];
    _gradientLayer.startPoint = CGPointMake(0, 0);
    _gradientLayer.endPoint = CGPointMake(1, 0);
    
    _lineLayer = [[CALayer alloc] init];
    _lineLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3].CGColor;
    _lineLayer.frame = CGRectMake(_gradientLayer.frame.size.width - 5, 0, 5, 60);
    [_gradientLayer addSublayer:_lineLayer];
    
//    _LodinglottieView = [LOTAnimationView animationNamed:@"music_loading"];
    NSBundle *mainBundle = [NSBundle bundleForClass:self.class];
    NSBundle *bundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"DYVideoCameraMedia" ofType:@"bundle"]];
    _LodinglottieView = [LOTAnimationView animationNamed:@"music_loading" inBundle:bundle];
    [self.contentView addSubview:_LodinglottieView];
    [_LodinglottieView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(self.contentView);
    }];
    _LodinglottieView.loopAnimation = true;
    [_LodinglottieView play];
    [_LodinglottieView setUserInteractionEnabled:false];
    [_LodinglottieView setHidden:true];
    
//    icSmallplay
    _playOrSuspendedBtn = [[UIButton alloc] init];
    [self.contentView addSubview:_playOrSuspendedBtn];
    [_playOrSuspendedBtn setImage:[DYVMConstants imageNamed:@"icSmallplay"] forState:UIControlStateNormal];
    [_playOrSuspendedBtn addTarget:self action:@selector(playOnButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_playOrSuspendedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView);
        make.width.height.equalTo(@40);
    }];
    
    
//    _playlottieView = [LOTAnimationView animationNamed:@"playingblack"];
    _playlottieView = [LOTAnimationView animationNamed:@"playingblack" inBundle:bundle];
    [self.contentView addSubview:_playlottieView];
    [_playlottieView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_playOrSuspendedBtn);
        make.width.height.equalTo(@31);
    }];
    _playlottieView.loopAnimation = true;
    [_playlottieView play];
    [_playlottieView setUserInteractionEnabled:false];
    [_playlottieView setHidden:true];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:13];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_playlottieView.mas_right);
        make.bottom.equalTo(self.contentView.mas_centerY);
    }];
    
    _infoLabel = [[UILabel alloc] init];
    _infoLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:11];
    _infoLabel.textColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    _infoLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_infoLabel];
    [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_playlottieView.mas_right);
        make.top.equalTo(self.contentView.mas_centerY);
    }];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}
-(void)playOnButtonAction{
    self.playOrSuspendedBlock();
}
-(void)updateMusicProgress:(float)progress{
    _gradientLayer.frame = CGRectMake(0, 0, [DYVMConstants screenWidth] * progress, 60);
    _lineLayer.frame = CGRectMake( _gradientLayer.frame.size.width - 5, 0, 5, 60);
    
}


-(void)setMusicModel:(id<DYMusicEntity>)musicModel{
    _musicModel = musicModel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end



@interface DYOnlineMusicLibraryViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong) NSMutableArray* musicCategorys;
@property (nonatomic ,strong) UITableView* mainTableView;
@property (nonatomic ,strong) UICollectionView* mainCollectionView;
@property (nonatomic ,strong) NSMutableDictionary* allDataDic;
@property (nonatomic ,strong) NSIndexPath* collectionSelectIndexPath;
@property (nonatomic ,strong) NSIndexPath* tableSelectIndexPath;
@property (nonatomic ,strong) UISlider* musicSlider;
@property (nonatomic ,strong) UIView* sliderHighDYightView;
@property (nonatomic ,strong) UIButton* compleBtn;

@property (nonatomic ,assign) float videoVolume;
@property (nonatomic ,assign) float musicVolume;

@property (nonatomic ,strong) NSObject* musicPlayer;
@property (nonatomic, strong) KSYFileDownloader * _Nullable downloader;
@property (nonatomic ,assign) NSUInteger playingMusicID;
@property (nonatomic ,assign) BOOL isShowLoding;
@property (nonatomic ,assign) BOOL isMusicPlaying;
@property (nonatomic ,strong) NSTimer *timer;

@property (nonatomic ,strong) id<DYMusicEntity> currentMusicItem;
@end

@implementation DYOnlineMusicLibraryViewController
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* cachePath = [docsdir stringByAppendingPathComponent:@"DYMusicCache"];
    [[KSYHTTPProxyService sharedInstance] setCacheRoot:cachePath];
    [[KSYHTTPProxyService sharedInstance] startServer];
    
    UIView* topHeaderView = [[UIView alloc] init];
    topHeaderView.backgroundColor = [DYVMConstants colorMainTheme];
    [self.view addSubview:topHeaderView];
    [topHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo([DYVMConstants iPhoneX] ? @88 : @64);
    }];
    
    UIButton* cancleBtn = [[UIButton alloc] init];
    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancleBtn setTitle:[self.videoModelDataSource getLocalizedStringForKey:@"Cancel"] forState:UIControlStateNormal];
    [cancleBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:15]];
    [topHeaderView addSubview:cancleBtn];
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.equalTo(topHeaderView);
        make.height.equalTo(@44);
        make.width.equalTo(@54);
    }];
    [cancleBtn addTarget:self action:@selector(clickCancleBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* TitleLable = [[UILabel alloc] init];
    TitleLable.text = [self.videoModelDataSource getLocalizedStringForKey:@"Music"];
    [TitleLable setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:15]];
    TitleLable.textColor = [UIColor whiteColor];
    [topHeaderView addSubview:TitleLable];
    [TitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cancleBtn);
        make.centerX.equalTo(topHeaderView);
    }];
    
    _collectionSelectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    _tableSelectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.view.backgroundColor = [UIColor whiteColor];
    _musicCategorys = [NSMutableArray arrayWithArray:[_videoModelDataSource musicCategorys]];
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [DYVMConstants screenWidth], self.view.frame.size.height - 50) style:UITableViewStylePlain];
    _mainTableView.backgroundColor = [UIColor whiteColor];
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [DYVMConstants screenWidth], 75)];
    headerView.backgroundColor = [UIColor whiteColor];
    _mainTableView.tableHeaderView = headerView;
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    
    
    [self.view addSubview:_mainTableView];
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(62, 75);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [DYVMConstants screenWidth], 75) collectionViewLayout:layout];
    _mainCollectionView.backgroundColor = [UIColor clearColor];
    _mainCollectionView.delegate = self;
    _mainCollectionView.dataSource = self;
    [_mainCollectionView registerClass:[DYOnlineItemCollectionViewCell class] forCellWithReuseIdentifier:@"onlineItemCollectionViewCell"];
    _mainCollectionView.showsHorizontalScrollIndicator = false ;
    _mainCollectionView.showsVerticalScrollIndicator = false ;
    _mainCollectionView.alwaysBounceHorizontal = true ;
    _mainCollectionView.bounces = true ;
    [headerView addSubview:_mainCollectionView];
    
    _allDataDic = [NSMutableDictionary dictionaryWithCapacity:_musicCategorys.count];
//    [_videoModelDataSource musicFetchWithCategory:_musicCategorys.lastObject byPage:1 callback:^(NSArray<id<DYMusicEntity>> * arry) {
//
//    }];
    [self startNetWork];
    
    UIView* bottomBarView = [[UIView alloc] init];
    bottomBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomBarView];
    [bottomBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottomMargin);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@50);
    }];
    
    UIImageView* shadowLineView = [[UIImageView alloc] initWithImage:[DYVMConstants imageNamed:@"icShadow"]];
    [self.view addSubview:shadowLineView];
    [shadowLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(bottomBarView.mas_top);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@9);
    }];
    
    _musicSlider = [[UISlider alloc] init];
    _musicSlider.minimumValue = 0.0;
    _musicSlider.maximumValue = 1.0;
    _musicSlider.value = 0.5;
    _musicSlider.minimumValueImage = [DYVMConstants imageNamed:@"icMusic19"];
    _musicSlider.maximumValueImage = [DYVMConstants imageNamed:@"icVideo"];
    _musicSlider.minimumTrackTintColor = [UIColor colorWithRed:197.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:0.5];
    _musicSlider.maximumTrackTintColor = [UIColor colorWithRed:197.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:0.5];
    _musicSlider.thumbTintColor = [UIColor whiteColor];
    [_musicSlider setThumbImage:[DYVMConstants imageNamed:@"circle"] forState:UIControlStateNormal];
    [_musicSlider setThumbImage:[DYVMConstants imageNamed:@"circle"] forState:UIControlStateHighlighted];
    [bottomBarView addSubview:_musicSlider];
    [_musicSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_musicSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomBarView);
        make.height.equalTo(@40);
        make.left.equalTo(bottomBarView).offset(24);
        make.right.equalTo(bottomBarView).offset(-144);
    }];
    
    _sliderHighDYightView = [[UIView alloc] init];
    _sliderHighDYightView.backgroundColor = [DYVMConstants colorMainTheme];
    [_sliderHighDYightView setUserInteractionEnabled:false];
    [_sliderHighDYightView setFrame:CGRectMake(0, 20, 0, 2)];
    _sliderHighDYightView.layer.cornerRadius = 1.0;
    [_musicSlider insertSubview:_sliderHighDYightView atIndex:0];
    

    _compleBtn = [[UIButton alloc] init];
    [_compleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_compleBtn setTitle:[self.videoModelDataSource getLocalizedStringForKey:@"Add music"] forState:UIControlStateNormal];
    [_compleBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:12]];
    [_compleBtn setBackgroundColor:[UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0]];
    _compleBtn.layer.cornerRadius = 7.5;
    [_compleBtn setEnabled:false];
    [bottomBarView addSubview:_compleBtn];
    [_compleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomBarView);
        make.height.equalTo(@30);
        make.width.equalTo(@108);
        make.right.equalTo(bottomBarView).offset(-12);
    }];
    [_compleBtn addTarget:self action:@selector(clickCompleBtn) forControlEvents:UIControlEventTouchUpInside];

    
    
    
    [_mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topHeaderView.mas_bottom);
        make.right.left.equalTo(self.view);
        make.bottom.equalTo(bottomBarView.mas_top);
    }];
    
    self.musicVolume = 1.0;
    self.videoVolume = 1.0;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateMusicTime) userInfo:nil repeats:YES];
//    Log(@"alldic -- %@",_allDataDic);
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaCacheDidChanged:)
                                                 name:CacheStatusNotification
                                               object:nil];
     */
    
    
    // Do any additional setup after loading the view.
}
-(void)startNetWork{
    for (id<DYMusicCategory> item in _musicCategorys) {
        [_videoModelDataSource musicFetchWithCategory:item byPage:1 callback:^(NSArray<id<DYMusicEntity>> * arry) {
            [_allDataDic setObject:arry forKey:item.title];
            
            id<DYMusicCategory> firstItem = _musicCategorys.firstObject;
            if ([item.title isEqualToString:firstItem.title] && _collectionSelectIndexPath.row == 0) {
                [self.mainTableView reloadData];
            }
        }];
    }
}


-(void)clickCancleBtn{
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void)sliderValueChanged:(UISlider *)sender{
    Log(@"sender--value = %lf",sender.value);
    if (sender.value > 0.5) {
        float volume = (1.0 - sender.value)*2;
        _videoVolume = 1.0 ;
        _musicVolume = volume ;
    }else{
        float volume = sender.value*2;
        _videoVolume = volume ;
        _musicVolume = 1.0 ;
    }
    [self updateSliderHighDYightViewFrame:sender.value];
}

-(void)updateSliderHighDYightViewFrame:(float)sliderValue {
    float slidertrackWidth = self.musicSlider.frame.size.width - 37 - 37 ;
    if (sliderValue > 0.5) {
        float slidertrackValue = (sliderValue - 0.5) * 2.0;
        _sliderHighDYightView.frame = CGRectMake(slidertrackWidth/2 + 37, 20, slidertrackWidth/2*slidertrackValue, 2);
    }else{
        float volume = sliderValue * 2.0;
        _sliderHighDYightView.frame = CGRectMake(37 + slidertrackWidth/2.0 * volume, 20, slidertrackWidth/2 * (1.0 - volume), 2);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark collectionView delegate&DataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _musicCategorys.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DYOnlineItemCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"onlineItemCollectionViewCell" forIndexPath:indexPath];
    id<DYMusicCategory> item = _musicCategorys[indexPath.row];
    cell.TitleLable.text = item.title;
    UIImage* tempImg ;
    if (_collectionSelectIndexPath.row == indexPath.row) {
        tempImg = item.imageSelected;
        cell.TitleLable.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:10.5];
    }else{
        tempImg = item.imageNormal;
        cell.TitleLable.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10.5];
    }
    cell.iconImageView.image = tempImg;
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.collectionSelectIndexPath = indexPath;
    [self.mainCollectionView reloadData];
    [self.mainTableView reloadData];
    [self moveList:indexPath.row];
//    [self.mainTableView setContentOffset:CGPointMake(0, 0) animated:false];
}
- (void)moveList:(NSInteger)classifyType{
    
    if (classifyType <= 1) {
        [_mainCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        CGFloat offsetX = 0;
        for (int i = 0; i <= classifyType - 2; i++) {
            if (i == classifyType - 2) {
                offsetX += 29;
            } else {
                offsetX += 58 + 29;
            }
        }
        if (offsetX < _mainCollectionView.contentOffset.x) {
            [_mainCollectionView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
        }
    }
    if (classifyType + 2 >= _musicCategorys.count) {
        [_mainCollectionView setContentOffset:CGPointMake(_mainCollectionView.contentSize.width - _mainCollectionView.frame.size.width, 0) animated:YES];
    } else {
        CGFloat offsetX = 0;
        for (NSInteger i = _musicCategorys.count - 1; i >= classifyType + 2; i--) {
            if (i == classifyType + 2) {
                offsetX += 29;
            } else {
                offsetX += 58+29;
            }
        }
        offsetX = (_mainCollectionView.contentSize.width - _mainCollectionView.frame.size.width) - offsetX;
        if (offsetX > _mainCollectionView.contentOffset.x) {
            [_mainCollectionView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
        }
    }
}

#pragma mark tableView delegate&DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id<DYMusicCategory> item = _musicCategorys[_collectionSelectIndexPath.row];
    NSArray* ary = _allDataDic[item.title];
    return ary.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id<DYMusicCategory> categoryItem = _musicCategorys[_collectionSelectIndexPath.row];
    id<DYMusicEntity> musicItem = _allDataDic[categoryItem.title][indexPath.row];
    DYOnlineMusicLibraryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"onlineMusicLibraryCell"];
    if (cell == nil) {
        cell = [[DYOnlineMusicLibraryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"onlineMusicLibraryCell"];
    }
    __weak typeof(self) weakSelf = self;
    cell.playOrSuspendedBlock = ^{
        [weakSelf.compleBtn setEnabled:true];
        [weakSelf.compleBtn setBackgroundColor:[DYVMConstants colorMainTheme]];
        weakSelf.tableSelectIndexPath = indexPath;
        weakSelf.currentMusicItem = musicItem;
        if (weakSelf.playingMusicID == musicItem.musicId) {
            //pause
            
            if (weakSelf.isMusicPlaying) {
                [weakSelf.videoModelDataSource musicPlayer_pause:weakSelf.musicPlayer];
                 weakSelf.isMusicPlaying = false;
                
            }else{
                [weakSelf.videoModelDataSource musicPlayer_play:weakSelf.musicPlayer];
                 weakSelf.isMusicPlaying = true;
            }
            
        }else{
            //play
            weakSelf.playingMusicID = musicItem.musicId;
            weakSelf.isMusicPlaying = true;
            [weakSelf ksyPlayerPlayWithMusicItem:musicItem];
        }
        [weakSelf.mainTableView reloadData];
        
        
    };
    cell.nameLabel.text = musicItem.name;
    NSString* infoStr;
    int musicDuration = musicItem.duration;
    int minute = musicDuration/60;
    int second = musicDuration%60;
    NSString* musicFormatTimeStr = [NSString stringWithFormat:@"%02d:%02d",minute,second];
    
    if (_collectionSelectIndexPath.row == 0 || _collectionSelectIndexPath.row == 1) {
        infoStr = [NSString stringWithFormat:@"%@ | %@ | %@",musicItem.category,musicFormatTimeStr,musicItem.artist];
    }else{
        infoStr = [NSString stringWithFormat:@"%@ | %@",musicFormatTimeStr,musicItem.artist];
    }
    
    if (self.playingMusicID == musicItem.musicId) {
        _tableSelectIndexPath = indexPath;
        [cell.gradientView setHidden:false];
        BOOL isplaying = self.isMusicPlaying;
        [cell.playOrSuspendedBtn setImage:isplaying ? [UIImage new] :[DYVMConstants imageNamed:@"icSmallplay"]  forState:UIControlStateNormal];
        
        [cell.playlottieView setHidden:!isplaying];
        [cell.playlottieView play];
        [cell.LodinglottieView setHidden:!_isShowLoding];
    }else{
        
        [cell.playOrSuspendedBtn setImage:[DYVMConstants imageNamed:@"icSmallplay"] forState:UIControlStateNormal];
        [cell.gradientView setHidden:true];
        [cell.LodinglottieView setHidden:true];
        [cell.gradientView setHidden:true];
        [cell.playlottieView setHidden:true];
    }
    
    cell.infoLabel.text = infoStr;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.compleBtn setEnabled:true];
    [self.compleBtn setBackgroundColor:[DYVMConstants colorMainTheme]];
    id<DYMusicCategory> categoryItem = _musicCategorys[_collectionSelectIndexPath.row];
    id<DYMusicEntity> musicItem = _allDataDic[categoryItem.title][indexPath.row];
    self.tableSelectIndexPath = indexPath;
    self.currentMusicItem = musicItem;
    if (self.playingMusicID == musicItem.musicId) {
        //pause
        
        if (self.isMusicPlaying) {
//            [self.musicPlayer pause];
            [self.videoModelDataSource musicPlayer_pause:self.musicPlayer];
            self.isMusicPlaying = false;
            
        }else{
            [self.videoModelDataSource musicPlayer_play:self.musicPlayer];
            self.isMusicPlaying = true;
        }
        
    }else{
        //play
        self.playingMusicID = musicItem.musicId;
        self.isMusicPlaying = true;
        [self ksyPlayerPlayWithMusicItem:musicItem];
    }
    [self.mainTableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    id<DYMusicCategory> categoryItem = _musicCategorys[_collectionSelectIndexPath.row];
    NSArray* currenDYistAry = self.allDataDic[categoryItem.title];
    if (indexPath.section == 0 && indexPath.row == currenDYistAry.count - 3) {
        int currentPageIndex = currenDYistAry.count / 10;
        if (currentPageIndex == 0) {
            return;
        }
        [_videoModelDataSource musicFetchWithCategory:categoryItem byPage:currentPageIndex+1 callback:^(NSArray<id<DYMusicEntity>> * arry) {
            NSMutableArray* lastAry = [NSMutableArray arrayWithArray:currenDYistAry];
            if (arry.count == 0 || [self arry1IsContainsArry2:lastAry andSubAry:arry]) {
                return ;
            }
            [lastAry addObjectsFromArray:arry];
            [_allDataDic setObject:lastAry forKey:categoryItem.title];
            [_mainTableView reloadData];
        }];
    }
}
-(BOOL)arry1IsContainsArry2:(NSArray* )allAry andSubAry:(NSArray* )subAry{
    for (id<DYMusicEntity> superItem in allAry) {
        for (id<DYMusicEntity> subItem in subAry) {
            if (superItem.musicId == subItem.musicId) {
                return  true;
            }
        }
    }
    return false;
}

-(void)ksyPlayerPlayWithMusicItem:(id<DYMusicEntity>)musicItem{
    
    NSString* urlStr = [[KSYHTTPProxyService sharedInstance] getProxyUrl:musicItem.url];
    NSURL* musicUrl = [NSURL URLWithString:urlStr];
    if (_musicPlayer == nil) {
//        _musicPlayer = [[KSYMoviePlayerController alloc] initWithContentURL:musicUrl];
////        [_musicPlayer setShouldEnableVideoPostProcessing:true];
//        [_musicPlayer setShouldLoop:true];
////        [_musicPlayer setVolume:2.0 rigthVolume:2.0];
//        [_musicPlayer setShouldAutoplay:true];
//        [_musicPlayer prepareToPlay];

        _musicPlayer = [self.videoModelDataSource initKSYMediaPlayerWithUrl:musicUrl];
    }else{
        [self.videoModelDataSource musicPlayer_pause:_musicPlayer];
        [self.videoModelDataSource KSYMediaPlayersetUrl:musicUrl andPlayer:_musicPlayer];
//        [_musicPlayer reset:false];
//        [_musicPlayer setUrl:musicUrl];
//        [_musicPlayer prepareToPlay];
    }
    [self.videoModelDataSource musicPlayer_pause:_musicPlayer];
    _isShowLoding = true;
    Log(@"_musicUrl: %@", urlStr);
}

-(void)updateMusicTime{
    if (_musicPlayer == nil) {
        return;
    }
//    float progress = (_musicPlayer.currentPlaybackTime)/(_musicPlayer.duration);
    float progress =  [self.videoModelDataSource getCurrenPlayerProgress:self.musicPlayer];
    
    if (isnan(progress)) {
        progress = 0 ;
    }
    DYOnlineMusicLibraryCell* cell = [self.mainTableView cellForRowAtIndexPath:self.tableSelectIndexPath];
    [cell updateMusicProgress:progress];
    if (progress > 0 && self.isShowLoding) {
        self.isShowLoding = false;
        [self.mainTableView reloadData];
    }
}
/*
- (void)mediaCacheDidChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    float progress = [userInfo[CacheProgressKey] floatValue];
    id<DYMusicCategory> categoryItem = _musicCategorys[_collectionSelectIndexPath.row];
    id<DYMusicEntity> musicItem = _allDataDic[categoryItem.Title][_tableSelectIndexPath.row];

    if (progress == 1) {
        NSString* cachePath = [[KSYHTTPProxyService sharedInstance] getCachedFilePathForUrl:[NSURL URLWithString:musicItem.url]];
        NSString* newFilePath = [NSString stringWithFormat:@"%@.mp3",cachePath];
        [[NSFileManager defaultManager] removeItemAtPath:newFilePath error:nil];
        [[NSFileManager defaultManager] linkItemAtPath:cachePath toPath:newFilePath error:nil];
        
        
    }
    Log(@"%@",[NSString stringWithFormat:@"文件缓存百分比：%.2f%%", progress*100]);
//    __block float progress = [userInfo[CacheProgressKey] floatValue];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ((NSInteger)(progress * 10000) > 10000) {
//            progress = 1.0;
//        }
//        Log(@"%@",[NSString stringWithFormat:@"文件缓存百分比：%.2f%%", progress*100]);
//    });
}*/
-(void)clickCompleBtn{
//    id<DYMusicCategory> categoryItem = _musicCategorys[_collectionSelectIndexPath.row];
//    id<DYMusicEntity> musicItem = _allDataDic[categoryItem.Title][_tableSelectIndexPath.row];
    id<DYMusicEntity> musicItem = self.currentMusicItem;
    BOOL isCacheComplete = [[KSYHTTPProxyService sharedInstance] isCacheCompleteForUrl:[NSURL URLWithString:musicItem.url]];
    
    void (^completeCallback)(void) = ^{
        NSString* cachePath = [[KSYHTTPProxyService sharedInstance] getCachedFilePathForUrl:[NSURL URLWithString:[musicItem url]]];
        NSString* newFilePath = [NSString stringWithFormat:@"%@.mp3",cachePath];
        [[NSFileManager defaultManager] removeItemAtPath:newFilePath error:nil];
        [[NSFileManager defaultManager] linkItemAtPath:cachePath toPath:newFilePath error:nil];
        
        [self dismissViewControllerAnimated:true completion:^{
            if ([self.delegate respondsToSelector:@selector(choseMusicComplete:andVideoVolum:andMusicVolum:)]) {
//                id<DYMusicCategory> categoryItem = _musicCategorys[_collectionSelectIndexPath.row];
//                id<DYMusicEntity> musicItem = _allDataDic[categoryItem.Title][_tableSelectIndexPath.row];
                id<DYMusicEntity> musicItem = self.currentMusicItem;
                [self.delegate choseMusicComplete:musicItem andVideoVolum:_videoVolume andMusicVolum:_musicVolume];
            }
        }];
    };
    
    if (isCacheComplete) {
        completeCallback();
    }
    else{
        __weak typeof(self) weakSelf = self;
        DYProgressCallback progressCallback = [[self.videoModelDataSource class] showProgressViewWithText:@"downloading"];
        self.downloader = [[KSYFileDownloader alloc] initWithUrlString:musicItem.url progressBlock:^(float progress) {
            Log(@"KSYFileDownloader progress -- %lf",progress);
            progressCallback(progress);
            if (progress >= 1.0) {
                [[weakSelf.videoModelDataSource class] hideProgressView];
//                completeCallback();
                NSString* cachePath = [[KSYHTTPProxyService sharedInstance] getCachedFilePathForUrl:[NSURL URLWithString:[musicItem url]]];
                NSString* newFilePath = [NSString stringWithFormat:@"%@.mp3",cachePath];
                [[NSFileManager defaultManager] removeItemAtPath:newFilePath error:nil];
                [[NSFileManager defaultManager] linkItemAtPath:cachePath toPath:newFilePath error:nil];
                
                [weakSelf dismissViewControllerAnimated:true completion:^{
                    if ([weakSelf.delegate respondsToSelector:@selector(choseMusicComplete:andVideoVolum:andMusicVolum:)]) {
                        [weakSelf.delegate choseMusicComplete:musicItem andVideoVolum:weakSelf.videoVolume andMusicVolum:weakSelf.musicVolume];
                    }
                }];
            }
        }];
        [self.downloader startDownload];
    }
    

    
}

-(void)viewWillDisappear:(BOOL)animated{
//    [_musicPlayer pause];
    [_videoModelDataSource musicPlayer_pause:self.musicPlayer];
    [_videoModelDataSource releasePlayer:self.musicPlayer];
    [_timer invalidate];
    _timer = nil;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[KSYHTTPProxyService sharedInstance] stopServer];
    Log(@"%@ dealloc",NSStringFromClass(self.class));
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

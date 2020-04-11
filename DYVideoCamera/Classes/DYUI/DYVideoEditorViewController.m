//
//  DYVideoEditorViewController.m
//  DYVideoModule
//
//  Created by  video on 22/11/2017.
//

#import "DYVideoEditorViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Masonry/Masonry.h>
#import "DYVideoSDK.h"
#import <GPUImage/GPUImage.h>
#import <KSYHTTPCache/KSYHTTPProxyService.h>
#import "OTScreenshotHelper.h"
#import "DYVMConstants+Private.h"
#import "DYVideoFilterCollectionViewCell.h"
#import "DYFilterEntityViewModel.h"
#import "DYOnlineMusicLibraryViewController.h"
#import "DYVideoEditorController.h"

#import "DYVideoProcessEngine.h"
#import "DYVideoProcess.h"

#define MAX_DURATION_SECONDS CMTimeGetSeconds([[self.videoModelDataSource class] videoTimeRange].duration)


@interface DYVideoEditorViewController () <UICollectionViewDataSource, UICollectionViewDelegate, DYOnlineMusicLibraryViewControllerDelegate, DYVideoEditorControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate> {
    UIButton *_filterButton;
    UIButton *_musicButton;
    UIButton *_trimButton;
    
    UICollectionView *_filtersCollectionView;
    UIView * _videoContainer;
    UIView * _bottomSeperatorView;
    UIView * _bottomContainer;
    UILabel * _musicTitleLabel;
    UIImageView * _playIndicatorImageView;
    
    DYFilterEngine *_filterEngine;
    AVPlayer *_audioPlayer;
}

@property (strong, nonatomic) UIImage * thunmbnail;
@property (strong, nonatomic) NSArray<DYFilterEntityViewModel * > * _Nonnull dataSource;
@property (assign, nonatomic) NSUInteger selectedIndex;
@property (strong, nonatomic) NSURL * _Nullable musicUrl;
@property (assign, nonatomic) float videoVolume;

@property (strong, nonatomic) UIImage* screenShotImage;
@property (strong, nonatomic) UIImageView* screenShotImageView;
@property (assign, nonatomic) BOOL isExporting;
@end

static BOOL xx = NO;

@implementation DYVideoEditorViewController

- (instancetype)initWithVideoURL:(NSURL * _Nonnull)videoUrl {
    self = [super init];
    if (self) {
        _filterButton = [[UIButton alloc] init];
        _musicButton = [[UIButton alloc] init];
        _trimButton = [[UIButton alloc] init];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [layout setItemSize:CGSizeMake(50, 70)];
        [layout setMinimumLineSpacing:12];
        [layout setMinimumInteritemSpacing:12];
        [layout setHeaderReferenceSize:CGSizeMake(12, 70)];
        
        _filtersCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_filtersCollectionView setDataSource:self];
        [_filtersCollectionView setDelegate:self];
        
        _videoContainer = [[UIView alloc] init];
        _bottomSeperatorView = [[UIView alloc] init];
        _bottomContainer = [[UIView alloc] init];
        _musicTitleLabel = [[UILabel alloc] init];
        _playIndicatorImageView = [[UIImageView alloc] initWithImage:[DYVMConstants imageNamed:@"icPlay"]];
        
        _filterEngine = [[DYFilterEngine alloc] initWithVideoURL:videoUrl];
        _audioPlayer = [[AVPlayer alloc] init];
        _videoURL = videoUrl;
        
        [_filtersCollectionView registerClass:[DYVideoFilterCollectionViewCell class] forCellWithReuseIdentifier:@"filterCell"];
        _dataSource = @[];
        _videoVolume = 0;
        _selectedIndex = 0;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self setupUI];
    [self setupActions];
    [self prepareDataSource];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self.videoModelDataSource getLocalizedStringForKey:@"Next"] style:UIBarButtonItemStylePlain target:self action:@selector(finishAction)];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_screenShotImageView) {
        [_screenShotImageView setHidden:true];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self pause];
    [_screenShotImageView setHidden:false];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault];
    [_filterEngine startProcessing];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompletePlayingMovie) name:@"didCompletePlayingMovie" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if (_screenShotImage == nil) {
        UIImage *image= [OTScreenshotHelper screenshotWithStatusBar:true rect:CGRectMake(0, 0, [DYVMConstants screenWidth], [DYVMConstants iPhoneX] ? 88.5 : 64.5)];
        
        _screenShotImage = image;
        _screenShotImageView = [[UIImageView alloc] init];
        _screenShotImageView.image = _screenShotImage;
        [self.view insertSubview:_screenShotImageView atIndex:0];
        [_screenShotImageView setHidden:true];
        [_screenShotImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.height.equalTo([DYVMConstants iPhoneX] ? @88.5 : @64.5);
        }];
    }
    
}

- (void)onApplicationWillResignActive
{
    
    self.isExporting = true;
    xx = YES;
    [[self.videoModelDataSource class] hideProgressView];
    if ([_playIndicatorImageView isHidden]) { // playing
        [_filterEngine endProcessing];
        [_audioPlayer pause];
        
    }
    else {
        return;
    }
    
    [_playIndicatorImageView setHidden:![_playIndicatorImageView isHidden]];
    
    
}

- (void)onApplicationDidBecomeActive
{
    
    [self collectionView:_filtersCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0]];
    self.isExporting = false;
    xx = NO;
    [self play];
    [_playIndicatorImageView setHidden:![_playIndicatorImageView isHidden]];
    
}

-(void)didCompletePlayingMovie{
    [_filterEngine replay];
    [_audioPlayer.currentItem seekToTime:kCMTimeZero];
    [_audioPlayer play];
}



- (void)prepareDataSource {
    AVAsset * asset = [AVURLAsset URLAssetWithURL:self.videoURL options:nil];
    assert(asset != nil);
    self.thunmbnail = [self.class thumbnailFromAsset:asset];
    
    self.dataSource = [DYFilterEntityViewModel modelFromFilters:[self.videoModelDataSource availableFilters] forImage:self.thunmbnail];
    [_filtersCollectionView reloadData];
    [self collectionView:_filtersCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0]];
    
    
#if TARGET_IPHONE_SIMULATOR
    //    [_filterEngine changeEngineVolume:0.01];
#endif
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    Log(@"VideoEditorViewController");
}

#pragma mark - View layout

- (void)setupUI {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [_bottomContainer setBackgroundColor:[UIColor clearColor]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithImage:[DYVMConstants imageNamed:@"icBlackback"]
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(back:)];
    
    CAGradientLayer *topLayer = [CAGradientLayer layer];
    topLayer.frame = CGRectMake(0, 0, [DYVMConstants screenWidth], 12);
    topLayer.colors = @[(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.05] CGColor]];
    [_bottomSeperatorView.layer addSublayer:topLayer];
    [_bottomSeperatorView setUserInteractionEnabled:NO];
    
    
    [self.view addSubview:_videoContainer];
    
    [self.view addSubview:_bottomSeperatorView];
    
    [_filterEngine.filterView setBackgroundColorRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    [_playIndicatorImageView setContentMode:UIViewContentModeScaleAspectFit];
    [_playIndicatorImageView setHidden:YES];
    
    [_videoContainer addSubview:_filterEngine.filterView];
    [_videoContainer addSubview:_playIndicatorImageView];
    
    [self.view addSubview:_bottomContainer];
    [_bottomContainer addSubview:_filtersCollectionView];
    [_bottomContainer addSubview:_filterButton];
    [_bottomContainer addSubview:_musicButton];
    [_bottomContainer addSubview:_trimButton];
    [_bottomContainer addSubview:_musicTitleLabel];
    
    [_filterButton setImage:[DYVMConstants imageNamed:@"icFilter"] forState:UIControlStateNormal];
    [_filterButton setImage:[DYVMConstants imageNamed:@"icFilterSeleted"] forState:UIControlStateSelected];
    [_filterButton setSelected:TRUE];
    [_musicButton setImage:[DYVMConstants imageNamed:@"icMusic"] forState:UIControlStateNormal];
    [_trimButton setImage:[DYVMConstants imageNamed:@"icVideocut"] forState:UIControlStateNormal];
    [_filtersCollectionView setBackgroundColor:[UIColor whiteColor]];
    
    [_musicTitleLabel setFont:[UIFont systemFontOfSize:15]];
    [_musicTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [_musicTitleLabel setHidden:YES];
    
    [self applyConstraints];
}

- (void)applyConstraints {
    [_videoContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_topMargin);
        }else {
            make.top.equalTo(self.view.mas_topMargin).offset([DYVMConstants iPhoneX]?0:64);
        }
        
        make.top.equalTo(self.view.mas_topMargin).offset([DYVMConstants iPhoneX] ? 0 : 64);
        make.bottom.equalTo(self.view.mas_bottomMargin).with.offset(-130);
    }];
    
    [_playIndicatorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_filterEngine.filterView);
        make.centerY.equalTo(_filterEngine.filterView);
        make.width.height.equalTo(@48);
    }];
    
    //    AVAsset * asset = [AVURLAsset URLAssetWithURL:self.videoURL options:nil];
    //    AVAssetTrack* videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    //    float videoWidth = [videoTrack naturalSize].width;
    //    float videoHeight = [videoTrack naturalSize].height;
    //    float aspectRatio = videoWidth/videoHeight;
    [_filterEngine.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        //        if (aspectRatio == 1) {
        //            make.center.equalTo(_videoContainer);
        //            make.left.right.equalTo(_videoContainer);
        //            make.height.equalTo(make.width);
        //        }else if (aspectRatio < 1){
        //            make.top.equalTo(_videoContainer).with.offset(5);
        //            make.bottom.equalTo(_videoContainer).with.offset(-3);
        //            make.width.equalTo(_filterEngine.filterView.mas_height).multipliedBy(aspectRatio);
        //            make.centerX.equalTo(_videoContainer);
        //        }else{
        //            make.left.right.equalTo(_videoContainer);
        //            make.height.equalTo(_filterEngine.filterView.mas_width).multipliedBy(1.0/aspectRatio);
        //            make.centerY.equalTo(_videoContainer);
        //        }
        make.top.equalTo(_videoContainer).with.offset(5);
        make.bottom.equalTo(_videoContainer).with.offset(-3);
        make.left.right.equalTo(_videoContainer);
        
        
    }];
    
    [_bottomSeperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(_bottomContainer.mas_top);
        make.height.equalTo(@12);
    }];
    
    [_bottomContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottomMargin);
        make.height.equalTo(@130);
    }];
    
    [_filtersCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomContainer);
        make.top.equalTo(_bottomContainer);
        make.right.equalTo(_bottomContainer);
        make.height.equalTo(@82);
    }];
    
    [_filterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_bottomContainer.mas_right).with.multipliedBy(0.25);
        make.centerY.equalTo(_bottomContainer.mas_bottom).with.offset(-24);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    
    [_musicButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_bottomContainer.mas_right).with.multipliedBy(0.5);
        make.centerY.equalTo(_bottomContainer.mas_bottom).with.offset(-24);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    
    [_trimButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_bottomContainer.mas_right).with.multipliedBy(0.75);
        make.centerY.equalTo(_bottomContainer.mas_bottom).with.offset(-24);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    
    [_musicTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leadingMargin.equalTo(_bottomContainer);
        make.trailingMargin.equalTo(_bottomContainer);
        make.top.equalTo(_bottomContainer).with.offset(12);
        make.height.equalTo(@21);
    }];
}

- (void)setupActions {
    [_filterButton addTarget:self action:@selector(filterButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_musicButton addTarget:self action:@selector(musicButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_trimButton addTarget:self action:@selector(trimButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_videoContainer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVideoContainer:)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    //    [_playIndicatorImageView setHidden:!_playIndicatorImageView.hidden];
}


/*
 #pragma mark - Navigation
 
 */

#pragma mark - actions

- (void)filterButtonAction {
    [_filterButton setSelected:TRUE];
    [self changeBottomContainerToFilterStyle:NO];
}

- (void)musicButtonAction {
    [_filterButton setSelected:FALSE];
    [self changeBottomContainerToFilterStyle:YES];
    
    DYOnlineMusicLibraryViewController* cor = [[DYOnlineMusicLibraryViewController alloc] init];
    cor.videoModelDataSource = self.videoModelDataSource;
    cor.delegate = self;
    [self presentViewController:cor animated:true completion:nil];
}

- (void)trimButtonAction {
    [_filterButton setSelected:FALSE];
    [self changeBottomContainerToFilterStyle:YES];
    
    DYVideoEditorController* editorController = [[DYVideoEditorController alloc] init];
    editorController.videoURL = _videoURL;
    editorController.leftBtnTitle = [self.videoModelDataSource getLocalizedStringForKey:@"Cancel"];
    editorController.rightBtnTiltle = [self.videoModelDataSource getLocalizedStringForKey:@"Done"];
    editorController.videoMaximumDuration = CMTimeGetSeconds([[self.videoModelDataSource class] videoTimeRange].duration);
    editorController.videoMinimumDuration = CMTimeGetSeconds([[self.videoModelDataSource class] videoTimeRange].start);
    editorController.delegate = self;
    [self presentViewController:editorController animated:YES completion:nil];
    
    //    if ([UIVideoEditorController canEditVideoAtPath:_videoURL.path]) {
    //        UIVideoEditorController *editorController = [[UIVideoEditorController alloc] init];
    //        [editorController setVideoPath:_videoURL.path];
    //        [editorController setVideoQuality:UIImagePickerControllerQualityTypeIFrame960x540];
    //        [editorController setVideoMaximumDuration:MAX_DURATION_SECONDS];
    //        [editorController setDelegate:self];
    //        [self presentViewController:editorController animated:YES completion:nil];
    //    }
}

- (void)tapVideoContainer:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([_playIndicatorImageView isHidden]) { // playing
            [_filterEngine endProcessing];
            [_audioPlayer pause];
        }
        else {
            [self play];
        }
        
        [_playIndicatorImageView setHidden:![_playIndicatorImageView isHidden]];
    }
}

- (void)changeBottomContainerToFilterStyle:(BOOL)isFilterStyle {
    [_filtersCollectionView setHidden:isFilterStyle];
    [_musicTitleLabel setHidden:!isFilterStyle];
    
    NSNumber *height = @130;
    if (isFilterStyle) {
        if (self.musicEntity == nil) {
            height = @50;
        }
        else {
            height = @81;
        }
    }
    
    [_bottomContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottomMargin);
        make.height.equalTo(height);
    }];
    
}

- (void)play {
    [_filterEngine startProcessing];
    [_audioPlayer play];
}

- (void)pause {
    [_filterEngine endProcessing];
    [_audioPlayer pause];
}

- (void)replay {
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.musicUrl];
    [_audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
    [self play];
}

- (void)finishAction {
    [self pause];
    [_playIndicatorImageView setHidden:false];
    __unsafe_unretained typeof(self) this = self;
    
    void (^completeHandle)(NSString *) = ^(NSString *outPutPath) {
        NSURL *videoUrl = [NSURL fileURLWithPath:outPutPath];
        AVAsset *asset = [AVURLAsset assetWithURL:videoUrl];
        UIImage *cover = [this.class thumbnailFromAsset:asset maximumSize:CGSizeMake(960, 960) centerCrop:NO];
        [this.videoModelDataSource readyWithCover:cover videoUrl:videoUrl];
        [this->_filterEngine endProcessing];
    };
    
    assert([[self.videoModelDataSource class] conformsToProtocol:@protocol(DYVideoModuleDataSource)]);
    NSString * text = [self.videoModelDataSource getLocalizedStringForKey:@"filter processing"];
    assert(text != nil);
    DYProgressCallback progressCallback = [[self.videoModelDataSource class] showProgressViewWithText:text];
    
    
    void (^applyFilterBlock)(NSURL *) = ^(NSURL *videoURL) {
//                [_filterEngine applyFilterToVideoWithInpuVideoURL:videoURL OutPutBitrate:[[this.videoModelDataSource class] bitRate] isNeedCancle:&xx ProcessHandler:^(float process) {
//                    Log(@"filter progressing: %f", process)
//                    progressCallback(process);
//                } CompletionHandler:^(NSString *outPutPath) {
//                    //            mergeAndExportVideos
//                    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//                    NSString* dataFilePath = [docsdir stringByAppendingPathComponent:@"DYVideo"];
//                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//                    formatter.dateFormat = @"yyyyMMddHHmmss";
//                    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
//                    NSString *fileName = [[dataFilePath stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"_EndOutPut.mov"];
//                    [DYVideoProcessEngine mergeAndExportVideos:[NSArray arrayWithObjects:[NSURL fileURLWithPath:outPutPath], nil] withOutPath:fileName CompletionHandler:^(int code) {
//
//                        completeHandle(fileName);
//                        [[this.videoModelDataSource class] hideProgressView];
//
//                    }];
//                }];
        
        // -=-=-=-=-
        NSString *home = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *videoFolder = [home stringByAppendingPathComponent:@"DYVideo"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        NSString *filePath = [[videoFolder stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"_mergeFilter.mp4"];
        NSURL *destURL = [NSURL fileURLWithPath:filePath];
        NSNumber *bitRate = [[this.videoModelDataSource class] bitRate];
        [_filterEngine endProcessing];
        
        [[DYDYVideoProcess sharedInstance]
         asyncApplyFilter:(GPUImageFilter *)[_filterEngine currentFilter]
         source:videoURL
         destination:destURL
         outputSettings:[DYDYVideoProcess videoOutputSettingFromURL:videoURL bitRate: bitRate]
         cancelProcess:&xx
         progress:^(float progress) {
             Log(@"filter progress: %f", progress)
             dispatch_async(dispatch_get_main_queue(), ^{
                 progressCallback(progress);
             });
         }
         completion:^{
             NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
             NSString *fileName = [[videoFolder stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"_EndOutPut.mp4"];
             [DYVideoProcessEngine mergeAndExportVideos:[NSArray arrayWithObjects:[NSURL fileURLWithPath:destURL.path], nil] withOutPath:fileName CompletionHandler:^(int code) {
                 completeHandle(fileName);
                 [[this.videoModelDataSource class] hideProgressView];
             }];

         }];
        
    };
    
    if (self.musicEntity) {
        [DYVideoProcessEngine mergeVideo:self.videoURL
                                  AndMusic:self.musicUrl
                         AndMusicTimeRange:kCMTimeZero
                             OriginalVolum:self.videoVolume
                                MusicVolum:_audioPlayer.volume
                     WithCompletionHandler:^(NSString *outPutPath, int code) {
                         applyFilterBlock([NSURL fileURLWithPath:outPutPath]);
                     }];
    }
    else {
        applyFilterBlock(self.videoURL);
    }
    
}

- (void)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - getter & setter

- (void)setMusicEntity:(id<DYMusicEntity>)musicEntity {
    _musicEntity = musicEntity;
    
    [_musicTitleLabel setText:[musicEntity name]];
}

- (void)setVideoURL:(NSURL *)videoURL {
    assert(videoURL != nil);
    _videoURL = videoURL;
    
    [_filterEngine replaceVideoURL:videoURL];
    [self prepareDataSource];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DYVideoFilterCollectionViewCell *cell = (DYVideoFilterCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"filterCell" forIndexPath:indexPath];
    DYFilterEntityViewModel *model = [self.dataSource objectAtIndex:indexPath.item];
    [cell setTitle:[model Title]];
    [cell setCover:[model filteredImage]];
    [cell setSelected:indexPath.item == self.selectedIndex];
    Log(@"cell: %@", cell);
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.item;
    DYFilterEntityViewModel *viewModel = [_dataSource objectAtIndex:indexPath.item];
    if ([viewModel filterPatternImage] == nil) {
        [_filterEngine resetOriginalFilter];
        return ;
    }
    [_filterEngine changeFilterWithLookupImage:[viewModel filterPatternImage]];
    [[collectionView visibleCells] enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger i = [collectionView indexPathForCell:obj].item;
        [obj setSelected:self.selectedIndex == i];
    }];
}

#pragma mark - DYVideoEditorControllerDelegate
-(void)showHUDForExportering{
    [[self.videoModelDataSource class] showHUDForIndeterminateWithText:[self.videoModelDataSource getLocalizedStringForKey:@"exportering..."]];
}

-(void)DYVideoEditorControllerDidCancel{
    
}
-(void)DYVideoEditorControllerDidSaveEditedVideoToPath:(NSString *)editedVideoPath{
    [[self.videoModelDataSource class] hideProgressView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setVideoURL:[NSURL fileURLWithPath:editedVideoPath]];
        [self replay];
    });
}

//#pragma mark - UIVideoEditorControllerDelegate

//- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath {
//    [self setVideoURL:[NSURL fileURLWithPath:editedVideoPath]];
//    [self replay];
//    [editor dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error {
//    [editor dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor {
//    [editor dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - DYOnlineMusicLibraryViewControllerDelegate

-(void)choseMusicComplete:(id<DYMusicEntity>)musicItem andVideoVolum:(float)videoVolum andMusicVolum:(float)musicVolum {
    self.videoVolume = videoVolum;
    [_filterEngine changeEngineVolume:videoVolum];
    [_audioPlayer setVolume:musicVolum];
    
    NSURL *musicUrl = [NSURL URLWithString:[musicItem url]];
    NSURL *localUrl = [[NSURL fileURLWithPath:[[KSYHTTPProxyService sharedInstance] getCachedFilePathForUrl:musicUrl]] URLByAppendingPathExtension:@"mp3"];
    assert([[NSFileManager defaultManager] fileExistsAtPath:localUrl.path]);
    [self setMusicUrl:localUrl];
    [self setMusicEntity:musicItem];
    [self replay];
    [_filterEngine replay];
    [self changeBottomContainerToFilterStyle:YES];
}

#pragma mark - helper methods

+ (UIImage * _Nonnull)thumbnailFromAsset:(AVAsset * _Nonnull)asset {
    return [self thumbnailFromAsset:asset maximumSize:CGSizeMake(512, 512)];
}

+ (UIImage * _Nonnull)thumbnailFromAsset:(AVAsset * _Nonnull)asset maximumSize:(CGSize)size {
    return [self thumbnailFromAsset:asset maximumSize:CGSizeMake(512, 512) centerCrop:YES];
}

+ (UIImage * _Nonnull)thumbnailFromAsset:(AVAsset * _Nonnull)asset maximumSize:(CGSize)size centerCrop:(BOOL)needCrop {
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    [imageGenerator setAppliesPreferredTrackTransform: YES];
    [imageGenerator setMaximumSize:size];
    
    CMTime time;
    CGImageRef result = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:&time error:nil];
    CGSize sizeOfThumbnail = CGSizeMake(CGImageGetWidth(result), CGImageGetHeight(result));
    
    UIImage *image;
    if (needCrop) {
        CGRect cropRect;
        if (sizeOfThumbnail.width > sizeOfThumbnail.height) {
            cropRect = CGRectMake((sizeOfThumbnail.width - sizeOfThumbnail.height) * 0.5, 0, sizeOfThumbnail.height, sizeOfThumbnail.height);
        }
        else {
            cropRect = CGRectMake(0, (sizeOfThumbnail.height - sizeOfThumbnail.width) * 0.5, sizeOfThumbnail.width, sizeOfThumbnail.width);
        }
        image = [[UIImage alloc] initWithCGImage:CGImageCreateWithImageInRect(result, cropRect)];
    }
    else {
        image = [[UIImage alloc] initWithCGImage:result];
    }
    return image;
}

@end

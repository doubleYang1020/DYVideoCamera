//
//  DYVideoRecoderViewController.m
//  DYVideoModule
//
//  Created by  video on 21/11/2017.
//  Copyright © 2017 co.thel.module.video. All rights reserved.
//

#import "DYVideoRecoderViewController.h"
#import <Masonry/Masonry.h>
#import "DYVideoSDK.h"
#import <GPUImage/GPUImage.h>

#import "DYVMConstants+Private.h"
#import "DYVideoPickerController.h"
#import "DYOnlineMusicLibraryViewController.h"
#import "DYImageManager.h"
#import <Photos/PHImageManager.h>
#import "DYSegmentPrograssView.h"
#import "DYVideoEditorViewController.h"


@interface DYVideoRecoderViewController () <TZImagePickerControllerDelegate> {
    UIButton * _cancelButton;
    UIButton * _retouchButton;
    UIButton * _changeCameraButton;
    UIButton * _leftBottomButton;
    UIButton * _rightBottomButton;
    UIButton * _recordingButton;
    UIButton * _finishButton;
    UIView * _topContainerView;
    UIView * _gradientBackgroundTopView;
    UIView * _gradientBackgroundBottomView;
    
    UILabel * _timerLabel;
    DYSegmentPrograssView * _progressView;
    
    // control components
    DYCameraEngine * _cameraEngine;
    NSTimer * _recordingTimer;
    float _totalDuration;
    float _currentSegmentDuration;
}

@property (assign, atomic) BOOL canRecording;
@property (assign, atomic) BOOL hasCameraAndMicrophonePermission;
@property (assign, atomic) BOOL isRecordingEarlyRelease;
@property (assign, nonatomic) NSTimeInterval maxDuration;
@property (assign, nonatomic) BOOL willRemoveRecordingSegment;
@property (assign, nonatomic) BOOL isShowAlbum;
@end

@implementation DYVideoRecoderViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        // Custom initialization
        _cancelButton = [[UIButton alloc] init];
        _retouchButton = [[UIButton alloc] init];
        _changeCameraButton = [[UIButton alloc] init];
        _leftBottomButton = [[UIButton alloc] init];
        _rightBottomButton = [[UIButton alloc] init];
        _recordingButton = [[UIButton alloc] init];
        _finishButton = [[UIButton alloc] init];
        _topContainerView = [[UIView alloc] init];
        
        _gradientBackgroundTopView = [[UIView alloc] init];
        _gradientBackgroundBottomView = [[UIView alloc] init];
        
        _timerLabel = [[UILabel alloc] init];
        _progressView = [[DYSegmentPrograssView alloc] init];
        
        _totalDuration = 0;
        _currentSegmentDuration = 0;
        
        _canRecording = YES;
        _isRecordingEarlyRelease = NO;
        _hasCameraAndMicrophonePermission = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setWillRemoveRecordingSegment: NO];
    
    [self setupUI];
    [self setupActions];
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage new]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_cameraEngine startEngine];
    [self.navigationController setNavigationBarHidden:true animated:false];
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:[self prefersStatusBarHidden]];
    
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//        [_cameraEngine startEngine];
//
//    });
    [DYImageManager manager].photoPreviewMaxWidth = 100;
    [DYImageManager manager].sortAscendingByModificationDate = false;
    [DYImageManager manager].columnNumber = 3;
    [[DYImageManager manager] getCameraRollAlbum:true allowPickingImage:false completion:^(TZAlbumModel *model) {
        if (model.models.count == 0) {
            return ;
        }
        DYAssetModel* TempModel = model.models.firstObject;

        _leftBottomButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [[DYImageManager manager] getPhotoWithAsset:TempModel.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_leftBottomButton setImage:photo forState:UIControlStateNormal];
                _leftBottomButton.layer.cornerRadius = 5;
                _leftBottomButton.layer.borderWidth = 1;
                _leftBottomButton.layer.borderColor = [UIColor whiteColor].CGColor;
                _leftBottomButton.clipsToBounds = true;
            });
            
        }];
        

    }];
//    [[UIApplication sharedApplication] setStatusBarHidden:true withAnimation:true];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:_isShowAlbum animated:true];
    [[UIApplication sharedApplication] setStatusBarHidden:false];
    [_cameraEngine endEngine];
}

- (BOOL)prefersStatusBarHidden {
    return ![DYVMConstants iPhoneX];
}

#pragma mark - View layout

- (void)setupUI {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:_cameraEngine.cameraPreview];
    [self.view addSubview:_gradientBackgroundTopView];
    [self.view addSubview:_gradientBackgroundBottomView];
    
    [self.view addSubview:_topContainerView];
    [_topContainerView addSubview:_cancelButton];
    [_topContainerView addSubview:_retouchButton];
    [_topContainerView addSubview:_changeCameraButton];
    [_topContainerView addSubview:_finishButton];
    [self.view addSubview:_leftBottomButton];
    [self.view addSubview:_rightBottomButton];
    [self.view addSubview:_recordingButton];
    [self.view addSubview:_progressView];
    [self.view addSubview:_timerLabel];
    
    CAGradientLayer *topLayer = [CAGradientLayer layer];
    topLayer.frame = CGRectMake(0, 0, [DYVMConstants screenWidth], [DYVMConstants screenHeight] * 0.25);
    topLayer.colors = @[(id)[[UIColor colorWithWhite:0 alpha:0.25] CGColor], (id)[[UIColor clearColor] CGColor]];
    [_gradientBackgroundTopView.layer addSublayer:topLayer];
    [_gradientBackgroundTopView setUserInteractionEnabled:NO];
    
    CAGradientLayer *bottomLayer = [CAGradientLayer layer];
    bottomLayer.frame = CGRectMake(0, 0, [DYVMConstants screenWidth], [DYVMConstants screenHeight] * 0.25);;
    bottomLayer.colors = @[(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.25] CGColor]];
    [_gradientBackgroundBottomView.layer addSublayer:bottomLayer];
    [_gradientBackgroundBottomView setUserInteractionEnabled:NO];
    
    [[_cameraEngine cameraPreview] setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    [[_cameraEngine cameraPreview] setBackgroundColor:[UIColor whiteColor]];
    
    [_cancelButton setImage:[DYVMConstants imageNamed:@"icCancel"] forState:UIControlStateNormal];
    
    [_retouchButton setImage:[DYVMConstants imageNamed:@"icBeautiful"] forState:UIControlStateNormal];
    [_retouchButton setImage:[DYVMConstants imageNamed:@"icBeautifulSelected"] forState:UIControlStateSelected];
    
    [_changeCameraButton setImage:[DYVMConstants imageNamed:@"icCamera"] forState:UIControlStateNormal];
    [_changeCameraButton setImage:[DYVMConstants imageNamed:@"icCameraSelected"] forState:UIControlStateSelected];
    
    [_recordingButton setBackgroundColor:[DYVMConstants colorMainTheme]];
    [_recordingButton.layer setCornerRadius:27];
    [_recordingButton.layer setBorderWidth:4];
    [_recordingButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    [_finishButton setTitleColor:[DYVMConstants colorPlainText] forState:UIControlStateNormal];
    [_finishButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [_finishButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:15]];
    [_finishButton setTitle:[self.videoModelDataSource getLocalizedStringForKey:@"Next"] forState:UIControlStateNormal];
//    [_finishButton setEnabled:NO];
    
    [_leftBottomButton setImage:[DYVMConstants imageNamed:@"icDefault"] forState:UIControlStateNormal];
    [_rightBottomButton setImage:[DYVMConstants imageNamed:@"icDelete"] forState:UIControlStateNormal];
    
    [_timerLabel setTextColor:[DYVMConstants colorPlainText]];
    [_timerLabel setTextAlignment:NSTextAlignmentCenter];
    [_timerLabel setFont:[UIFont systemFontOfSize:11]];
    
    [_progressView setBackgroundColor:[UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:0.3]];
    float progress = CMTimeGetSeconds([[self.videoModelDataSource class] videoTimeRange].start) / CMTimeGetSeconds([[self.videoModelDataSource class] videoTimeRange].duration);
    [_progressView addSegmentSeperatorAt:progress];
    
    [self applyConstrains];
    
    [self updateTimerLabelText];
}

- (void)applyConstrains {
    [_cameraEngine.cameraPreview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    [_gradientBackgroundTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(self.view).with.multipliedBy(0.25);
    }];
    
    [_gradientBackgroundBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.equalTo(self.view).with.multipliedBy(0.25);
    }];
    
    [_topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_topMargin);
        make.width.equalTo(@([DYVMConstants screenWidth]));
        make.height.equalTo(@44);
    }];
    
    [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_topContainerView).with.offset(12);
        make.centerY.equalTo(_topContainerView);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    
    [_retouchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_topContainerView).with.offset(-(22));
        make.centerY.equalTo(_topContainerView);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    
    [_changeCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_topContainerView).with.offset(22);
        make.centerY.equalTo(_topContainerView);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    
    [_recordingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_bottomMargin).with.offset(-12 - 32);
        make.width.equalTo(@54);
        make.height.equalTo(@54);
    }];
    
    [_finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_topContainerView.mas_right).offset(-12);
        make.centerY.equalTo(_topContainerView);
        make.width.equalTo(@54);
        make.height.equalTo(@44);
    }];
    
    [_leftBottomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.centerY.equalTo(_recordingButton);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    
    [_rightBottomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).with.offset(-32);
        make.centerY.equalTo(_recordingButton);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).with.offset(32);
        make.trailing.equalTo(self.view).with.offset(-32);
        make.bottom.equalTo(_recordingButton.mas_centerY).with.offset(-42);
        make.height.equalTo(@5);
    }];
    
    [_timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(_progressView);
        make.height.equalTo(@16);
        make.centerX.equalTo(_progressView);
        make.bottom.equalTo(_progressView.mas_top).with.offset(-12);;
    }];
}

- (void)setupActions {
    [_cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_retouchButton addTarget:self action:@selector(retouchButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_changeCameraButton addTarget:self action:@selector(changeCameraButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_recordingButton addTarget:self action:@selector(recordingStartAction) forControlEvents:UIControlEventTouchDown];
    [_recordingButton addTarget:self action:@selector(recordingEndAction) forControlEvents:UIControlEventTouchUpInside];
    [_recordingButton addTarget:self action:@selector(recordingEndAction) forControlEvents:UIControlEventTouchUpOutside];
    
    [_finishButton addTarget:self action:@selector(finishedAction) forControlEvents:UIControlEventTouchUpInside];
    [_rightBottomButton addTarget:self action:@selector(removeLastVideoSegment) forControlEvents:UIControlEventTouchUpInside];
    [_leftBottomButton addTarget:self action:@selector(clickAblumBtn) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Button Actions

- (void)cancelButtonAction {
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)retouchButtonAction {
    [_retouchButton setSelected:![_retouchButton isSelected]];
    [_cameraEngine changeBeautyFace:[[self.videoModelDataSource class] beautyPreset]];
}

- (void)changeCameraButtonAction {
    [_cameraEngine changeCameraPositionAndAutoUseBeautifyWhenPostionFront:NO];
}

- (void)recordingStartAction {
    if (![self permissionCheckAndShowPermissionAlertIfNeeded]) {
        return ;
    }
    
    // 防止过快点击
    if (!self.canRecording) {
        Log(@"SKIP")
        [[self.videoModelDataSource class] showToastWithText:[self.videoModelDataSource getLocalizedStringForKey:@"Tap too fast"] dismissAfter:1];
        return;
    }
    if (_totalDuration >= _maxDuration){
        [[self.videoModelDataSource class] showToastWithText:[self.videoModelDataSource getLocalizedStringForKey:@"Video can't be greater than 60s"] dismissAfter:1];
        return;
    }
    
    self.canRecording = NO;
    self.isRecordingEarlyRelease = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.canRecording = YES;
        
        if (self.isRecordingEarlyRelease) {
            [self recordingEndAction];
        }
    });
    
#if !(TARGET_IPHONE_SIMULATOR)
    [_cameraEngine startRecord];
#endif
    Log(@"recording");
    self.willRemoveRecordingSegment = NO;
    _recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateCurrentProgress) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_recordingTimer forMode:UITrackingRunLoopMode];
    [_progressView startAnimationWithMaxDuration:(1.0 - [_progressView currentProgress]) * _maxDuration];
    
    [UIView animateWithDuration:0.2 animations:^{
        [_recordingButton setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
    }];
    
    [self checkAllButtonAvaliable];
}

- (void)recordingEndAction {
    if (![_cameraEngine isRecoding] || !self.canRecording) { // skip while not recording
        self.isRecordingEarlyRelease = YES;
        return;
    }

    [self endRecording];
}

- (void)finishedAction {
    if (_totalDuration < CMTimeGetSeconds([[self.videoModelDataSource class] videoTimeRange].start)){
        [[self.videoModelDataSource class] showToastWithText:[self.videoModelDataSource getLocalizedStringForKey:@"Video can't be less than 5s"] dismissAfter:1];
        return;
    }
    [_finishButton setEnabled:false];
    [_cameraEngine exportVideoWithCompletionHandler:^(NSString *outPutPath, int code) {
        Log(@"%d output: %@", code, outPutPath);
        dispatch_async(dispatch_get_main_queue(), ^{
            [_finishButton setEnabled:true];
            [self showVideoEditorViewControllerWithUrl:[NSURL fileURLWithPath:outPutPath]];
        });
    }];
}

- (void)removeLastVideoSegment {
    if (self.willRemoveRecordingSegment) {
        float removedSegmentProgress = [_progressView removeLastSegment];
        _totalDuration -= removedSegmentProgress * _maxDuration;
        [self updateTimerLabelText];
        [self checkAllButtonAvaliable];
        
        #if !(TARGET_IPHONE_SIMULATOR)
        [_cameraEngine deleteVidoSegment];
        #endif
        self.willRemoveRecordingSegment = NO;
    }
    else {
        self.willRemoveRecordingSegment = YES;
    }
}

- (void)clickAblumBtn {
    DYVideoPickerController* cor = [[DYVideoPickerController alloc] initWithdelegate:self];
    _isShowAlbum = true;
    [self presentViewController:cor animated:true completion:nil];

}

#pragma mark - TZImagePickerControllerDelegate

-(void)imagePickerController:(DYVideoPickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset{
    
    PHAsset* myasset = asset;
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestAVAssetForVideo:myasset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AVURLAsset *urlAsset = (AVURLAsset *)asset;
            NSURL *url = urlAsset.URL;
            
            [self showVideoEditorViewControllerWithUrl:url];
        });
        
    }];
}


- (void)imagePickerController:(DYVideoPickerController *)picker didFinishPickingCover:(UIImage *)coverImage videoUrl:(NSURL *)url {
    [self showVideoEditorViewControllerWithUrl:url];
}
-(void)imagePickerControllerShowHUDForExportering{
     [[self.videoModelDataSource class] showHUDForIndeterminateWithText:[self.videoModelDataSource getLocalizedStringForKey:@"exportering..."]];
}

-(void)imagePickerControllerHiddenHUDForExportering{
    [[self.videoModelDataSource class] hideProgressView];
}


-(void)imagePickerControllerShowHud:(NSString *)tipString{
         [[self.videoModelDataSource class] showToastWithText:[self.videoModelDataSource getLocalizedStringForKey:tipString] dismissAfter:1];
}

-(NSString *)imagePickerControllergetLocalizedStringForKey:(NSString *)key{
    return [self.videoModelDataSource getLocalizedStringForKey:key];
}

- (CMTimeRange)videoTimeRange {
//    return kCMTimeRangeZero;
    return [[self.videoModelDataSource class] videoTimeRange];
}

/*
 
#pragma mark - Navigation

*/

#pragma mark - Getter & Setter

- (void)setVideoModelDataSource:(id<DYVideoModuleDataSource>)videoModelDataSource {
    _videoModelDataSource = videoModelDataSource;
    
    _cameraEngine = [[DYCameraEngine alloc] initWithBitrate:[[videoModelDataSource class] bitRate] WithSessionPreset:[[videoModelDataSource class] sessionPreset]];
    _maxDuration = CMTimeGetSeconds([[videoModelDataSource class] videoTimeRange].duration);
}

- (void)setWillRemoveRecordingSegment:(BOOL)willRemoveRecordingSegment {
    _willRemoveRecordingSegment = willRemoveRecordingSegment;
    UIColor *segmentColor = willRemoveRecordingSegment ? [UIColor colorWithRed:255.0/255.0 green:101.0/255.0 blue:101.0/255.0 alpha:1.0] : [UIColor whiteColor];
    [_progressView setColor:segmentColor toSegmentIndex:-1];
}

#pragma mark - helper methods

- (void)showVideoEditorViewControllerWithUrl:(NSURL * _Nonnull)url {
    _isShowAlbum = false;
    DYVideoEditorViewController *vc = [[DYVideoEditorViewController alloc] initWithVideoURL: url];
    [vc setVideoModelDataSource:self.videoModelDataSource];
    [self showViewController:vc sender:self];
}

- (void)updateCurrentProgress {
    _currentSegmentDuration += 0.01;
    
    [self updateTimerLabelText];
    
    if (_currentSegmentDuration + _totalDuration >= _maxDuration) {
        [[self.videoModelDataSource class] showToastWithText:[self.videoModelDataSource getLocalizedStringForKey:@"Video can't be greater than 60s"] dismissAfter:1];
        [self endRecording];
    }
    
}

- (void)updateTimerLabelText {
    if (_totalDuration < 0) _totalDuration = 0;
    if (_totalDuration > _maxDuration) _totalDuration = _maxDuration;
    [_timerLabel setText:[NSString stringWithFormat:@"%.1f S", (_currentSegmentDuration + _totalDuration)]];
}

- (void)checkAllButtonAvaliable {
    BOOL isRecording = [_recordingTimer isValid];
    [_cancelButton setEnabled:!isRecording];
    [_retouchButton setEnabled:!isRecording];
    [_changeCameraButton setEnabled:!isRecording];
    [_leftBottomButton setEnabled:!isRecording];
    [_rightBottomButton setEnabled:!isRecording];
    [_finishButton setEnabled:!isRecording];
    
    if (!isRecording) {
        [_leftBottomButton setEnabled:[_progressView currentProgress] == 0];
        [_rightBottomButton setEnabled:[_progressView currentProgress] > 0];
    }
    
    
//    [_recordingButton setEnabled:_totalDuration < _maxDuration];
//    [_finishButton setEnabled:_totalDuration >= CMTimeGetSeconds([[self.videoModelDataSource class] videoTimeRange].start)];
}

- (void)endRecording {
    [_recordingTimer invalidate];
    if(_cameraEngine.isRecoding){
        [_cameraEngine stopRecordWithCompletionHandler:^{
            Log(@"recorded");
        }];
        [_progressView addProgressSegment:_currentSegmentDuration / _maxDuration];
    }
    
    _totalDuration = [_progressView currentProgress] * _maxDuration;
    _currentSegmentDuration = 0;
    
    [UIView animateWithDuration:0.2 animations:^{
        [_recordingButton setTransform:CGAffineTransformIdentity];
    }];
    
    [self checkAllButtonAvaliable];
}

- (BOOL)permissionCheckAndShowPermissionAlertIfNeeded {
    BOOL hasCameraPermission = [self checkAVCaptureDevicePermissionByType:AVMediaTypeVideo];
    BOOL hasMicrophonePermission = [self checkAVCaptureDevicePermissionByType:AVMediaTypeAudio];
    
    if (hasCameraPermission && hasMicrophonePermission) {
        return hasCameraPermission && hasMicrophonePermission;
    }
    
    NSMutableString *message = [@"Request " mutableCopy];
    if (!hasCameraPermission) [message appendString:@"camera "];
    if (!hasMicrophonePermission) [message appendString:@"microphone "];
    [message appendString:@"permission"];
    [self showPermissionAlertControllerWithMessage:[self.videoModelDataSource getLocalizedStringForKey:message]];
    
    return hasCameraPermission && hasMicrophonePermission;
}

- (void)showPermissionAlertControllerWithMessage:(NSString *)message {
    NSArray<UIAlertAction *> * actions =
    @[
      [UIAlertAction
       actionWithTitle:[self.videoModelDataSource getLocalizedStringForKey:@"Setting"]
       style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * _Nonnull action) {
           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
       }]
      ];
    
    [[self.videoModelDataSource class]
     showAlertControllerWithTitle:@"Persmission"
     message:message
     preferredStyle:UIAlertControllerStyleAlert
     actions:actions];
}

- (BOOL)checkAVCaptureDevicePermissionByType:(AVMediaType)mediaType {
    BOOL hasPermission = NO;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
        hasPermission = YES;
    } else if(authStatus == AVAuthorizationStatusDenied){
        // denied
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access to %@", mediaType);
            } else {
                NSLog(@"Not granted access to %@", mediaType);
            }
        }];
    } else {
        // impossible, unknown authorization status
    }
    return hasPermission;
}

-(void)dealloc{
    Log("Dealloc");
}

@end

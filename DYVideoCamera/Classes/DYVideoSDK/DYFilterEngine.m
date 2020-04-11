//
//  DYFilterEngine.m
//  DYVideoSDK
//
//  Created by huyangyang on 2017/11/2.
//  Copyright © 2017年 DY. All rights reserved.
//

#import "DYFilterEngine.h"
#import <AVFoundation/AVFoundation.h>
#import "DYGPUImageEmptyFilter.h"
#import "DYGPUImageLookupFilter.h"
#import "DYVideoProcessEngine.h"
#import "DYVMConstants+Private.h"

@interface DYFilterEngine ()
{
    //    GPUImageMovie* endMovieFile;
    //    GPUImageMovieWriter *movieWriter;
    GPUImageOutput<GPUImageInput> *_processFilter;
}
@property (nonatomic , strong) NSURL* inputVideoUrl;

@property (nonatomic , strong) AVPlayer* audioPlayer;

@property (nonatomic , strong) AVPlayerItem* playerItem;
@property (nonatomic , strong) GPUImageMovie* movieFile;
@property (nonatomic ,strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic ,assign) GPUImageRotationMode orientation;
//@property (nonatomic ,strong) GPUImageOutput<GPUImageInput> *processFilter;
@end

@implementation DYFilterEngine

-(instancetype)initWithVideoURL:(NSURL *)url{
    self = [super init];
    if (self) {
        _inputVideoUrl = url;
        [self initOther];
        
    }
    return self;
}
-(void)initOther{
    _playerItem = [[AVPlayerItem alloc] initWithURL:_inputVideoUrl];
    _audioPlayer = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
    _movieFile = [[GPUImageMovie alloc] initWithPlayerItem:_playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    
    _movieFile.runBenchmark = false; _movieFile.playAtActualSpeed = YES;
    _filter = [[DYGPUImageEmptyFilter alloc] init];
    _processFilter = [[DYGPUImageEmptyFilter alloc] init];
    [_movieFile addTarget:_filter];
    _filterView = [[GPUImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    AVAsset* asset = [AVAsset assetWithURL:_inputVideoUrl];
    CGSize videoSize = [[asset tracksWithMediaType:AVMediaTypeVideo].firstObject naturalSize];
    CGAffineTransform txf =[[asset tracksWithMediaType:AVMediaTypeVideo].firstObject preferredTransform];
    _orientation = kGPUImageNoRotation;
    //    kGPUImageRotateLeft,
    //    kGPUImageRotateRight,
    //    kGPUImageFlipVertical,
    //    kGPUImageFlipHorizonal,
    //    kGPUImageRotateRightFlipVertical,
    //    kGPUImageRotateRightFlipHorizontal,
    //    kGPUImageRotate180
    float videoAngleInDegree = atan2(txf.b,txf.a) * 180 / M_PI ;
    //    Log(@"videoAngleInDegree = %f",videoAngleInDegree);
    switch ((int)videoAngleInDegree) {
        case 0:
            _orientation = kGPUImageNoRotation;
            break;
        case 90:
            _orientation = kGPUImageRotateRight;
            break;
        case 180:
            _orientation = kGPUImageRotate180;
            break;
        case -90:
            _orientation = kGPUImageRotateLeft;
            break;
            
        default:
            _orientation = kGPUImageNoRotation;
            break;
    }
    
    [_filterView setInputRotation:_orientation atIndex:0];
    [_filter addTarget:_filterView];
}

- (void)replaceVideoURL:(NSURL * _Nonnull)url {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:_playerItem];
    [_movieFile removeAllTargets];
    
    _inputVideoUrl = url;
    _playerItem = [[AVPlayerItem alloc] initWithURL:_inputVideoUrl];
    _audioPlayer = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
    _movieFile = [[GPUImageMovie alloc] initWithPlayerItem:_playerItem];
    [_movieFile addTarget:_filter];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackFinished:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_playerItem];
}

-(void)startProcessing{
    [_audioPlayer play];
    [_movieFile startProcessing];
}
-(void)endProcessing{
    [_audioPlayer pause];
    [_movieFile endProcessing];
}

-(void)replay{
    [_playerItem seekToTime:kCMTimeZero];
    [_audioPlayer play];
}

-(void)changeEngineVolume:(float)volume{
    _audioPlayer.volume = volume;
}

-(void)resetOriginalFilter{
    [_movieFile removeAllTargets];
    [_filter removeAllTargets];
    
    _filter = [[DYGPUImageEmptyFilter alloc] init];
    _processFilter = [[DYGPUImageEmptyFilter alloc] init];
    [_movieFile addTarget:_filter];
    [_filterView setInputRotation:_orientation atIndex:0];
    [_filter addTarget:_filterView];
}

-(void)changeFilterWithLookupImage:(UIImage *)LookupImage{
    [_movieFile removeAllTargets];
    [_filter removeAllTargets];
    
    _filter = [[DYGPUImageLookupFilter alloc] initWithLookupImage:LookupImage];
    _processFilter = [[DYGPUImageLookupFilter alloc] initWithLookupImage:LookupImage];
    [_movieFile addTarget:_filter];
    [_filterView setInputRotation:_orientation atIndex:0];
    [_filter addTarget:_filterView];
}
-(void)changeFilterWithFilterClassName:(NSString *)className{
    [_movieFile removeAllTargets];
    [_filter removeAllTargets];
    
    _filter = [[NSClassFromString(className) alloc] init];
    _processFilter = [[NSClassFromString(className) alloc] init];
    [_movieFile addTarget:_filter];
    [_filterView setInputRotation:_orientation atIndex:0];
    [_filter addTarget:_filterView];
}
-(void)changeFilterWithFragmentShaderFromFile:(NSString *)fragmentShaderFilePath{
    [_movieFile removeAllTargets];
    [_filter removeAllTargets];
    
    //    _filter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:fragmentShaderFilePath];
    _filter = [[GPUImageFilter alloc] initWithFragmentShaderFromString:[NSString stringWithContentsOfFile:fragmentShaderFilePath encoding:kCFStringEncodingUTF8 error:nil]];
    _processFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromString:[NSString stringWithContentsOfFile:fragmentShaderFilePath encoding:kCFStringEncodingUTF8 error:nil]];
    [_movieFile addTarget:_filter];
    [_filterView setInputRotation:_orientation atIndex:0];
    [_filter addTarget:_filterView];
}
-(void)applyFilterToVideoWithInpuVideoURL:(NSURL *)VideoUrl OutPutBitrate:(NSNumber *)bitrate isNeedCancle:(BOOL *)isNeedCancle ProcessHandler:(void (^)(float))processHandler CompletionHandler:(void (^)(NSString *))completionHandler{
    [_filter removeAllTargets];
    [_movieFile removeAllTargets];
    [_audioPlayer pause];
    [DYVideoProcessEngine applyFilterToVideoWithInpuVideoURL:VideoUrl Filter:_processFilter OutPutBitrate:bitrate isNeedCancle:isNeedCancle ProcessHandler:^(float process) {
         processHandler(process);
    } CompletionHandler:^(NSString *outPutPath, int code) {
        completionHandler(outPutPath);
    }];
}
-(void)playbackFinished:(NSNotification *)notification{
    Log(@"视频播放完成.");
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didCompletePlayingMovie" object:nil];
}

- (CMTime)videoDuration {
    return [_playerItem duration];
}

- (GPUImageOutput<GPUImageInput> * _Nullable)currentFilter {
    return _processFilter;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    Log(@"%@释放了",self.class);
    [[[GPUImageContext sharedImageProcessingContext] framebufferCache] purgeAllUnassignedFramebuffers];
}
@end


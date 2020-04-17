//
//  CameraEngine.m
//  DYVideoSDK
//
//  Created by huyangyang on 2017/10/31.
//  Copyright © 2017年 DY. All rights reserved.
//

#import "DYCameraEngine.h"
#import "DYGPUImageEmptyFilter.h"
#import "GPUImageBeautifyFilter.h"
#import "DYVideoProcessEngine.h"
#import "DYGPUImageMovieWriter.h"
@interface DYCameraEngine ()
{
}
@property (nonatomic ,strong) GPUImageVideoCamera* videoCamera;
@property (nonatomic , strong) NSNumber* bit;
@property (nonatomic ,strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic ,strong) DYGPUImageMovieWriter* movieWriter;
@property (nonatomic ,strong) NSString* dataFilePath;
@property (nonatomic ,strong) NSMutableArray* videoListAry;
@property (nonatomic, assign) DYCameraEngineSessionPreset sessionPreset;
@end

@implementation DYCameraEngine

- (instancetype)initWithBitrate:(NSNumber*) bitrate WithSessionPreset:(DYCameraEngineSessionPreset) SessionPreset{
    self = [super init];
    if (self) {
        self.bit = bitrate;
        _videoListAry = [NSMutableArray array];
        [self createFile];
        [self initCamera];
        self.sessionPreset = SessionPreset;
    }
    return self;
}
- (void) createFile{
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _dataFilePath = [docsdir stringByAppendingPathComponent:@"DYVideo"]; // 在指定目录下创建 "head" 文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:_dataFilePath isDirectory:&isDir];
    
    if ( !(isDir == YES && existed == YES) ) {
        
        // 在 Document 目录下创建一个 head 目录
        [fileManager createDirectoryAtPath:_dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    

    

    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:_dataFilePath error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    
    NSString *filename;
    
    while ((filename = [e nextObject])) {
        
        [fileManager removeItemAtPath:[_dataFilePath stringByAppendingPathComponent:filename] error:NULL];
    }
    
}

- (void) initCamera {
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    _position = CameraManagerDevicePositionBack;
    if ([self.videoCamera.inputCamera lockForConfiguration:nil]) {
        //自动对焦
        if ([self.videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [self.videoCamera.inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动曝光
        if ([self.videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [self.videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        //自动白平衡
        if ([self.videoCamera.inputCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [self.videoCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }

        [self.videoCamera.inputCamera unlockForConfiguration];
    }
    
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [self.videoCamera addAudioInputsAndOutputs];
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    self.filter = [[DYGPUImageEmptyFilter alloc] init];
    _cameraPreview = [[GPUImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_videoCamera addTarget:_filter];
    [_filter addTarget:_cameraPreview];
    
    self.isRecoding = false;
    
}

-(void)startEngine{
    [self.videoCamera startCameraCapture];
}
-(void)endEngine{
    [self.videoCamera stopCameraCapture];
}

-(void)changeCameraPositionAndAutoUseBeautifyWhenPostionFront:(BOOL)isNeed{
    switch (_position) {
        case CameraManagerDevicePositionBack: {
            if (_videoCamera.cameraPosition == AVCaptureDevicePositionBack) {
                [_videoCamera pauseCameraCapture];
                _position = CameraManagerDevicePositionFront;
                //                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [_videoCamera rotateCamera];
                [_videoCamera resumeCameraCapture];
                

                if (isNeed) {
                    [_videoCamera removeAllTargets];
                    _filter = [[GPUImageBeautifyFilter alloc] init];
                    [_videoCamera addTarget:_filter];
                    [_filter addTarget:_cameraPreview];
                }

                
                
            }
        }
            break;
        case CameraManagerDevicePositionFront: {
            if (_videoCamera.cameraPosition == AVCaptureDevicePositionFront) {
                [_videoCamera pauseCameraCapture];
                _position = CameraManagerDevicePositionBack;
                
                //                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [_videoCamera rotateCamera];
                [_videoCamera resumeCameraCapture];
                

                if (isNeed) {
                    [_videoCamera removeAllTargets];
                    _filter = [[DYGPUImageEmptyFilter alloc] init];
                    [_videoCamera addTarget:_filter];
                    [_filter addTarget:_cameraPreview];
                }

            }
        }
            break;
        default:
            break;
    }
    
    if ([_videoCamera.inputCamera lockForConfiguration:nil] && [_videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [_videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        [_videoCamera.inputCamera unlockForConfiguration];
    }
}

-(void)changeFlashingLight{
    if (_videoCamera.inputCamera.hasFlash) {
        [_videoCamera.inputCamera lockForConfiguration:nil];
        _videoCamera.inputCamera.torchMode = _videoCamera.inputCamera.isTorchActive ? AVCaptureTorchModeOff : AVCaptureTorchModeOn ;
        [_videoCamera.inputCamera unlockForConfiguration];
        
    }
}

- (void)changeBeautyFace:(DYCameraEngineBeautyPreset)beautyPreset{
    if ([_filter isKindOfClass:[GPUImageBeautifyFilter class]]) {
        [_videoCamera removeAllTargets];
        _filter = [[DYGPUImageEmptyFilter alloc] init];
        [_videoCamera addTarget:_filter];
        [_filter addTarget:_cameraPreview];
    }else{
        [_videoCamera removeAllTargets];
        _filter = [[GPUImageBeautifyFilter alloc] init];
        [_videoCamera addTarget:_filter];
        [_filter addTarget:_cameraPreview];
        
        switch (beautyPreset) {
            case BeautyFaceLowQuality:
                [self changeBeautyFaceLowQuality];
                break;
            case BeautyFaceMediumQuality:
                [self changeBeautyFaceMediumQuality];
                break;
            case BeautyFaceHighestQuality:
                [self changeBeautyFaceHighestQuality];
                break;
            
            default:
                break;
        }
    }
    
}
-(void)changeBeautyFaceLowQuality{
    if ([_filter isKindOfClass:[GPUImageBeautifyFilter class]]) {
        [(GPUImageBeautifyFilter*)_filter setBeautyFaceConfigurationTypeOne];
    }
}
-(void)changeBeautyFaceMediumQuality{
    if ([_filter isKindOfClass:[GPUImageBeautifyFilter class]]) {
        [(GPUImageBeautifyFilter*)_filter setBeautyFaceConfigurationTypeTwo];
    }
}
-(void)changeBeautyFaceHighestQuality{
    if ([_filter isKindOfClass:[GPUImageBeautifyFilter class]]) {
        [(GPUImageBeautifyFilter*)_filter setBeautyFaceConfigurationTypeThree];
    }
}

-(void) startRecord {
    self.isRecoding = true;
    float width , height;
    switch (self.sessionPreset) {
        case CameraEngineSessionPreset1280x720:
            {
                width = 720;
                height = 1280;
            }
            break;
        case CameraEngineSessionPreset960x540:
        {
            width = 540;
            height = 960;
        }
            break;
            
        default:
        {
            width = 540;
            height = 960;
        }
            break;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [[_dataFilePath stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"_temp.mov"];
    [_videoListAry addObject:[NSURL fileURLWithPath:fileName]];
    _movieWriter  = [[DYGPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:fileName] size:CGSizeMake(width, height) fileType:AVFileTypeQuickTimeMovie outputSettings:@
                     {
                     AVVideoCodecKey: AVVideoCodecH264,
                     AVVideoWidthKey: [NSNumber numberWithFloat:width],   //Set your resolution width here
                     AVVideoHeightKey: [NSNumber numberWithFloat:height],  //set your resolution height here
                     AVVideoCompressionPropertiesKey: @
                         {
                         AVVideoAverageBitRateKey: _bit,
                         AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
                         },
                     }];
    _movieWriter.encodingLiveVideo = true;
    _movieWriter.shouldPassthroughAudio = YES;
    [_filter addTarget:_movieWriter];
//    [_movieWriter setHasAudioTrack:true];
    _videoCamera.audioEncodingTarget =  (GPUImageMovieWriter *)_movieWriter;
    [_movieWriter startRecording];
}
- (void)stopRecordWithCompletionHandler:(void (^)(void))handler
{
    self.isRecoding = false;
    [_movieWriter finishRecordingWithCompletionHandler:^{
        handler();
    }];
}
-(void)deleteVidoSegment{
    [_videoListAry removeLastObject];
}

-(void)exportVideoWithCompletionHandler:(void (^)(NSString *, int))handler{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [[_dataFilePath stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"_merge.mp4"];
    [DYVideoProcessEngine mergeAndExportVideos:_videoListAry withOutPath:fileName CompletionHandler:^(int code) {
        handler(fileName,code);
    }];
}

@end

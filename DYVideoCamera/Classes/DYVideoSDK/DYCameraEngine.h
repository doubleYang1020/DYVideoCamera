//
//  CameraEngine.h
//  DYVideoSDK
//
//  Created by huyangyang on 2017/10/31.
//  Copyright © 2017年 DY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImageVideoCamera.h>
#import <GPUImage/GPUImageView.h>
typedef NS_ENUM(NSInteger, CameraManagerDevicePosition) {
    CameraManagerDevicePositionBack,
    CameraManagerDevicePositionFront,
};

typedef NS_ENUM(NSInteger, DYCameraEngineSessionPreset) {
    CameraEngineSessionPreset1280x720,
    CameraEngineSessionPreset960x540,
    CameraEngineSessionPreset540x540,//暂不支持
    CameraEngineSessionPreset720x720,//暂不支持
};

typedef NS_ENUM(NSInteger, DYCameraEngineBeautyPreset) {
    BeautyFaceLowQuality,
    BeautyFaceMediumQuality,
    BeautyFaceHighestQuality,
};
@interface DYCameraEngine : NSObject

@property (nonatomic , assign) BOOL isRecoding;

/**
 相机预览画面
 */
@property (nonatomic, strong) GPUImageView* cameraPreview;


/**
 前后摄像头方向
 */
@property (nonatomic, assign) CameraManagerDevicePosition position;

/**
 初始化

 @param bitrate 输出视频 比特率  //2000*1000  建议800*1000-5000*1000
 @return //
 */
- (instancetype)initWithBitrate:(NSNumber*) bitrate WithSessionPreset:(DYCameraEngineSessionPreset) SessionPreset;
/**
 开启相机
 */
- (void)startEngine;

/**
 关闭
 */
- (void)endEngine;
/**
 切换摄像头
 */
- (void)changeCameraPositionAndAutoUseBeautifyWhenPostionFront:(BOOL)isNeed;

/**
 闪光灯开关
 */
- (void)changeFlashingLight;
/**
 美颜开关
 */
- (void)changeBeautyFace:(DYCameraEngineBeautyPreset)beautyPreset;

/**
 美颜程度低
 grind:8.8004 hues:0 saturation:1.0 brightness:1.0886 whiteLeave:1.3341
 */
- (void)changeBeautyFaceLowQuality;

/**
 美颜程度中
 美颜typeTwo grind:4.0 hues:0 saturation:0.8744 brightness:1.1132 whiteLeave:1.4798
 */
- (void)changeBeautyFaceMediumQuality;

/**
 美颜程度高
 美颜TypeThree grind:0 hues:0 saturation:1.1256 brightness:1.1368 whiteLeave:2.1861
 */
- (void)changeBeautyFaceHighestQuality;


/**
 开始录制
 */
- (void)startRecord;


/**
 结束录制
 */
- (void)stopRecordWithCompletionHandler:(void (^)(void))handler;

/**
 回删上一段
 */
- (void) deleteVidoSegment;


/**
 多段视频拍摄完成后导出

 @param handler 结果回调 输出地址，错误码
 */
- (void) exportVideoWithCompletionHandler:(void (^)(NSString* outPutPath, int code))handler;
@end

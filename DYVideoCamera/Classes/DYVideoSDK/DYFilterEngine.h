//
//  DYFilterEngine.h
//  DYVideoSDK
//
//  Created by huyangyang on 2017/11/2.
//  Copyright © 2017年 DY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImage.h>

//didCompletePlayingMovie  NotificationName
@interface DYFilterEngine : NSObject

/**
 编辑页面效果预览图
 */
@property (nonatomic ,strong) GPUImageView *filterView;

/**
 初始化引擎

 @param url 视频的url
 @return 实例化对象
 */
- (instancetype)initWithVideoURL:(NSURL*) url;

// 替换视频URL
- (void)replaceVideoURL:(NSURL * _Nonnull)url;

/**
 开始
 */
- (void)startProcessing;
/**
 结束
 */
- (void)endProcessing;
/**
 重播
 */
- (void)replay;

/**
 原片效果
 */
- (void)resetOriginalFilter;

/**
 改变滤镜效果

 @param fragmentShaderFilePath FragmentShader路径
 */
- (void)changeFilterWithFragmentShaderFromFile:(NSString *)fragmentShaderFilePath;

/**
 改变滤镜效果

 @param LookupImage LookupImage对象
 */
- (void)changeFilterWithLookupImage:(UIImage *)LookupImage;

/**
 改变滤镜效果

 @param className Filter类名
 */
- (void)changeFilterWithFilterClassName:(NSString *)className;


/**
 改变预览视频播放音量

 @param volume 视频播放音量 0 ～ 1.0
 */
- (void)changeEngineVolume:(float)volume;
/**
 滤镜处理

 @param VideoUrl 原视频URL
 @param bitrate 输出视频比特率  建议800*1000-5000*1000
 @param processHandler 进度回调
 @param completionHandler 成功回调（目标文件路径）
 */
- (void)applyFilterToVideoWithInpuVideoURL:(NSURL*)VideoUrl OutPutBitrate:(NSNumber*)bitrate isNeedCancle:(BOOL *)isNeedCancle ProcessHandler:(void (^)(float process))processHandler CompletionHandler:(void (^)(NSString* outPutPath))completionHandler;

/**
 * 视频时长
 */
- (CMTime)videoDuration;

- (GPUImageOutput<GPUImageInput> * _Nullable)currentFilter;

@end

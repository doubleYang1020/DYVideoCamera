//
//  DYVideoProcessEngine.h
//  DYVideoSDK
//
//  Created by huyangyang on 2017/11/1.
//  Copyright © 2017年 DY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <GPUImage/GPUImage.h>
@interface DYVideoProcessEngine : NSObject


/**
 多段视频合并

 @param videosPathArray 视频URLlist
 @param outpath 视频输出路径
 @param handler 结果回调
 */
+ (void)mergeAndExportVideos:(NSArray*)videosPathArray withOutPath:(NSString*)outpath CompletionHandler:(void (^)(int code))handler;


/**
 音乐合成

 @param videoInputURL 原视频地址
 @param musicInputURL 导入音乐地址
 @param musicStartTime 音乐开始时间
 @param originalVolum 原片音量
 @param musicVolum 音乐音量
 @param handler 结果回调（目标文件路径,结果码）
 */
+ (void)mergeVideo:(NSURL*)videoInputURL AndMusic:(NSURL*)musicInputURL AndMusicTimeRange:(CMTime)musicStartTime OriginalVolum:(double)originalVolum MusicVolum:(double)musicVolum   WithCompletionHandler:(void (^)(NSString* outPutPath, int code))handler;


/**
 视频裁剪

 @param videoInputURL 原视频地址
 @param videoStartTime 开始时间
 @param videoDuration 结束时间
 @param handler 结果回调（目标文件路径,结果码）
 */
+(void)croppingVideo:(NSURL*)videoInputURL AndStartTime:(CMTime)videoStartTime AndDuration:(CMTime)videoDuration WithCompletionHandler:(void (^)(NSString* outPutPath, int code))handler;


/**
 滤镜处理

 @param VideoUrl 原视频URL
 @param filter 滤镜filter对象
 @param bitrate bit 输出视频比特率  建议800*1000-5000*1000
 @param processHandler 进度回调
 @param completionHandler 成功回调（目标文件路径,结果码）
 */
+ (void)applyFilterToVideoWithInpuVideoURL:(NSURL*)VideoUrl Filter:(GPUImageOutput<GPUImageInput>*)filter OutPutBitrate:(NSNumber*)bitrate isNeedCancle:(BOOL *)isNeedCancle ProcessHandler:(void (^)(float process))processHandler CompletionHandler:(void (^)(NSString* outPutPath, int code))completionHandler;


+ (UIImage*)applyFilterToImageWithInputImage:(UIImage *)inputImage LookupImage:(UIImage *)lookupImage;

@end

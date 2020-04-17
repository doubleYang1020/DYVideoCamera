//
//  DYVideoProcessEngine.m
//  DYVideoSDK
//
//  Created by huyangyang on 2017/11/1.
//  Copyright © 2017年 DY. All rights reserved.
//

#import "DYVideoProcessEngine.h"
#import "DYGPUImageLookupFilter.h"
#import <AVFoundation/AVFoundation.h>
#import "DYVMConstants+Private.h"


@implementation DYVideoProcessEngine

+(void)mergeAndExportVideos:(NSArray *)videosPathArray withOutPath:(NSString *)outpath CompletionHandler:(void (^)(int))handler{
    if (videosPathArray.count == 0) {
        handler(-1000);
    }
    //音频视频合成体
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    //创建音频通道容器
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    //创建视频通道容器
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime totalDuration = kCMTimeZero;
    for (int i = 0; i < videosPathArray.count; i++) {
        //        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:videosPathArray[i]]];
        NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
        AVAsset* asset = [AVURLAsset URLAssetWithURL:videosPathArray[i] options:options];
        
        
        NSError *errorVideo = nil;
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
        BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetVideoTrack.asset.duration)
                                      ofTrack:assetVideoTrack
                                       atTime:totalDuration
                                        error:&errorVideo];
        
        Log(@"errorVideo:%@%d",errorVideo,bl);
        
        videoTrack.preferredTransform = assetVideoTrack.preferredTransform;
        NSError *erroraudio = nil;
        //获取AVAsset中的音频 或者视频
        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        //向通道内加入音频或者视频
        BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetVideoTrack.asset.duration)
                                      ofTrack:assetAudioTrack
                                       atTime:totalDuration
                                        error:&erroraudio];
        Log(@"erroraudio:%@%d",erroraudio,ba);

        totalDuration = CMTimeAdd(totalDuration, assetVideoTrack.asset.duration);
    }
    NSURL *mergeFileURL = [NSURL fileURLWithPath:outpath];
    
    //视频导出工具
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetPassthrough];
    /*
     exporter.progress
     导出进度
     This property is not key-value observable.
     不支持kvo 监听
     只能用定时器监听了  NStimer
     */
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if (exporter.status != AVAssetExportSessionStatusCompleted) {
//            handler(exporter.error.code);
        }else{
            handler(0);
        }
        
        
    }];
    
}

+(void)mergeVideo:(NSURL *)videoInputURL AndMusic:(NSURL *)musicInputURL AndMusicTimeRange:(CMTime)musicStartTime OriginalVolum:(double)originalVolum MusicVolum:(double)musicVolum WithCompletionHandler:(void (^)(NSString *, int))handler{
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack* videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *musicTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableAudioMix* mutableAudioMix = [AVMutableAudioMix audioMix];
    NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    
    AVAsset* asset = [AVURLAsset URLAssetWithURL:videoInputURL options:options];
    
    AVAssetTrack* assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    NSError *errorVideo = nil;
    BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetVideoTrack.asset.duration)
                                  ofTrack:assetVideoTrack
                                   atTime:kCMTimeZero
                                    error:&errorVideo];
    videoTrack.preferredTransform = assetVideoTrack.preferredTransform;
    Log(@"errorVideo:%@%d",errorVideo,bl);
    
    AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    NSError *erroraudio = nil;
    BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetVideoTrack.asset.duration)
                                  ofTrack:assetAudioTrack
                                   atTime:kCMTimeZero
                                    error:&erroraudio];
    Log(@"erroraudio:%@%d",erroraudio,ba);
    
    AVMutableAudioMixInputParameters* videomixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
    [videomixParameters setVolume:originalVolum atTime:kCMTimeZero];
    
    AVAsset* musicAsset = [AVURLAsset URLAssetWithURL:musicInputURL options:options];
    AVAssetTrack* assetMusicTrack = [[musicAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    NSError *errorMusic = nil;
    
    // TODO:
    //判断音乐时长 是否符合视频长度CMTimeMinimum(musicAsset.duration,asset.duration)
    Log(@"asset.duration%lf",CMTimeGetSeconds(assetVideoTrack.asset.duration));
    Log(@"musicAsset.duration%lf",CMTimeGetSeconds(musicAsset.duration));
    Log(@"CMTimeMinimum%lf",CMTimeGetSeconds(CMTimeMinimum(musicAsset.duration,assetVideoTrack.asset.duration)));
    
    if (CMTimeCompare(musicAsset.duration, assetVideoTrack.asset.duration) == -1) {
        // music 长度小于视频原音频长度
        int timeIndex = 1;
        while ( CMTimeCompare(CMTimeMultiply(musicAsset.duration, timeIndex), assetVideoTrack.asset.duration) == -1) {
            BOOL bm = [musicTrack insertTimeRange:CMTimeRangeMake(musicStartTime,musicAsset.duration)
                                          ofTrack:assetMusicTrack
                                           atTime:CMTimeMultiply(musicAsset.duration, (timeIndex - 1))
                                            error:&errorMusic];
            Log(@"errorMusic:%@%d",errorMusic,bm);
            timeIndex += 1;
        }
        
        ;
        BOOL bm = [musicTrack insertTimeRange:CMTimeRangeMake(musicStartTime,CMTimeSubtract(assetVideoTrack.asset.duration, CMTimeMultiply(musicAsset.duration, (timeIndex - 1))))
                                      ofTrack:assetMusicTrack
                                       atTime:CMTimeMultiply(musicAsset.duration, (timeIndex - 1))
                                        error:&errorMusic];
        Log(@"errorMusic:%@%d",errorMusic,bm);
        
        
    }else{
        BOOL bm = [musicTrack insertTimeRange:CMTimeRangeMake(musicStartTime, assetVideoTrack.asset.duration)
                                      ofTrack:assetMusicTrack
                                       atTime:kCMTimeZero
                                        error:&errorMusic];
        Log(@"errorMusic:%@%d",errorMusic,bm);
    }
    

    
    AVMutableAudioMixInputParameters* musicMixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:musicTrack];
    [musicMixParameters setVolume:musicVolum atTime:kCMTimeZero];
    
    mutableAudioMix.inputParameters = @[videomixParameters,musicMixParameters];
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* datePath = [docsdir stringByAppendingPathComponent:@"DYVideo"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *filePath = [[datePath stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"_mergeMusic.mov"];
    NSURL *mergeMusicFileURL = [NSURL fileURLWithPath:filePath];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = mergeMusicFileURL;
    exporter.audioMix = mutableAudioMix;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if (exporter.status != AVAssetExportSessionStatusCompleted) {
            handler(filePath,exporter.error.code);
        }else{
            handler(filePath,0);
        }
    }];
}

+(void)croppingVideo:(NSURL *)videoInputURL AndStartTime:(CMTime)videoStartTime AndDuration:(CMTime)videoDuration WithCompletionHandler:(void (^)(NSString *, int))handler{
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    AVAsset* asset = [AVURLAsset URLAssetWithURL:videoInputURL options:options];
    NSError *errorVideo = nil;
    AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
    BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(videoStartTime, videoDuration)
                                  ofTrack:assetVideoTrack
                                   atTime:kCMTimeZero
                                    error:&errorVideo];
    videoTrack.preferredTransform = assetVideoTrack.preferredTransform;
    Log(@"errorVideo:%@%d",errorVideo,bl);
    
    
    NSError *erroraudio = nil;
    //获取AVAsset中的音频 或者视频
    AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    //向通道内加入音频或者视频
    BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(videoStartTime, videoDuration)
                                  ofTrack:assetAudioTrack
                                   atTime:kCMTimeZero
                                    error:&erroraudio];
    Log(@"erroraudio:%@%d",erroraudio,ba);
    
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* datePath = [docsdir stringByAppendingPathComponent:@"DYVideo"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *filePath = [[datePath stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"_cropping.mov"];
    NSURL *croppingFileURL = [NSURL fileURLWithPath:filePath];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetPassthrough];

    exporter.outputURL = croppingFileURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if (exporter.status != AVAssetExportSessionStatusCompleted) {
                handler(filePath,exporter.error.code);
        }else{
            handler(filePath,0);
        }
    }];
    
}

+(void)applyFilterToVideoWithInpuVideoURL:(NSURL *)VideoUrl Filter:(GPUImageOutput<GPUImageInput> *)filter OutPutBitrate:(NSNumber *)bitrate isNeedCancle:(BOOL *)isNeedCancle ProcessHandler:(void (^)(float))processHandler CompletionHandler:(void (^)(NSString *, int))completionHandler{
    NSString *home = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* datePath = [home stringByAppendingPathComponent:@"DYVideo"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *filePath = [[datePath stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"_mergeFilter.mp4"];
    NSURL *destURL = [NSURL fileURLWithPath:filePath];
    

    GPUImageMovie *source = [[GPUImageMovie alloc] initWithURL:VideoUrl];
    source.playAtActualSpeed = false;
    AVAsset* asset = [AVAsset assetWithURL:VideoUrl];
    CGSize videoSize = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject.naturalSize;
    
    GPUImageMovieWriter *assetsWriter = [[GPUImageMovieWriter alloc]
                                         initWithMovieURL:destURL
                                         size:videoSize
                                         fileType:AVFileTypeQuickTimeMovie
                                         outputSettings: @{AVVideoCodecKey: AVVideoCodecH264,
                                                           AVVideoWidthKey: [NSNumber numberWithInt:videoSize.width],
                                                           AVVideoHeightKey: [NSNumber numberWithInt:videoSize.height],
                                                           AVVideoCompressionPropertiesKey: @{
                                                                   AVVideoAverageBitRateKey: bitrate
                                                                   }
                                                           }
                                         ];
    
    [source addTarget:filter];
    [filter addTarget:assetsWriter];
    assetsWriter.shouldPassthroughAudio = true;
    
    if ([asset tracksWithMediaType:AVMediaTypeAudio].count > 0) {
        source.audioEncodingTarget = assetsWriter;
    }else{
        source.audioEncodingTarget = nil;
    }
    assetsWriter.transform = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject].preferredTransform;
    [source enableSynchronizedEncodingUsingMovieWriter:assetsWriter];
    [assetsWriter startRecording];
    [source startProcessing];
    
    __weak GPUImageMovieWriter *weakmovieWriter = assetsWriter;
    [assetsWriter setCompletionBlock:^{
        [filter removeTarget:weakmovieWriter];
        [source removeTarget:filter];
        [source cancelProcessing];
        [weakmovieWriter finishRecording];
        completionHandler(filePath,0);
        
    }];
    Log(@"xxxxx");
    NSRunLoop* loop = [NSRunLoop currentRunLoop];
    while (source.progress != 1) {
        if (*isNeedCancle) {
            [assetsWriter cancelRecording];
            [filter removeTarget:weakmovieWriter];
            [source removeTarget:filter];
            [source cancelProcessing];
            break;
        }
        [loop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        processHandler(source.progress);
    }
}

+ (UIImage*)applyFilterToImageWithInputImage:(UIImage *)inputImage LookupImage:(UIImage *)lookupImage
{
    GPUImageOutput<GPUImageInput> *filter = [[DYGPUImageLookupFilter alloc] initWithLookupImage:lookupImage];
    return [filter imageByFilteringImage:inputImage];
}


@end

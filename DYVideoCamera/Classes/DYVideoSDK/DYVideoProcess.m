//
//  DYDYVideoProcess.m
//  KPI_Feb
//
//  Created by  video on 01/03/2018.
//  Copyright © 2018 . All rights reserved.
//

#import "DYVideoProcess.h"

@interface DYDYVideoProcess()

@property (strong, atomic) dispatch_queue_t queue;
@property (strong, atomic) dispatch_queue_t concurrentQueue;

@end

@implementation DYDYVideoProcess

+ (instancetype _Nonnull)sharedInstance {
    static DYDYVideoProcess* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DYDYVideoProcess alloc] init];
        
        dispatch_queue_t queue, concurrentQueue;
        if (@available(iOS 10.0, *)) {
            dispatch_queue_attr_t attributes = dispatch_queue_attr_make_with_autorelease_frequency(dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, -1), DISPATCH_AUTORELEASE_FREQUENCY_WORK_ITEM);
            queue = dispatch_queue_create("me.DY.video.process", attributes);
        } else {
            queue = dispatch_queue_create("me.DY.video.process", DISPATCH_QUEUE_SERIAL);
        }
        concurrentQueue = dispatch_queue_create("me.DY.video.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
        
        [sharedInstance setQueue:queue];
        [sharedInstance setConcurrentQueue:concurrentQueue];
    });
    return sharedInstance;
}

+ (void)applyFilter:(GPUImageOutput<GPUImageInput> * _Nonnull)filter
             source:(GPUImageMovie * _Nonnull)movie
        destination:(NSURL * _Nonnull)destination
     outputSettings:(NSDictionary * _Nonnull)outputSettings
      cancelProcess:(BOOL *)cancel
{
    NSAssert(movie.asset, @"Use - [GPUImageMovie initWithAsset] instead");
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [movie setPlayAtActualSpeed:NO];
    [movie addTarget:filter];
    
    [NSFileManager.defaultManager removeItemAtURL:destination error:nil];
    
    GPUImageMovieWriter *writer = [[GPUImageMovieWriter alloc] 
                                   initWithMovieURL:destination
                                   size:CGSizeMake([outputSettings[AVVideoWidthKey] intValue], [outputSettings[AVVideoHeightKey] intValue])
                                   fileType:AVFileTypeQuickTimeMovie
                                   outputSettings:outputSettings];
    
    
    [writer setShouldPassthroughAudio:YES];
    if ([movie.asset tracksWithMediaType:AVMediaTypeAudio].count > 0) {
        movie.audioEncodingTarget = writer;
    }else{
        movie.audioEncodingTarget = nil;
    }
    [filter addTarget:writer];
    [movie enableSynchronizedEncodingUsingMovieWriter:writer];
    
    [writer setTransform:[[[movie.asset tracksWithMediaType:AVMediaTypeVideo] firstObject] preferredTransform]];
    [writer startRecording];
    [movie startProcessing];
    
    [writer setCompletionBlock:^{
        dispatch_semaphore_signal(semaphore);
        NSLog(@"writer release");
    }];
    
    __weak GPUImageMovie *weakMovie = movie;
    __weak GPUImageMovieWriter *weakMovieWriter = writer;
    dispatch_async([[self sharedInstance] concurrentQueue], ^{
        while (weakMovie != nil && weakMovie.progress != 1.0) {
            NSLog(@"Cancel? %@", *cancel ? @"YES" : @"NO");
            if (*cancel) {
                [weakMovieWriter cancelRecording];
                [weakMovie cancelProcessing];
                [weakMovie removeTarget:filter];
                [filter removeTarget:weakMovieWriter];
                dispatch_semaphore_signal(semaphore);
                break;
            }
            usleep(100000);
        }
        NSLog(@"progress finished");
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [writer finishRecording];
    [filter removeTarget:writer];
    
}

+ (NSDictionary * _Nonnull)videoOutputSettingFromURL:(NSURL * _Nonnull)url bitRate:(NSNumber * _Nonnull)bitRate {
    AVAsset * asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetTrack* videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    NSDictionary *dictionary = @{
                                 AVVideoCodecKey: AVVideoCodecH264,
                                 AVVideoWidthKey: [NSNumber numberWithInt:[videoTrack naturalSize].width],
                                 AVVideoHeightKey: [NSNumber numberWithInt:[videoTrack naturalSize].height],
                                 AVVideoCompressionPropertiesKey: @{ AVVideoAverageBitRateKey: bitRate }
                                 };
    return dictionary;
}

- (void)asyncApplyFilter:(GPUImageOutput<GPUImageInput> * _Nonnull)filter
                  source:(NSURL * _Nonnull)source
             destination:(NSURL * _Nonnull)destination
          outputSettings:(NSDictionary * _Nonnull)outputSettings
           cancelProcess:(BOOL * _Nullable)cancel
                progress:(Progress _Nullable)progress
              completion:(Completion _Nullable)completion
{
    __weak typeof(self) this = self;
    dispatch_async(this.queue, ^{
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:source options:nil];
        GPUImageMovie *movie = [[GPUImageMovie alloc] initWithAsset:asset];
        if (progress) {
            __weak GPUImageMovie *weakMovie = movie;
            dispatch_async(this.concurrentQueue, ^{
                while (weakMovie != nil && weakMovie.progress != 1.0 && !*cancel) {
                    if (!isnan(weakMovie.progress))
                        progress(weakMovie.progress);
                    usleep(100000);
                }
                progress(1.0);
                NSLog(@"progress finished");
            });
        }
        
        [DYDYVideoProcess applyFilter:filter source:movie destination:destination outputSettings:outputSettings cancelProcess:cancel];
        if (!*cancel)
            completion();
        
        NSLog(@"Apply filter process finished");
    });
}

@end

//
//  KSYFileDownloader.h
//  KSYHTTPCache
//
//  Created by devcdl on 2017/7/26.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPCacheDefines.h"

/** 视频下载器，一个视频文件对应一个下载器，用于开播前预先缓存视频 **/

@interface KSYFileDownloader : NSObject

/**
 * 初始化下载器
 * @param urlString      视频原始地址（未经过代理处理的）
 * @param progressBlock  视频下载进度变化时处理的事件
 */
- (instancetype)initWithUrlString:(NSString *)urlString
                    progressBlock:(void(^)(float progress))progressBlock;

- (void)startDownload;

- (void)pauseDownload;

- (NSString *)urlString;

- (KSYFileDownloaderState)downloaderState;

/**
 * 播放地址为url的视频时，调用此方法
 */
+ (void)handleOpenPlayerForUrl:(NSString *)url
                 progressBlock:(void(^)(float))progressBlock;

/**
 * 停止播放地址为url的视频时，调用此方法
 */
+ (void)handleClosePlayerForUrl:(NSString *)url
                  progressBlock:(void(^)(float))progressBlock;

@end

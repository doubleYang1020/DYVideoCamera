//
//  KSYHTTPProxyService.h
//  KSYHTTPCache
//
//  Created by sujia on 2016/11/9.
//  Copyright © 2016年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KSYHTTPProxyService : NSObject

/**
 * 设置是否忽略http url参数，YES时对于参数不用的URL作为同一个文件处理，为NO时当做不同文件处理
 * @since Available in KSYHTTPCache 1.2.2 and later.
 */
@property(nonatomic, assign)BOOL ignoreURLParamter;

/**
 * 获取版本号
 */
+(NSString*)getVersion;

/**
 * 获取唯一示例
 */
+ (KSYHTTPProxyService*)sharedInstance;

/**
 * 设置缓存区位置
 */
-(void)setCacheRoot:(NSString *)cacheRoot;

/**
 * 查询缓存区位置
 */
-(NSString*)cacheRoot;


/**
 * 查询当前缓存策略，0代表限制缓存区总大小，1代表限制缓存区文件个数
 */
-(NSInteger)getCacheStrategy;

/**
 * 设置缓存区文件总大小限制
 */
-(void)setMaxCacheSizeLimited:(long long)maxCacheSize;

/**
 * 查询缓存区最大大小
 */
-(long long)maxCacheSize;

/**
 * 设置缓存区文件总个数限制
 */
-(void)setMaxFilesCountLimited:(NSInteger)maxFilesCount;

/**
 * 查询缓存区最大文件个数
 */
-(NSInteger)maxFilesCount;

/**
 * 设置单个文件大小限制，超过该大小的文件将不被缓存。
 * 默认大小为500M
 */
-(void)setMaxSingleFileSize:(long long)maxSingleFileSize;

/**
 * 设置单个文件大小限制，超过该大小的文件将不被缓存。
 * 默认大小为500M
 */
-(void)setDisableCache:(BOOL)disableCache;

/**
 * 启动server
 */
- (void)startServer;

/**
 * 关闭server
 */
- (void)stopServer;


/**
 * 查询server是否在运行状态
 */
- (BOOL)isRunning;


/**
 * 获取代理后的播放地址
 */
-(NSString*)getProxyUrl:(NSString*)url;

/**
 * 获取原始播放地址
 */
- (NSString *)getOriginalUrl:(NSString *)url;

/**
 * 获取代理后的播放地址
 */
-(NSString*)getProxyUrl:(NSString*)url newCache:(BOOL)newCache;

/**
 * 删除缓存区所以文件
 */
-(void)deleteAllCachesWithError:(NSError**)error;

/**
 * 删除某个url对应的缓存文件
 */
-(void)deleteCacheForUrl:(NSURL*)url error:(NSError**)error;

/**
 * 查询某个url缓存是否完成
 */
-(BOOL)isCacheCompleteForUrl:(NSURL*)url;

/**
 * 获得缓存已完成文件列表
 * 返回的数组元素为NSDictionay, 包含为url和文件路径
 */
-(NSArray*)getAllCachedFileListWithError:(NSError**)errors;

/**
 * 获得缓存未完成文件列表
 * 返回的数组元素为NSDictionay, 包含url、文件路径、content length、cache fragments
 */
-(NSArray*)getAllCachingFileListWithError:(NSError**)error;

/**
 * 获得url对应缓存文件的路径
 */
-(NSString*)getCachedFilePathForUrl:(NSURL *)url;

/**
 * 获得url对应缓存未完成url对应的cache fragment
 */
-(NSArray*)getCacheFragmentForUrl:(NSURL *)url error:(NSError **)error;

/**
 发送http请求时需要header带上的字段
 必须 key:value 都是NSString类型
 @param headers 请求头带的字段
 */
-(void)setHttpHeaders:(NSDictionary<NSString *,NSString *> *)headers;


@end

#define KSYHTTPCACHE_VER 1.2.2
#define KSYHTTPCACHE_ID  39840a2b3d9af193aa4f6c591f4896f5362aa15b

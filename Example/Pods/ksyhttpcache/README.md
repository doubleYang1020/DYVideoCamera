# 金山云iOS HTTPCache SDK


[![Apps Using](https://img.shields.io/cocoapods/at/ksyhttpcache.svg?label=Apps%20Using%20ksyhttpcache&colorB=28B9FE)](http://cocoapods.org/pods/ksyhttpcache)[![Downloads](https://img.shields.io/cocoapods/dt/ksyhttpcache.svg?label=Total%20Downloads%20ksyhttpcache&colorB=28B9FE)](http://cocoapods.org/pods/ksyhttpcache)


[![CocoaPods version](https://img.shields.io/cocoapods/v/ksyhttpcache.svg)](https://cocoapods.org/pods/ksyhttpcache)
[![CocoaPods platform](https://img.shields.io/cocoapods/p/ksyhttpcache.svg)](https://cocoapods.org/pods/ksyhttpcache)

<pre>Source Type:<b> Binary SDK</b>
Charge Type:<b> free of charge</b></pre>

金山云iOS平台http缓存SDK，可方便地与播放器集成，实现http视频边播放边下载（缓存）功能。ksyun http cache sdk for ios platform, it's easy to integrated with media players to provide caching capability when watching http videos.

## 1. 产品概述
金山云iOS HTTPCache SDK可以方便地和播放器进行集成，提供对HTTP视频边播放缓存的功能，缓存完成的内容可以离线工作。

KSY HTTPCache与播放器及视频服务器的关系如下图：
![](https://github.com/sujia/image_foder/blob/master/ksy_http_cache.png)

KSY HTTPCache相当于本地的代理服务，使用KSY HTTPCache后，播放器不直接请求视频服务器，而是向KSY HTTPCache请求数据。KSY HTTPCache在代理HTTP请求的同时，缓存视频数据到本地。

### 1.1 关于热更新

金山云SDK保证，提供的[HTTP Cache SDK](https://github.com/ksvc/ksyhttpcache_ios)未使用热更新技术，例如：RN(ReactNative)、weex、JSPatch等，请放心使用。

### 1.2 关于费用
金山云SDK保证，提供的[HTTP Cache SDK](https://github.com/ksvc/ksyhttpcache_ios)可以用于商业应用，不会收取任何SDK使用费用。

### 1.3 License
详情请见[License](LICENSE)文件。

## 2.功能说明
它可以很方便的和播放器进行集成，提供以下功能：
1. http点播视频边缓存边播放，且播放器可从通过回调得到缓存的进度以及错误码

2. 缓存完成的视频，再次点播时可以离线播放，不再请求视频    
获取代理url方式（newCache参数一定要置为NO）：[[KSYHTTPProxyService sharedInstance] getProxyUrl:@"url.mp4" newCache:NO]];

3. 查询缓存已完成的文件列表， 缓存未完成的文件列表

4. 清除缓存（清除所有缓存，或删除某个url缓存）
      
5. 提供两种缓存策略供选择（限制缓存区总大小或者限制缓存文件总个数)

6. 提供预缓存接口KSYFileDownloader （v1.2.1）


## 3.下载和使用
### 3.1 此demo的编译和运行  
1. 使用git下载源码或者从release页面下载zipg格式压缩包后解码  
2. 打开终端，进入demo目录  
3. 执行`pod install`命令  
4. 成功后使用xcode打开新生成的KSYHTTPCacheDemo.xcworkspace工程文件即可编译和运行  

### 3.2 SDK的下载和使用  
#### 3.2.1 下载SDK
本SDK依赖cocopads中的CocoaAsyncSocket，CocoaLumberjack两个库，建议使用pod的方式下载和使用。  
在Podfile文件中添加以下语句，执行pod install之后即可将sdk添加入工程  
`pod 'ksyhttpcache'`  

#### 3.2.2 使用SDK
1. KSYHTTPProxyService类实现了本地HTTP代理，一般在appDelegate中将其启动即可  
```objectivec
#import <KSYHTTPCache/KSYHTTPProxyService.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[KSYHTTPProxyService sharedInstance] startServer];
    return YES;
}

```

2. 使用[getProxyUrl](https://ksvc.github.io/ksyhttpcache_ios/doc/html/Classes/KSYHTTPProxyService.html#//api/name/getProxyUrl:)方法获取原始URL经过本地HTTP代理后的URL，之后将代理URL传递给播放器即可实现在播放的同时将文件cache到本地    
```objectivec
//get proxy url from ksyhttpcache
NSString *proxyUrl = [[KSYHTTPProxyService sharedInstance] getProxyUrl:@"http://maichang.kssws.ks-cdn.com/upload20150716161913.mp4"];
    
//init player with proxy url
KSYMoviePlayerController *player = [[KSYMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:proxyUrl]];

//play the video
[player prepareToPlay];
```


3. 状态监听
   
   KSYHTTPCache发生错误时的发送CacheErrorNotification通知

   ```objectivec
   CacheErrorNotification
   ```
   
   KSYHTTPCache缓存进度发送变化时发送CacheStatusNotification通知

   ```objectivec
   CacheStatusNotification
   ```
   
   注册notification监听
   ```objectivec
   [[NSNotificationCenter defaultCenter] addObserver:self 
               selector:@selector(mediaCacheDidChanged:)
               name:CacheStatusNotification 
               object:nil];
   ```
   去掉notification监听
   ```objectivec
   [[NSNotificationCenter defaultCenter] removeObserver:self
                name:CacheStatusNotification
                object:nil];
    ```

使用以上方法，proxy将采用默认配置。可采用如下方法自定义配置(需在startServer前设置)：  

设置缓存区位置  
   ```objectivec
  (void)setCacheRoot:(NSString *)cacheRoot
   ```

缓存区大小限制策略（文件个数限制、文件总大小限制)，目前这两种策略只能二选一，且策略在每次播放完成或者退出播放时生效。  

   ```objectivec
  -(void)setMaxCacheSizeLimited:(long long)maxCacheSize;
   ```
   
使用限制文件总个数的策略  

   ```objectivec
   -(void)setMaxFilesCountLimited:(NSInteger)maxFilesCount;
   ```
## 4.其他接口说明


对于http flv直播，如果播放器通过接口getProxyUrl( ur）获得播放地址，播放行为是：首次播放，边播放边缓存；以后播放相同url，则是回看缓存好的视频。
而如果播放器通过getProxyUrl(url, newCache)获得播放地址，播放行为是：newCache参数为true，无论是否有url对应的缓存内容，都是播放并缓存新的直播内容。newCache为false，如果有url对应的缓存内容（命中缓存），播放时回看已缓存的直播内容；没有命中的缓存视频（未命中缓存），则播放并缓存新的直播内容。

```objectivec
(NSString*)getProxyUrl:(NSString*)url newCache:(BOOL)newCache;
```
```objectivec
(NSString*)getProxyUrl:(NSString*)url;
```
启动server
```objectivec
(void)startServer;
```
关闭server
```objectivec
(void)stopServer;
```
查询server是否在运行状态
```objectivec
(BOOL)isRunning;
```
删除缓存区所以文件
```objectivec
(void)deleteAllCachesWithError:(NSError**)error;
```
删除某个url对应的缓存文件
```objectivec
(void)deleteCacheForUrl:(NSURL*)url error:(NSError**)error;
```
 查询某个url缓存是否完成
```objectivec
-(BOOL)isCacheCompleteForUrl:(NSURL*)url;
```
获得缓存已完成文件列表
```objectivec
-(NSArray*)getAllCachedFileListWithError:(NSError**)errors;
```
获得缓存未完成文件列表
```objectivec
-(NSArray*)getAllCachingFileListWithError:(NSError**)error;
```
获得url对应缓存文件的路径
```objectivec
-(NSString*)getCachedFilePathForUrl:(NSURL *)url;
```
获得url对应缓存未完成url对应的cache fragment
```objectivec
-(NSArray*)getCacheFragmentForUrl:(NSURL *)url error:(NSError **)error;
```
查询缓存区位置
```objectivec
-(NSString*)cacheRoot;
```

获得缓存区路径

## 5.API接口文档
API接口文档[在线版](https://ksvc.github.io/ksyhttpcache_ios/doc/html/index.html)  

## 6.其他文档
请见[wiki](https://github.com/ksvc/ksyhttpcache_ios/wiki)

## 7.反馈与建议
- 主页：[金山云](http://www.ksyun.com/)
- 邮箱：<zengfanping@kingsoft.com>
* QQ讨论群：
    * 574179720 [视频云技术交流群]
    * 621137661 [视频云iOS技术交流]
    * 以上两个加一个QQ群即可
- Issues:https://github.com/ksvc/ksyhttpcache_ios/issues

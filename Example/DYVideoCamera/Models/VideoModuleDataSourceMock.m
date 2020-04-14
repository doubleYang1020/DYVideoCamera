//
//  VideoModuleDataSource.m
//  RelaVideoContainer
//
//  Created by hirochin on 21/11/2017.
//  Copyright © 2017 thel. All rights reserved.
//

#import "VideoModuleDataSourceMock.h"
#import "UIAlertController+Window.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MusicCategory.h"
#import "MusicEntity.h"
#import "FilterEntity.h"
#import <PLPlayerKit/PLPlayerKit.h>


@implementation VideoModuleDataSourceMock

- (NSArray<id<DYMusicCategory>> * _Nonnull)musicCategorys {
    MusicCategory* musicItemNew = [[MusicCategory alloc] initWithImageNormal:[UIImage imageNamed:@"icNew"] andImageSelected:[UIImage imageNamed:@"icNewSelected"] AndTitle:@"最新" AndIdx:@"0"];
    MusicCategory* musicItemHot = [[MusicCategory alloc] initWithImageNormal:[UIImage imageNamed:@"icHot"] andImageSelected:[UIImage imageNamed:@"icHotSelected"] AndTitle:@"热门" AndIdx:@"1"];
    MusicCategory* musicItemLove = [[MusicCategory alloc] initWithImageNormal:[UIImage imageNamed:@"icLove"] andImageSelected:[UIImage imageNamed:@"icLoveSelected"] AndTitle:@"浪漫" AndIdx:@"2"];
    MusicCategory* musicItemQuiet = [[MusicCategory alloc] initWithImageNormal:[UIImage imageNamed:@"icQuiet"] andImageSelected:[UIImage imageNamed:@"icQuietSelected"] AndTitle:@"安静" AndIdx:@"3"];
    MusicCategory* musicItemClassical = [[MusicCategory alloc] initWithImageNormal:[UIImage imageNamed:@"icClassical"] andImageSelected:[UIImage imageNamed:@"icClassicalSelected"] AndTitle:@"怀旧" AndIdx:@"4"];
    MusicCategory* musicItemSad = [[MusicCategory alloc] initWithImageNormal:[UIImage imageNamed:@"icSad"] andImageSelected:[UIImage imageNamed:@"icSadSelected"] AndTitle:@"忧郁" AndIdx:@"5"];
    MusicCategory* musicItemExciting = [[MusicCategory alloc] initWithImageNormal:[UIImage imageNamed:@"icExciting"] andImageSelected:[UIImage imageNamed:@"icExcitingSelected"] AndTitle:@"动感" AndIdx:@"6"];
    MusicCategory* musicItemHappy = [[MusicCategory alloc] initWithImageNormal:[UIImage imageNamed:@"icHappy"] andImageSelected:[UIImage imageNamed:@"icHappySelected"] AndTitle:@"欢乐" AndIdx:@"7"];
    MusicCategory* musicItemMovie = [[MusicCategory alloc] initWithImageNormal:[UIImage imageNamed:@"icMovie"] andImageSelected:[UIImage imageNamed:@"icMovieSelected"] AndTitle:@"电影" AndIdx:@"8"];
    
    return @[
             musicItemNew,
             musicItemHot,
             musicItemLove,
             musicItemLove,
             musicItemQuiet,
             musicItemClassical,
             musicItemSad,
             musicItemExciting,
             musicItemHappy,
             musicItemMovie
             ];
}

- (void)musicFetchWithCategory:(id<DYMusicCategory> _Nonnull)category byPage:(NSUInteger)page callback:(DYMusicCallback _Nonnull)callback {
    NSArray *data = @[@{
                          @"musicId": @57,
                          @"name": @"夏天的风",
                          @"singer": @"火羊瞌睡了",
                          @"musicHours": @151,
                          @"url": @"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/hackton/ocr/music/%E7%81%AB%E7%BE%8A%E7%9E%8C%E7%9D%A1%E4%BA%86%20-%20%E5%A4%8F%E5%A4%A9%E7%9A%84%E9%A3%8E%EF%BC%88%E6%8A%96%E9%9F%B3%E5%BC%B9%E5%94%B1%E7%89%88%EF%BC%89%EF%BC%88%E7%BF%BB%E8%87%AA%20%E6%B8%A9%E5%B2%9A%EF%BC%89.mp3",
                          @"categoryName": @"怀旧",
                          @"collectStatus": @0
                          }, @{
                          @"musicId": @54,
                          @"name": @"MOM",
                          @"singer": @"蜡笔小新",
                          @"musicHours": @245,
                          @"url": @"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/hackton/ocr/music/%E4%BD%A0%E7%9A%84%E4%BA%8C%E6%99%BAbb%20-%20MOM%EF%BC%88%E6%8A%96%E9%9F%B3%E7%89%88%EF%BC%89%EF%BC%88%E7%BF%BB%E8%87%AA%20%E8%9C%A1%E7%AC%94%E5%B0%8F%E5%BF%83%EF%BC%89.mp3",
                          @"categoryName": @"欢乐",
                          @"collectStatus": @0
                          }, @{
                          @"musicId": @53,
                          @"name": @"游京",
                          @"singer": @"海伦",
                          @"musicHours": @213,
                          @"url": @"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/hackton/ocr/music/DJ%E6%8A%96%E9%9F%B3%E7%83%AD%E6%AD%8C%20-%20%E6%B8%B8%E4%BA%AC%EF%BC%88%E6%8A%96%E9%9F%B3%E7%89%88%EF%BC%89%EF%BC%88%E7%BF%BB%E8%87%AA%20%E6%B5%B7%E4%BC%A6%EF%BC%89.mp3",
                          @"categoryName": @"欢乐",
                          @"collectStatus": @0
                          }, @{
                          @"musicId": @52,
                          @"name": @"爱得太迟",
                          @"singer": @"古巨基",
                          @"musicHours": @249,
                          @"url": @"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/hackton/ocr/music/DJ%E6%8A%96%E9%9F%B3%E7%83%AD%E6%AD%8C%20-%20%E5%8F%A4%E5%B7%A8%E5%9F%BA-%E7%88%B1%E5%BE%97%E5%A4%AA%E8%BF%9F%EF%BC%88%E6%8A%96%E9%9F%B3%E7%89%88%EF%BC%89%EF%BC%88DJ%E6%8A%96%E9%9F%B3%E7%83%AD%E6%AD%8C%20remix%EF%BC%89.mp3.tmp.mp3",
                          @"categoryName": @"欢乐",
                          @"collectStatus": @0
                          }, @{
                          @"musicId": @30,
                          @"name": @"今晚打老虎版",
                          @"singer": @"arsonist",
                          @"musicHours": @262,
                          @"url": @"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/hackton/ocr/music/%E6%8A%96%E9%9F%B3%E7%83%AD%E6%AD%8CDJ%20-%20UUU%EF%BC%88%E4%BB%8A%E6%99%9A%E6%89%93%E8%80%81%E8%99%8E%E7%89%88%EF%BC%89%EF%BC%88%E7%BF%BB%E8%87%AA%20%E6%BD%98%E7%8E%AE%E6%9F%8F%EF%BC%89.mp3",
                          @"categoryName": @"忧郁",
                          @"collectStatus": @0
                          }, @{
                          @"musicId": @22,
                          @"name": @"Bleeding Love",
                          @"singer": @"Leona Lewis",
                          @"musicHours": @265,
                          @"url": @"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/hackton/ocr/music/%E6%8A%96%E9%9F%B3%E7%83%AD%E6%AD%8CDJ%20-%20Bleeding%20Love%20(%E6%8A%96%E9%9F%B3DJ%E7%89%88)%20(%E7%BF%BB%E8%87%AA%20Leona%20Lewis).mp3",
                          @"categoryName": @"忧郁",
                          @"collectStatus": @0
                          }, @{
                          @"musicId": @19,
                          @"name": @"山楂树之恋",
                          @"singer": @"程佳佳",
                          @"musicHours": @318,
                          @"url": @"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/hackton/ocr/music/%E6%8A%96%E9%9F%B3%E7%83%AD%E6%AD%8CDJ%20-%20%E5%B1%B1%E6%A5%82%E6%A0%91%E4%B9%8B%E6%81%8B%20(%E6%8A%96%E9%9F%B3dj%E7%89%88)%20(%E7%BF%BB%E8%87%AA%20%E7%A8%8B%E4%BD%B3%E4%BD%B3).mp3",
                          @"categoryName": @"忧郁",
                          @"collectStatus": @0
                          }, @{
                          @"musicId": @16,
                          @"name": @"KO KO BOP",
                          @"singer": @"EXO",
                          @"musicHours": @197,
                          @"url": @"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/hackton/ocr/music/%E6%8A%96%E9%9F%B3%E7%83%AD%E6%AD%8CDJ%20-%20KO%20KO%20BOP%EF%BC%88%E6%8A%96%E9%9F%B3%E7%89%88%EF%BC%89%EF%BC%88%E7%BF%BB%E8%87%AA%20EXO%EF%BC%89.mp3",
                          @"categoryName": @"安静",
                          @"collectStatus": @0
                          }, @{
                          @"musicId": @10,
                          @"name": @"月半小夜曲",
                          @"singer": @"陈慧娴",
                          @"musicHours": @225,
                          @"url": @"https://webfs.yun.kugou.com/202004110025/bf8de427dac55e89ab142d986136b750/G159/M05/1E/1B/3w0DAFy3CKOAL0BIAB6wf8YzF9k950.mp3",
                          @"categoryName": @"怀旧",
                          @"collectStatus": @0
                          }, @{
                          @"musicId": @3,
                          @"name": @"夏天的风",
                          @"singer": @"赵航",
                          @"musicHours": @161,
                          @"url": @"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/hackton/ocr/music/%E8%B5%B5%E8%88%AAaa%20-%20%E5%A4%8F%E5%A4%A9%E7%9A%84%E9%A3%8E%EF%BC%88%E6%8A%96%E9%9F%B3%E7%94%B7%E7%89%88%EF%BC%89%EF%BC%88%E7%BF%BB%E8%87%AA%20%E6%B8%A9%E5%B2%9A%EF%BC%89.mp3",
                          @"categoryName": @"动感",
                          @"collectStatus": @0
                          }, @{
                          @"musicId": @2,
                          @"name": @"王妃",
                          @"singer": @"萧敬腾",
                          @"musicHours": @193,
                          @"url": @"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/hackton/ocr/music/DJ%E6%8A%96%E9%9F%B3%E7%83%AD%E6%AD%8C%20-%20%E7%8E%8B%E5%A6%83%EF%BC%88%E6%8A%96%E9%9F%B3%E7%89%88%EF%BC%89%EF%BC%88%E7%BF%BB%E8%87%AA%20%E8%90%A7%E6%95%AC%E8%85%BE%EF%BC%89.mp3",
                          @"categoryName": @"动感",
                          @"collectStatus": @0
                          }, @{
                          @"musicId": @1,
                          @"name": @"关键词",
                          @"singer": @"不称职歌手",
                          @"musicHours": @213,
                          @"url": @"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/hackton/ocr/music/%E4%B8%8D%E7%A7%B0%E8%81%8C%E6%AD%8C%E6%89%8B%20-%20%E5%85%B3%E9%94%AE%E8%AF%8D%20(%E7%BF%BB%E8%87%AA%20%E6%9E%97%E4%BF%8A%E6%9D%B0).mp3",
                          @"categoryName": @"动感",
                          @"collectStatus": @0
                          }];
    if (page <= 1) {
        callback([MusicEntity musicsFromArray:data]);
    }
    else {
        callback(@[]);
    }
}

- (NSString *)getLocalizedStringForKey:(NSString *)key {
    if ([key isEqualToString:@"Cancel"])
        return @"取消";
    else if ([key isEqualToString:@"retouch"])
        return @"美颜";
    else
        return key;
}

- (NSArray<id<DYFilterEntity>> * _Nonnull)availableFilters {
    return @[
             [[FilterEntity alloc] initWithImage:nil title:@"原片"],
             [[FilterEntity alloc] initWithImage:[UIImage imageNamed:@"日系清新-红"] title:@"R1"],
             [[FilterEntity alloc] initWithImage:[UIImage imageNamed:@"日系清新-蓝"] title:@"R2"],
             [[FilterEntity alloc] initWithImage:[UIImage imageNamed:@"日系清新-绿"] title:@"R3"],
             [[FilterEntity alloc] initWithImage:[UIImage imageNamed:@"filter_1.3.2清新"] title:@"S1"],
             [[FilterEntity alloc] initWithImage:[UIImage imageNamed:@"filter_1.3.4粉红"] title:@"S2"],
             [[FilterEntity alloc] initWithImage:[UIImage imageNamed:@"filter_1.3.5低饱和"] title:@"S3"],
             [[FilterEntity alloc] initWithImage:[UIImage imageNamed:@"FX10"] title:@"S4"]
             ];
}

+ (void)showToastWithText:(NSString * _Nonnull)text dismissAfter:(float)duration {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[self theMostTopView] animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = text;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:[self theMostTopView] animated:YES];
        });
    });
}

+ (DYProgressCallback _Nonnull)showProgressViewWithText:(NSString * _Nullable)text {

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[self theMostTopView] animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = @"Loading";
    return ^(float progress) {
        hud.progress = progress;
        hud.label.text = [NSString stringWithFormat:@"%02.2f", progress];
    };
    
}
+(void)showHUDForIndeterminateWithText:(NSString *)text{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[self theMostTopView] animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = text;
    });
}

+ (void)hideProgressView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:[self theMostTopView] animated:YES];
    });
}

+ (void)showAlertControllerWithTitle:(NSString * _Nullable)title
                             message:(NSString * _Nullable)message
                      preferredStyle:(UIAlertControllerStyle)preferredStyle
                             actions:(NSArray<UIAlertAction *> * _Nullable)actions
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    [actions enumerateObjectsUsingBlock:^(UIAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [alertController addAction:obj];
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[alertController presentedViewController] dismissViewControllerAnimated:alertController completion:nil];
    }]];
    
    [alertController show];
}

+ (NSNumber * _Nonnull)bitRate {
    return @2500000;
}

+ (DYCameraEngineBeautyPreset)beautyPreset{
    return BeautyFaceLowQuality;
}

+(DYCameraEngineSessionPreset)sessionPreset{
    return CameraEngineSessionPreset960x540;
}


- (void)readyWithCover:(UIImage * _Nonnull)cover videoUrl:(NSURL * _Nonnull)videoUrl {
    NSLog(@"readyWithCover: image -> %@ \t videoUrl -> %@", cover, videoUrl);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.holder dismissViewControllerAnimated:YES completion:nil];
    });
}


+ (CMTimeRange)videoTimeRange {
    int scale = 100;
    return CMTimeRangeMake(CMTimeMake(5 * scale, scale), CMTimeMake(60 * scale, scale));
}


+ (UIView *)theMostTopView {
    return [[[UIApplication sharedApplication] delegate] window];
}

//- (NSObject* _Nonnull)initKSYMediaPlayerWithUrl:(NSURL *_Nonnull)musicUrl;
- (NSObject *)initKSYMediaPlayerWithUrl:(NSURL *)musicUrl{
    
    PLPlayerOption *option = [PLPlayerOption defaultOption];

    // 更改需要修改的 option 属性键所对应的值
    [option setOptionValue:@15 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
    [option setOptionValue:@2000 forKey:PLPlayerOptionKeyMaxL1BufferDuration];
    [option setOptionValue:@1000 forKey:PLPlayerOptionKeyMaxL2BufferDuration];
    [option setOptionValue:@(NO) forKey:PLPlayerOptionKeyVideoToolbox];
    [option setOptionValue:@(kPLLogInfo) forKey:PLPlayerOptionKeyLogLevel];
    [option setOptionValue:@(kPLPLAY_FORMAT_MP3) forKey:PLPlayerOptionKeyVideoPreferFormat];
    
    PLPlayer *player = [PLPlayer playerWithURL:musicUrl option:option];
    player.loopPlay = YES;
    [player play];
    return (NSObject *)player;
}
- (float ) getCurrenPlayerProgress:(NSObject*_Nonnull)player{
//    KSYMoviePlayerController* musicPlayer =  (KSYMoviePlayerController*)player;
//    float progress = (musicPlayer.currentPlaybackTime)/(musicPlayer.duration);
//    return progress;
    PLPlayer* musicPlayer =  (PLPlayer*)player;
    float progress = (CMTimeGetSeconds(musicPlayer.currentTime))/(CMTimeGetSeconds(musicPlayer.totalDuration));
    return progress;
}
- (void) KSYMediaPlayersetUrl:(NSURL *_Nonnull)musicUrl andPlayer:(NSObject * _Nonnull)player
{
    PLPlayer* musicPlayer =  (PLPlayer*)player;
    [musicPlayer playWithURL:musicUrl];
//    KSYMoviePlayerController* musicPlayer =  (KSYMoviePlayerController*)player;
//    [musicPlayer reset:false];
//    [musicPlayer setUrl:musicUrl];
//    [musicPlayer prepareToPlay];
//    [musicPlayer play];
}
- (void) releasePlayer:(NSObject*_Nonnull)player{
    PLPlayer* musicPlayer =  (PLPlayer*)player;
    [musicPlayer stop];
//    KSYMoviePlayerController* musicPlayer =  (KSYMoviePlayerController*)player;
//    [musicPlayer stop];
}
- (void) musicPlayer_play:(NSObject*_Nonnull)player{
    PLPlayer* musicPlayer =  (PLPlayer*)player;
    [musicPlayer play];
//     KSYMoviePlayerController* musicPlayer =  (KSYMoviePlayerController*)player;
//    [musicPlayer play];
}
- (void) musicPlayer_pause:(NSObject*_Nonnull)player{
    PLPlayer* musicPlayer =  (PLPlayer*)player;
    [musicPlayer pause];
//    KSYMoviePlayerController* musicPlayer =  (KSYMoviePlayerController*)player;
//    [musicPlayer pause];
}

@end



//
//  DYVideoModuleDataSource.h
//  DYVideoModule
//

#import <Foundation/Foundation.h>
//@import CoreMedia;

#import "DYMusicCategory.h"
#import "DYMusicEntity.h"
#import "DYFilterEntity.h"
#import "DYVideoSDK.h"
typedef void (^DYMusicCallback)(NSArray<id<DYMusicEntity>> * _Nullable);
typedef void (^DYProgressCallback)(float);

@protocol DYVideoModuleDataSource <NSObject>

- (void)musicFetchWithCategory:(id<DYMusicCategory> _Nonnull)category byPage:(NSUInteger)page callback:(DYMusicCallback _Nonnull)callback;

- (NSArray<id<DYMusicCategory>> * _Nonnull)musicCategorys;

- (NSArray<id<DYFilterEntity>> * _Nonnull)availableFilters;

- (NSString * _Nonnull)getLocalizedStringForKey:(NSString * _Nonnull)key;

- (void)readyWithCover:(UIImage * _Nonnull)cover videoUrl:(NSURL * _Nonnull)videoUrl;

+ (void)showToastWithText:(NSString * _Nonnull)text dismissAfter:(float)duration;

+ (DYProgressCallback _Nonnull)showProgressViewWithText:(NSString * _Nullable)text;

+ (void)showHUDForIndeterminateWithText:(NSString * _Nullable)text;

+ (void)hideProgressView;

+ (void)showAlertControllerWithTitle:(NSString * _Nullable)Title
                             message:(NSString * _Nullable)message
                      preferredStyle:(UIAlertControllerStyle)preferredStyle
                             actions:(NSArray<UIAlertAction *> * _Nullable)actions;

+ (NSNumber * _Nonnull)bitRate;
+ (DYCameraEngineBeautyPreset)beautyPreset;
+ (DYCameraEngineSessionPreset) sessionPreset;
+ (CMTimeRange)videoTimeRange;

- (NSObject* _Nonnull)initKSYMediaPlayerWithUrl:(NSURL *_Nonnull)musicUrl;
- (float ) getCurrenPlayerProgress:(NSObject*_Nonnull)player;
- (void) KSYMediaPlayersetUrl:(NSURL *_Nonnull)musicUrl andPlayer:(NSObject*_Nonnull)player;
- (void) releasePlayer:(NSObject*_Nonnull)player;
- (void) musicPlayer_play:(NSObject*_Nonnull)player;
- (void) musicPlayer_pause:(NSObject*_Nonnull)player;
//pause play


@end

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import CoreMedia;

typedef enum : NSUInteger {
    DYAssetModelMediaTypePhoto = 0,
    DYAssetModelMediaTypeLivePhoto,
    DYAssetModelMediaTypePhotoGif,
    DYAssetModelMediaTypeVideo,
    DYAssetModelMediaTypeAudio
} DYAssetModelMediaType;

@class PHAsset;
@interface DYAssetModel : NSObject

@property (nonatomic, strong) id asset;             ///< PHAsset or ALAsset
@property (nonatomic, assign) BOOL isSelected;      ///< The select status of a photo, default is No
@property (nonatomic, assign) DYAssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;

/// Init a photo dataModel With a asset
/// 用一个PHAsset/ALAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(id)asset type:(DYAssetModelMediaType)type;
+ (instancetype)modelWithAsset:(id)asset type:(DYAssetModelMediaType)type timeLength:(NSString *)timeLength;

- (CMTime)duration;

@end


@class PHFetchResult;
@interface TZAlbumModel : NSObject

@property (nonatomic, strong) NSString *name;        ///< The album name
@property (nonatomic, assign) NSInteger count;       ///< Count of photos the album contain
@property (nonatomic, strong) id result;             ///< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>

@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *selectedModels;
@property (nonatomic, assign) NSUInteger selectedCount;

@property (nonatomic, assign) BOOL isCameraRoll;

@end

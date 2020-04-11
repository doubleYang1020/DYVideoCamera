//
//  DYVideoPickerControllerViewController.h
//  DYVideoPickerController
//
//  Created by huyangyang on 2017/11/21.
//  Copyright © 2017年 HuYangYang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreMedia;

@protocol TZImagePickerControllerDelegate;
@interface DYVideoPickerController : UINavigationController

- (instancetype)initWithdelegate:(id<TZImagePickerControllerDelegate>)delegate;

@property (nonatomic, weak) id<TZImagePickerControllerDelegate> pickerDelegate;
@end

@protocol TZImagePickerControllerDelegate <NSObject>

- (NSString *)imagePickerControllergetLocalizedStringForKey:(NSString *)key;

- (CMTimeRange)videoTimeRange;

- (void)imagePickerControllerShowHUDForExportering;

- (void)imagePickerControllerHiddenHUDForExportering;

@optional
// The picker should dismiss itself; when it dismissed these handle will be called.
// You can also set autoDismiss to NO, then the picker don't dismiss itself.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的handle
// 你也可以设置autoDismiss属性为NO，选择器就不会自己dismis了
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(DYVideoPickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto;
- (void)imagePickerController:(DYVideoPickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos;
//- (void)imagePickerControllerDidCancel:(TZImagePickerController *)picker __attribute__((deprecated("Use -tz_imagePickerControllerDidCancel:.")));
- (void)tz_imagePickerControllerDidCancel:(DYVideoPickerController *)picker;

// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(DYVideoPickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset;

- (void)imagePickerController:(DYVideoPickerController *)picker didFinishPickingCover:(UIImage *)coverImage videoUrl:(NSURL *)url;

// If user picking a gif image, this callback will be called.
// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(DYVideoPickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset;

// Decide album show or not't
// 决定相册显示与否 albumName:相册名字 result:相册原始数据
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result;

// Decide asset show or not't
// 决定照片显示与否
- (BOOL)isAssetCanSelect:(id)asset;

- (void)imagePickerControllerShowHud:(NSString *)tipString;

@end


@interface TZAlbumPickerController : UIViewController
@property (nonatomic, assign) NSInteger columnNumber;
- (void)configMainCollectionView ;
@end




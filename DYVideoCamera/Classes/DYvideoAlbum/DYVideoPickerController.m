//
//  DYVideoPickerControllerViewController.m
//  DYVideoPickerController
//
//  Created by huyangyang on 2017/11/21.
//  Copyright © 2017年 HuYangYang.com. All rights reserved.
//

#import "DYVideoPickerController.h"
#import "DYImageManager.h"
#import <Photos/Photos.h>
#import "DYVideoAlbumCollectionViewCell.h"
#import "DYVideoAlbumPlayerViewController.h"
#import <Masonry/Masonry.h>
#import "DYVideoEditorController.h"
#define kCollectionViewVideoCellIdentifier @"kDYVideoAlbumCollectionViewCell"

@interface CustomTitleView: UILabel
@end
@implementation CustomTitleView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
        return self;
    }
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
        return self;
    }
    return nil;
}

- (void)setup {
    [self setTextAlignment:NSTextAlignmentCenter];
    [self setAutoresizesSubviews:NO];
    [self setAutoresizingMask:UIViewAutoresizingNone];
}

- (void)setTransform:(CGAffineTransform)transform {
    return;
}

- (void)setFrame:(CGRect)frame {
    if (CGRectGetWidth(frame) != [self intrinsicContentSize].width) {
        return;
    }
    [super setFrame:frame];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(180, 44);
}
@end


@interface DYVideoPickerController () <DYVideoEditorControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic , strong) UILabel* tipLabel;
@property (nonatomic , strong) UIButton* settingBtn;

@end

@implementation DYVideoPickerController
- (instancetype)initWithdelegate:(id<TZImagePickerControllerDelegate>)delegate{
    
    //    [DYImageManager manager].pickerDelegate = delegate;
    self.pickerDelegate = delegate;
    [DYImageManager manager].photoPreviewMaxWidth = 600;
    [DYImageManager manager].sortAscendingByModificationDate = false;
    [DYImageManager manager].columnNumber = 3;
    TZAlbumPickerController *albumPickerVc = [[TZAlbumPickerController alloc] init];
    self = [super initWithRootViewController:albumPickerVc];
    if (self) {
        
        PHAuthorizationStatus state = [PHPhotoLibrary authorizationStatus];
        switch (state) {
            case PHAuthorizationStatusAuthorized://已授权
            {
                [albumPickerVc configMainCollectionView];
            }
                
                break;
            case PHAuthorizationStatusNotDetermined://未询问
            {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    dispatch_after(0.2, dispatch_get_main_queue(), ^{
                        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
                            // 已授权的
                            [albumPickerVc configMainCollectionView];
                            
                        }else{
                            // 拒绝授权
                            [self showTip];
                        }
                    });
                    
                }];
            }
                break;
            case PHAuthorizationStatusRestricted://系统限制
                [self showTip];
                break;
            case PHAuthorizationStatusDenied://拒绝的
                [self showTip];
                break;
        }
    }
    return self;
}
-(void)showTip{
    _tipLabel = [[UILabel alloc] init];
    _tipLabel.frame = CGRectMake(8, 120, self.view.frame.size.width - 16, 60);
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.numberOfLines = 0;
    _tipLabel.font = [UIFont systemFontOfSize:16];
    _tipLabel.textColor = [UIColor blackColor];
    NSDictionary *infoDict = [NSBundle mainBundle].localizedInfoDictionary;
    if (!infoDict) {
        infoDict = [NSBundle mainBundle].infoDictionary;
    }
    
    NSString* tipStr;
    NSString* settingStr;
    if ([self.pickerDelegate respondsToSelector:@selector(imagePickerControllergetLocalizedStringForKey:)]) {
        tipStr = [self.pickerDelegate imagePickerControllergetLocalizedStringForKey:@"Allow DY to access your album in \"Settings -> Privacy -> Photos\""];
        settingStr = [self.pickerDelegate imagePickerControllergetLocalizedStringForKey:@"Setting"];
    }
    //    NSString *appName = [infoDict valueForKey:@"CFBundleDisplayName"];
    //    if (!appName) appName = [infoDict valueForKey:@"CFBundleName"];
    //    NSString *tipText = [NSString stringWithFormat:@"Allow %@ to access your album in \"Settings -> Privacy -> Photos\"",appName];
    _tipLabel.text = tipStr;
    [self.view addSubview:_tipLabel];
    
    
    _settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_settingBtn setTitle:settingStr forState:UIControlStateNormal];
    _settingBtn.frame = CGRectMake(0, 180, self.view.frame.size.width, 44);
    _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_settingBtn];
    
}
- (void)settingBtnClick {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

//- (void)pushPhotoPickerVc {
//    [[DYImageManager manager] getAllAlbums:true allowPickingImage:false completion:^(NSArray<TZAlbumModel *> *models) {
//        NSLog(@"get sucell");
//    }];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleLightContent];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar.barTintColor = [UIColor colorWithRed:(74/255.0) green:(186/255.0)  blue:(188/255.0) alpha:1.0];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
    [self configNaviTitleAppearance];
    [self configBarButtonItemAppearance];
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)configNaviTitleAppearance {
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];;
    
    textAttrs[NSFontAttributeName] = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    
    self.navigationBar.titleTextAttributes = textAttrs;
}
- (void)configBarButtonItemAppearance {
    UIBarButtonItem *barItem;
    if (@available(iOS 9.0, *)) {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[DYVideoPickerController class]]];
    } else {
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[DYVideoPickerController class], nil];
    }
    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttrs[NSFontAttributeName] = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}
- (void)cancelButtonClick {
    
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@interface TZAlbumPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout> {
    UITableView *_tableView;
}
@property (nonatomic, strong) NSMutableArray *videoModels;
@property (assign, nonatomic) BOOL isFirstAppear;
@property (nonatomic, strong) UICollectionView* mainCollectionView;

@property (nonatomic ,strong) NSIndexPath* lastSelectedIndexPath;

@property (nonatomic ,strong) UIButton* previewBtn;
@property (nonatomic ,strong) UIButton* completeBtn;

@property (nonatomic ,strong) UIImage* Photo;
@end

@implementation TZAlbumPickerController




- (void)viewDidLoad {
    [super viewDidLoad];
    DYVideoPickerController *imagePickerVc = (DYVideoPickerController *)self.navigationController;
    NSString* previewStr;
    NSString* completeStr;
    NSString* cancelStr;
    if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerControllergetLocalizedStringForKey:)]) {
        previewStr = [imagePickerVc.pickerDelegate imagePickerControllergetLocalizedStringForKey:@"Preview"];
        completeStr = [imagePickerVc.pickerDelegate imagePickerControllergetLocalizedStringForKey:@"Done"];
        cancelStr = [imagePickerVc.pickerDelegate imagePickerControllergetLocalizedStringForKey:@"Cancel"];
    }
    
    _lastSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.isFirstAppear = YES;
    self.view.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout* videoFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [videoFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//垂直滚动
    UICollectionView *videocollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height ) collectionViewLayout:videoFlowLayout];
    videocollectionView.alwaysBounceVertical = YES;//当不够一屏的话也能滑动
    videocollectionView.delegate = self;
    videocollectionView.dataSource = self;
    [videocollectionView setBackgroundColor:[UIColor clearColor]];
    [videocollectionView registerClass:[DYVideoAlbumCollectionViewCell class] forCellWithReuseIdentifier:kCollectionViewVideoCellIdentifier];
    self.mainCollectionView = videocollectionView;
    [self.view addSubview:self.mainCollectionView];
    
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenheight = [UIScreen mainScreen].bounds.size.height;
    _previewBtn = [[UIButton alloc] init];
    [_previewBtn setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [_previewBtn setTitle:previewStr forState:UIControlStateNormal];
    [_previewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _previewBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    [_previewBtn setFrame:CGRectMake(12, screenheight - 47, 68, 35)];
    _previewBtn.layer.cornerRadius = 5;
    _previewBtn.layer.borderWidth = 1;
    _previewBtn.layer.borderColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:1.0].CGColor;
    _previewBtn.clipsToBounds = true;
    [_previewBtn setHidden:true];
    [_previewBtn addTarget:self action:@selector(clickPreviewBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_previewBtn];
    [_previewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@68);
        make.height.equalTo(@35);
        make.left.equalTo(self.view).offset(12);
        make.bottom.equalTo(self.view.mas_bottomMargin).offset(-12);
    }];
    
    _completeBtn = [[UIButton alloc] init];
    [_completeBtn setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [_completeBtn setTitle:completeStr forState:UIControlStateNormal];
    [_completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _completeBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    [_completeBtn setFrame:CGRectMake(screenWidth - 80, screenheight - 47, 68, 35)];
    _completeBtn.layer.cornerRadius = 5;
    _completeBtn.layer.borderWidth = 1;
    _completeBtn.layer.borderColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:1.0].CGColor;
    _completeBtn.clipsToBounds = true;
    [_completeBtn setHidden:true];
    [_completeBtn addTarget:self action:@selector(clickCompleBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_completeBtn];
    [_completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@68);
        make.height.equalTo(@35);
        make.right.equalTo(self.view).offset(-12);
        make.bottom.equalTo(self.view.mas_bottomMargin).offset(-12);
    }];
    
   self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:cancelStr style:UIBarButtonItemStylePlain target:imagePickerVc action:@selector(cancelButtonClick)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    [self configMainCollectionView];
}

- (void)configMainCollectionView {
    
    DYVideoPickerController *imagePickerVc = (DYVideoPickerController *)self.navigationController;
    NSString* titleStr;
    if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerControllergetLocalizedStringForKey:)]) {
        titleStr = [imagePickerVc.pickerDelegate imagePickerControllergetLocalizedStringForKey:@"Videos"];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[DYImageManager manager] getCameraRollAlbum:true allowPickingImage:false completion:^(TZAlbumModel *model) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoModels = [NSMutableArray arrayWithArray:model.models];
                //            self.Title = model.name ;
                self.title = titleStr;
                CustomTitleView *titleView = [[CustomTitleView alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
                self.navigationItem.titleView = titleView;
                [titleView setTextColor:[UIColor whiteColor]];
                [titleView setText:titleStr];
                //                self.navigationItem.TitleView.backgroundColor = [UIColor redColor];
                
                [self.mainCollectionView reloadData];
                NSLog(@"getCameraRollAlbum");
            });
        }];
    });
}

- (void)dealloc {
    NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

#pragma mark - UICollectionViewDataSource && Delegate
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//定义展示的UICollectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return _videoModels.count;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = kCollectionViewVideoCellIdentifier;
    DYVideoAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier1 forIndexPath:indexPath];
    cell.model = [_videoModels objectAtIndex:indexPath.row];
    return cell;
}

//返回头headerView的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(0, 1.0);
}
//定义每个item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat ScreenWidth = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake((ScreenWidth-2)/3, ((ScreenWidth-2)/3));
}
//定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(0.0,0.0,0.0,0.0);
}
//每个item之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
    
}

//每个section中不同的行之间的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    
    return 1.0f;
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DYAssetModel* selectedModel = _videoModels[indexPath.row];
    PHAsset *phAsset = (PHAsset *)selectedModel.asset;
    if (phAsset.duration < 4.5) {
        
        DYVideoPickerController *imagePickerVc = (DYVideoPickerController *)self.navigationController;
        if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerControllerShowHud:)]) {
            [imagePickerVc.pickerDelegate imagePickerControllerShowHud:@"请选择大于5秒的视频 😂"];
        }
        return;
    }else if (phAsset.duration > 600){
        DYVideoPickerController *imagePickerVc = (DYVideoPickerController *)self.navigationController;
        if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerControllerShowHud:)]) {
            [imagePickerVc.pickerDelegate imagePickerControllerShowHud:@"请选择小于10分钟的视频 😂"];
        }
        return;
    }
    
    
    if (_lastSelectedIndexPath.row == indexPath.row) {
        DYAssetModel* temp = _videoModels[indexPath.row];
        temp.isSelected = !temp.isSelected;
        _videoModels[indexPath.row] = temp;
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        
        temp.isSelected?[self showBtns]:[self hiddenBtns];
    }else{
        DYAssetModel* lastTemp = _videoModels[_lastSelectedIndexPath.row];
        lastTemp.isSelected = false;
        _videoModels[_lastSelectedIndexPath.row] = lastTemp;
        
        DYAssetModel* temp = _videoModels[indexPath.row];
        temp.isSelected = true;
        _videoModels[indexPath.row] = temp;
        [collectionView reloadItemsAtIndexPaths:@[_lastSelectedIndexPath,indexPath]];
        
        [self showBtns];
    }
    _lastSelectedIndexPath = indexPath;
    
    DYAssetModel* TempModel = _videoModels[_lastSelectedIndexPath.row];
    [[DYImageManager manager] getPhotoWithAsset:TempModel.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        _Photo = photo;
        
    }];
    
}

-(void)clickPreviewBtn{
    DYVideoAlbumPlayerViewController* cor = [[DYVideoAlbumPlayerViewController alloc] init];
    DYAssetModel* tempModel = _videoModels[self.lastSelectedIndexPath.row];
    cor.model = tempModel;
    [self.navigationController pushViewController:cor animated:true];
}

-(void)clickCompleBtn{

    DYAssetModel* TempModel = _videoModels[_lastSelectedIndexPath.row];
    
    DYVideoPickerController *imagePickerVc = (DYVideoPickerController *)self.navigationController;
    
    __weak typeof(self) this = self;
    
    if (CMTimeCompare(TempModel.duration, [imagePickerVc.pickerDelegate videoTimeRange].duration) > 0) {
        PHAsset* myasset = TempModel.asset;
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.networkAccessAllowed = YES;
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestAVAssetForVideo:myasset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AVURLAsset *urlAsset = (AVURLAsset *)asset;
                NSURL *url = urlAsset.URL;
                DYVideoEditorController* editorController = [[DYVideoEditorController alloc] init];
                editorController.videoURL = url;
                editorController.leftBtnTitle =  [imagePickerVc.pickerDelegate imagePickerControllergetLocalizedStringForKey:@"Cancel"];
                editorController.rightBtnTiltle =  [imagePickerVc.pickerDelegate imagePickerControllergetLocalizedStringForKey:@"Done"];
                editorController.videoMaximumDuration = CMTimeGetSeconds(imagePickerVc.pickerDelegate.videoTimeRange.duration);
                editorController.videoMinimumDuration = CMTimeGetSeconds(imagePickerVc.pickerDelegate.videoTimeRange.start);
                editorController.delegate = self;
                [self presentViewController:editorController animated:YES completion:nil];
//                if ([UIVideoEditorController canEditVideoAtPath:url.path]) {
//                    UIVideoEditorController *editorController = [[UIVideoEditorController alloc] init];
//                    [editorController setVideoPath:url.path];
//                    [editorController setVideoQuality:UIImagePickerControllerQualityTypeIFrame960x540];
//                    [editorController setVideoMaximumDuration:CMTimeGetSeconds(imagePickerVc.pickerDelegate.videoTimeRange.duration)];
//                    [editorController setDelegate:this];
//                    [self presentViewController:editorController animated:YES completion:nil];
//                }
            });
            
        }];
        
        
    }
    else {
        [self.navigationController dismissViewControllerAnimated:true completion:^{
            if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingVideo:sourceAssets:)]) {
                [imagePickerVc.pickerDelegate imagePickerController:imagePickerVc didFinishPickingVideo:_Photo sourceAssets:TempModel.asset];
            }
        }];
    }
}

-(void)showBtns{
    [_previewBtn setHidden:false];
    [_completeBtn setHidden:false];
}
-(void)hiddenBtns{
    [_previewBtn setHidden:true];
    [_completeBtn setHidden:true];
}

#pragma mark - DYVideoEditorControllerDelegate
-(void)showHUDForExportering{
    DYVideoPickerController *imagePickerVc = (DYVideoPickerController *)self.navigationController;
    if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerControllerShowHUDForExportering)]) {
        [imagePickerVc.pickerDelegate imagePickerControllerShowHUDForExportering];
    }
}

-(void)DYVideoEditorControllerDidCancel{
    
}
-(void)DYVideoEditorControllerDidSaveEditedVideoToPath:(NSString *)editedVideoPath{
    
    DYVideoPickerController *imagePickerVc = (DYVideoPickerController *)self.navigationController;
    if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerControllerHiddenHUDForExportering)]) {
        [imagePickerVc.pickerDelegate imagePickerControllerHiddenHUDForExportering];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
            if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingCover:videoUrl:)]) {
                NSURL *videoUrl = [NSURL fileURLWithPath:editedVideoPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [imagePickerVc.pickerDelegate imagePickerController:imagePickerVc didFinishPickingCover:_Photo videoUrl:videoUrl];
                });
            }
        }];
    });
}

//#pragma mark - UIVideoEditorControllerDelegate
//
//- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath {
//    __weak typeof(self) this = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [editor dismissViewControllerAnimated:NO completion:^{
//            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//            DYVideoPickerController *imagePickerVc = (DYVideoPickerController *)this.navigationController;
//            if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingCover:videoUrl:)]) {
//                NSURL *videoUrl = [NSURL fileURLWithPath:editedVideoPath];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [imagePickerVc.pickerDelegate imagePickerController:imagePickerVc didFinishPickingCover:_Photo videoUrl:videoUrl];
//                });
//            }
//        }];
//    });
//}

//- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error {
//    [editor dismissViewControllerAnimated:NO completion:nil];
//}
//
//- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor {
//    [editor dismissViewControllerAnimated:NO completion:nil];
//}

@end


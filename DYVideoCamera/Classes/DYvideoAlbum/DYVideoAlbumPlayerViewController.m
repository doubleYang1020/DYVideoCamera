//
//  DYVideoAlbumPlayerViewController.m
//  DYVideoPickerController
//
//  Created by huyangyang on 2017/11/23.
//  Copyright © 2017年 HuYangYang.com. All rights reserved.
//

#import "DYVideoAlbumPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "DYImageManager.h"
#import "DYVideoPickerController.h"
#import "DYVMConstants+Private.h"
#import <Masonry/Masonry.h>
#import "DYVideoEditorController.h"
@interface DYVideoAlbumPlayerViewController () <UIGestureRecognizerDelegate,DYVideoEditorControllerDelegate>
@property (nonatomic , strong) AVPlayer* player;
@property (nonatomic , strong) AVPlayerLayer* playerLayer;
@property (nonatomic , strong) UIImage* coverImage;

@property (nonatomic , strong) UIButton* palyerBtn;
@end

@implementation DYVideoAlbumPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithImage:[DYVMConstants imageNamed:@"icWhiteback"]
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(back)];
    DYVideoPickerController *imagePickerVc = (DYVideoPickerController *)self.navigationController;
    NSString* previewStr;
    NSString* completeStr;
    if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerControllergetLocalizedStringForKey:)]) {
        previewStr = [imagePickerVc.pickerDelegate imagePickerControllergetLocalizedStringForKey:@"Preview"];
        completeStr = [imagePickerVc.pickerDelegate imagePickerControllergetLocalizedStringForKey:@"Done"];
    }
    self.title = previewStr;
//    self.view.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:229.0/255.0 blue:234.0/255.0 alpha:1.0];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayer) name:UIApplicationWillResignActiveNotification object:nil];
    [self configMoviePlayer];
    
    UIView* toolView = [[UIView alloc] init];
    toolView.backgroundColor = [UIColor whiteColor];
    toolView.frame = CGRectMake(0, self.view.frame.size.height - 45, self.view.frame.size.width, 45);
    [self.view addSubview:toolView];
    [toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottomMargin);
        make.height.equalTo(@45);
    }];
    
    
    UIButton* compleBtn = [[UIButton alloc] init];
    [compleBtn setBackgroundColor:[UIColor colorWithRed:74.0/255.0 green:186.0/255.0 blue:188.0/255.0 alpha:1.0]];
    compleBtn.frame = CGRectMake(5, 5, self.view.frame.size.width - 10, 35);
    [toolView addSubview:compleBtn];
    [compleBtn setTitle:completeStr forState:UIControlStateNormal];
    [compleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    compleBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    compleBtn.layer.cornerRadius = 5;
    compleBtn.clipsToBounds = true;
    [compleBtn addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    
}
- (void)configMoviePlayer {
    [[DYImageManager manager] getPhotoWithAsset:_model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        _coverImage = photo;
    }];
    [[DYImageManager manager] getVideoWithAsset:_model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL isIphenX = [self DY_isIPhoneX];
            UIView* playBGView = [UIView new];
            [self.view addSubview:playBGView];
            [playBGView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).offset(isIphenX ? 88 : 64);
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(self.view.mas_bottomMargin).offset(-45);
            }];
            
            _player = [AVPlayer playerWithPlayerItem:playerItem];
        
            
            _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
            [self.view.superview layoutIfNeeded];
//            _playerLayer.frame = CGRectMake(0, isIphenX ? 88 : 64, self.view.frame.size.width, self.view.frame.size.height - (isIphenX ? 88 : 64) - 45);
            _playerLayer.frame = playBGView.bounds;
            [playBGView.layer addSublayer:_playerLayer];
            [_player play];
            
            _palyerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_palyerBtn setImage:[UIImage new] forState:UIControlStateNormal];
            _palyerBtn.frame = _playerLayer.frame;
            [_palyerBtn addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
            [playBGView addSubview:_palyerBtn];
            
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replay) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
        });
    }];
}


- (BOOL)DY_isIPhoneX {

   return [UIScreen mainScreen].bounds.size.height == 812;

}

- (void)doneButtonClick {
    
    __weak typeof(self) this = self;
    DYVideoPickerController *imagePickerVc = (DYVideoPickerController *)self.navigationController;

    if (CMTimeCompare(self.model.duration, [imagePickerVc.pickerDelegate videoTimeRange].duration) > 0) {
        PHAsset* myasset = this.model.asset;
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
//
//                }
            });
            
        }];
        
        
    }
    else {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    }
    

}
- (void)callDelegateMethod {
    DYVideoPickerController *imagePickerVc = (DYVideoPickerController *)self.navigationController;
    if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingVideo:sourceAssets:)]) {
        [imagePickerVc.pickerDelegate imagePickerController:imagePickerVc didFinishPickingVideo:_coverImage sourceAssets:_model.asset];
    }
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
                    [imagePickerVc.pickerDelegate imagePickerController:imagePickerVc didFinishPickingCover:_coverImage videoUrl:videoUrl];
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
//            [self.navigationController dismissViewControllerAnimated:YES completion:^{
//                DYVideoPickerController *imagePickerVc = (DYVideoPickerController *)this.navigationController;
//                if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingCover:videoUrl:)]) {
//                    NSURL *videoUrl = [NSURL fileURLWithPath:editedVideoPath];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [imagePickerVc.pickerDelegate imagePickerController:imagePickerVc didFinishPickingCover:_coverImage videoUrl:videoUrl];
//                    });
//                }
//            }];
//
//        }];
//    });
//}

- (void)playButtonClick {
    if (!_palyerBtn.isSelected) {
         [_palyerBtn setImage:[DYVMConstants imageNamed:@"icVideoAlbumPlayBtn"] forState:UIControlStateNormal];
        [_palyerBtn setSelected:true];
        [self pausePlayer];
    }else{
        [_palyerBtn setImage:[UIImage new] forState:UIControlStateNormal];
        [_palyerBtn setSelected:false];
        [self playPlayer];
    }
}

-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)replay{
    [_player.currentItem seekToTime:CMTimeMake(0, 1)];[_player play];
}
- (void)pausePlayer {
    [_player pause];
}
-(void)playPlayer{
    [_player play];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     [self pausePlayer];
    [_palyerBtn setImage:[DYVMConstants imageNamed:@"icVideoAlbumPlayBtn"] forState:UIControlStateNormal];
    [_palyerBtn setSelected:true];
    
}
- (void)dealloc {
    [self pausePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a litDYe preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  DYVideoTrimViewController.m
//  DYVideoTrimController
//
//  Created by huyangyang on 2018/1/9.
//  Copyright © 2018年 com.huyangyang.landscapePhotography. All rights reserved.
//

#import "DYVideoEditorController.h"
#import "SAVideoRangeSlider.h"
#import "DYVMConstants+Private.h"
#import "DYVideoProcessEngine.h"
@interface DYVideoEditorController ()<SAVideoRangeSliderDelegate>
@property (strong, nonatomic) SAVideoRangeSlider *mySAVideoRangeSlider;
@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat stopTime;
@property (nonatomic , strong) AVPlayer *moviePlayer;
@property (nonatomic , strong) UILabel* timeLabel;
@property (nonatomic , assign) BOOL isSeekInProgress;

@property (nonatomic , strong) UIButton* palyerBtn;

@property (nonatomic, weak) NSTimer *videoPlayertimer;

@property (nonatomic, strong) CALayer* whiteLineLayer;
@end

@implementation DYVideoEditorController

-(void)viewWillDisappear:(BOOL)animated{
    [self.moviePlayer pause];
    [self.videoPlayertimer invalidate];
    self.videoPlayertimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _moviePlayer = [[AVPlayer alloc] initWithURL:self.videoURL];
    AVPlayerLayer* videoPreviewlayer = [AVPlayerLayer playerLayerWithPlayer:_moviePlayer];
    videoPreviewlayer.frame = CGRectMake(0, 92, self.view.frame.size.width, self.view.frame.size.height - 200);
    [self.view.layer addSublayer:videoPreviewlayer];
    
    self.mySAVideoRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(12,self.view.frame.size.height - 84 , self.view.frame.size.width - 24 , 40) videoUrl:self.videoURL ];
    [self.mySAVideoRangeSlider setPopoverBubbleSize:0 height:0];
    // Do any additional setup after loading the view.
//    74 186 188
    self.mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 74.0/255.0 green: 186.0/255.0 blue: 188.0/255.0 alpha: 1];
    self.mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 74.0/255.0 green: 186.0/255.0 blue: 188.0/255.0 alpha: 1];
    
    self.mySAVideoRangeSlider.delegate = self;
    
    float videoTime = CMTimeGetSeconds([AVAsset assetWithURL:self.videoURL].duration) ;
    self.startTime = 0.0;
    
    self.mySAVideoRangeSlider.minGap = self.videoMinimumDuration;
    
    
    if (videoTime > self.videoMaximumDuration) {
        videoTime = self.videoMaximumDuration;
        self.mySAVideoRangeSlider.maxGap = videoTime;
    }else{
        videoTime = self.videoMinimumDuration;
    }
    self.stopTime = videoTime;
    
    
    

    
    [self.view addSubview:self.mySAVideoRangeSlider];
    
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    [self.timeLabel setFont:[UIFont fontWithName:@"PingFangSC-Semibold" size:14]];
    self.timeLabel.textColor = [UIColor blackColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_timeLabel];
    self.timeLabel.text = [NSString stringWithFormat:@"%dS",(int)roundf(self.stopTime - self.startTime)];
    
    UIButton* cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,([DYVMConstants iPhoneX] ? 44 : 20), 54, 44)];
    [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancleBtn setTitle:self.leftBtnTitle forState:UIControlStateNormal];
    [cancleBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:15]];
    [self.view addSubview:cancleBtn];
    [cancleBtn addTarget:self action:@selector(clickCancleBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* completeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 54,([DYVMConstants iPhoneX] ? 44 : 20), 54, 44)];
    [completeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [completeBtn setTitle:self.rightBtnTiltle forState:UIControlStateNormal];
    [completeBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:15]];
    [self.view addSubview:completeBtn];
    [completeBtn addTarget:self action:@selector(clickCompleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _palyerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_palyerBtn setImage:[DYVMConstants imageNamed:@"icPlay"] forState:UIControlStateNormal];
    _palyerBtn.frame = videoPreviewlayer.frame;
    [_palyerBtn addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _palyerBtn.selected = true;
    [self.view addSubview:_palyerBtn];
    
    self.videoPlayertimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0
                                                             target:self
                                                           selector:@selector(timerAction)
                                                           userInfo:nil
                                                            repeats:YES];
    
    _whiteLineLayer = [[CALayer alloc] init];
    _whiteLineLayer.backgroundColor = [UIColor whiteColor].CGColor;
    _whiteLineLayer.frame = CGRectMake(12, 0, 5, 40);
    _whiteLineLayer.cornerRadius = 2.5;
    [self.mySAVideoRangeSlider.layer addSublayer:_whiteLineLayer];
    
}
-(void)timerAction{
    if (_palyerBtn.isSelected) {
        return;
    }else{
        CMTime time = self.moviePlayer.currentTime;
        NSLog(@"avplayer_currentTime %lf", CMTimeGetSeconds(time));
        
        float currentTime = CMTimeGetSeconds(time);
        
        float sliderWidth = self.mySAVideoRangeSlider.frame.size.width;
        

        float videoTime = CMTimeGetSeconds([AVAsset assetWithURL:self.videoURL].duration);
        
        float scale = currentTime / videoTime;
        float whiteLineCenterX = (sliderWidth - 24 - 5) * scale;
        
        float timeScale = ( (currentTime - _startTime))/(self.stopTime - self.startTime);
        float whiteLinex = (_mySAVideoRangeSlider.rightThumb.frame.origin.x - _mySAVideoRangeSlider.leftThumb.frame.origin.x - _mySAVideoRangeSlider.leftThumb.frame.size.width)*timeScale;
        
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
//        self.whiteLineLayer.frame = CGRectMake(12 + whiteLineCenterX , 0, 5, 40);
        self.whiteLineLayer.frame = CGRectMake(_mySAVideoRangeSlider.leftThumb.frame.origin.x + _mySAVideoRangeSlider.leftThumb.frame.size.width -2.5 + whiteLinex , 0, 5, 40);
        [CATransaction commit];
        

        
        
        if (CMTimeGetSeconds(time) >= self.stopTime) {
            [self playButtonClick];
        }
    }
}
- (void)playButtonClick {
    if (!_palyerBtn.isSelected) {
        [_palyerBtn setImage:[UIImage imageNamed:@"icPlay"] forState:UIControlStateNormal];
        [_palyerBtn setSelected:true];
        

        [_moviePlayer pause];
        _whiteLineLayer.hidden = YES;
    }else{
        [_palyerBtn setImage:[UIImage new] forState:UIControlStateNormal];
        
        [_moviePlayer seekToTime:CMTimeMakeWithSeconds(self.startTime, 60) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            [_moviePlayer play];
            _whiteLineLayer.hidden = false;
            [_palyerBtn setSelected:false];
        }];
        
//        [_moviePlayer seekToTime:CMTimeMakeWithSeconds(self.startTime, 60) completionHandler:^(BOOL finished) {
//            [_moviePlayer play];
//            _whiteLineLayer.hidden = false;
//            [_palyerBtn setSelected:false];
//        }];
        
    }
}
-(void)clickCompleteBtn:(UIButton*)sender{

    
    [sender setEnabled:false];
    
    if ([self.delegate respondsToSelector:@selector(showHUDForExportering)]) {
        [self.delegate showHUDForExportering];
    }
    
    CMTime start = CMTimeMakeWithSeconds(self.startTime, 60);
    CMTime duration = CMTimeMakeWithSeconds(self.stopTime-self.startTime, 60);
    [DYVideoProcessEngine croppingVideo:self.videoURL AndStartTime:start AndDuration:duration WithCompletionHandler:^(NSString *outPutPath, int code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:^{
                if ([self.delegate respondsToSelector:@selector(DYVideoEditorControllerDidSaveEditedVideoToPath:)]) {
                    [self.delegate DYVideoEditorControllerDidSaveEditedVideoToPath:outPutPath];
                }
            }];
        });
    }];
}
-(void)clickCancleBtn{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition{
    
    [_palyerBtn setImage:[UIImage imageNamed:@"icPlay"] forState:UIControlStateNormal];
    [_palyerBtn setSelected:true];
    [_moviePlayer pause];
    _whiteLineLayer.hidden = YES;

    
    self.startTime = leftPosition;
    self.stopTime = rightPosition;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%dS",(int)roundf(rightPosition - leftPosition)];
}

-(void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition{
        // 此时滑动左端
        if (_isSeekInProgress) {
            return;
        }
        _isSeekInProgress = YES;
        [_moviePlayer seekToTime:CMTimeMakeWithSeconds(leftPosition, 60) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                        _isSeekInProgress = NO;
        }];
//        [_moviePlayer seekToTime:CMTimeMakeWithSeconds(leftPosition, 60) completionHandler:^(BOOL finished) {
//            _isSeekInProgress = NO;
//        }];
}
-(void)videoRange:(SAVideoRangeSlider *)videoRange didChangerightPosition:(CGFloat)rightPosition{
    if (_isSeekInProgress) {
        return;
    }
    _isSeekInProgress = YES;
    
    [_moviePlayer seekToTime:CMTimeMakeWithSeconds(rightPosition, 60) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        _isSeekInProgress = NO;
    }];
    // 此时滑动右端
//    [_moviePlayer seekToTime:CMTimeMakeWithSeconds(rightPosition, 60) completionHandler:^(BOOL finished) {
//        _isSeekInProgress = NO;
//    }];
}

-(void)videoRange:(SAVideoRangeSlider *)videoRange didChangeForTogetherLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition{
    // 此时滑动左端
    if (_isSeekInProgress) {
        return;
    }
    _isSeekInProgress = YES;
//    [_moviePlayer seekToTime:CMTimeMakeWithSeconds(leftPosition, 60) completionHandler:^(BOOL finished) {
//        _isSeekInProgress = NO;
//    }];
    [_moviePlayer seekToTime:CMTimeMakeWithSeconds(leftPosition, 60) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        _isSeekInProgress = NO;
    }];
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

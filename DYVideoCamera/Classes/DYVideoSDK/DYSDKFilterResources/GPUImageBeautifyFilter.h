//
//  GPUImageBeautifyFilter.h
//  BeautifyFaceDemo
//
//  Created by guikz on 16/4/28.
//  Copyright © 2016年 guikz. All rights reserved.
//

#import "GPUImage.h"

@class GPUImageCombinationFilter;

@interface GPUImageBeautifyFilter : GPUImageFilterGroup {
    GPUImageBilateralFilter *bilateralFilter;
    GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter;
    GPUImageCombinationFilter *combinationFilter;
    GPUImageHSBFilter *hsbFilter;
}

/**
 磨皮系数 0 < value <= 25 值越小磨皮效果越明显
 
 @param value 磨皮系数
 */
-(void)changeExfoliatingValue:(double)value;

/**
 色相 [-360, 360] with 0 being no-change.
 
 @param value 很难调教
 */
-(void)changeHues:(double)value;

/**
 饱和度和亮度 [0.0, 2.0] with 1.0 being no-chang
 
 @param value 饱和度
 @param value2 亮度
 */
-(void)changeSaturation:(double)value andBrightness:(double)value2;

/**
 亮度和饱和度 [0.0, 2.0] with 1.0 being no-chang
 
 @param value 亮度
 @param value2 饱和度
 */
-(void)changeBrightness:(double)value andSaturation:(double)value2;

/**
 美白系数 0 < value <= 5.0
 
 @param value 美白系数
 */
-(void)changeWhiteLevel:(double)value;

/*
 以下是一些调试好的参数。
 */


/**
 美颜typeTwo grind:8.8004 hues:0 saturation:1.0 brightness:1.0886 whiteLeave:1.3341
 */
-(void)setBeautyFaceConfigurationTypeOne;


/**
 美颜typeOne grind:4.0 hues:0 saturation:0.8744 brightness:1.1132 whiteLeave:1.4798
 */
-(void)setBeautyFaceConfigurationTypeTwo;

/**
 美颜TypeThree grind:0 hues:0 saturation:1.1256 brightness:1.1368 whiteLeave:2.1861
 */
-(void)setBeautyFaceConfigurationTypeThree;

- (void)isNeedMirror:(BOOL)on;

- (void)isNeedBeauty:(BOOL)on;
@end

//
//  GPUImageBeautifyFilter.m
//  BeautifyFaceDemo
//
//  Created by guikz on 16/4/28.
//  Copyright © 2016年 guikz. All rights reserved.
//

#import "GPUImageBeautifyFilter.h"

// Internal CombinationFilter(It should not be used outside)
@interface GPUImageCombinationFilter : GPUImageThreeInputFilter
{
    GLint smoothDegreeUniform;
    
    GLint whiteLevelUniform;
    
    GLint isNeedMirrorUniform;
    
    GLint isBeautyOpenUniform;
}

@property (nonatomic, assign) CGFloat intensity;
@property (nonatomic, assign) CGFloat whiteLevel;
@property (nonatomic, assign) CGFloat isNeedMirror;
@property (nonatomic, assign) CGFloat isBeautyOpen;
@end

NSString *const kGPUImageBeautifyFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 varying highp vec2 textureCoordinate3;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 uniform mediump float smoothDegree;
 uniform mediump float whiteLevel;
 uniform mediump float isNeedMirror;
 uniform mediump float isBeautyOpen;
 void main()
 {
     highp vec4 bilateral;
     highp vec4 canny;
     highp vec4 origin;
     if (isNeedMirror == 0.0 ){
         bilateral = texture2D(inputImageTexture, textureCoordinate);
         canny = texture2D(inputImageTexture2, textureCoordinate2);
         origin = texture2D(inputImageTexture3,textureCoordinate3);
     }else{
         bilateral = texture2D(inputImageTexture, vec2(textureCoordinate.x,1.0 - textureCoordinate.y));
         canny = texture2D(inputImageTexture2, vec2(textureCoordinate2.x,1.0 - textureCoordinate2.y));
         origin = texture2D(inputImageTexture3,vec2(textureCoordinate3.x,1.0 - textureCoordinate3.y));
     }
     
     if (isBeautyOpen == 1.0){
         highp vec4 smooth;
         lowp float r = origin.r;
         lowp float g = origin.g;
         lowp float b = origin.b;
         if (canny.r < 0.2 && r > 0.3725 && g > 0.1568 && b > 0.0784 && r > b && (max(max(r, g), b) - min(min(r, g), b)) > 0.0588 && abs(r-g) > 0.0588) {
             smooth = (1.0 - smoothDegree) * (origin - bilateral) + bilateral;
         }
         else {
             smooth = origin;
         }
         smooth.r = log(1.0 + whiteLevel * smooth.r)/log(1.0 + whiteLevel);
         smooth.g = log(1.0 + whiteLevel * smooth.g)/log(1.0 + whiteLevel);
         smooth.b = log(1.0 + whiteLevel * smooth.b)/log(1.0 + whiteLevel);
         gl_FragColor = smooth;
     }else{
         gl_FragColor = origin;
     }
     
     
     
 }
 );

@implementation GPUImageCombinationFilter

- (id)init {
    if (self = [super initWithFragmentShaderFromString:kGPUImageBeautifyFragmentShaderString]) {
        smoothDegreeUniform = [filterProgram uniformIndex:@"smoothDegree"];
        whiteLevelUniform = [filterProgram uniformIndex:@"whiteLevel"];
        isNeedMirrorUniform = [filterProgram uniformIndex:@"isNeedMirror"];
        isBeautyOpenUniform = [filterProgram uniformIndex:@"isBeautyOpen"];
    }
    self.intensity = 0.5;
    self.whiteLevel = 0.2;
    self.isNeedMirror = 0.0;
    self.isBeautyOpen = 1.0;
    return self;
}

- (void)setIntensity:(CGFloat)intensity {
    _intensity = intensity;
    [self setFloat:intensity forUniform:smoothDegreeUniform program:filterProgram];
}

-(void)setWhiteLevel:(CGFloat)whiteLevel {
    _whiteLevel = whiteLevel;
    [self setFloat:whiteLevel forUniform:whiteLevelUniform program:filterProgram];
}

-(void)setIsNeedMirror:(CGFloat)isNeedMirror {
    _isNeedMirror = isNeedMirror;
    [self setFloat:isNeedMirror forUniform:isNeedMirrorUniform program:filterProgram];
}

-(void)setIsBeautyOpen:(CGFloat)isBeautyOpen{
    _isBeautyOpen = isBeautyOpen;
    [self setFloat:isBeautyOpen forUniform:isBeautyOpenUniform program:filterProgram];
}

@end

@implementation GPUImageBeautifyFilter

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    // First pass: face smoothing filter
    bilateralFilter = [[GPUImageBilateralFilter alloc] init];
    bilateralFilter.distanceNormalizationFactor = 4.0;
    [self addFilter:bilateralFilter];
    
    // Second pass: edge detection
    cannyEdgeFilter = [[GPUImageCannyEdgeDetectionFilter alloc] init];
    [self addFilter:cannyEdgeFilter];
    
    // Third pass: combination bilateral, edge detection and origin
    combinationFilter = [[GPUImageCombinationFilter alloc] init];
    [self addFilter:combinationFilter];
    
    // Adjust HSB
    hsbFilter = [[GPUImageHSBFilter alloc] init];
    [hsbFilter adjustBrightness:1.1];
    [hsbFilter adjustSaturation:1.1];
    
    [bilateralFilter addTarget:combinationFilter];
    [cannyEdgeFilter addTarget:combinationFilter];
    
    [combinationFilter addTarget:hsbFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:bilateralFilter,cannyEdgeFilter,combinationFilter,nil];
    self.terminalFilter = hsbFilter;
    
    return self;
}
-(void)isNeedMirror:(BOOL)on{
    if (on) {
        [combinationFilter setIsNeedMirror:1.0];
    }else{
        [combinationFilter setIsNeedMirror:0.0];
    }
}

- (void)isNeedBeauty:(BOOL)on{
    if (on) {
        [combinationFilter setIsBeautyOpen:1.0];
    }else{
        [combinationFilter setIsBeautyOpen:0.0];
    }
}

-(void)changeWhiteLevel:(double)value{
    [combinationFilter setWhiteLevel:value];
}

-(void)changeExfoliatingValue:(double)value{
    bilateralFilter.distanceNormalizationFactor = value;
}
-(void)changeHues:(double)value{
    [hsbFilter reset];
    [hsbFilter rotateHue:value];
}
-(void)changeBrightness:(double)value andSaturation:(double)value2{
    [hsbFilter reset];
    [hsbFilter adjustBrightness:value];
    [hsbFilter adjustSaturation:value2];
}
-(void)changeSaturation:(double)value andBrightness:(double)value2{
    [hsbFilter reset];
    [hsbFilter adjustSaturation:value];
    [hsbFilter adjustBrightness:value2];
}

/**
 美颜typeTwo grind:8.8004 hues:0 saturation:1.0 brightness:1.0886 whiteLeave:1.3341
 */
-(void)setBeautyFaceConfigurationTypeOne{
    
    bilateralFilter.distanceNormalizationFactor = 8.8004;
    [hsbFilter reset];
    [hsbFilter adjustSaturation:1.0];
    [hsbFilter adjustBrightness:1.0886];
    [combinationFilter setWhiteLevel:1.3341];
    
}

/**
 美颜typeOne grind:4.0 hues:0 saturation:0.8744 brightness:1.1132 whiteLeave:1.4798
 */
-(void)setBeautyFaceConfigurationTypeTwo{
    
    
    bilateralFilter.distanceNormalizationFactor = 4.0;
    [hsbFilter reset];
    [hsbFilter adjustSaturation:0.8744];
    [hsbFilter adjustBrightness:1.1132];
    [combinationFilter setWhiteLevel:1.4798];
}

/**
 美颜TypeThree grind:0 hues:0 saturation:1.1256 brightness:1.1368 whiteLeave:2.1861
 */
-(void)setBeautyFaceConfigurationTypeThree{
    bilateralFilter.distanceNormalizationFactor = 0.0001;
    [hsbFilter reset];
    [hsbFilter adjustSaturation:1.1256];
    [hsbFilter adjustBrightness:1.1368];
    [combinationFilter setWhiteLevel:2.1861];
}

#pragma mark -
#pragma mark GPUImageInput protocol

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    for (GPUImageOutput<GPUImageInput> *currentFilter in self.initialFilters)
    {
        if (currentFilter != self.inputFilterToIgnoreForUpdates)
        {
            if (currentFilter == combinationFilter) {
                textureIndex = 2;
            }
            [currentFilter newFrameReadyAtTime:frameTime atIndex:textureIndex];
        }
    }
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    for (GPUImageOutput<GPUImageInput> *currentFilter in self.initialFilters)
    {
        if (currentFilter == combinationFilter) {
            textureIndex = 2;
        }
        [currentFilter setInputFramebuffer:newInputFramebuffer atIndex:textureIndex];
    }
}

@end

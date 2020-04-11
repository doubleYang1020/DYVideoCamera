//
//  DYGPUImageEmptyFilter.m
//  DYVideoSDK
//
//  Created by huyangyang on 2017/11/1.
//  Copyright © 2017年 DY. All rights reserved.
//

#import "DYGPUImageEmptyFilter.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kDYGPUImageEmptyFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform mediump float isNeedMirror;
 
 void main()
 {
     if ( isNeedMirror == 0.0) {
         gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
     }else{
          gl_FragColor = texture2D(inputImageTexture, vec2(textureCoordinate.x,1.0 - textureCoordinate.y));
     }
     
     
     
 
 }
 );
#else
NSString *const kDYGPUImageEmptyFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
  uniform mediump float isNeedMirror;
 
 void main()
 {
     if ( isNeedMirror == 0.0) {
         gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
     }else{
         gl_FragColor = texture2D(inputImageTexture, vec2(textureCoordinate.x,1.0 - textureCoordinate.y));
     }
     
 }
 );
#endif
@implementation DYGPUImageEmptyFilter
- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kDYGPUImageEmptyFragmentShaderString]))
    {
        isNeedMirrorUniform = [filterProgram uniformIndex:@"isNeedMirror"];
        return nil;
    }
    self.isNeedMirror = 0.0;
    return self;
}
-(void)setIsNeedMirror:(CGFloat)isNeedMirror {
    _isNeedMirror = isNeedMirror;
    [self setFloat:isNeedMirror forUniform:isNeedMirrorUniform program:filterProgram];
}

-(void)isNeedMirror:(BOOL)on{
    if (on) {
        self.isNeedMirror = 1.0;
    }else{
        self.isNeedMirror = 0.0;
    }
}

@end

//
//  DYGPUImageEmptyFilter.h
//  DYVideoSDK
//
//  Created by huyangyang on 2017/11/1.
//  Copyright © 2017年 DY. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface DYGPUImageEmptyFilter : GPUImageFilter{
    GLint isNeedMirrorUniform;
}
@property (nonatomic, assign) CGFloat isNeedMirror;

- (void)isNeedMirror:(BOOL)on;
@end

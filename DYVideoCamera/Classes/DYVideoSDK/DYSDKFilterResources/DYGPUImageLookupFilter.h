//
//  DYGPUImageLookupFilter.h
//  DYVideoSDK
//
//  Created by huyangyang on 2017/11/3.
//  Copyright © 2017年 DY. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface DYGPUImageLookupFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}
- (instancetype)initWithLookupImage:(UIImage *)LookupImage;
@end

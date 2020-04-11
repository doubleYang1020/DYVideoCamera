//
//  DYGPUImageLookupFilter.m
//  DYVideoSDK
//
//  Created by huyangyang on 2017/11/3.
//  Copyright © 2017年 DY. All rights reserved.
//

#import "DYGPUImageLookupFilter.h"

@implementation DYGPUImageLookupFilter
-(instancetype)initWithLookupImage:(UIImage *)LookupImage{
    self = [super init];
    if (self) {
        lookupImageSource = [[GPUImagePicture alloc] initWithImage:LookupImage];
        GPUImageLookupFilter* lookupFilter = [[GPUImageLookupFilter alloc] init];
        [self addFilter:lookupFilter];
        [lookupImageSource addTarget:lookupFilter atTextureLocation:1];
        [lookupImageSource processImage];
        self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
        self.terminalFilter = lookupFilter;
    }
    return self;
}
@end

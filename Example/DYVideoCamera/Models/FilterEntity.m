//
//  FilterEntity.m
//  RelaVideoModule_Example
//
//  Created by hirochin on 27/11/2017.
//  Copyright © 2017 Chen Hao. All rights reserved.
//

#import "FilterEntity.h"

@implementation FilterEntity

- (instancetype)initWithImage:(UIImage * _Nullable)image title:(NSString * _Nonnull)title {
    if (self = [super init]) {
        _filterImage = image;
        _title = title;
        return self;
    }
    return nil;
}

@end

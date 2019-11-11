//
//  DYSingleObject.m
//  DP_Single
//
//  Created by  ZhuHong on 2018/1/3.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

#import "DYSingleObject.h"

@implementation DYSingleObject

static DYSingleObject* kDYSingleObject = nil;

/** 单例类方法 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kDYSingleObject = [[super allocWithZone:NULL] init];
    });
    
    return kDYSingleObject;
}

// 重写创建对象空间的方法
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    // 直接调用单例的创建方法
    return [self sharedInstance];
}

// 重写copy方法
- (id)copy {
    return kDYSingleObject;
}

// 重写 mutableCopy 方法
- (id)mutableCopy {
    return kDYSingleObject;
}

#pragma mark - 感觉没有上面的经典
//// 重写copy方法
//- (id)copy {
//    return [self.class sharedInstance];
//}
//
//// 重写 mutableCopy 方法
//- (id)mutableCopy {
//    return [self.class sharedInstance];
//}

#pragma mark - 支持MRC
#if !__has_feature(objc_arc)
- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return 1;
}

- (id)autorelease {
    return self;
}

- (oneway void)release {
}
#endif

@end

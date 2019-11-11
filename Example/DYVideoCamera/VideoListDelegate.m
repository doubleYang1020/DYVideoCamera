//
//  VideoListDelegate.m
//  DYVideoCamera_Example
//
//  Created by videopls on 2019/11/5.
//  Copyright © 2019 doubleYang1020. All rights reserved.
//

#import "VideoListDelegate.h"

@implementation VideoListDelegate


- (void)reloadListDataWithCallBack:(DYListDataCallback _Nonnull)callback {
    NSLog(@"reloadListDataWithCallBack 1");
    callback(nil);
}
@end

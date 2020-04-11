//
//  OTSwizzleHelper.h
//  OTNotificationViewDemo
//
//  Created by openthread on 8/9/13.
//
//

#import <Foundation/Foundation.h>

@interface ComOpenThreadOTScreenshotHelperSwizzleHelper : NSObject

+ (void)swizzClass:(Class)c selector:(SEL)orig selector:(SEL)replace;

@end

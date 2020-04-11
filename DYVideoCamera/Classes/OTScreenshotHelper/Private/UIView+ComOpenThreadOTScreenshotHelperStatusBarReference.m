//
//  UIView+OTStatusBarReference.m
//  OTNotificationViewDemo
//
//  Created by openthread on 8/9/13.
//
//

static UIView *statusBarInstance = nil;

#import "UIView+ComOpenThreadOTScreenshotHelperStatusBarReference.h"
#import "ComOpenThreadOTScreenshotHelperSwizzleHelper.h"

@implementation UIView (ComOpenThreadOTScreenshotHelperStatusBarReference)

+ (UIView *)statusBarInstance_ComOpenThreadOTScreenshotHelper
{
    return statusBarInstance;
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class statusBarClass = NSClassFromString(@"UIStatusBar");
        [ComOpenThreadOTScreenshotHelperSwizzleHelper swizzClass:statusBarClass
                           selector:@selector(setFrame:)
                           selector:@selector(setFrameIntercept_ComOpenThreadOTScreenshotHelper:)];
        [ComOpenThreadOTScreenshotHelperSwizzleHelper swizzClass:statusBarClass
                           selector:NSSelectorFromString(@"dealloc")
                           selector:@selector(deallocIntercept_ComOpenThreadOTScreenshotHelper)];
    });
}

- (void)setFrameIntercept_ComOpenThreadOTScreenshotHelper:(CGRect)frame
{
    [self setFrameIntercept_ComOpenThreadOTScreenshotHelper:frame];
    statusBarInstance = self;
}

- (void)deallocIntercept_ComOpenThreadOTScreenshotHelper
{
    statusBarInstance = nil;
    [self deallocIntercept_ComOpenThreadOTScreenshotHelper];
}

@end

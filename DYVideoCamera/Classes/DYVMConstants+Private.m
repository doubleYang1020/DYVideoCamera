//
//  DYVMConstants+Private.m
//  DYVideoModule
//
//

#import "DYVMConstants+Private.h"

@implementation DYVMConstants

+ (CGFloat)screenWidth {
    return CGRectGetWidth([[UIScreen mainScreen] bounds]);
}

+ (CGFloat)screenHeight {
    return CGRectGetHeight([[UIScreen mainScreen] bounds]);
}

+ (BOOL)iPhoneX {
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    
    return iPhoneXSeries;
}

+ (UIImage * _Nullable)imageNamed:(NSString * _Nonnull)name {
    NSBundle *mainBundle = [NSBundle bundleForClass:self.class];
    NSBundle *bundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"DYVideoCameraMedia" ofType:@"bundle"]];
    UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

+ (UIColor *)colorMainTheme {
    static UIColor * color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:75.0f / 255.0f green:186.0f / 255.0f blue:188.0f / 255.0f alpha:1.0f];
    });
    return color;
}

+ (UIColor *)colorPlainText {
    static UIColor * color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor whiteColor];
    });
    return color;
}

+ (UIColor * _Nonnull)colorComponentSelected {
    return [self colorMainTheme];
}

+ (UIColor * _Nonnull)colorComponentUnselected {
    static UIColor * color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithWhite:0 alpha:0.3];
    });
    return color;
}

@end

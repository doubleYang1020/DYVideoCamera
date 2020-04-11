//
//  DYVMConstants+Private.h
//  DYVideoModule
//
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#   define Log(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define Log(...)
#endif

@interface DYVMConstants : NSObject

+ (CGFloat)screenWidth;

+ (CGFloat)screenHeight;

+ (BOOL)iPhoneX;

+ (UIImage * _Nullable)imageNamed:(NSString * _Nonnull)name;

+ (UIColor * _Nonnull)colorMainTheme;

+ (UIColor * _Nonnull)colorPlainText;

+ (UIColor * _Nonnull)colorComponentSelected;

+ (UIColor * _Nonnull)colorComponentUnselected;

@end

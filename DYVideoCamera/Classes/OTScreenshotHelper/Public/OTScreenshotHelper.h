//
//  OTScreenShotHelper.h
//  OTNotificationViewDemo
//
//  Created by openthread on 8/9/13.
//
//  Screen Capture in UIKit Applications : http://developer.apple.com/library/ios/qa/qa1703/_index.html

#import <Foundation/Foundation.h>

@interface OTScreenshotHelper : NSObject

//Get the screenshot of a view.
+ (UIImage *)screenshotOfView:(UIView *)view;

//Get the screenshot, image rotate to status bar's current interface orientation. With status bar.
+ (UIImage *)screenshot;

//Get the screenshot, image rotate to status bar's current interface orientation.
+ (UIImage *)screenshotWithStatusBar:(BOOL)withStatusBar;

//Get the screenshot with rect, image rotate to status bar's current interface orientation.
+ (UIImage *)screenshotWithStatusBar:(BOOL)withStatusBar rect:(CGRect)rect;

//Get the screenshot with rect, you can specific a interface orientation.
+ (UIImage *)screenshotWithStatusBar:(BOOL)withStatusBar rect:(CGRect)rect orientation:(UIInterfaceOrientation)o;

@end

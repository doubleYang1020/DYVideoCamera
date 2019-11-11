#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "testViewController.h"
#import "DYSingleObject.h"
#import "DYVideoListDelegate.h"
#import "DYVideoListView.h"

FOUNDATION_EXPORT double DYVideoCameraVersionNumber;
FOUNDATION_EXPORT const unsigned char DYVideoCameraVersionString[];


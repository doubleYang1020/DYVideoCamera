//
//  YCAutoHideOrShowTon.h
//  YCAutoHideOrShowTon
//
//  Created by xiaochong on 16/9/18.
//  Copyright © 2016年 尹冲. All rights reserved.
//

// Property
#define YCAutoHideOrShowTonProperty \
@property (nonatomic,strong) NSNumber *lastY; \
@property (nonatomic,strong) NSNumber *originY;

// Method
#define YCAutoHideOrShowTonMethod(navBar, tabBar) \
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView { \
    self.originY = [NSNumber numberWithFloat:scrollView.contentOffset.y]; \
    self.lastY = [NSNumber numberWithFloat:scrollView.contentOffset.y]; \
} \
- (void)scrollViewDidScroll:(UIScrollView *)scrollView { \
        if (self.lastY == nil) { \
            return; \
        } \
        CGFloat distance = scrollView.contentOffset.y - self.lastY.floatValue; \
        if (distance >= 0) { \
            if (navBar.frame.origin.y <= -44) { \
                (navBar == nil) ? : [navBar setTransform:CGAffineTransformMakeTranslation(0, -64)]; \
                (tabBar == nil) ? : [tabBar setTransform:CGAffineTransformMakeTranslation(0, 49)]; \
                return; \
            } \
        } else { \
        if (navBar.frame.origin.y >= 20) { \
            (navBar == nil) ? : [navBar setTransform:CGAffineTransformMakeTranslation(0, 0)]; \
            (tabBar == nil) ? : [tabBar setTransform:CGAffineTransformMakeTranslation(0, 0)]; \
            return; \
        } \
    } \
    self.lastY = [NSNumber numberWithFloat:scrollView.contentOffset.y]; \
    if(scrollView.contentOffset.y - self.originY.floatValue > 64 && self.originY != nil) { \
        (navBar == nil) ? : [navBar setTransform:CGAffineTransformMakeTranslation(0, -64)]; \
        (tabBar == nil) ? : [tabBar setTransform:CGAffineTransformMakeTranslation(0, 49)]; \
    } else if(self.originY.floatValue - scrollView.contentOffset.y > 64 && self.originY != nil){ \
        (navBar == nil) ? : [navBar setTransform:CGAffineTransformIdentity]; \
        (tabBar == nil) ? : [tabBar setTransform:CGAffineTransformIdentity]; \
    } else { \
        (navBar == nil) ? : [navBar setTransform:CGAffineTransformTranslate(navBar.transform, 0, -distance)]; \
        (tabBar == nil) ? : [tabBar setTransform:CGAffineTransformTranslate(tabBar.transform, 0, distance)]; \
    } \
} \
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate { \
    [self hideOrHiddenNavBar:scrollView]; \
    self.lastY = nil; \
    self.originY = nil; \
} \
- (void)hideOrHiddenNavBar:(UIScrollView *)scrollView { \
    CGFloat navY = navBar.frame.origin.y; \
    if (navY == 20 || navY == -44) { \
        return; \
    } \
    if (navY > -11) { \
        [UIView animateWithDuration:0.3 animations:^{ \
            (navBar == nil) ? : [navBar setTransform:CGAffineTransformMakeTranslation(0, 0)]; \
            (tabBar == nil) ? : [tabBar setTransform:CGAffineTransformMakeTranslation(0, 0)]; \
        }]; \
    } else { \
        [UIView animateWithDuration:0.3 animations:^{ \
            (navBar == nil) ? : [navBar setTransform:CGAffineTransformMakeTranslation(0, -64)]; \
            (tabBar == nil) ? : [tabBar setTransform:CGAffineTransformMakeTranslation(0, 49)]; \
        }]; \
        if (scrollView.contentOffset.y < 0) { \
            [scrollView setContentOffset:CGPointMake(0, 0)]; \
        } \
    } \
} \
- (void)viewWillDisappear:(BOOL)animated { \
    [super viewWillDisappear:animated]; \
    (navBar == nil) ? : [navBar setTransform:CGAffineTransformIdentity]; \
    (tabBar == nil) ? : [tabBar setTransform:CGAffineTransformIdentity]; \
}

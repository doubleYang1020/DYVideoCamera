//
//  DYSegmentPrograssView.m
//  DYVideoModule
//
//  Created by  video on 23/11/2017.
//

#import "DYSegmentPrograssView.h"
#import <Masonry/Masonry.h>

@interface DYSegmentPrograssView()

@property (strong, nonatomic) NSMutableArray<NSNumber *> * segmentStack;
@property (strong, nonatomic) NSMutableArray<UIView *> * segmentViews;
@property (strong, nonatomic) UIView * progressingView;

@end

@implementation DYSegmentPrograssView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
        return self;
    }
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
        return self;
    }
    return nil;
}

- (void)setup {
    self.segmentColor = [UIColor whiteColor];
    self.segmentViews = [@[] mutableCopy];
    self.segmentStack = [@[] mutableCopy];
    self.progressingView = [self newSegmentView];
    [self.layer setCornerRadius:CGRectGetMidY(self.bounds)];
    [self setClipsToBounds:YES];
}

- (void)setColor:(UIColor * _Nullable)color toSegmentIndex:(NSUInteger)index {
    if ([self.segmentViews count] == 0) return;
    
    if (index == -1) {
        [[self.segmentViews lastObject] setBackgroundColor:color];
        return;
    }
    [[self.segmentViews objectAtIndex:index] setBackgroundColor:color];
}

- (void)addProgressSegment:(float)progress {
    assert(progress + [self currentProgress] <= 1.01);
    
    UIView *v = [self newSegmentView];
    [self addSubview:v];
    
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(self).with.multipliedBy(progress);
        if (self.segmentStack.count == 0) {
            make.left.equalTo(self);
        }
        else {
            UIView *previousView = self.segmentViews.lastObject;
            assert(previousView != nil);
            make.left.equalTo(previousView.mas_right).with.offset(1);
        }
    }];
    
    [self.segmentStack addObject:@(progress)];
    [self.segmentViews addObject:v];
    
    [self stopAnimation];
    
}

- (float)removeLastSegment {
    float lastProgress = [self.segmentStack.lastObject floatValue];
    [self.segmentStack removeLastObject];
    [self.segmentViews.lastObject removeFromSuperview];
    [self.segmentViews removeLastObject];
    
    assert(self.segmentStack.count == self.segmentViews.count);
    return lastProgress;
}

- (float)currentProgress {
    NSNumber *progress = [self.segmentStack valueForKeyPath:@"@sum.self"];
    return [progress floatValue];
}

- (void)startAnimationWithMaxDuration:(float)maxDuration {
    CGFloat offset = 0;
    if (self.segmentViews.count > 0) offset = 1;
    CGFloat x = CGRectGetMaxX(self.segmentViews.lastObject.frame) + offset; // add 1 for left margin
    [self.progressingView setFrame:CGRectMake(x, 0, 0, CGRectGetHeight(self.bounds))];
    [self addSubview:self.progressingView];
    [UIView animateWithDuration:maxDuration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.progressingView setFrame:CGRectMake(x, 0, CGRectGetWidth(self.bounds) - x, CGRectGetHeight(self.bounds))];
    } completion:nil];
}

- (void)stopAnimation {
    [self.progressingView removeFromSuperview];
    [self.progressingView.layer removeAllAnimations];
    
}

- (void)addSegmentSeperatorAt:(float)progress {
    UIView *segmentView = [self newSegmentView];
    [self addSubview:segmentView];
    [segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@1);
        make.height.equalTo(self);
        make.top.equalTo(self);
        make.left.equalTo(self.mas_right).with.multipliedBy(progress);
    }];
}

#pragma mark - helper methods

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.layer setCornerRadius:CGRectGetMidY(self.bounds)];
}

//- (void)appendSegmentViewWith

- (UIView *)newSegmentView {
    UIView * v = [[UIView alloc] init];
    [v setBackgroundColor:self.segmentColor];
    return v;
}

#pragma mark - getter & setter

- (void)setSegmentColor:(UIColor *)segmentColor {
    if (_segmentColor == segmentColor) return;
    _segmentColor = segmentColor;
    [self.segmentViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setBackgroundColor:segmentColor];
    }];
    [self.progressingView setBackgroundColor:segmentColor];
}

@end

//
//  DYSegmentPrograssView.h
//  DYVideoModule
//
//  Created by  video on 23/11/2017.
//

#import <UIKit/UIKit.h>


@interface DYSegmentPrograssView : UIView

@property (strong, nonatomic) IBInspectable UIColor * _Nonnull segmentColor;

- (void)addSegmentSeperatorAt:(float)progress;

- (void)setColor:(UIColor * _Nullable)color toSegmentIndex:(NSUInteger)index;

- (void)addProgressSegment:(float)progress;

- (float)removeLastSegment;

- (float)currentProgress;

- (void)startAnimationWithMaxDuration:(float)maxDuration;

@end

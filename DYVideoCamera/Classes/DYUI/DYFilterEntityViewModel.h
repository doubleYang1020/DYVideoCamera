//
//  DYFilterEntityViewModel.h
//  DYVideoModule
//
//

#import <Foundation/Foundation.h>
#import "DYFilterEntity.h"

@interface DYFilterEntityViewModel : NSObject <DYFilterEntity>

@property (strong, nonatomic)UIImage * _Nullable filterPatternImage;

@property (strong, nonatomic)UIImage * _Nonnull filteredImage;

@property (strong, nonatomic)NSString * _Nonnull Title;

+ (NSArray<DYFilterEntityViewModel * > * _Nonnull)modelFromFilters:(NSArray<id<DYFilterEntity>> * _Nonnull)filters forImage:(UIImage * _Nonnull)image;

@end

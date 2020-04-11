//
//  DYFilterEntityViewModel.m
//  DYVideoModule
//
//  Created by  video on 27/11/2017.
//

#import "DYFilterEntityViewModel.h"
#import "DYVideoSDK.h"


@implementation DYFilterEntityViewModel

+ (NSArray<DYFilterEntityViewModel * > * _Nonnull)modelFromFilters:(NSArray<id<DYFilterEntity>> *)filters forImage:(UIImage *)image {
    NSMutableArray<DYFilterEntityViewModel * > *result = [@[] mutableCopy];

    [filters enumerateObjectsUsingBlock:^(id<DYFilterEntity>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *filtredImage;
        if ([obj filterImage] == nil) {
            filtredImage = image;
        }
        else {
            filtredImage = [DYVideoProcessEngine applyFilterToImageWithInputImage:image LookupImage:[obj filterImage]];
        }
        DYFilterEntityViewModel *m = [[DYFilterEntityViewModel alloc] init];
        [m setTitle:[obj title]];
        [m setFilterPatternImage:[obj filterImage]];
        [m setFilteredImage:filtredImage];
        [result addObject:m];
    }];
    
    return [result copy];
}

- (UIImage * _Nullable)filterImage { 
    return _filterPatternImage;
}

- (NSString * _Nonnull)Title { 
    return _Title;
}

@end

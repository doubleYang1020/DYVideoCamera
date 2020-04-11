#import "DYAssetModel.h"
#import "DYImageManager.h"

@implementation DYAssetModel

+ (instancetype)modelWithAsset:(id)asset type:(DYAssetModelMediaType)type{
    DYAssetModel *model = [[DYAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(id)asset type:(DYAssetModelMediaType)type timeLength:(NSString *)timeLength {
    DYAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

- (CMTime)duration {
    CMTime result = kCMTimeInvalid;
    if ([self.asset isKindOfClass:[AVAsset class]]) {
        result = [(AVAsset *)self.asset duration];
    }
    else if ([self.asset isKindOfClass:[PHAsset class]]) {
        NSTimeInterval time = [(PHAsset *)self.asset duration];
        result = CMTimeMake(time * 600, 600);
    }
    return result;
}

@end



@implementation TZAlbumModel

- (void)setResult:(id)result {
    _result = result;
    BOOL allowPickingImage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tz_allowPickingImage"] isEqualToString:@"1"];
    BOOL allowPickingVideo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tz_allowPickingVideo"] isEqualToString:@"1"];
    allowPickingImage = false;
    allowPickingVideo = true;
    [[DYImageManager manager] getAssetsFromFetchResult:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage completion:^(NSArray<DYAssetModel *> *models) {
        _models = models;
        if (_selectedModels) {
            [self checkSelectedModels];
        }
    }];
}

- (void)setSelectedModels:(NSArray *)selectedModels {
    _selectedModels = selectedModels;
    if (_models) {
        [self checkSelectedModels];
    }
}

- (void)checkSelectedModels {
    self.selectedCount = 0;
    NSMutableArray *selectedAssets = [NSMutableArray array];
    for (DYAssetModel *model in _selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (DYAssetModel *model in _models) {
        if ([[DYImageManager manager] isAssetsArray:selectedAssets containAsset:model.asset]) {
            self.selectedCount ++;
        }
    }
}

- (NSString *)name {
    if (_name) {
        return _name;
    }
    return @"";
}

@end

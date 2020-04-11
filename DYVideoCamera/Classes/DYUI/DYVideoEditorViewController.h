//
//  DYVideoEditorViewController.h
//  DYVideoModule
//
//  Created by  video on 22/11/2017.
//

#import <UIKit/UIKit.h>
#import "DYVideoModuleDataSource.h"
#import "DYMusicEntity.h"

@interface DYVideoEditorViewController : UIViewController

@property (weak, nonatomic) id<DYVideoModuleDataSource> _Nullable videoModelDataSource;
@property (strong, nonatomic) NSURL * _Nonnull videoURL;
@property (strong, nonatomic) id<DYMusicEntity> _Nullable musicEntity;

- (instancetype _Nullable)initWithVideoURL:(NSURL * _Nonnull)videoUrl;

@end

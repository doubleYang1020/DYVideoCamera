//
//  DYOnlineMusicLibraryViewController.h
//  DYVideoModule
//
//  Created by huyangyang on 2017/11/23.
//

#import <UIKit/UIKit.h>
#import "DYVideoModuleDataSource.h"

@protocol DYOnlineMusicLibraryViewControllerDelegate <NSObject>//协议
-(void)choseMusicComplete:(id<DYMusicEntity>)musicItem andVideoVolum:(float)videoVolum andMusicVolum:(float)musicVolum;
@end

@interface DYOnlineItemCollectionViewCell : UICollectionViewCell
@end

@interface DYOnlineMusicLibraryCell : UITableViewCell
@property (nonatomic , strong) id<DYMusicEntity> musicModel;
-(void)updateMusicProgress:(float)progress;
@end

@interface DYOnlineMusicLibraryViewController : UIViewController
@property (weak, nonatomic) id<DYVideoModuleDataSource> videoModelDataSource;
@property (nonatomic, assign) id<DYOnlineMusicLibraryViewControllerDelegate>delegate;//代理属性
@end




//
//  DYVideoEditorController.h
//  DYVideoTrimController
//
//  Created by huyangyang on 2018/1/9.
//  Copyright © 2018年 com.huyangyang.landscapePhotography. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DYVideoEditorControllerDelegate <NSObject>//协议
- (void)DYVideoEditorControllerDidSaveEditedVideoToPath:(NSString *)editedVideoPath;
- (void)DYVideoEditorControllerDidCancel;
- (void)showHUDForExportering;
@end

@interface DYVideoEditorController : UIViewController
//@property (nonatomic, strong)
@property (nonatomic, strong) NSURL* videoURL;
@property (nonatomic, strong) NSString* leftBtnTitle;
@property (nonatomic, strong) NSString* rightBtnTiltle;
@property (nonatomic, assign) NSInteger videoMaximumDuration;
@property (nonatomic, assign) NSInteger videoMinimumDuration;
@property (nonatomic, assign) id<DYVideoEditorControllerDelegate>delegate;//代理属性
@end

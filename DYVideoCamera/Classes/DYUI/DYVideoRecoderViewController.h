//
//  DYVideoRecoderViewController.h
//  DYVideoModule
//
//  Created by  video on 21/11/2017.
//  Copyright © 2017 co.thel.module.video. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYVideoModuleDataSource.h"

@interface DYVideoRecoderViewController : UIViewController

@property (weak, nonatomic) id<DYVideoModuleDataSource> videoModelDataSource;

@end

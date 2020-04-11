//
//  VideoModuleDataSource.h
//  RelaVideoContainer
//
//  Created by hirochin on 21/11/2017.
//  Copyright © 2017 thel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DYVideoCamera/DYVideoModule.h>

@interface VideoModuleDataSourceMock : NSObject <DYVideoModuleDataSource>

@property (weak, nonatomic) UIViewController *holder;

@end

//
//  FilterEntity.h
//  RelaVideoModule_Example
//
//  Created by hirochin on 27/11/2017.
//  Copyright © 2017 Chen Hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DYVideoCamera/DYVideoModule.h>

@interface FilterEntity : NSObject <DYFilterEntity>

@property (strong, nonatomic) UIImage * _Nullable filterImage;
@property (strong, nonatomic) NSString * _Nonnull title;

- (instancetype _Nullable )initWithImage:(UIImage * _Nullable)image title:(NSString * _Nonnull)title;

@end

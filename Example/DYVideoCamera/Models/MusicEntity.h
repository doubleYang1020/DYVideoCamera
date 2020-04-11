//
//  TLMusicEntity.h
//  RelaVideoModule_Example
//
//  Created by hirochin on 23/11/2017.
//  Copyright © 2017 Chen Hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DYVideoCamera/DYVideoModule.h>

@interface MusicEntity: NSObject <DYMusicEntity>
@property (nonatomic, assign) NSUInteger musicId;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * artist;
@property (nonatomic, assign) NSUInteger duration;
@property (nonatomic, strong) NSString * category;
@property (nonatomic, assign) NSUInteger status;
@property (nonatomic, strong) NSString * url;

+ (instancetype)initWithDict:(NSDictionary<NSString *, NSObject *> *)dict;

+ (NSArray<id<DYMusicEntity>> *)musicsFromArray:(NSArray<NSDictionary<NSString *, NSObject *> *> *)array;

@end

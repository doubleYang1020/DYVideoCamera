//
//  TLMusicEntity.m
//  RelaVideoModule_Example
//
//  Created by hirochin on 23/11/2017.
//  Copyright © 2017 Chen Hao. All rights reserved.
//

#import "MusicEntity.h"

@implementation MusicEntity

+ (instancetype)initWithDict:(NSDictionary<NSString *, NSObject *> *)dict {
    MusicEntity *entity = [[MusicEntity alloc] init];
    entity.musicId = [(NSNumber *)dict[@"musicId"] unsignedIntegerValue];
    entity.name = (NSString *) dict[@"name"];
    entity.artist = (NSString *) dict[@"singer"];
    entity.duration = [(NSNumber *)dict[@"musicHours"] unsignedIntegerValue];
    entity.category = (NSString *)dict[@"categoryName"];
    entity.status = [(NSNumber *)dict[@"collectStatus"] unsignedIntegerValue];
    entity.url = (NSString *) dict[@"url"];
    

    return entity;
}

+ (NSArray<id<DYMusicEntity>> *)musicsFromArray:(NSArray<NSDictionary<NSString *, NSObject *> *> *)array {
    __block NSMutableArray * result = [@[] mutableCopy];
    [array enumerateObjectsUsingBlock:^(NSDictionary<NSString *,NSObject *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [result addObject:[MusicEntity initWithDict:obj]];
    }];
    return [result copy];
}

@end

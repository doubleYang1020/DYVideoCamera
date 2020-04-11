//
//  DYMusicEntity.h
//  DYVideoModule
//

#import <Foundation/Foundation.h>

@protocol DYMusicEntity <NSObject>

- ( NSUInteger )musicId;
- ( NSString * _Nonnull )name;
- ( NSString * _Nonnull )artist;
- ( NSUInteger )duration;
- ( NSString * _Nonnull )category;
- ( NSInteger )status;
- ( NSString * _Nonnull )url;

@end

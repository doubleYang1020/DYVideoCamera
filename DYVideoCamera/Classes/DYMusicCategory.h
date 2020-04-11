//
//  DYMusicCategory.h
//  DYVideoModule
//
//  Created by  video on 23/11/2017.
//

#import <Foundation/Foundation.h>

@protocol DYMusicCategory <NSObject>

- (UIImage * _Nonnull)imageNormal;

- (UIImage * _Nonnull)imageSelected;

- (NSString * _Nonnull)title;

@end

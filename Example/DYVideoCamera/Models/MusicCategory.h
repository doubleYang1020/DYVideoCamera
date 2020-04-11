//
//  TLMusicCategory.h
//  RelaVideoModule_Example
//
//  Created by hirochin on 23/11/2017.
//  Copyright © 2017 Chen Hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DYVideoCamera/DYVideoModule.h>

@interface MusicCategory: NSObject <DYMusicCategory>
@property (nonatomic, strong) UIImage * imageNormal;
@property (nonatomic, strong) UIImage * imageSelected;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * idx;

-(instancetype)initWithImageNormal:(UIImage *)imageorMal andImageSelected:(UIImage *)imageSelected AndTitle:(NSString *)title AndIdx:(NSString *)idx;
@end




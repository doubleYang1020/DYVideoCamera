//
//  TLMusicCategory.m
//  RelaVideoModule_Example
//
//  Created by hirochin on 23/11/2017.
//  Copyright © 2017 Chen Hao. All rights reserved.
//

#import "MusicCategory.h"

@implementation MusicCategory
-(instancetype)initWithImageNormal:(UIImage *)imageorMal andImageSelected:(UIImage *)imageSelected AndTitle:(NSString *)title AndIdx:(NSString *)idx{
    self = [super init];
    if (self) {
        self.imageNormal = imageorMal;
        self.imageSelected = imageSelected;
        self.title = title;
        self.idx = idx;
    }
    return self;
}
@end

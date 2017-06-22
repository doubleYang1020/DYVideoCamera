//
//  VideoLisetCell.h
//  DYVideoCamera
//
//  Created by huyangyang on 2017/6/22.
//  Copyright © 2017年 huyangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoDataModel.h"
@interface VideoLisetCell : UITableViewCell
@property (nonatomic ,strong) UIImageView* coverImgView;
@property (nonatomic, strong) UIButton                      *playBtn;
@property (nonatomic, copy  ) void(^playBlock)(UIButton *);
@property (nonatomic , strong) VideoDataModel* DataModel;

- (void)play:(UIButton *)sender ;
@end

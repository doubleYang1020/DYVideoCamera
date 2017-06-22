//
//  VideoLisetCell.m
//  DYVideoCamera
//
//  Created by huyangyang on 2017/6/22.
//  Copyright © 2017年 huyangyang. All rights reserved.
//

#import "VideoLisetCell.h"
#import "SDImageCache.h"
#import "masonry.h"
#import "UIImageView+WebCache.h"
@implementation VideoLisetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _coverImgView = [[UIImageView alloc] init];
    [self.contentView addSubview:_coverImgView];
    _coverImgView.tag = 101;
    UIView* superView = self.contentView;
    _coverImgView.userInteractionEnabled  =   YES;
    //        [[AppDelegate appDelegate].cmImageSize setImagesRounded:_videoCoverImageView cornerRadiusValue:3 borderWidthValue:0 borderColorWidthValue:[UIColor whiteColor]];

    _coverImgView.contentMode = UIViewContentModeScaleAspectFill;
    [_coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.left.right.bottom.equalTo(superView);
    }];

    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setImage:[UIImage imageNamed:@"video_list_cell_big_icon"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [_coverImgView addSubview:self.playBtn];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.center.equalTo(_coverImgView);
      make.width.height.mas_equalTo(50);
    }];
    //        self.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
  }
  return self;
}

- (void)play:(UIButton *)sender {
  if (self.playBlock) {
    self.playBlock(sender);
  }
}

-(void)setDataModel:(VideoDataModel *)DataModel
{
  _DataModel = DataModel;
  [_coverImgView sd_setImageWithURL:[NSURL URLWithString:DataModel.cover_url] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"usericon02" ofType:@"png"]]];


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  VideoCommentsTableViewCell.m
//  iShow
//
//  Created by 胡阳阳 on 17/2/25.
//
//

#import "VideoCommentsTableViewCell.h"
#import "SDImageCache.h"
#import "masonry.h"
#import "UIImageView+WebCache.h"

@interface VideoCommentsTableViewCell()

@end

@implementation VideoCommentsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
        self.backgroundColor = [UIColor whiteColor];
        UIView* superView = self.contentView;
        
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"usericon02" ofType:@"png"]];
//        [[AppDelegate appDelegate].cmImageSize setImagesRounded:_iconImgView cornerRadiusValue:15 borderWidthValue:0 borderColorWidthValue:[UIColor whiteColor]];
        _iconImgView.layer.masksToBounds = YES;
        _iconImgView.layer.cornerRadius = 15;
        [superView addSubview:_iconImgView];
        [_iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(superView).offset(8);
            make.width.height.equalTo(@(30));
        }];
        
        _nickeNameLabel = [[UILabel alloc] init];
        _nickeNameLabel.text = @"";
        _nickeNameLabel.font = [UIFont systemFontOfSize:14];
        _nickeNameLabel.textAlignment = NSTextAlignmentLeft;
        _nickeNameLabel.textColor = [UIColor blackColor];
        [superView addSubview:_nickeNameLabel];
        [_nickeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_iconImgView);
            make.left.equalTo(_iconImgView.mas_right).offset(8);
        }];
        
        UIImageView* goodImgView = [[UIImageView alloc] init];
        goodImgView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xggood" ofType:@""]];
        [superView addSubview:goodImgView];
        [goodImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_iconImgView);
            make.right.equalTo(superView).offset(-12);
            make.height.width.equalTo(@(15));
        }];
        goodImgView.hidden = YES;
        
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.text = @"刚刚";
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.textColor = [UIColor grayColor];
        [superView addSubview:_timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(superView).offset(-8);
            make.left.equalTo(_iconImgView.mas_right).offset(8);
        }];
        
        _commentLabel = [[UILabel alloc] init];
        _commentLabel.numberOfLines = 0;
        _commentLabel.font = [UIFont systemFontOfSize:12];
        [superView addSubview:_commentLabel];
        [_commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iconImgView.mas_bottom);
            make.left.equalTo(_iconImgView.mas_right).offset(8);
            make.bottom.equalTo(superView).offset(-26);
            make.right.lessThanOrEqualTo(superView).offset(-30);
            
        }];
        
        UIView* lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor grayColor];
        lineView.alpha = .4;
        [superView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(superView);
            make.left.equalTo(_iconImgView.mas_right).offset(8);
             make.right.equalTo(superView);
            make.height.equalTo(@(0.7));
        }];
        
    }
    return self;
}

@end

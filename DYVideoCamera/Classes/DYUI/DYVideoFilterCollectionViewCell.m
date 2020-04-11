//
//  DYVideoFilterCollectionViewCell.m
//  FBSnapshotTestCase
//
//  Created by  video on 27/11/2017.
//

#import "DYVideoFilterCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import "DYVMConstants+Private.h"

@interface DYVideoFilterCollectionViewCell() {
    UILabel * _TitleLabel;
    UIImageView * _imageView;
}

@end

@implementation DYVideoFilterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
        return self;
    }
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
        return self;
    }
    return nil;
}

- (void)setup {
    _TitleLabel = [[UILabel alloc] init];
    _imageView = [[UIImageView alloc] init];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    [_imageView.layer setCornerRadius:5];
    [_imageView setClipsToBounds:YES];
    
    [_TitleLabel setTextAlignment:NSTextAlignmentCenter];
    [_TitleLabel setFont:[UIFont systemFontOfSize:11]];
    
    [self.contentView addSubview:_TitleLabel];
    [self.contentView addSubview:_imageView];
    
    [_TitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo(@15);
    }];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo(@50);
    }];

}

#pragma mark - getter & setter

- (void)setTitle:(NSString *)Title {
    _Title = Title;
    
    [_TitleLabel setText:Title];
}

- (void)setCover:(UIImage *)cover {
    _cover = cover;
    
    [_imageView setImage:cover];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        [_TitleLabel setTextColor:[DYVMConstants colorComponentSelected]];
        [_TitleLabel setFont:[UIFont fontWithName:@"PingFangSC-Semibold" size:11]];
    }
    else {
        [_TitleLabel setTextColor:[DYVMConstants colorComponentUnselected]];
        [_TitleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:11]];
    }
}

@end

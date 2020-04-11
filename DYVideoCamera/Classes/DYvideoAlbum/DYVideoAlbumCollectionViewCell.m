//
//  DYVideoAlbumCollectionViewCell.m
//  DYVideoPickerController
//
//  Created by huyangyang on 2017/11/22.
//  Copyright © 2017年 HuYangYang.com. All rights reserved.
//

#import "DYVideoAlbumCollectionViewCell.h"
#import "DYImageManager.h"
#import "DYVMConstants+Private.h"
@interface DYVideoAlbumCollectionViewCell()

@property (nonatomic ,strong) UIImageView* CoverImageView;
@property (nonatomic ,strong) UIImageView* selectedStyleImageView;
@property (nonatomic ,strong) UILabel* timeLabel;
@end

@implementation DYVideoAlbumCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat cellWidth = ([UIScreen mainScreen].bounds.size.width - 2 )/3;
        _CoverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cellWidth , cellWidth )];
        [self.contentView addSubview:_CoverImageView];
        _CoverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _CoverImageView.clipsToBounds = true;
        
        _selectedStyleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(cellWidth - 26, 5, 21, 21)];
        _selectedStyleImageView.image = [DYVMConstants imageNamed:@"icVideoAlbumSelected"];
        [self.contentView addSubview:_selectedStyleImageView];
        
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:12];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.frame = CGRectMake(5, cellWidth - 20, cellWidth - 10 , 15);
        _timeLabel.textColor = [UIColor whiteColor];

        _timeLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _timeLabel.shadowOffset = CGSizeMake(0, 1);
        [self.contentView addSubview:_timeLabel];
    }
    return self;
}

-(void)setModel:(DYAssetModel *)model{
    _model = model;
    [[DYImageManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        _CoverImageView.image = photo;
    }];
    _timeLabel.text = model.timeLength;
    [_selectedStyleImageView setHidden:!model.isSelected] ;
}


@end


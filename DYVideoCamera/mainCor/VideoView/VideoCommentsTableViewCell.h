//
//  VideoCommentsTableViewCell.h
//  iShow
//
//  Created by 胡阳阳 on 17/2/25.
//
//

#import <UIKit/UIKit.h>

@interface VideoCommentsTableViewCell : UITableViewCell
@property (nonatomic ,strong) UILabel* titleLabel;
@property (nonatomic ,strong) UILabel* timeLabel;
@property (nonatomic ,strong) UIImageView* iconImgView;
@property (nonatomic ,strong) UILabel* nickeNameLabel;
@property (nonatomic ,strong) UILabel* commentLabel;
@end

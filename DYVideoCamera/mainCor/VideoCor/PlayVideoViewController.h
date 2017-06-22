//
//  PlayVideoViewController.h
//  iShow
//
//  Created by 胡阳阳 on 17/2/24.
//
//

#import <UIKit/UIKit.h>
#import "VideoDataModel.h"
@interface PlayVideoViewController : UIViewController

@property (nonatomic , strong) VideoDataModel* DataModel;
@property (nonatomic , assign) BOOL whenBackIsNeedhiddenBottomBar;
@end

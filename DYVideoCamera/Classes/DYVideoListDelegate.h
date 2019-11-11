//
//  DYVideoListDelegate.h
//  DYVideoCamera
//
//  Created by videopls on 2019/11/5.
//

#import <Foundation/Foundation.h>

typedef void (^DYListDataCallback)(NSArray<NSDictionary*> * _Nullable);

@protocol DYVideoListDelegate <NSObject>
-(void)reloadListDataWithCallBack:(DYListDataCallback _Nonnull)callback;
@end


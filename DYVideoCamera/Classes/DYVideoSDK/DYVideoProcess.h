//
//  DYDYVideoProcess.h
//  KPI_Feb
//
//  Created by  video on 01/03/2018.
//  Copyright © 2018 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImage.h>


@interface DYDYVideoProcess : NSObject

typedef void (^Completion)(void);
typedef void (^Progress)(float);

+ (instancetype _Nonnull)sharedInstance;

+ (void)applyFilter:(GPUImageOutput<GPUImageInput> * _Nonnull)filter
             source:(GPUImageMovie * _Nonnull)movie
        destination:(NSURL * _Nonnull)destination
     outputSettings:(NSDictionary * _Nonnull)outputSettings
      cancelProcess:(BOOL * _Nullable)cancel;

+ (NSDictionary * _Nonnull)videoOutputSettingFromURL:(NSURL * _Nonnull)url bitRate:(NSNumber * _Nonnull)bitRate;

- (void)asyncApplyFilter:(GPUImageOutput<GPUImageInput> * _Nonnull)filter
                  source:(NSURL * _Nonnull)source
             destination:(NSURL * _Nonnull)destination
          outputSettings:(NSDictionary * _Nonnull)outputSettings
           cancelProcess:(BOOL * _Nullable)cancel
                progress:(Progress _Nullable)progress
              completion:(Completion _Nullable)completion;

@end

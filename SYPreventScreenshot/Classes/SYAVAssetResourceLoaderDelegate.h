//
//  SYAVAssetResourceLoaderDelegate.h
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/11.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
@class SYServerManager;
typedef void (^SYAVAssetResourceLoaderDelegateErrorBlock)(
    NSError *_Nullable error);
NS_ASSUME_NONNULL_BEGIN

@interface SYAVAssetResourceLoaderDelegate
    : NSObject <AVAssetResourceLoaderDelegate>

@property(nonatomic, strong) SYServerManager *serverManager;
@property(nonatomic, copy) NSString *videoPath;
@property(nonatomic, copy) NSData *mp4Data;
- (instancetype)initWithMP4Data:(NSData *)data
                     errorBlock:
                         (SYAVAssetResourceLoaderDelegateErrorBlock)errorBlock;
@end

NS_ASSUME_NONNULL_END

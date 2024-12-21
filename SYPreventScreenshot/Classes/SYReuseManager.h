//
//  SYReuseManager.h
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/9.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SYPreventSampleBufferDisplayLayerView;
NS_ASSUME_NONNULL_BEGIN

@interface SYReuseManager : NSObject

@property(nonatomic, strong, class, readonly) SYReuseManager *sharedManager;
- (SYPreventSampleBufferDisplayLayerView *)dequeueSampleBufferDisplayLayerView;
- (void)enqueueSampleBufferDisplayLayerView:
    (SYPreventSampleBufferDisplayLayerView *)sampleBufferDisplayLayerView;

@end

NS_ASSUME_NONNULL_END

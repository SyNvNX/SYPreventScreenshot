//
//  SYReuseManager.m
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/9.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import "SYReuseManager.h"
#import "SYMacros.h"
#import "SYPreventSampleBufferDisplayLayerView.h"
#import <AVFoundation/AVFoundation.h>

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@interface SYReuseManager ()

@property(nonatomic, strong) dispatch_queue_t queue;
@property(nonatomic, strong)
    NSMutableSet<SYPreventSampleBufferDisplayLayerView *>
        *sampleBufferDisplayLayerViewReuseSet;

@end

@implementation SYReuseManager

- (instancetype)init {
    if (self = [super init]) {
        _queue =
            dispatch_queue_create("com.sy.pool.queue", DISPATCH_QUEUE_SERIAL);
        _sampleBufferDisplayLayerViewReuseSet = [NSMutableSet set];
    }
    return self;
}

+ (SYReuseManager *)sharedManager {
    static SYReuseManager *_pool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      _pool = [[self alloc] init];
    });
    return _pool;
}

- (SYPreventSampleBufferDisplayLayerView *)dequeueSampleBufferDisplayLayerView {
    __block SYPreventSampleBufferDisplayLayerView *view = nil;
    dispatch_sync(self.queue, ^{
      view = self.sampleBufferDisplayLayerViewReuseSet.anyObject;
      if (view) {
          [self.sampleBufferDisplayLayerViewReuseSet removeObject:view];
      } else {
          view = [[SYPreventSampleBufferDisplayLayerView alloc] init];
      }
    });
    assert(view != nil);
    return view;
}

- (void)enqueueSampleBufferDisplayLayerView:
    (SYPreventSampleBufferDisplayLayerView *)sampleBufferDisplayLayerView {
    dispatch_async(dispatch_get_main_queue(), ^{
      CALayer *layer = sampleBufferDisplayLayerView.layer;
      if ([layer isKindOfClass:AVSampleBufferDisplayLayer.class]) {
          AVSampleBufferDisplayLayer *sampleBufferDisplayLayer =
              (AVSampleBufferDisplayLayer *)layer;
          [sampleBufferDisplayLayer flushAndRemoveImage];
          sampleBufferDisplayLayer.bounds = CGRectZero;
          sampleBufferDisplayLayer.videoGravity =
              AVLayerVideoGravityResizeAspect;
          dispatch_async(self.queue, ^{
            if (self.sampleBufferDisplayLayerViewReuseSet.count <= 100) {
                [self.sampleBufferDisplayLayerViewReuseSet
                    addObject:sampleBufferDisplayLayerView];
            }
          });
      }
    });
}

@end

//
//  SYReuseManager.m
//
// Copyright (c) 2024 SyNvNX (https://github.com/SyNvNX)
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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

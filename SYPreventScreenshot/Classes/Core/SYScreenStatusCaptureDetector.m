//
//  SYScreenCaptureDetector.m
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/9.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import "SYScreenStatusCaptureDetector.h"
#import "SYMacros.h"
#import "SYScreenStatusCaptureObserver.h"

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

static void *SYScreenStatusCaptureDetectorKVOContext =
    &SYScreenStatusCaptureDetectorKVOContext;
@implementation SYScreenStatusCaptureDetector

- (instancetype)init {
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    self.screenCaptureObserver = [SYScreenStatusCaptureObserver instance];
    [self.screenCaptureObserver
        addObserver:self
         forKeyPath:@"isApplicationActive"
            options:0
            context:SYScreenStatusCaptureDetectorKVOContext];

    [self.screenCaptureObserver
        addObserver:self
         forKeyPath:@"isScreenBeingMirrored"
            options:0
            context:SYScreenStatusCaptureDetectorKVOContext];
    [self.screenCaptureObserver
        addObserver:self
         forKeyPath:@"isScreenBeingRecordedByQuickTime"
            options:0
            context:SYScreenStatusCaptureDetectorKVOContext];
    [self.screenCaptureObserver
        addObserver:self
         forKeyPath:@"isScreenBeingRecordedOnDevice"
            options:0
            context:SYScreenStatusCaptureDetectorKVOContext];
    [self updateState];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    if (context == SYScreenStatusCaptureDetectorKVOContext) {
        [self updateState];
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)dealloc {
    [self.screenCaptureObserver removeObserver:self
                                    forKeyPath:@"isApplicationActive"];
    [self.screenCaptureObserver removeObserver:self
                                    forKeyPath:@"isScreenBeingMirrored"];
    [self.screenCaptureObserver
        removeObserver:self
            forKeyPath:@"isScreenBeingRecordedByQuickTime"];
    [self.screenCaptureObserver
        removeObserver:self
            forKeyPath:@"isScreenBeingRecordedOnDevice"];
    self.screenCaptureObserver = nil;
}

- (void)updateState {
    dispatch_main_sync_safe(^{
      BOOL isApplicationActive = self.screenCaptureObserver.isApplicationActive;
      BOOL isScreenBeingMirrored =
          self.screenCaptureObserver.isScreenBeingMirrored;
      BOOL isScreenBeingRecordedByQuickTime =
          self.screenCaptureObserver.isScreenBeingRecordedByQuickTime;
      BOOL isScreenBeingRecordedOnDevice =
          self.screenCaptureObserver.isScreenBeingRecordedOnDevice;

      BOOL isCaptured = isScreenBeingMirrored ||
                        isScreenBeingRecordedByQuickTime ||
                        isScreenBeingRecordedOnDevice;
      if (isCaptured != self.isCaptured) {
          self.captured = isCaptured;
      }

      BOOL shouldHideContent = isCaptured || !isApplicationActive;
      if (shouldHideContent != self.shouldHideContent) {
          self.shouldHideContent = shouldHideContent;
      }

      if (isCaptured != self.shouldShowScreenCaptureView) {
          self.shouldShowScreenCaptureView = isCaptured;
      }

      BOOL mayShowScreenCaptureView = isCaptured || (isApplicationActive);
      if (mayShowScreenCaptureView != self.mayShowScreenCaptureView) {
          self.mayShowScreenCaptureView = mayShowScreenCaptureView;
      }

      if (isScreenBeingRecordedByQuickTime !=
          self.isScreenBeingRecordedByQuickTime) {
          self.isScreenBeingRecordedByQuickTime =
              isScreenBeingRecordedByQuickTime;
          if (!isScreenBeingRecordedByQuickTime) {
              if ([self.delegate respondsToSelector:@selector
                                 (screenStatusCaptureDetectorShouldReload:)]) {
                  [self.delegate screenStatusCaptureDetectorShouldReload:self];
              }
          }
      }
    });
}

@end

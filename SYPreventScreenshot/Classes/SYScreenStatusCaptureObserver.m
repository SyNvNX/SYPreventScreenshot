//
//  SYScreenStatusCaptureObserver.m
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/14.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import "SYScreenStatusCaptureObserver.h"
#import "SYWeakProxy.h"
#import <AVFoundation/AVFoundation.h>
#import <libkern/OSAtomic.h>

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@interface SYScreenStatusCaptureObserver ()
@property(nonatomic, strong) CADisplayLink *screenRecordingDetectionDisplayLink;

@end

@interface SYScreenStatusCaptureObserver () {
    BOOL _isStatusBarIndicatingPotentialScreenRecording;
}
@end

@implementation SYScreenStatusCaptureObserver

+ (instancetype)instance {
    static __weak SYScreenStatusCaptureObserver *instance;
    SYScreenStatusCaptureObserver *strongInstance = instance;
    @synchronized(self) {
        if (strongInstance == nil) {
            strongInstance = [[[self class] alloc] init];
            instance = strongInstance;
        }
    }
    return strongInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    BOOL isActive = UIApplication.sharedApplication.applicationState ==
                    UIApplicationStateActive;
    self.isApplicationActive = isActive;

    [NSNotificationCenter.defaultCenter
        addObserver:self
           selector:@selector(applicationWillResignActive:)
               name:UIApplicationWillResignActiveNotification
             object:nil];

    [NSNotificationCenter.defaultCenter
        addObserver:self
           selector:@selector(applicationDidBecomeActive:)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];

    [NSNotificationCenter.defaultCenter
        addObserver:self
           selector:@selector(updateState)
               name:UIScreenDidConnectNotification
             object:nil];
    [NSNotificationCenter.defaultCenter
        addObserver:self
           selector:@selector(updateState)
               name:UIScreenDidDisconnectNotification
             object:nil];
    [NSNotificationCenter.defaultCenter
        addObserver:self
           selector:@selector(updateState)
               name:UIScreenModeDidChangeNotification
             object:nil];

    if (@available(iOS 11.0, *)) {
        [NSNotificationCenter.defaultCenter
            addObserver:self
               selector:@selector(updateState)
                   name:UIScreenCapturedDidChangeNotification
                 object:nil];
    }

    [AVAudioSession sharedInstance];
    [NSNotificationCenter.defaultCenter
        addObserver:self
           selector:@selector(updateState)
               name:AVAudioSessionRouteChangeNotification
             object:nil];
    if (self.deviceSupportsScreenRecording) {
        SYWeakProxy *weakProxy = [SYWeakProxy proxyWithTarget:self];
        self.screenRecordingDetectionDisplayLink = [CADisplayLink
            displayLinkWithTarget:weakProxy
                         selector:@selector(screenRecordingDetectionUpdate:)];
        [self.screenRecordingDetectionDisplayLink
            addToRunLoop:NSRunLoop.mainRunLoop
                 forMode:NSRunLoopCommonModes];
        self.screenRecordingDetectionDisplayLink.paused = YES;
    }
}

- (BOOL)isScreenBeingRecorded {
    __block BOOL result = NO;
    [UIScreen.screens
        enumerateObjectsUsingBlock:^(UIScreen *_Nonnull obj, NSUInteger idx,
                                     BOOL *_Nonnull stop) {
          if (@available(iOS 11.0, *)) {
              if (obj.isCaptured) {
                  result = YES;
                  *stop = YES;
              }
          }
        }];
    return result;
}

- (BOOL)_isScreenBeingRecordedByQuickTime {
    __block BOOL result = NO;
    NSArray<AVAudioSessionPortDescription *> *outputs =
        AVAudioSession.sharedInstance.currentRoute.outputs;
    [outputs enumerateObjectsUsingBlock:^(
                 AVAudioSessionPortDescription *_Nonnull obj, NSUInteger idx,
                 BOOL *_Nonnull stop) {
      BOOL isHDMI = [obj.portType isEqualToString:AVAudioSessionPortHDMI];
      if (isHDMI) {
          result = YES;
          *stop = YES;
      }
    }];
    return result;
}

- (BOOL)_isScreenBeingMirrored {
    __block BOOL result = NO;
    [UIScreen.screens
        enumerateObjectsUsingBlock:^(UIScreen *_Nonnull obj, NSUInteger idx,
                                     BOOL *_Nonnull stop) {
          if (obj.mirroredScreen) {
              result = YES;
              *stop = YES;
          }
        }];
    return result;
}

- (void)screenRecordingDetectionUpdate:(CADisplayLink *)displayLink {
    [self updateState];
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
          [self updateState];
        });
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self.screenRecordingDetectionDisplayLink invalidate];
}

- (void)updateState {
    BOOL _isScreenBeingMirrored = [self _isScreenBeingMirrored];
    if (_isScreenBeingMirrored != self.isScreenBeingMirrored) {
        self.isScreenBeingMirrored = _isScreenBeingMirrored;
    }
    BOOL _isScreenBeingRecordedByQuickTime =
        [self _isScreenBeingRecordedByQuickTime];
    if (_isScreenBeingRecordedByQuickTime !=
        self.isScreenBeingRecordedByQuickTime) {
        self.isScreenBeingRecordedByQuickTime =
            _isScreenBeingRecordedByQuickTime;
    }
    BOOL isScreenBeingRecordedOnDevice =
        [self isScreenBeingRecorded] &&
        (!(_isScreenBeingMirrored || _isScreenBeingRecordedByQuickTime));
    if (isScreenBeingRecordedOnDevice != [self isScreenBeingRecordedOnDevice]) {
        self.isScreenBeingRecordedOnDevice = isScreenBeingRecordedOnDevice;
    }
}

- (BOOL)deviceSupportsScreenRecording {
    if (@available(iOS 11.0, *)) {
        return YES;
    }
    return NO;
}

- (void)applicationDidBecomeActive:(NSNotification *)not{
    self.isApplicationActive = YES;
    [self updateState];
    if ([self deviceSupportsScreenRecording]) {
        self.screenRecordingDetectionDisplayLink.paused = NO;
        __weak __auto_type weakSelf = self;
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
            dispatch_get_main_queue(), ^{
              weakSelf.screenRecordingDetectionDisplayLink.paused = YES;
            });
    }
}

- (void)applicationWillResignActive:(NSNotification *)not{
    self.isApplicationActive = NO;
    [self updateState];
}

@end

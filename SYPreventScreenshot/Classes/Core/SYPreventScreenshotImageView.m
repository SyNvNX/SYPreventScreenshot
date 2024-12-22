//
//  SYPreventScreenshotImageView.m
//  SYPreventScreenshot
//
//  Created by SyNvNX on 2024/12/9.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import "SYPreventScreenshotImageView.h"
#import "SYAVAssetResourceLoaderDelegate.h"
#import "SYImageToSampleBufferConverter.h"
#import "SYImageToVideoConverter.h"
#import "SYLogger.h"
#import "SYMacros.h"
#import "SYPreventPlayerLayerView.h"
#import "SYPreventSampleBufferDisplayLayerView.h"
#import "SYReuseManager.h"
#import "SYScreenStatusCaptureDetector.h"
#import "SYServerManager.h"
#import <AVFoundation/AVFoundation.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

static NSString *const kShouldHideContentKey = @"shouldHideContent";
static NSString *const kShouldShowScreenCaptureViewKey =
    @"shouldShowScreenCaptureView";
static NSString *const kMayShowScreenCaptureViewKey =
    @"mayShowScreenCaptureView";
static void *SYPreventScreenshotImageViewKVOContext =
    &SYPreventScreenshotImageViewKVOContext;

@interface SYPreventScreenshotImageView () <
    SYScreenStatusCaptureDetectorDelegate>

@property(nonatomic, strong) UIView *screenCaptureView;
@property(nonatomic, strong)
    SYScreenStatusCaptureDetector *screenStatusCaptureDetector;

@property(nonatomic, strong) AVPlayerLayer *playerLayer;
@property(nonatomic, strong) SYPreventPlayerLayerView *playerLayerView;
@property(nonatomic, strong) AVPlayer *player;

@property(nonatomic, strong) id<AVAssetResourceLoaderDelegate>
    assetResourceLoaderDelegate;
@property(nonatomic, strong) NSData *videoData;
@property(nonatomic, strong)
    AVSampleBufferDisplayLayer *sampleBufferDisplayLayer;
@property(nonatomic, strong)
    SYPreventSampleBufferDisplayLayerView *sampleBufferDisplayLayerView;
@property(nonatomic, strong) NSError *error;
@property(nonatomic, strong) UIImageView *placeholderImageView;
@property(nonatomic, assign) BOOL hasResponse;
@property(nonatomic, copy) NSString *videoPath;
@end

IB_DESIGNABLE
@implementation SYPreventScreenshotImageView

- (instancetype)init {
    return [self initWithImage:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithImage:nil placeholderImage:nil];
}

- (instancetype)initWithImage:(UIImage *)image
             placeholderImage:(UIImage *)placeholderImage {
    return [self initWithImage:image placeholderImage:placeholderImage frame:CGRectZero];
}

- (instancetype)initWithImage:(UIImage *)image
             placeholderImage:(UIImage *)placeholderImage
                        frame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUp];
        self.image = image;
        self.placeholderImage = placeholderImage;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    return [self initWithImage:image placeholderImage:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setUp];
    }
    return self;
}
- (void)setImage:(UIImage *)image placeholderImage:(UIImage *)placeholderImage {
    self.image = image;
    self.placeholderImage = placeholderImage;
    [self updatePlaceholderImageView];
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    _placeholderImage = placeholderImage;
    self.placeholderImageView.image = placeholderImage;
    [self updatePlaceholderImageView];
}

- (BOOL)isCaptured {
    return self.screenStatusCaptureDetector.isCaptured;
}

+ (NSSet *)keyPathsForValuesAffectingCaptured {
    return [NSSet setWithObject:@"screenStatusCaptureDetector.captured"];
}

- (CGSize)intrinsicContentSize {
    UIImage *image = self.image;
    CGSize size = CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
    if (image) {
        size = image.size;
    }
    return size;
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    if (self.image) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:imageView];
        NSArray *cons = @[
            [imageView.leadingAnchor
                constraintEqualToAnchor:self.leadingAnchor],
            [imageView.trailingAnchor
                constraintEqualToAnchor:self.trailingAnchor],
            [imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [imageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ];
        [NSLayoutConstraint activateConstraints:cons];
    }
}

- (void)setContentMode:(SYPreventScreenshotImageViewContentMode)contentMode {
    if (_contentMode == contentMode) {
        [self updateVideoGravity];
    } else {
        _contentMode = contentMode;
        if (!self.sampleBufferDisplayLayer) {
            [self updateVideoGravity];
        } else {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [self updateVideoGravity];
            CGRect bounds = self.sampleBufferDisplayLayer.bounds;
            self.sampleBufferDisplayLayer.bounds = CGRectMake(
                bounds.origin.x, bounds.origin.y, bounds.size.width + DBL_MIN,
                bounds.size.height + DBL_MIN);
            self.sampleBufferDisplayLayer.bounds = bounds;
            [CATransaction commit];
        }
    }

    switch (contentMode) {
    case SYPreventScreenshotImageViewContentModeResize:
        self.placeholderImageView.contentMode = UIViewContentModeScaleToFill;
        break;
    case SYPreventScreenshotImageViewContentModeAspect:
        self.placeholderImageView.contentMode = UIViewContentModeScaleAspectFit;
        break;
    case SYPreventScreenshotImageViewContentModeAspectFill:
        self.placeholderImageView.contentMode =
            UIViewContentModeScaleAspectFill;
        break;
    default:
        break;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    UIColor *color = self.backgroundColor;
    [super setBackgroundColor:backgroundColor];
    if (![color isEqual:backgroundColor]) {
        self.image = self.image;
    }
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self invalidateIntrinsicContentSize];
    [self.playerLayer removeObserver:self
                          forKeyPath:@"readyForDisplay"
                             context:SYPreventScreenshotImageViewKVOContext];
    self.playerLayer = nil;

    [self.playerLayerView removeFromSuperview];
    self.playerLayerView = nil;

    [self.player removeObserver:self
                     forKeyPath:@"status"
                        context:SYPreventScreenshotImageViewKVOContext];
    [self.player pause];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;

    self.assetResourceLoaderDelegate = nil;
    self.videoData = nil;

    [self.sampleBufferDisplayLayer
        removeObserver:self
            forKeyPath:@"status"
               context:SYPreventScreenshotImageViewKVOContext];

    __auto_type sampleBufferDisplayLayerView =
        self.sampleBufferDisplayLayerView;
    if (sampleBufferDisplayLayerView) {
        [SYReuseManager.sharedManager
            enqueueSampleBufferDisplayLayerView:sampleBufferDisplayLayerView];
    }
    [sampleBufferDisplayLayerView removeFromSuperview];
    self.sampleBufferDisplayLayerView = nil;

    [self setStatusUnknown];

    if (image) {
        BOOL useAVPlayer = [self.class useAVPlayer];
        if (useAVPlayer) {
            __weak __auto_type weakSelf = self;
            UIColor *backgroundColor =
                self.backgroundColor ?: self.superview.backgroundColor;
            [SYImageToVideoConverter
                convertVideoFromImage:image
                      backgroundColor:backgroundColor
                      completionBlock:^(NSData *_Nullable data,
                                        NSError *_Nullable error) {
                        dispatch_main_sync_safe(^{
                          BOOL isSameImage = weakSelf.image == image;
                          if (isSameImage) {
                              if (data) {
                                  [weakSelf setUpVideoPlayerWithData:data];
                              } else {
                                  [weakSelf setFailWithError:error];
                              }
                          } else {
                              [SYLogger logAtLevelOnFormat:@"!isSameImage"];
                          }
                        });
                      }];
        } else {
            NSError *error = nil;
            CMSampleBufferRef sampleBufferRef = [SYImageToSampleBufferConverter
                convertImageToSampleBuffer:image
                                     error:&error];
            if (!sampleBufferRef || error) {
                [self setFailWithError:error];
            } else {
                SYPreventSampleBufferDisplayLayerView *displayLayerView =
                    [SYReuseManager
                            .sharedManager dequeueSampleBufferDisplayLayerView];
                assert(SYReuseManager.sharedManager != nil);
                displayLayerView.translatesAutoresizingMaskIntoConstraints = NO;
                self.sampleBufferDisplayLayerView = displayLayerView;
                AVSampleBufferDisplayLayer *sampleBufferDisplayLayer =
                    (AVSampleBufferDisplayLayer *)displayLayerView.layer;
                if (@available(iOS 13.0, *)) {
                    sampleBufferDisplayLayer.preventsCapture = YES;
                }
                self.sampleBufferDisplayLayer = sampleBufferDisplayLayer;
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                [self updateVideoGravity];
                [CATransaction commit];
                [self setUpDisplayLayerWithSampleBuffer:sampleBufferRef];
                [self addSubview:displayLayerView];
                if (!displayLayerView) {
                    [SYLogger logAtLevelOnFormat:@"nil"];
                }
                assert(displayLayerView != nil);
                NSArray *cons = @[
                    [displayLayerView.leadingAnchor
                        constraintEqualToAnchor:self.leadingAnchor],
                    [displayLayerView.trailingAnchor
                        constraintEqualToAnchor:self.trailingAnchor],
                    [displayLayerView.topAnchor
                        constraintEqualToAnchor:self.topAnchor],
                    [displayLayerView.bottomAnchor
                        constraintEqualToAnchor:self.bottomAnchor]
                ];
                [NSLayoutConstraint activateConstraints:cons];
                [sampleBufferDisplayLayer
                    addObserver:self
                     forKeyPath:@"status"
                        options:NSKeyValueObservingOptionInitial
                        context:SYPreventScreenshotImageViewKVOContext];
            }
        }
    }
}

- (void)setUpDisplayLayerWithSampleBuffer:(CMSampleBufferRef)sampleBufferRef {
    BOOL shouldHideContent = NO;
    if (self.screenStatusCaptureDetector) {
        shouldHideContent = self.screenStatusCaptureDetector.shouldHideContent;
    }
    self.sampleBufferDisplayLayer.hidden = shouldHideContent;
    if (self.sampleBufferDisplayLayer.status !=
        AVQueuedSampleBufferRenderingStatusUnknown) {
        [self.sampleBufferDisplayLayer flush];
    }
    if (@available(iOS 13.0, *)) {
        self.sampleBufferDisplayLayer.preventsCapture = YES;
    }
    [self.sampleBufferDisplayLayer enqueueSampleBuffer:sampleBufferRef];
    if (sampleBufferRef) {
        CFRelease(sampleBufferRef);
    }
}

- (void)setStatusToReady {
    if (self.error) {
        self.error = nil;
    }
    self.status = SYPreventScreenshotImageViewStatusReady;
    [self updateScreenCaptureViewVisibility];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self.player removeObserver:self
                     forKeyPath:@"status"
                        context:SYPreventScreenshotImageViewKVOContext];
    [self.playerLayer removeObserver:self
                          forKeyPath:@"readyForDisplay"
                             context:SYPreventScreenshotImageViewKVOContext];
    [self.screenStatusCaptureDetector
        removeObserver:self
            forKeyPath:@"shouldHideContent"
               context:SYPreventScreenshotImageViewKVOContext];
    [self.screenStatusCaptureDetector
        removeObserver:self
            forKeyPath:@"shouldShowScreenCaptureView"
               context:SYPreventScreenshotImageViewKVOContext];
    [self.screenStatusCaptureDetector
        removeObserver:self
            forKeyPath:@"mayShowScreenCaptureView"
               context:SYPreventScreenshotImageViewKVOContext];

    [self.player pause];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;

    [self.playerLayerView removeFromSuperview];

    self.playerLayerView = nil;
    [self.sampleBufferDisplayLayer
        removeObserver:self
            forKeyPath:@"status"
               context:SYPreventScreenshotImageViewKVOContext];
    self.sampleBufferDisplayLayer = nil;

    if (self.sampleBufferDisplayLayerView) {
        [SYReuseManager.sharedManager enqueueSampleBufferDisplayLayerView:
                                          self.sampleBufferDisplayLayerView];
    }
    [self.sampleBufferDisplayLayerView removeFromSuperview];
    self.sampleBufferDisplayLayerView = nil;

    self.screenStatusCaptureDetector = nil;
}

- (void)setUpVideoPlayerWithData:(NSData *)data {
    self.videoData = data;
    [self.playerLayer removeObserver:self
                          forKeyPath:@"readyForDisplay"
                             context:SYPreventScreenshotImageViewKVOContext];
    self.playerLayer = nil;

    [self.playerLayerView removeFromSuperview];
    self.playerLayerView = nil;

    [self.player removeObserver:self
                     forKeyPath:@"status"
                        context:SYPreventScreenshotImageViewKVOContext];
    [self.player pause];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;

    self.assetResourceLoaderDelegate = nil;

    NSURL *URL = [NSURL URLWithString:@"sy://video.m3u8"];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:URL options:nil];
    __weak __auto_type weakSelf = self;
    SYAVAssetResourceLoaderDelegate *delegate =
        [[SYAVAssetResourceLoaderDelegate alloc]
            initWithMP4Data:data
                 errorBlock:^(NSError *_Nullable error) {
                   [weakSelf setFailWithError:error];
                 }];
    self.videoPath = delegate.videoPath;
    dispatch_queue_t queue = dispatch_queue_create(
        "com.sy.resourceLoader.queue", DISPATCH_QUEUE_SERIAL);
    [asset.resourceLoader setDelegate:delegate queue:queue];
    self.assetResourceLoaderDelegate = delegate;

    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    player.allowsExternalPlayback = NO;
    player.volume = 0;
    player.muted = 1;
    self.player = player;

    SYPreventPlayerLayerView *layerView = [SYPreventPlayerLayerView new];
    layerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.playerLayerView = layerView;

    AVPlayerLayer *layer = (AVPlayerLayer *)layerView.layer;
    layer.player = player;

    BOOL shouldHideContent = NO;
    if (self.screenStatusCaptureDetector) {
        shouldHideContent = self.screenStatusCaptureDetector.shouldHideContent;
    }
    layer.hidden = shouldHideContent;

    self.playerLayer = layer;
    [self updateVideoGravity];
    [self addSubview:layerView];
    NSArray *cons = @[
        [layerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [layerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [layerView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [layerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ];
    [NSLayoutConstraint activateConstraints:cons];

    [self.player addObserver:self
                  forKeyPath:@"status"
                     options:NSKeyValueObservingOptionInitial
                     context:SYPreventScreenshotImageViewKVOContext];
    [self.playerLayer addObserver:self
                       forKeyPath:@"readyForDisplay"
                          options:NSKeyValueObservingOptionInitial
                          context:SYPreventScreenshotImageViewKVOContext];
}

- (void)updatePlaceholderImageView {
    dispatch_main_sync_safe(^{
        BOOL hasImage = self.image != nil;
        if ([self.class useAVPlayer]) {
            BOOL hasResponse = self.hasResponse;
            BOOL shouldHideContent =
                self.screenStatusCaptureDetector.shouldHideContent &&
                self.hideContentEnabled;
            if (shouldHideContent) {
                self.placeholderImageView.hidden = YES;
            } else {
                self.placeholderImageView.hidden = hasResponse && !hasImage;
            }
        } else {
            if (self.placeholderImageView.image && !hasImage) {
                self.placeholderImageView.hidden = NO;
            } else {
                self.placeholderImageView.hidden = YES;
            }
        }
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    if (context != SYPreventScreenshotImageViewKVOContext) {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
        return;
    }
    [self updatePlaceholderImageView];
    BOOL isPlayer = object == self.player;
    __auto_type playerStatus = self.player.status;
    BOOL isReadyForDisplayKey = [keyPath isEqualToString:@"readyForDisplay"];
    if (isPlayer) {
        if (playerStatus == AVPlayerStatusFailed) {
            BOOL isReset = NO;
            NSData *videoData = self.videoData;
            if (videoData) {
                NSError *error = self.error;
                NSString *domain = error.domain;
                if ([domain isEqualToString:AVFoundationErrorDomain]) {
                    if (error.code == AVErrorMediaServicesWereReset) {
                        isReset = YES;
                        [self setStatusUnknown];
                        if (!isReadyForDisplayKey) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                              [self setUpVideoPlayerWithData:videoData];
                            });
                        }
                    }
                }
            }
            if (!isReset) {
                [self setFailWithError:self.player.error];
            }
        }
    }

    BOOL isReadyForDisplay = self.playerLayer.isReadyForDisplay;
    if (isReadyForDisplay && (playerStatus == AVPlayerStatusReadyToPlay)) {
        [self setStatusToReady];
    }

    BOOL isPlayerLayer = object == self.playerLayer;
    if (isPlayerLayer) {
        if (isReadyForDisplayKey) {
            if (!isReadyForDisplay) {
                if (self.status == SYPreventScreenshotImageViewStatusReady) {
                    [self setStatusUnknown];
                }
            }
        }
    }

    BOOL isSampleBufferDisplayLayer = self.sampleBufferDisplayLayer == object;
    if (isSampleBufferDisplayLayer) {
        if (AVQueuedSampleBufferRenderingStatusFailed ==
            self.sampleBufferDisplayLayer.status) {
            NSError *error = self.sampleBufferDisplayLayer.error;
            dispatch_main_sync_safe(^{
              if (![error.domain isEqualToString:AVFoundationErrorDomain]) {
                  [self setFailWithError:error];
                  return;
              }

              if (UIApplication.sharedApplication.applicationState !=
                  UIApplicationStateActive) {
                  [self setFailWithError:error];
                  return;
              }

              if (error.code == AVErrorMediaServicesWereReset) {
                  [self setStatusUnknown];
                  return;
              }
              [self setFailWithError:error];
            });
        } else if (AVQueuedSampleBufferRenderingStatusUnknown ==
                   self.sampleBufferDisplayLayer.status) {
            [self setStatusUnknown];
        }
    }

    BOOL isScreenStatusCaptureDetector =
        object == self.screenStatusCaptureDetector;
    if (isScreenStatusCaptureDetector) {
        dispatch_main_sync_safe(^{
          [CATransaction begin];
          [CATransaction setDisableActions:YES];
          BOOL shouldHideContent =
              self.screenStatusCaptureDetector.shouldHideContent &&
              self.hideContentEnabled;
          self.playerLayer.hidden = shouldHideContent;
          self.sampleBufferDisplayLayer.hidden = shouldHideContent;
          [self updateScreenCaptureViewVisibility];
          [CATransaction commit];
        });
    }
}

- (void)updateVideoGravity {
    AVLayerVideoGravity videoGravity = nil;

    if (self.contentMode == SYPreventScreenshotImageViewContentModeAspectFill) {
        videoGravity = AVLayerVideoGravityResizeAspectFill;
    } else if (self.contentMode ==
               SYPreventScreenshotImageViewContentModeAspect) {
        videoGravity = AVLayerVideoGravityResizeAspect;
    } else {
        if (self.contentMode) {
            return;
        }
        videoGravity = AVLayerVideoGravityResize;
    }
    if (videoGravity) {
        self.playerLayer.videoGravity = videoGravity;
        self.sampleBufferDisplayLayer.videoGravity = videoGravity;
    }
}

- (void)setFailWithError:(NSError *)error {
    self.error = error;
    self.status = SYPreventScreenshotImageViewStatusFailed;
    [self updateScreenCaptureViewVisibility];
    [SYLogger logAtLevelOnFormat:@"fail error: %@", error];
}

+ (BOOL)useAVPlayer {
    if (@available(iOS 13.0, *)) {
        return NO;
    }
    return YES;
}

- (void)setStatusUnknown {
    if (self.error) {
        self.error = nil;
    }
    self.status = SYPreventScreenshotImageViewStatusUnknown;
    [self updateScreenCaptureViewVisibility];
}

- (void)updateScreenCaptureViewVisibility {
    dispatch_main_sync_safe(^{
      BOOL hidden = YES;
      if (self.canShowScreenCaptureView) {
          if ([self.screenStatusCaptureDetector shouldShowScreenCaptureView]) {
              hidden = NO;
          } else if (self.status == SYPreventScreenshotImageViewStatusReady) {
              hidden =
                  !self.screenStatusCaptureDetector.mayShowScreenCaptureView;
          }
      } else {
          hidden = YES;
      }
      self.screenCaptureView.hidden = hidden;
    });
}

- (void)setUp {
    [NSNotificationCenter.defaultCenter
        addObserver:self
           selector:@selector(applicationWillEnterForeground:)
               name:UIApplicationWillEnterForegroundNotification
             object:nil];
    [NSNotificationCenter.defaultCenter
        addObserver:self
           selector:@selector(applicationDidBecomeActive:)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];
    [NSNotificationCenter.defaultCenter
        addObserver:self
           selector:@selector(processRequestNotification:)
     name:SYServerManagerProcessRequestNotification
             object:nil];
    
    self.hideContentEnabled = YES;
    self.canShowScreenCaptureView = YES;
    self.contentMode = SYPreventScreenshotImageViewContentModeResize;

    UIView *view = [UIView new];
    view.hidden = YES;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:view];

    self.screenCaptureView = view;
    NSArray<NSLayoutConstraint *> *constraints = @[
        [view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [view.topAnchor constraintEqualToAnchor:self.topAnchor],
        [view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ];

    [NSLayoutConstraint activateConstraints:constraints];

    self.screenStatusCaptureDetector = [SYScreenStatusCaptureDetector new];
    self.screenStatusCaptureDetector.delegate = self;

    [self.screenStatusCaptureDetector
        addObserver:self
         forKeyPath:kShouldHideContentKey
            options:0
            context:SYPreventScreenshotImageViewKVOContext];
    [self.screenStatusCaptureDetector
        addObserver:self
         forKeyPath:kShouldShowScreenCaptureViewKey
            options:0
            context:SYPreventScreenshotImageViewKVOContext];
    [self.screenStatusCaptureDetector
        addObserver:self
         forKeyPath:kMayShowScreenCaptureViewKey
            options:0
            context:SYPreventScreenshotImageViewKVOContext];

    self.placeholderImageView = [[UIImageView alloc] init];
    self.placeholderImageView.hidden = YES;
    self.placeholderImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.placeholderImageView];

    constraints = @[
        [self.placeholderImageView.leadingAnchor
            constraintEqualToAnchor:self.leadingAnchor],
        [self.placeholderImageView.trailingAnchor
            constraintEqualToAnchor:self.trailingAnchor],
        [self.placeholderImageView.topAnchor
            constraintEqualToAnchor:self.topAnchor],
        [self.placeholderImageView.bottomAnchor
            constraintEqualToAnchor:self.bottomAnchor]
    ];

    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)processRequestNotification:(NSNotification *)not {
    NSString *path = not.userInfo[SYServerManagerPathKey] ?: @"";
    self.hasResponse = [self.videoPath isEqualToString:path];
    [self updatePlaceholderImageView];
}

- (void)screenStatusCaptureDetectorShouldReload:
    (SYScreenStatusCaptureDetector *)det {
    if ([self.class useAVPlayer]) {
        if (self.videoData) {
            [self setStatusUnknown];
            [self setUpVideoPlayerWithData:self.videoData];
        }
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)not{
    if ([self.class useAVPlayer]) {
        BOOL isReadyForDisplay = NO;
        if (SYPreventScreenshotImageViewStatusUnknown == self.status) {
            isReadyForDisplay = self.playerLayer.isReadyForDisplay;
        }
        if (AVPlayerStatusReadyToPlay == self.player.status) {
            isReadyForDisplay =
                self.playerLayer.isReadyForDisplay || isReadyForDisplay;
        }

        if (isReadyForDisplay) {
            if (self.videoData) {
                [self setStatusUnknown];
                [self setUpVideoPlayerWithData:self.videoData];
            }
        }
    } else {
        [self sampleBufferDisplayLayerRecoveryIfNeeded];
    }
}
- (void)sampleBufferDisplayLayerRecoveryIfNeeded {
    if (![self.class useAVPlayer]) {
        if (AVQueuedSampleBufferRenderingStatusFailed ==
            self.sampleBufferDisplayLayer.status) {
            UIImage *image = self.image;
            if (image) {
                NSError *error = nil;
                CMSampleBufferRef buffer = [SYImageToSampleBufferConverter
                    convertImageToSampleBuffer:image
                                         error:&error];
                if (!buffer || error) {
                    [self setFailWithError:error];
                } else {
                    [self setUpDisplayLayerWithSampleBuffer:buffer];
                }
            }
        }
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)not{
    if (![self.class useAVPlayer]) {
        [self sampleBufferDisplayLayerRecoveryIfNeeded];
    }
}

@end

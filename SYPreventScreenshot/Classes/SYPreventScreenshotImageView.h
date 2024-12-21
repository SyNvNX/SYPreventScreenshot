//
//  SYPreventScreenshotImageView.h
//  SYPreventScreenshot
//
//  Created by SyNvNX on 2024/12/9.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SYPreventScreenshotImageViewStatus) {
    SYPreventScreenshotImageViewStatusUnknown = 0,
    SYPreventScreenshotImageViewStatusReady = 1,
    SYPreventScreenshotImageViewStatusFailed = 2,
};

typedef NS_ENUM(NSInteger, SYPreventScreenshotImageViewContentMode) {
    SYPreventScreenshotImageViewContentModeResize = 0,
    SYPreventScreenshotImageViewContentModeAspect = 1,
    SYPreventScreenshotImageViewContentModeAspectFill = 2,
};

@interface SYPreventScreenshotImageView : UIView
- (instancetype)initWithImage:(nullable UIImage *)image
             placeholderImage:(nullable UIImage *)placeholderImage;
- (instancetype)initWithImage:(nullable UIImage *)image;
- (void)setImage:(nullable UIImage *)image
    placeholderImage:(nullable UIImage *)placeholderImage;
+ (BOOL)useAVPlayer;

@property(nullable, nonatomic, strong) IBInspectable UIImage *image;
@property(nullable, nonatomic, strong) IBInspectable UIImage *placeholderImage;
@property(nonatomic, strong, readonly, nullable) NSError *error;
@property(nonatomic, readonly, getter=isCaptured) BOOL captured;
@property(nonatomic, assign) BOOL canShowScreenCaptureView;
@property(nonatomic, assign) SYPreventScreenshotImageViewStatus status;
@property(nonatomic, assign)
    SYPreventScreenshotImageViewContentMode contentMode;
@property(nonatomic, assign) BOOL hideContentEnabled;

@end

NS_ASSUME_NONNULL_END

//
//  SYPreventScreenshotImageView.h
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

- (instancetype)initWithImage:(UIImage *)image
             placeholderImage:(UIImage *)placeholderImage
                        frame:(CGRect)frame;

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

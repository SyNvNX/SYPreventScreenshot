//
//  SYPreventScreenshotImageView+WebCache.m
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

#import "SYMacros.h"
#import "SYPreventScreenshotImageView+WebCache.h"
#import <objc/runtime.h>
@implementation SYPreventScreenshotImageView (WebCache)

- (nullable SDWebImageCombinedOperation *)sy_operationOperation {
    return objc_getAssociatedObject(self, @selector(sy_operationOperation));
}

- (void)setSy_operation:
    (SDWebImageCombinedOperation *_Nullable)operationOperation {
    objc_setAssociatedObject(self, @selector(sy_operationOperation),
                             operationOperation,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)sy_setImageWithURL:(nullable NSURL *)url {
    [self sy_setImageWithURL:url
            placeholderImage:nil
                     options:0
                    progress:nil
                   completed:nil];
}

- (void)sy_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder {
    [self sy_setImageWithURL:url
            placeholderImage:placeholder
                     options:0
                    progress:nil
                   completed:nil];
}

- (void)sy_setImageWithURL:(nullable NSURL *)url
                 completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sy_setImageWithURL:url
            placeholderImage:nil
                     options:0
                    progress:nil
                   completed:completedBlock];
}

- (void)sy_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                 completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sy_setImageWithURL:url
            placeholderImage:placeholder
                     options:0
                    progress:nil
                   completed:completedBlock];
}

- (void)sy_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(nullable SDImageLoaderProgressBlock)progressBlock
                 completed:(nullable SDExternalCompletionBlock)completedBlock {
    [[self sy_operationOperation] cancel];
    __weak __auto_type weakSelf = self;
    self.placeholderImage = placeholder;
    SDWebImageCombinedOperation *operation = [SDWebImageManager.sharedManager
        loadImageWithURL:url
                 options:options
                 context:nil
                progress:progressBlock
               completed:^(UIImage *_Nullable image, NSData *_Nullable data,
                           NSError *_Nullable error, SDImageCacheType cacheType,
                           BOOL finished, NSURL *_Nullable imageURL) {
                 dispatch_main_sync_safe(^{
                   __strong __auto_type strongSelf = weakSelf;
                   if (strongSelf) {
                       if (image && finished) {
                           strongSelf.image = image;
                       }
                   }
                 });

                 if (completedBlock) {
                     completedBlock(image, error, cacheType, imageURL);
                 }
               }];
    [self setSy_operation:operation];
}

@end

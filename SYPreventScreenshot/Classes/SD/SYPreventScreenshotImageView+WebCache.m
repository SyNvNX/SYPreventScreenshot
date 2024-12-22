//
//  SYPreventScreenshotImageView+WebCache.m
//  Pods-SYPreventScreenshot_Example
//
//  Created by sy on 2024/12/22.
//

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

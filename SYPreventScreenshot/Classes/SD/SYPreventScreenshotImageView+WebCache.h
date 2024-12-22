//
//  SYPreventScreenshotImageView+WebCache.h
//  Pods-SYPreventScreenshot_Example
//
//  Created by sy on 2024/12/22.
//

#import <SYPreventScreenshot/SYPreventScreenshot.h>
#import <SDWebImage/SDWebImage.h>
NS_ASSUME_NONNULL_BEGIN

@interface SYPreventScreenshotImageView (WebCache)

- (void)sy_setImageWithURL:(nullable NSURL *)url;
- (void)sy_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder;
- (void)sy_setImageWithURL:(nullable NSURL *)url completed:(nullable SDExternalCompletionBlock)completedBlock;
- (void)sy_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable SDExternalCompletionBlock)completedBlock;
@end

NS_ASSUME_NONNULL_END

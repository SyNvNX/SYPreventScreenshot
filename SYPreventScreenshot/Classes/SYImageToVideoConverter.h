//
//  SYImageToVideoConverter.h
//  SYPreventScreenshot
//
//  Created by SyNvNX on 2024/12/10.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SYImageToVideoConverterBlock)(NSData *_Nullable data,
                                             NSError *_Nullable error);

@interface SYImageToVideoConverter : NSObject

+ (void)convertVideoFromImage:(UIImage *)image
              completionBlock:(SYImageToVideoConverterBlock)block;

+ (void)convertVideoFromImage:(UIImage *)image
              backgroundColor:(nullable UIColor *)backgroundColor
              completionBlock:(SYImageToVideoConverterBlock)block;
@end

NS_ASSUME_NONNULL_END

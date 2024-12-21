//
//  SYImageEncoder.h
//  SYPreventScreenshot
//
//  Created by SyNvNX on 2024/12/10.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYImageEncoder : NSObject

+ (NSError *)videoToolboxErrorWithStatus:(OSStatus)sta;
+ (CVPixelBufferRef)
    createPixelBufferFromImage:(UIImage *)image
                         error:(NSError *__autoreleasing _Nullable *)error;
@property(nonatomic, strong) NSError *error;
@property(nonatomic, strong) NSData *avcC;
@property(nonatomic, strong) NSData *encodedFrames;
- (NSError *)encodeImage:(UIImage *)image;
- (NSError *)encodeImage:(UIImage *)image
         backgroundColor:(nullable UIColor *)backgroundColor;

@end

NS_ASSUME_NONNULL_END

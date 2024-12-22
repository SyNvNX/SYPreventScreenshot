//
//  SYImageToVideoConverter.m
//  SYPreventScreenshot
//
//  Created by SyNvNX on 2024/12/10.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import "SYImageToVideoConverter.h"
#import "SYImageEncoder.h"
#import "SYMP4HeaderConstructor.h"

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@implementation SYImageToVideoConverter

+ (void)convertVideoFromImage:(UIImage *)image
              backgroundColor:(UIColor *)backgroundColor
              completionBlock:(SYImageToVideoConverterBlock)block {
    SYImageEncoder *encoder = [SYImageEncoder new];
    NSError *error = [encoder encodeImage:image
                          backgroundColor:backgroundColor];
    if (error) {
        if (block) {
            block(nil, error);
        }
    } else {
        NSData *encodedFrames = encoder.encodedFrames;
        CGSize size = image.size;
        CGFloat scale = image.scale;
        CGSize dimension = CGSizeMake(size.width * scale, size.height * scale);
        __auto_type length = encodedFrames.length;
        NSMutableData *data = [NSMutableData dataWithCapacity:length];

        NSData *header =
            [SYMP4HeaderConstructor mp4HeaderWithDimension:dimension
                                               bytesLength:(unsigned int)length
                                                      avcC:encoder.avcC];
        [data appendData:header];
        [data appendData:encodedFrames];
        if (block) {
            block(data, nil);
        }
    }
}

+ (void)convertVideoFromImage:(UIImage *)image
              completionBlock:(SYImageToVideoConverterBlock)block {
    [self convertVideoFromImage:image
                backgroundColor:nil
                completionBlock:block];
}

@end

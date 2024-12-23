//
//  SYImageToVideoConverter.m
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

//
//  SYImageToSampleBufferConverter.m
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/13.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import "SYImageToSampleBufferConverter.h"
#import "NSError+SYError.h"
#import <CoreVideo/CoreVideo.h>

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@implementation SYImageToSampleBufferConverter

+ (CMSampleBufferRef)createSampleBufferFromPixelBuffer:
                         (CVPixelBufferRef)pixelBuffer
                                                 error:(NSError **)error {
    CMVideoFormatDescriptionRef formatDescriptionOut = NULL;
    OSStatus status = CMVideoFormatDescriptionCreateForImageBuffer(
        kCFAllocatorDefault, pixelBuffer, &formatDescriptionOut);
    if (status != noErr) {
        if (error) {
            *error = [NSError
                sye_errorWithMessages:
                    @"CMVideoFormatDescriptionCreateForImageBuffer: %@",
                    @(status)];
        }
        if (formatDescriptionOut) {
            CFRelease(formatDescriptionOut);
            formatDescriptionOut = NULL;
        }
        return NULL;
    }

    CMSampleTimingInfo timingInfo = kCMTimingInfoInvalid;
    timingInfo.presentationTimeStamp = kCMTimeZero;
    CMSampleBufferRef sampleBufferOut = NULL;
    status = CMSampleBufferCreateReadyWithImageBuffer(
        kCFAllocatorDefault, pixelBuffer, formatDescriptionOut, &timingInfo,
        &sampleBufferOut);
    if (formatDescriptionOut) {
        CFRelease(formatDescriptionOut);
        formatDescriptionOut = NULL;
    }
    if (status != noErr) {
        if (error) {
            *error = [NSError
                sye_errorWithMessages:
                    @"CMSampleBufferCreateReadyWithImageBuffer: %@", @(status)];
        }

        return NULL;
    }

    return sampleBufferOut;
}
+ (CVPixelBufferRef)createPixelBufferFromImage:(UIImage *)image
                                         error:(NSError **)error {
    CGSize size = image.size;
    CGFloat width = size.width * image.scale;
    CGFloat height = size.height * image.scale;

    CFDictionaryRef empty = CFDictionaryCreate(
        kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks,
        &kCFTypeDictionaryValueCallBacks);
    CFMutableDictionaryRef attrs = CFDictionaryCreateMutable(
        kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks,
        &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);

    CVPixelBufferRef renderTarget = NULL;
    CVReturn err =
        CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                            kCVPixelFormatType_32ARGB, attrs, &renderTarget);
    if (err != kCVReturnSuccess) {
        if (error) {

            *error = [NSError sye_errorWithMessages:@"CVError: %@", @(err)];
        }
        if (renderTarget) {
            CVPixelBufferRelease(renderTarget);
            renderTarget = NULL;
        }
        return NULL;
    }

    if (!renderTarget) {
        if (error) {
            *error = [NSError sye_errorWithMessages:@"renderTarget nil"];
        }

        return NULL;
    }
    CVReturn ret = CVPixelBufferLockBaseAddress(renderTarget, 0);
    if (ret != kCVReturnSuccess) {
        if (error) {
            *error = [NSError
                sye_errorWithMessages:@"CVPixelBufferLockBaseAddress: %@",
                                      @(ret)];
        }
        if (renderTarget) {
            CVPixelBufferRelease(renderTarget);
            renderTarget = NULL;
        }
        return NULL;
    }
    void *pxdata = CVPixelBufferGetBaseAddress(renderTarget);

    if (!pxdata) {
        if (error) {
            *error = [NSError sye_errorWithMessages:@"pxdata == nil"];
        }
        if (renderTarget) {
            CVPixelBufferRelease(renderTarget);
            renderTarget = NULL;
        }
        return NULL;
    }

    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    size_t perRow = CVPixelBufferGetBytesPerRow(renderTarget);
    CGContextRef context =
        CGBitmapContextCreate(pxdata, width, height, 8, perRow, rgbColorSpace,
                              kCGImageAlphaPremultipliedFirst);

    CGContextConcatCTM(context, CGAffineTransformIdentity);
    UIGraphicsPushContext(context);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1, -1);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIGraphicsPopContext();
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    CVPixelBufferUnlockBaseAddress(renderTarget, 0);

    return renderTarget;
}
+ (CMSampleBufferRef)convertImageToSampleBuffer:(UIImage *)image
                                          error:(NSError **)error {
    NSError *err = nil;
    CVPixelBufferRef buffer = [self createPixelBufferFromImage:image
                                                         error:&err];
    CMSampleBufferRef sample = NULL;
    if (buffer) {
        sample = [self createSampleBufferFromPixelBuffer:buffer error:&err];
        CVPixelBufferRelease(buffer);
    }
    return sample;
}

@end

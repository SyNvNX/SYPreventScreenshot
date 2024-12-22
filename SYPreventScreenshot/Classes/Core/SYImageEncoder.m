//
//  SYImageEncoder.m
//  SYPreventScreenshot
//
//  Created by SyNvNX on 2024/12/10.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import "SYImageEncoder.h"
#import "NSError+SYError.h"
#import "SYLogger.h"
#import <VideoToolbox/VideoToolbox.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

static void compressionCallback(void *outputCallbackRefCon,
                                void *sourceFrameRefCon, OSStatus status,
                                VTEncodeInfoFlags infoFlags,
                                CMSampleBufferRef sampleBuffer) {
    SYImageEncoder *encoder = (__bridge SYImageEncoder *)(outputCallbackRefCon);
    if (status != noErr) {
        NSError *error = [SYImageEncoder videoToolboxErrorWithStatus:status];
        encoder.error = error;
    } else {
        CMFormatDescriptionRef des =
            CMSampleBufferGetFormatDescription(sampleBuffer);
        CFPropertyListRef list = CMFormatDescriptionGetExtension(
            des, kCMFormatDescriptionExtension_SampleDescriptionExtensionAtoms);
        if (list) {
            const void *data = CFDictionaryGetValue(list, @"avcC");
            NSData *ns_data =
                [NSData dataWithData:(__bridge NSData *_Nonnull)(data)];
            encoder.avcC = ns_data;
        }
        CMBlockBufferRef buf = CMSampleBufferGetDataBuffer(sampleBuffer);
        size_t totalLengthOut = 0;
        char *dataPointerOut = NULL;
        OSStatus status = CMBlockBufferGetDataPointer(
            buf, 0, NULL, &totalLengthOut, &dataPointerOut);
        if (status == noErr) {
            NSData *data = [NSData dataWithBytes:dataPointerOut
                                          length:totalLengthOut];
            encoder.encodedFrames = data;
        } else {
            NSError *error =
                [SYImageEncoder videoToolboxErrorWithStatus:status];
            encoder.error = error;
        }
    }
}
@implementation SYImageEncoder

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (NSError *)encodeImage:(UIImage *)image
         backgroundColor:(UIColor *)backgroundColor {
    CGSize size = image.size;
    CGFloat scale = image.scale;

    CGFloat width = size.width * scale;
    CGFloat height = size.height * scale;
    NSDictionary *sourceImageBufferAttributes = [NSDictionary
        dictionaryWithObjectsAndKeys:@(32), kCVPixelBufferPixelFormatTypeKey,
                                     @(width), kCVPixelBufferWidthKey,
                                     @(height), kCVPixelBufferHeightKey, nil];

    VTCompressionSessionRef compressionSessionOut = nil;
    OSStatus status = VTCompressionSessionCreate(
        kCFAllocatorDefault, width, height, kCMVideoCodecType_H264, NULL,
        (__bridge CFDictionaryRef _Nullable)(sourceImageBufferAttributes), NULL,
        compressionCallback, (__bridge void *_Nullable)(self),
        &compressionSessionOut);
    if (status != noErr) {
        NSError *error = [self.class videoToolboxErrorWithStatus:status];
        if (compressionSessionOut) {
            CFRelease(compressionSessionOut);
        }
        [SYLogger
            logAtLevelOnFormat:@"VTCompressionSessionCreate: %d", (int)status];
        return error;
    }
    NSDictionary *propertyDic = [NSDictionary
        dictionaryWithObjectsAndKeys:@(YES), kVTCompressionPropertyKey_RealTime,
                                     @(1),
                                     kVTCompressionPropertyKey_SourceFrameCount,
                                     kVTProfileLevel_H264_Baseline_AutoLevel,
                                     kVTCompressionPropertyKey_ProfileLevel,
                                     nil];
    status = VTSessionSetProperties(
        compressionSessionOut, (__bridge CFDictionaryRef _Nullable)propertyDic);

    if (status != noErr) {
        NSError *error = [self.class videoToolboxErrorWithStatus:status];
        if (compressionSessionOut) {
            CFRelease(compressionSessionOut);
        }
        [SYLogger
            logAtLevelOnFormat:@"VTSessionSetProperties: %d", (int)status];
        return error;
    }

    status = VTCompressionSessionPrepareToEncodeFrames(compressionSessionOut);
    if (status != noErr) {
        NSError *error = [self.class videoToolboxErrorWithStatus:status];
        if (compressionSessionOut) {
            CFRelease(compressionSessionOut);
        }
        [SYLogger
            logAtLevelOnFormat:@"VTCompressionSessionPrepareToEncodeFrames: %d",
                               (int)status];
        return error;
    }
    NSError *tempError = nil;
    CVPixelBufferRef bufferRef =
        [self.class createPixelBufferFromImage:image
                               backgroundColor:backgroundColor
                                         error:&tempError];
    if (tempError) {
        if (compressionSessionOut) {
            CFRelease(compressionSessionOut);
        }

        if (bufferRef) {
            CFRelease(bufferRef);
        }
        [SYLogger
            logAtLevelOnFormat:@"createPixelBufferFromImage: %d", (int)status];
        return tempError;
    }
    CMTime presentationTimeStamp = CMTimeMake(0, 0);
    status = VTCompressionSessionEncodeFrame(compressionSessionOut, bufferRef,
                                             presentationTimeStamp,
                                             kCMTimeInvalid, NULL, NULL, NULL);
    if (status != noErr) {
        NSError *error = [self.class videoToolboxErrorWithStatus:status];
        if (compressionSessionOut) {
            CFRelease(compressionSessionOut);
        }

        if (bufferRef) {
            CFRelease(bufferRef);
        }
        [SYLogger logAtLevelOnFormat:@"VTCompressionSessionEncodeFrame: %d",
                                     (int)status];
        return error;
    }
    status = VTCompressionSessionCompleteFrames(compressionSessionOut,
                                                kCMTimeInvalid);
    if (status != noErr) {
        NSError *error = [self.class videoToolboxErrorWithStatus:status];
        if (compressionSessionOut) {
            CFRelease(compressionSessionOut);
        }

        if (bufferRef) {
            CFRelease(bufferRef);
        }
        [SYLogger logAtLevelOnFormat:@"VTCompressionSessionCompleteFrames: %d",
                                     (int)status];
        return error;
    }
    VTCompressionSessionInvalidate(compressionSessionOut);
    if (bufferRef) {
        CFRelease(bufferRef);
    }

    if (compressionSessionOut) {
        CFRelease(compressionSessionOut);
    }
    return nil;
}

- (NSError *)encodeImage:(UIImage *)image {
    return [self encodeImage:image backgroundColor:nil];
}

+ (NSError *)videoToolboxErrorWithStatus:(OSStatus)status {
    return [NSError errorWithDomain:@"SYError"
                               code:status
                           userInfo:@{
                               NSLocalizedDescriptionKey : [NSString
                                   stringWithFormat:@"status:%@", @(status)]
                           }];
}

+ (CVPixelBufferRef)
    createPixelBufferFromImage:(UIImage *)image
               backgroundColor:(UIColor *)backgroundColor
                         error:(NSError *__autoreleasing _Nullable *)error {
    CGSize size = image.size;
    CGFloat scale = image.scale;
    CGFloat width = size.width * scale;
    CGFloat height = size.height * scale;

    NSDictionary *options =
        [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithBool:YES],
                          kCVPixelBufferCGBitmapContextCompatibilityKey,
                          [NSNumber numberWithBool:YES],
                          kCVPixelBufferCGImageCompatibilityKey, nil];

    CVPixelBufferRef pxbuffer = NULL;

    CVReturn status = CVPixelBufferCreate(
        kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB,
        (__bridge CFDictionaryRef)options, &pxbuffer);
    if (status != kCVReturnSuccess) {
        if (error) {
            *error =
                [NSError sye_errorWithMessages:@"status != kCVReturnSuccess"];
        }
        if (pxbuffer) {
            CVPixelBufferRelease(pxbuffer);
        }
        return NULL;
    }

    if (!pxbuffer) {
        if (error) {
            *error = [NSError sye_errorWithMessages:@"pxbuffer == nil"];
        }
        return NULL;
    }

    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);

    if (!pxdata) {
        if (error) {
            *error = [NSError sye_errorWithMessages:@"pxdata == nil"];
        }
        if (pxbuffer) {
            CVPixelBufferRelease(pxbuffer);
        }
        return NULL;
    }

    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    size_t perRow = CVPixelBufferGetBytesPerRow(pxbuffer);
    CGContextRef context =
        CGBitmapContextCreate(pxdata, width, height, 8, perRow, rgbColorSpace,
                              kCGImageAlphaNoneSkipFirst);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    UIGraphicsPushContext(context);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1, -1);

    CGFloat r = 0;
    CGFloat g = 0;
    CGFloat b = 0;
    CGFloat a = 1;
    if (backgroundColor) {
        [backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    }

    CGContextSetRGBFillColor(context, r, g, b, a);
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIGraphicsPopContext();
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

+ (CVPixelBufferRef)
    createPixelBufferFromImage:(UIImage *)image
                         error:(NSError *__autoreleasing _Nullable *)error {
    return [self createPixelBufferFromImage:image
                            backgroundColor:nil
                                      error:error];
}

@end

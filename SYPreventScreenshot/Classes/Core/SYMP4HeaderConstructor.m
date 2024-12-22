//
//  SYMP4HeaderConstructor.m
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

#import "SYMP4HeaderConstructor.h"
#include <libkern/OSByteOrder.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#if __arm64__
#import <arm_acle.h>
#import <arm_neon.h>
#endif

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

static unsigned int MajorBrand = 0x71742020;
static unsigned int MinorVersion = 0;
static unsigned int CompatibleBrands = 0x71742020;

static inline uint64_t convertDouble(double value) {
#if __arm64__
    return vcvtd_n_u64_f64(value, 0x10);
#endif
    return (uint64_t)llrint(value);
}

@implementation SYMP4HeaderConstructor

+ (NSData *)ftypBox {
    NSMutableData *data = [NSMutableData data];
    [self appendHeaderType:0x66747970 length:20 to:data];
    [self appendUInt32:MajorBrand to:data];
    [self appendUInt32:MinorVersion to:data];
    [self appendUInt32:CompatibleBrands to:data];
    return data;
}

+ (void)appendHeaderType:(unsigned int)type
                  length:(unsigned int)length
                      to:(NSMutableData *)data {
    [self appendUInt32:length to:data];
    [self appendUInt32:type to:data];
}

+ (void)appendUInt32:(unsigned int)value to:(NSMutableData *)data {
    __auto_type v = htonl(value);
    [data appendBytes:&v length:sizeof(unsigned int)];
}

+ (void)appendUInt16:(unsigned short)value to:(NSMutableData *)data {
    unsigned short v = htons(value);
    [data appendBytes:&v length:sizeof(unsigned short)];
}

+ (void)appendFloatAsFixedPoint:(double)point to:(NSMutableData *)data {
    unsigned int value = (unsigned int)convertDouble(point);
    [self appendUInt32:value to:data];
}

+ (NSData *)moovBoxWithCreationDate:(NSDate *)creationDate
                   modificationDate:(NSDate *)modificationDate
                               size:(CGSize)size
                        bytesLength:(unsigned int)bytesLength
                               avcC:(NSData *)avcC
                         byteOffset:(unsigned int)byteOffset {
    NSMutableData *data = [NSMutableData data];
    NSData *mvhdBox = [self mvhdBoxWithCreationDate:creationDate
                                   modificationDate:modificationDate];
    NSData *trakBox = [self trakBoxWithCreationDate:creationDate
                                   modificationDate:modificationDate
                                               size:size
                                        bytesLength:bytesLength
                                               avcC:avcC
                                         byteOffset:byteOffset];
    [self appendHeaderType:0x6D6F6F76
                    length:(unsigned int)(mvhdBox.length + trakBox.length + 8)
                        to:data];
    [data appendData:mvhdBox];
    [data appendData:trakBox];

    return data;
}

+ (NSData *)mvhdBoxWithCreationDate:(NSDate *)creationDate
                   modificationDate:(NSDate *)modificationDate {
    NSMutableData *data = [NSMutableData data];
    [self appendHeaderType:0x6D766864 length:108 to:data];
    [self appendVersion:0 flags:0 to:data];
    [self appendDate:creationDate to:data];
    [self appendDate:modificationDate to:data];
    [self appendUInt32:600 to:data];
    [self appendUInt32:40 to:data];
    [self appendUInt32:0x10000 to:data];
    [self appendUInt16:256 to:data];
    [self appendUInt16:0 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:0 to:data];
    [self appendUnityMatrixTo:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:2 to:data];
    return data;
}

+ (NSData *)tkhdBoxWithCreationDate:(NSDate *)creationDate
                   modificationDate:(NSDate *)modificationDate
                               size:(CGSize)size {
    NSMutableData *data = [NSMutableData data];
    [self appendHeaderType:0x746B6864 length:92 to:data];
    [self appendVersion:0 flags:15 to:data];
    [self appendDate:creationDate to:data];
    [self appendDate:modificationDate to:data];
    [self appendUInt32:1 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:40 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt16:0 to:data];
    [self appendUInt16:0 to:data];
    [self appendUInt16:0 to:data];
    [self appendUInt16:0 to:data];
    [self appendUnityMatrixTo:data];
    [self appendFloatAsFixedPoint:size.width to:data];
    [self appendFloatAsFixedPoint:size.height to:data];
    return data;
}

+ (NSData *)taptBoxWithSize:(CGSize)size {
    NSMutableData *data = [NSMutableData data];
    [self appendHeaderType:0x74617074 length:68 to:data];
    [self appendUInt32:20 to:data];
    [self appendUInt32:0x636C6566 to:data];
    [self appendVersion:0 flags:0 to:data];
    [self appendFloatAsFixedPoint:size.width to:data];
    [self appendFloatAsFixedPoint:size.height to:data];
    [self appendUInt32:20 to:data];
    [self appendUInt32:0x70726F66 to:data];
    [self appendVersion:0 flags:0 to:data];
    [self appendFloatAsFixedPoint:size.width to:data];
    [self appendFloatAsFixedPoint:size.height to:data];
    [self appendUInt32:20 to:data];
    [self appendUInt32:0x656E6F66 to:data];
    [self appendVersion:0 flags:0 to:data];
    [self appendFloatAsFixedPoint:size.width to:data];
    [self appendFloatAsFixedPoint:size.height to:data];
    return data;
}

+ (NSData *)elstBox {
    NSMutableData *data = [NSMutableData data];
    [self appendHeaderType:0x656C7374 length:28 to:data];
    [self appendVersion:0 flags:0 to:data];
    [self appendUInt32:1 to:data];
    [self appendUInt32:40 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:0x10000 to:data];
    return data;
}

+ (NSData *)edtsBox {
    NSMutableData *data = [NSMutableData data];
    NSData *elstBox = [self elstBox];
    [self appendHeaderType:0x65647473
                    length:(unsigned int)(elstBox.length + 8)
                        to:data];
    [data appendData:elstBox];
    return data;
}

+ (NSData *)mdhdBoxWithCreationDate:(NSDate *)creationDate
                   modificationDate:(NSDate *)modificationDate {
    NSMutableData *data = [NSMutableData data];
    [self appendHeaderType:0x6D646864 length:32 to:data];
    [self appendVersion:0 flags:0 to:data];
    [self appendDate:creationDate to:data];
    [self appendDate:modificationDate to:data];
    [self appendUInt32:600 to:data];
    [self appendUInt32:40 to:data];
    [self appendUInt16:21956 to:data];
    [self appendUInt16:0 to:data];
    return data;
}

+ (NSData *)vmhdBox {
    NSMutableData *data = [NSMutableData data];
    [self appendHeaderType:0x766D6864 length:20 to:data];
    [self appendVersion:0 flags:1 to:data];
    [self appendUInt16:64 to:data];
    [self appendUInt16:0x8000 to:data];
    [self appendUInt16:0x8000 to:data];
    [self appendUInt16:0x8000 to:data];
    return data;
}

+ (NSData *)alisBox {
    NSMutableData *data = [NSMutableData data];
    [self appendHeaderType:0x616C6973 length:12 to:data];
    [self appendUInt32:1 to:data];
    return data;
}

+ (NSData *)drefBox {
    NSMutableData *data = [NSMutableData data];
    NSData *alisBox = [self alisBox];
    __auto_type length = alisBox.length;
    [self appendHeaderType:0x64726566
                    length:(unsigned int)(length + 16)
                        to:data];
    [self appendVersion:0 flags:0 to:data];
    [self appendUInt32:1 to:data];
    [data appendData:alisBox];
    return data;
}

+ (NSData *)dinfBox {
    NSMutableData *data = [NSMutableData data];
    NSData *drefBox = [self drefBox];
    __auto_type length = drefBox.length;
    [self appendHeaderType:0x64696E66 length:(unsigned int)length + 8 to:data];
    [data appendData:drefBox];
    return data;
}

+ (NSData *)avcCBoxWithInnerData:(NSData *)d {
    NSMutableData *data = [NSMutableData data];
    __auto_type length = d.length;
    [self appendHeaderType:0x61766343 length:(unsigned int)length + 8 to:data];
    [data appendData:d];
    return data;
}

+ (NSData *)avc1BoxWithSize:(CGSize)size avcC:(NSData *)avcC {
    NSMutableData *data = [NSMutableData data];
    NSData *innerData = [self avcCBoxWithInnerData:avcC];
    __auto_type length = innerData.length;
    [self appendHeaderType:0x61766331 length:(unsigned int)length + 90 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt16:0 to:data];
    [self appendUInt16:1 to:data];
    [self appendUInt16:0 to:data];
    [self appendUInt16:0 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:512 to:data];
    [self appendUInt32:512 to:data];
    [self appendUInt16:size.width to:data];
    [self appendUInt16:size.height to:data];
    [self appendUInt32:0x480000 to:data];
    [self appendUInt32:0x480000 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt16:1 to:data];
    uint64_t array[] = {0x3436322E4805, 0, 0, 0};
    [data appendBytes:&array length:32];
    [self appendUInt16:24 to:data];
    [self appendUInt16:0xFFFF to:data];
    [data appendData:innerData];
    [self appendUInt32:0 to:data];
    return data;
}

+ (NSData *)sdtpBox {
    NSMutableData *data = [NSMutableData data];
    [self appendHeaderType:0x73647470 length:13 to:data];
    [self appendVersion:0 flags:0 to:data];
    char v = ' ';
    [data appendBytes:&v length:1];
    return data;
}

+ (NSData *)stsdBoxWithSize:(CGSize)size avcC:(NSData *)avcC {
    NSMutableData *data = [NSMutableData data];
    NSData *avc1 = [self avc1BoxWithSize:size avcC:avcC];
    [self appendHeaderType:0x73747364
                    length:(unsigned int)avc1.length + 16
                        to:data];
    [self appendVersion:0 flags:0 to:data];
    [self appendUInt32:1 to:data];
    [data appendData:avc1];
    return data;
}

+ (NSData *)stscBox {
    NSMutableData *data = [NSMutableData data];
    [self appendHeaderType:0x73747363 length:28 to:data];
    [self appendVersion:0 flags:0 to:data];
    [self appendUInt32:1 to:data];
    [self appendUInt32:1 to:data];
    [self appendUInt32:1 to:data];
    [self appendUInt32:1 to:data];
    return data;
}

+ (NSData *)stszBoxWithbytesLength:(unsigned int)bytes {
    NSMutableData *data = [NSMutableData data];
    [self appendHeaderType:0x7374737A length:20 to:data];
    [self appendVersion:0 flags:0 to:data];
    unsigned int b = bytes;
    [self appendUInt32:b to:data];
    [self appendUInt32:1 to:data];
    return data;
}

+ (NSData *)stcoBoxWithByteOffset:(unsigned int)offset {
    NSMutableData *data = [NSMutableData data];
    [self appendHeaderType:0x7374636F length:20 to:data];
    [self appendVersion:0 flags:0 to:data];
    [self appendUInt32:1 to:data];
    unsigned int b = offset;
    [self appendUInt32:b to:data];

    return data;
}

+ (NSData *)mdatBoxHeaderWithbytesLength:(unsigned int)by {
    NSMutableData *data = [NSMutableData data];
    [self appendHeaderType:0x6D646174 length:by + 8 to:data];
    return data;
}
+ (NSData *)wideBox {
    NSMutableData *data = [NSMutableData data];
    [self appendHeaderType:0x77696465 length:8 to:data];
    return data;
}

+ (NSData *)stblBoxWithSize:(CGSize)size
                bytesLength:(unsigned int)bytesLength
                       avcC:(NSData *)avcC
                 byteOffset:(unsigned int)byteOffset {
    NSMutableData *data = [NSMutableData data];
    NSData *stsdBox = [self stsdBoxWithSize:size avcC:avcC];
    NSData *sttsBox = [self sttsBox];
    NSData *sdtpBox = [self sdtpBox];
    NSData *stscBox = [self stscBox];
    NSData *stszBox = [self stszBoxWithbytesLength:bytesLength];
    NSData *stcoBox = [self stcoBoxWithByteOffset:byteOffset];
    [self appendHeaderType:0x7374626C
                    length:(unsigned int)(stsdBox.length + sttsBox.length +
                                          sdtpBox.length + stscBox.length +
                                          stszBox.length + stcoBox.length + 8)
                        to:data];
    [data appendData:stsdBox];
    [data appendData:sttsBox];
    [data appendData:sdtpBox];
    [data appendData:stscBox];
    [data appendData:stszBox];
    [data appendData:stcoBox];
    return data;
}

+ (NSData *)sttsBox {
    NSMutableData *data = [NSMutableData data];
    [self appendHeaderType:0x73747473 length:24 to:data];
    [self appendVersion:0 flags:0 to:data];
    [self appendUInt32:1 to:data];
    [self appendUInt32:1 to:data];
    [self appendUInt32:40 to:data];
    return data;
}

+ (NSData *)minfBoxWithSize:(CGSize)size
                bytesLength:(unsigned int)bytesLength
                       avcC:(NSData *)avcC
                 byteOffset:(unsigned int)byteOffset {
    NSMutableData *data = [NSMutableData data];
    NSData *vmhdBox = [self vmhdBox];
    NSData *hdlrBox = [self hdlrBoxWithComponentType:0x64686C72
                                             subtype:0x616C6973
                                                name:@""];
    NSData *dinfBox = [self dinfBox];
    NSData *stblBox = [self stblBoxWithSize:size
                                bytesLength:bytesLength
                                       avcC:avcC
                                 byteOffset:byteOffset];
    [self appendHeaderType:0x6D696E66
                    length:(unsigned int)(vmhdBox.length + hdlrBox.length +
                                          dinfBox.length + stblBox.length + 8)
                        to:data];
    [data appendData:vmhdBox];
    [data appendData:hdlrBox];
    [data appendData:dinfBox];
    [data appendData:stblBox];
    return data;
}

+ (NSData *)mdiaBoxWithCreationDate:(NSDate *)creationDate
                   modificationDate:(NSDate *)modificationDate
                               size:(CGSize)size
                        bytesLength:(unsigned int)bytesLength
                               avcC:(NSData *)avcC
                         byteOffset:(unsigned int)byteOffset {
    NSMutableData *data = [NSMutableData data];
    NSData *mdhdBox = [self mdhdBoxWithCreationDate:creationDate
                                   modificationDate:modificationDate];

    NSData *hdlrBox = [self hdlrBoxWithComponentType:0x6D686C72
                                             subtype:0x76696465
                                                name:@""];
    NSData *minfBox = [self minfBoxWithSize:size
                                bytesLength:bytesLength
                                       avcC:avcC
                                 byteOffset:byteOffset];
    [self appendHeaderType:0x6D646961
                    length:(unsigned int)(mdhdBox.length + hdlrBox.length +
                                          minfBox.length + 8)
                        to:data];
    [data appendData:mdhdBox];
    [data appendData:hdlrBox];
    [data appendData:minfBox];
    return data;
}

+ (NSData *)hdlrBoxWithComponentType:(unsigned int)type
                             subtype:(unsigned int)subtype
                                name:(NSString *)name {
    NSMutableData *data = [NSMutableData data];
    NSData *nameData = [name dataUsingEncoding:NSASCIIStringEncoding];
    __auto_type length = MIN(nameData.length, 255);
    NSData *subData = [nameData subdataWithRange:NSMakeRange(0, length)];
    [self appendHeaderType:0x68646C72
                    length:(unsigned int)(subData.length + 33)
                        to:data];
    [self appendVersion:0 flags:0 to:data];
    [self appendUInt32:type to:data];
    [self appendUInt32:subtype to:data];

    [self appendUInt32:0x6170706C to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:0 to:data];
    __auto_type l = subData.length;
    [data appendBytes:&l length:1];
    [data appendData:subData];
    return data;
}

+ (NSData *)mp4HeaderWithDimension:(CGSize)dimension
                       bytesLength:(unsigned int)bytesLength
                              avcC:(NSData *)avcC {
    NSData *data = [self mp4HeaderWithDimension:dimension
                                    bytesLength:bytesLength
                                           avcC:avcC
                                     byteOffset:0];
    NSData *retData = [self mp4HeaderWithDimension:dimension
                                       bytesLength:bytesLength
                                              avcC:avcC
                                        byteOffset:(unsigned int)data.length];
    return retData;
}

+ (NSData *)mp4HeaderWithDimension:(CGSize)dimension
                       bytesLength:(unsigned int)bytesLength
                              avcC:(NSData *)avcC
                        byteOffset:(unsigned int)byteOffset {
    NSMutableData *data = [NSMutableData data];
    NSDate *now = [NSDate date];
    NSData *ftypBox = [self ftypBox];
    NSData *moovBox = [self moovBoxWithCreationDate:now
                                   modificationDate:now
                                               size:dimension
                                        bytesLength:bytesLength
                                               avcC:avcC
                                         byteOffset:byteOffset];
    NSData *wideBox = [self wideBox];
    NSData *mdatBox = [self mdatBoxHeaderWithbytesLength:bytesLength];
    [data appendData:ftypBox];
    [data appendData:moovBox];
    [data appendData:wideBox];
    [data appendData:mdatBox];
    return data;
}

+ (NSData *)trakBoxWithCreationDate:(NSDate *)creationDate
                   modificationDate:(NSDate *)modificationDate
                               size:(CGSize)size
                        bytesLength:(unsigned int)bytesLength
                               avcC:(NSData *)avcC
                         byteOffset:(unsigned int)byteOffset {
    NSMutableData *data = [NSMutableData data];
    NSData *tkhdBoxData = [self tkhdBoxWithCreationDate:creationDate
                                       modificationDate:modificationDate
                                                   size:size];
    NSData *taptBox = [self taptBoxWithSize:size];
    NSData *edtsBox = [self edtsBox];
    NSData *mdiaBox = [self mdiaBoxWithCreationDate:creationDate
                                   modificationDate:modificationDate
                                               size:size
                                        bytesLength:bytesLength
                                               avcC:avcC
                                         byteOffset:byteOffset];
    unsigned int length = (unsigned int)(tkhdBoxData.length + taptBox.length +
                                         edtsBox.length + mdiaBox.length);
    [self appendHeaderType:0x7472616B length:length + 8 to:data];
    [data appendData:tkhdBoxData];
    [data appendData:taptBox];
    [data appendData:edtsBox];
    [data appendData:mdiaBox];
    return data;
}

+ (void)appendUnityMatrixTo:(NSMutableData *)data {
    [self appendUInt32:0x10000 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:0x10000 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:0 to:data];
    [self appendUInt32:0x40000000 to:data];
}

+ (void)appendVersion:(unsigned char)version
                flags:(unsigned int)flags
                   to:(NSMutableData *)data {
    [self appendUInt32:(flags & 0xFFFFFF) | (version << 24) to:data];
}

+ (void)appendDate:(NSDate *)date to:(NSMutableData *)data {
    NSTimeInterval res =
        kCFAbsoluteTimeIntervalSince1904 + date.timeIntervalSinceReferenceDate;
    [self appendUInt32:res to:data];
}

@end

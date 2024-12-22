//
//  SYMP4HeaderConstructor.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYMP4HeaderConstructor : NSObject

+ (void)appendDate:(NSDate *)date to:(NSMutableData *)data;
+ (void)appendFloatAsFixedPoint:(double)point to:(NSMutableData *)data;
+ (void)appendUnityMatrixTo:(NSMutableData *)data;
+ (void)appendVersion:(unsigned char)version
                flags:(unsigned int)flags
                   to:(NSMutableData *)data;
+ (void)appendHeaderType:(unsigned int)type
                  length:(unsigned int)length
                      to:(NSMutableData *)data;
+ (void)appendUInt32:(unsigned int)value to:(NSMutableData *)data;
+ (void)appendUInt16:(unsigned short)value to:(NSMutableData *)data;
+ (NSData *)mdatBoxHeaderWithbytesLength:(unsigned int)by;
+ (NSData *)wideBox;
+ (NSData *)stcoBoxWithByteOffset:(unsigned int)offset;
+ (NSData *)stszBoxWithbytesLength:(unsigned int)bytes;
+ (NSData *)stscBox;
+ (NSData *)sdtpBox;
+ (NSData *)sttsBox;
+ (NSData *)avcCBoxWithInnerData:(NSData *)data;
+ (NSData *)avc1BoxWithSize:(CGSize)size avcC:(NSData *)avcC;
+ (NSData *)stsdBoxWithSize:(CGSize)size avcC:(NSData *)avcC;
+ (NSData *)stblBoxWithSize:(CGSize)size
                bytesLength:(unsigned int)bytesLength
                       avcC:(NSData *)avcC
                 byteOffset:(unsigned int)byteOffset;
+ (NSData *)alisBox;
+ (NSData *)drefBox;
+ (NSData *)dinfBox;
+ (NSData *)vmhdBox;
+ (NSData *)minfBoxWithSize:(CGSize)size
                bytesLength:(unsigned int)bytesLength
                       avcC:(NSData *)avcC
                 byteOffset:(unsigned int)byteOffset;
+ (NSData *)hdlrBoxWithComponentType:(unsigned int)type
                             subtype:(unsigned int)subtype
                                name:(NSString *)name;
+ (NSData *)mdhdBoxWithCreationDate:(NSDate *)creationDate
                   modificationDate:(NSDate *)modificationDate;
+ (NSData *)mdiaBoxWithCreationDate:(NSDate *)creationDate
                   modificationDate:(NSDate *)modificationDate
                               size:(CGSize)size
                        bytesLength:(unsigned int)bytesLength
                               avcC:(NSData *)avcC
                         byteOffset:(unsigned int)byteOffset;
+ (NSData *)elstBox;
+ (NSData *)edtsBox;
+ (NSData *)taptBoxWithSize:(CGSize)size;
+ (NSData *)tkhdBoxWithCreationDate:(NSDate *)creationDate
                   modificationDate:(NSDate *)modificationDate
                               size:(CGSize)size;
+ (NSData *)trakBoxWithCreationDate:(NSDate *)creationDate
                   modificationDate:(NSDate *)modificationDate
                               size:(CGSize)size
                        bytesLength:(unsigned int)bytesLength
                               avcC:(NSData *)avcC
                         byteOffset:(unsigned int)byteOffset;
+ (NSData *)mvhdBoxWithCreationDate:(NSDate *)creationDate
                   modificationDate:(NSDate *)modificationDate;
+ (NSData *)moovBoxWithCreationDate:(NSDate *)creationDate
                   modificationDate:(NSDate *)modificationDate
                               size:(CGSize)size
                        bytesLength:(unsigned int)bytesLength
                               avcC:(NSData *)avcC
                         byteOffset:(unsigned int)byteOffset;
+ (NSData *)ftypBox;
+ (NSData *)mp4HeaderWithDimension:(CGSize)dimension
                       bytesLength:(unsigned int)bytesLength
                              avcC:(NSData *)avcC
                        byteOffset:(unsigned int)byteOffset;
+ (NSData *)mp4HeaderWithDimension:(CGSize)dimension
                       bytesLength:(unsigned int)bytesLength
                              avcC:(NSData *)avcC;

@end

NS_ASSUME_NONNULL_END

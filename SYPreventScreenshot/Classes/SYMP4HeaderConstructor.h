//
//  SYMP4HeaderConstructor.h
//  SYPreventScreenshot
//
//  Created by SyNvNX on 2024/12/10.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

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

//
//  SYLogger.h
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

typedef NS_ENUM(NSUInteger, SYLogLevel) { SYLogLevelOff = 0, SYLogLevelOn = 1 };

typedef void (^SYLoggerBlock)(NSString *_Nullable message);

@interface SYLogger : NSObject

+ (void)setLevel:(SYLogLevel)level;
+ (void)setLoggerBlock:(SYLoggerBlock)logger;
+ (SYLogLevel)level;
+ (void)logAtLevel:(SYLogLevel)level
            format:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);
+ (void)logAtLevelOnFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
+ (SYLoggerBlock)loggerBlock;

@end

NS_ASSUME_NONNULL_END

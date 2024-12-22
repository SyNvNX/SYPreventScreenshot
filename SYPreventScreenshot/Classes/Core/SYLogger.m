//
//  SYLogger.m
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

#import "SYLogger.h"

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

static SYLogLevel _level;
static SYLoggerBlock _loggerBlock;

@implementation SYLogger

+ (void)setLevel:(SYLogLevel)level {
    _level = level;
}

+ (SYLogLevel)level {
    return _level;
}

+ (void)setLoggerBlock:(SYLoggerBlock)logger {
    _loggerBlock = [logger copy];
}

+ (SYLoggerBlock)loggerBlock {
    return _loggerBlock;
}

+ (void)logAtLevel:(SYLogLevel)level
            format:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3) {
    if (_level >= level) {
        va_list args;
        va_start(args, format);
        NSString *string = [[NSString alloc] initWithFormat:format
                                                  arguments:args];
        va_end(args);
        if (_loggerBlock) {
            _loggerBlock(string);
        }
    }
}

+ (void)logAtLevelOnFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2) {
    va_list args;
    va_start(args, format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    [self logAtLevel:SYLogLevelOn format:@"%@", string];
}

@end

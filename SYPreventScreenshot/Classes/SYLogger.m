//
//  SYLogger.m
//  SYPreventScreenshot
//
//  Created by SyNvNX on 2024/12/19.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

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

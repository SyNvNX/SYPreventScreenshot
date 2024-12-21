//
//  SYLogger.h
//  SYPreventScreenshot
//
//  Created by SyNvNX on 2024/12/19.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

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

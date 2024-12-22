//
//  SYPreventScreenshot.h
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/19.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import "SYLogger.h"
#import "SYPreventScreenshotImageView.h"
#import "SYPreventScreenshotLabel.h"
#import "SYWebServer.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYPreventScreenshot : NSObject

+ (void)setLevel:(SYLogLevel)level;
+ (void)setLoggerBlock:(SYLoggerBlock)logger;

@end

NS_ASSUME_NONNULL_END

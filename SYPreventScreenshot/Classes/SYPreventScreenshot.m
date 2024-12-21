//
//  SYPreventScreenshot.m
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/19.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import "SYPreventScreenshot.h"

@implementation SYPreventScreenshot

+ (void)setLevel:(SYLogLevel)level {
    [SYLogger setLevel:level];
}
+ (void)setLoggerBlock:(SYLoggerBlock)logger {
    [SYLogger setLoggerBlock:logger];
}

@end

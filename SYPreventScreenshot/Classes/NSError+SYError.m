//
//  NSError+SYError.m
//  SYPreventScreenshot
//
//  Created by SyNvNX on 2024/12/19.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import "NSError+SYError.h"

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

static NSString *const SYErrorDomain = @"com.sy.error";
@implementation NSError (SYError)

+ (NSError *)sye_errorWithMessages:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *string =
        [[NSString alloc] initWithFormat:format arguments:args] ?: @"";
    va_end(args);
    NSError *error =
        [NSError errorWithDomain:SYErrorDomain
                            code:-1
                        userInfo:@{NSLocalizedDescriptionKey : string}];
    return error;
}

@end

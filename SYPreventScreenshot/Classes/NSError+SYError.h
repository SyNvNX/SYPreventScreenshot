//
//  NSError+SYError.h
//  SYPreventScreenshot
//
//  Created by SyNvNX on 2024/12/19.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (SYError)

+ (NSError *)sye_errorWithMessages:(NSString *)format,
                                   ... NS_FORMAT_FUNCTION(1, 2);

@end

NS_ASSUME_NONNULL_END

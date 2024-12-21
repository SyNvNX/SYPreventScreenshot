//
//  SYMacros.h
//  ExampleT
//
//  Created by SyNvNX on 2024/12/19.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#ifndef SYMacros_h
#define SYMacros_h

#define dispatch_main_sync_safe(block)                                         \
    if ([NSThread isMainThread]) {                                             \
        block();                                                               \
    } else {                                                                   \
        dispatch_sync(dispatch_get_main_queue(), block);                       \
    }

#endif /* SYMacros_h */

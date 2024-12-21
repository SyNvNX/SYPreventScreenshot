//
//  SYWeakProxy.h
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/11.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYWeakProxy : NSProxy

@property(nullable, nonatomic, weak, readonly) id target;

- (instancetype)initWithTarget:(id)target;

+ (instancetype)proxyWithTarget:(id)target;
@end

NS_ASSUME_NONNULL_END

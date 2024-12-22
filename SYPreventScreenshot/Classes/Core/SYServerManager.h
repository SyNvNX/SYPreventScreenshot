//
//  SYServerManager.h
//  SYPreventScreenshot
//
//  Created by SyNvNX on 2024/12/12.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import <Foundation/Foundation.h>
FOUNDATION_EXTERN NSString * _Nonnull const SYServerManagerProcessRequestNotification;
FOUNDATION_EXTERN NSString * _Nonnull const SYServerManagerPathKey;
NS_ASSUME_NONNULL_BEGIN

@interface SYServerManager : NSObject

@property(nonatomic, strong, class, readonly) SYServerManager *sharedInstance;
- (void)addVideoDataToServer:(NSData *)data withPath:(NSString *)path;
- (void)removeVideoDataFromWebServer:(NSString *)path;
- (NSString *)randomPath;
@property(nonatomic, strong) dispatch_queue_t queue;
@property(nonatomic, assign) NSUInteger port;
@property(strong, nonatomic, nullable) NSError *error;
@end

NS_ASSUME_NONNULL_END

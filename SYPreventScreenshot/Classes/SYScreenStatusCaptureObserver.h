//
//  SYScreenStatusCaptureObserver.h
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/14.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYScreenStatusCaptureObserver : NSObject
+ (instancetype)instance;
@property(nonatomic, assign) BOOL isScreenBeingRecordedOnDevice;
@property(nonatomic, assign) BOOL isScreenBeingRecordedByQuickTime;
@property(nonatomic, assign) BOOL isScreenBeingMirrored;
@property(nonatomic, assign) BOOL isApplicationActive;
@end

NS_ASSUME_NONNULL_END

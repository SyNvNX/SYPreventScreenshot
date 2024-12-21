//
//  SYScreenCaptureDetector.h
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/9.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SYScreenStatusCaptureDetector, SYScreenStatusCaptureObserver;
NS_ASSUME_NONNULL_BEGIN

@protocol SYScreenStatusCaptureDetectorDelegate <NSObject>

@optional
- (void)screenStatusCaptureDetectorShouldReload:
    (SYScreenStatusCaptureDetector *)det;

@end

@interface SYScreenStatusCaptureDetector : NSObject

@property(nonatomic, strong, nullable)
    SYScreenStatusCaptureObserver *screenCaptureObserver;
@property(nonatomic, assign) BOOL isScreenBeingRecordedByQuickTime;
@property(nonatomic, assign) BOOL mayShowScreenCaptureView;
@property(nonatomic, assign) BOOL shouldShowScreenCaptureView;
@property(nonatomic, assign) BOOL shouldHideContent;
@property(nonatomic, getter=isCaptured) BOOL captured;
@property(nonatomic, weak) id<SYScreenStatusCaptureDetectorDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

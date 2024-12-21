//
//  SYImageToSampleBufferConverter.h
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/13.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
NS_ASSUME_NONNULL_BEGIN

@interface SYImageToSampleBufferConverter : NSObject

+ (CMSampleBufferRef)convertImageToSampleBuffer:(UIImage *)image
                                          error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

//
//  SYPreventPlayerLayerView.m
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/9.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import "SYPreventPlayerLayerView.h"
#import <AVFoundation/AVFoundation.h>

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@implementation SYPreventPlayerLayerView

+ (Class)layerClass {
    return AVPlayerLayer.class;
}

@end

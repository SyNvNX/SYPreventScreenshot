//
//  SYAVAssetResourceLoaderDelegate.m
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/11.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import "SYAVAssetResourceLoaderDelegate.h"
#import "NSError+SYError.h"
#import "SYLogger.h"
#import "SYServerManager.h"
#import <CoreServices/CoreServices.h>

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@interface SYAVAssetResourceLoaderDelegate ()

@end
@implementation SYAVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader
    shouldWaitForLoadingOfRequestedResource:
        (AVAssetResourceLoadingRequest *)loadingRequest {
    NSString *url = loadingRequest.request.URL.absoluteString;
    if ([url isEqualToString:@"sy://video.m3u8"]) {
        dispatch_async(self.serverManager.queue, ^{
          NSString *keyString = [self createm3u8WithPort:self.serverManager.port
                                                    path:self.videoPath];
          NSData *data = [keyString dataUsingEncoding:NSUTF8StringEncoding
                                 allowLossyConversion:NO];
          [loadingRequest.dataRequest respondWithData:data];
          [loadingRequest finishLoading];
        });
    } else if ([url isEqualToString:@"sy://video.key"]) {
        NSMutableData *data = [NSMutableData dataWithLength:16];
        [data resetBytesInRange:NSMakeRange(0, [data length])];
        [loadingRequest.dataRequest respondWithData:data];
        [loadingRequest finishLoading];
    } else {
        assert(false);
    }

    return YES;
}

- (NSString *)createm3u8WithPort:(NSUInteger)port path:(NSString *)path {
    CGFloat EXTINF = 1 / 15.0;
    return [self createm3u8WithDuration:1 EXTINF:EXTINF port:port path:path];
}

- (NSString *)createm3u8WithDuration:(NSInteger)duration
                              EXTINF:(CGFloat)EXTINF
                                port:(NSUInteger)port
                                path:(NSString *)path {
    NSString *format = @"#EXTM3U\n\
#EXT-X-PLAYLIST-TYPE:VOD\n\
#EXT-X-VERSION:"
                       @"5\n\
#EXT-X-TARGETDURATION:%@\n\
#EXT-X-KEY:METHOD="
                       @"SAMPLE-AES,URI=\"sy://"
                       @"video.key\"\n\
#EXTINF:%@,\n\
http://"
                       @"localhost:%@%@\n\
#EXT-X-ENDLIST\n";
    NSString *res = [NSString
        stringWithFormat:format, @(duration), @(EXTINF), @(port), path];
    return res;
}

- (instancetype)initWithMP4Data:(NSData *)data
                     errorBlock:
                         (SYAVAssetResourceLoaderDelegateErrorBlock)errorBlock {
    if (self = [super init]) {
        _mp4Data = data;
        _serverManager = [SYServerManager sharedInstance];
        _videoPath = [_serverManager randomPath];
        if (_videoPath) {
            [_serverManager addVideoDataToServer:_mp4Data withPath:_videoPath];
        } else {
            if (errorBlock) {
                NSError *error = [NSError sye_errorWithMessages:@"path == nil"];
                errorBlock(error);
                [SYLogger logAtLevelOnFormat:@"%@", error];
            }
        }
    }
    return self;
}

- (void)dealloc {
    [self.serverManager removeVideoDataFromWebServer:_videoPath ?: @""];
}

@end

//
//  SYServerManager.m
//
// Copyright (c) 2024 SyNvNX (https://github.com/SyNvNX)
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "SYServerManager.h"
#import "SYLogger.h"
#import "SYMacros.h"
#import "SYWebServer.h"
#import "SYWebServerDataResponse.h"
#import "SYWebServerErrorResponse.h"
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif
NSString *_Nonnull const SYServerManagerProcessRequestNotification =
    @"SYServerManagerProcessRequestNotification";
NSString *_Nonnull const SYServerManagerPathKey = @"path";

@interface SYServerManager ()

@property(nonatomic, strong) SYWebServer *webServer;
@property(nonatomic, strong) NSMutableDictionary *videoData;
@property(nonatomic, assign) BOOL hasResponse;
@end

@implementation SYServerManager

+ (SYServerManager *)sharedInstance {
    static SYServerManager *_mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      _mgr = [[self alloc] init];
    });
    return _mgr;
}
- (instancetype)init {
    if (self = [super init]) {
        _queue =
            dispatch_queue_create("com.sy.server.queue", DISPATCH_QUEUE_SERIAL);
        _videoData = [NSMutableDictionary dictionary];
        _webServer = nil;
    }
    return self;
}

- (void)retryGcdServer:(SYWebServer *)webServer limit:(NSInteger)limit {
    if (![webServer isRunning] && limit < 1) {
        NSNetService *service =
            [[NSNetService alloc] initWithDomain:@"local."
                                            type:@"_http._tcp."
                                            name:@""
                                            port:0];
        [service publishWithOptions:NSNetServiceListenForConnections];
        [service stop];
        NSInteger port = service.port;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[SYWebServerOption_Port] = @(port);
        dic[SYWebServerOption_AutomaticallySuspendInBackground] = @(YES);
        dic[SYWebServerOption_BindToLocalhost] = @(YES);
        NSError *error = nil;
        BOOL ret = [webServer startWithOptions:dic error:&error];
        self.error = error;
        if (error) {
            [SYLogger
                logAtLevelOnFormat:@"error web:%@,port:%@", error, @(port)];
        } else if (ret) {
            [SYLogger logAtLevelOnFormat:@"__>count:%@", @(limit)];
        }
        [self retryGcdServer:webServer limit:++limit];
    }
}
- (void)_startWebServer {
    self.webServer = [[SYWebServer alloc] init];
    __weak __auto_type weakSelf = self;
    [self.webServer
        addDefaultHandlerForMethod:@"GET"
                      requestClass:[SYWebServerRequest class]
                      processBlock:^SYWebServerResponse *_Nullable(
                          __kindof SYWebServerRequest *_Nonnull request) {
                        weakSelf.hasResponse = YES;

                        NSString *Host = request.headers[@"Host"];
                        BOOL hasPrefix = [Host hasPrefix:@"localhost:"];
                        if (hasPrefix) {
                            NSString *path = request.path ?: @"";
                            NSData *data = weakSelf.videoData[path];
                            if (data) {
                                dispatch_main_sync_safe(^{
                                  [NSNotificationCenter.defaultCenter
                                      postNotificationName:
                                          SYServerManagerProcessRequestNotification
                                                    object:nil
                                                  userInfo:@{
                                                      SYServerManagerPathKey :
                                                          path
                                                  }];
                                });
                                return [[SYWebServerDataResponse alloc]
                                    initWithData:data
                                     contentType:@"application/octet-stream"];
                            }
                        }
                        [SYLogger
                            logAtLevelOnFormat:@"data not found %@",
                                               request.URL.absoluteString];
                        return [SYWebServerErrorResponse
                            responseWithClientError:
                                kSYWebServerHTTPStatusCode_NotFound
                                            message:@"data not found"];
                      }];
    int retryCount = 3;
    do {
        if (![self.webServer isRunning]) {
            NSNetService *service =
                [[NSNetService alloc] initWithDomain:@"local."
                                                type:@"_http._tcp."
                                                name:@""
                                                port:0];
            [service publishWithOptions:NSNetServiceListenForConnections];
            [service stop];
            NSInteger port = service.port;
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[SYWebServerOption_Port] = @(port);
            dic[SYWebServerOption_AutomaticallySuspendInBackground] = @(YES);
            dic[SYWebServerOption_BindToLocalhost] = @(YES);
            NSError *error = nil;
            [self.webServer startWithOptions:dic error:&error];
            self.error = error;
            if (error) {
                [SYLogger
                    logAtLevelOnFormat:@"error web:%@,port:%@", error, @(port)];
            }
        } else {
            break;
        }

        retryCount--;
    } while (retryCount > 0);
    if (self.error) {
        [SYLogger logAtLevelOnFormat:@"error web:%@", self.error];
    }
}

- (NSString *)randomPath {
    return [NSString stringWithFormat:@"/%@", NSUUID.UUID.UUIDString];
}

- (void)addVideoDataToServer:(NSData *)data withPath:(NSString *)path {
    __weak __auto_type weakSelf = self;
    dispatch_async(self.queue, ^{
      weakSelf.videoData[path] = data;
      if (weakSelf.videoData.count == 1) {
          dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf _startWebServer];
          });
      }
    });
}

- (void)removeVideoDataFromWebServer:(NSString *)path {
    __weak __auto_type weakSelf = self;
    dispatch_async(self.queue, ^{
      [weakSelf.videoData removeObjectForKey:path];
      if (weakSelf.videoData.count == 0) {
          if (weakSelf.webServer.isRunning) {
              [weakSelf.webServer stop];
          }

          weakSelf.hasResponse = NO;
          weakSelf.webServer = nil;
          weakSelf.error = nil;
      }
    });
}

- (NSUInteger)port {
    return self.webServer.port;
}

@end

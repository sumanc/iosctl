//
//  BSIWebServer.m
//  iosctl
//
//  Created by Suman Cherukuri on 6/25/19.
//  Copyright © 2019 Suman Cherukuri. All rights reserved.
//

#import "BSIWebServer.h"
#import "BSICaptureSession.h"
#import "GCDWebServerDataResponse.h"
#import "GCDWebServerURLEncodedFormRequest.h"

@implementation BSIWebServer {
    
}

+ (BSIWebServer *)sharedInstance {
    static BSIWebServer *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[BSIWebServer alloc] init];
    });
    return _sharedInstance;
}

- (void)start:(NSInteger)port {
    GCDWebServer* webServer = [[GCDWebServer alloc] init];
    
    [GCDWebServer setLogLevel:3];
    [webServer setDelegate:self];
    // Add a handler to respond to GET requests on any URL
    [webServer addDefaultHandlerForMethod:@"GET"
                             requestClass:[GCDWebServerRequest class]
                             processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                 return [GCDWebServerDataResponse responseWithJSONObject:@{@"Status" : @"0", @"Message" : @"Hello, World!"}];
                             }];
    
    [webServer addHandlerForMethod:@"POST"
                              path:@"/screencast"
                      requestClass:[GCDWebServerURLEncodedFormRequest class]
                      processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                          NSData *data = [(GCDWebServerURLEncodedFormRequest*)request data];
                          NSError *error;
                          NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                          if (error) {
                              return [GCDWebServerDataResponse responseWithJSONObject:@{@"Status" : @"1", @"Message" : error.localizedDescription}];
                          }
                          NSLog(@"%@", dictionary);
                          NSString *deviceId = [dictionary objectForKey:@"udid"];
                          if (deviceId == nil) {
                              return [GCDWebServerDataResponse responseWithJSONObject:@{@"Status" : @"2", @"Message" : @"Missing udid"}];
                          }
                          NSInteger fps = [[dictionary objectForKey:@"fps"] integerValue];
                          if (fps <= 0) {
                              fps = 10;
                          }
                          if (fps > 60) {
                              fps = 60;
                          }
                          NSError *ret = [BSICaptureSession startSession:deviceId fps:fps];
                          return [GCDWebServerDataResponse responseWithJSONObject:@{@"Status" : ret == nil ? @"4" : @"0", @"Message" : ret == nil ? @"Success" : ret.userInfo}];
                      }];
    
    [webServer addHandlerForMethod:@"POST"
                              path:@"/stopscreencast"
                      requestClass:[GCDWebServerURLEncodedFormRequest class]
                      processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                          NSData *data = [(GCDWebServerURLEncodedFormRequest*)request data];
                          NSError *error;
                          NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                          if (error) {
                              return [GCDWebServerDataResponse responseWithJSONObject:@{@"Status" : @"1", @"Message" : error.localizedDescription}];
                          }
                          NSLog(@"%@", dictionary);
                          NSString *deviceId = [dictionary objectForKey:@"udid"];
                          if (deviceId == nil) {
                              return [GCDWebServerDataResponse responseWithJSONObject:@{@"Status" : @"2", @"Message" : @"Missing udid"}];
                          }
                          [BSICaptureSession stopSession:deviceId];
                          return [GCDWebServerDataResponse responseWithJSONObject:@{@"Status" : @"0", @"Message" : @"Success"}];
                      }];
    
    [webServer runWithPort:port bonjourName:nil];
}

- (void)webServerDidStart:(GCDWebServer*)server {
    printf("iosctl Server Started at %s\n", [server.serverURL.absoluteString UTF8String]);
}

@end

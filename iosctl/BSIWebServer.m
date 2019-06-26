//
//  BSIWebServer.m
//  iosctl
//
//  Created by Suman Cherukuri on 6/25/19.
//  Copyright © 2019 Suman Cherukuri. All rights reserved.
//

#import "BSIWebServer.h"
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
                                 return [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>Hello World</p></body></html>"];
                             }];
    
    [webServer addHandlerForMethod:@"POST"
                              path:@"/screencast"
                      requestClass:[GCDWebServerURLEncodedFormRequest class]
                      processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                          NSString* value = [[(GCDWebServerURLEncodedFormRequest*)request arguments] objectForKey:@"value"];
//                          NSData *data = [(GCDWebServerURLEncodedFormRequest*)request data];
//                          NSString *dataString = [NSString stringWithUTF8String:[data bytes]];
                          NSString* html = [NSString stringWithFormat:@"<html><body><p>%@</p></body></html>", value];
                          return [GCDWebServerDataResponse responseWithHTML:html];
                      }];
    [webServer runWithPort:port bonjourName:nil];
}

- (void)webServerDidStart:(GCDWebServer*)server {
    printf("***\niosctl Server Started...\n");
    printf("Visit %s in your web browser\n***\n", [server.serverURL.absoluteString UTF8String]);
}

@end

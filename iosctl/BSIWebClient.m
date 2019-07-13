//
//  BSIWebClient.m
//  iosctl
//
//  Created by Suman Cherukuri on 7/12/19.
//  Copyright © 2019 Suman Cherukuri. All rights reserved.
//

#import "BSIWebClient.h"

@implementation BSIWebClient {
    SRWebSocket *_srWebSocket;
}

+ (BSIWebClient *)sharedInstance {
    static BSIWebClient *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[BSIWebClient alloc] init];
    });
    return _sharedInstance;
}

- (void)initWith:(NSString *)url {
    NSURL *nsURL = [NSURL URLWithString:url];
    _srWebSocket = [[SRWebSocket alloc] initWithURL:nsURL securityPolicy:[SRSecurityPolicy defaultPolicy]];
    _srWebSocket.delegate = self;
    [_srWebSocket open];
    return;
}

- (void)sendData:(NSData *)data {
    NSError *error = nil;
    [_srWebSocket sendData:data error:&error];
    if (error) {
        printf("WEBSOCKET ERROR: %s\n", [error.localizedDescription UTF8String]);
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    printf("WEBSOCKET ERROR: %s: %s\n", [error.localizedDescription UTF8String], [webSocket.url.absoluteString UTF8String]);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    printf("websocket Opened connection to %s\n", [webSocket.url.absoluteString UTF8String]);
}

@end

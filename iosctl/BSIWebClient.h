//
//  BSIWebClient.h
//  iosctl
//
//  Created by Suman Cherukuri on 7/12/19.
//  Copyright © 2019 Suman Cherukuri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketRocket.h"

@interface BSIWebClient : NSObject <SRWebSocketDelegate>

+ (BSIWebClient *)sharedInstance;
- (void)initWith:(NSString *)url;
- (void)sendData:(NSData *)data;

@end


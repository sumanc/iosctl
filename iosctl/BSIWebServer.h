//
//  BSIWebServer.h
//  iosctl
//
//  Created by Suman Cherukuri on 6/25/19.
//  Copyright © 2019 Suman Cherukuri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDWebServer.h"

@interface BSIWebServer : NSObject <GCDWebServerDelegate>

+ (BSIWebServer *)sharedInstance;
- (void)start:(NSInteger)port;

@end


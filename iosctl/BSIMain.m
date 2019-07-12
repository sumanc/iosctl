//
//  BSIMain.m
//  iosctl
//
//  Created by Suman Cherukuri on 6/25/19.
//  Copyright © 2019 Suman Cherukuri. All rights reserved.
//

#import "BSIMain.h"
#import "BSIWebServer.h"
#import "BSIWebClient.h"

@implementation BSIMain

+ (void)showUsage {
    printf("\niosctl - Commandline tool to control devices and simulators");
    printf("\nUsage:\n");
    printf("./iosctl [-h] [-port <port number>]\n");
    printf("   -h                   display this message\n");
    printf("   -port <port numnber> port number to listen on for commands\n");
    printf("   -url <url>           websocket url to send data to\n");
}

+ (int)main:(int)argc argv:(const char **)argv {
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    NSInteger portNumber = 4567;
    NSString *urlString;
    for (int i = 1; i < args.count; i++) {
        if ([args[i] caseInsensitiveCompare:@"-help"] == NSOrderedSame ||
            [args[i] caseInsensitiveCompare:@"-?"] == NSOrderedSame ||
            [args[i] caseInsensitiveCompare:@"-h"] == NSOrderedSame) {
            [BSIMain showUsage];
            return 0;
        }
        if ([args[i] caseInsensitiveCompare:@"-port"] == NSOrderedSame) {
            if (++i < args.count) {
                portNumber = [args[i] integerValue];
            }
            else {
                printf("\n*** Missing argument for -port ***\n");
                [BSIMain showUsage];
                return 1;
            }
        }
        
        if ([args[i] caseInsensitiveCompare:@"-url"] == NSOrderedSame) {
            if (++i < args.count) {
                urlString = args[i];
            }
            else {
                printf("\n*** Missing argument for -url ***\n");
                [BSIMain showUsage];
                return 2;
            }
        }
    }

    if (portNumber <= 0) {
        printf("\n*** Invalid or missing port number: %ld ***\n", (long)portNumber);
        [BSIMain showUsage];
        return 3;
    }
    
    if (urlString == nil) {
        printf("\n*** Invalid or missing url: %s ***\n", [urlString UTF8String]);
        [BSIMain showUsage];
        return 4;
    }
    [[BSIWebClient sharedInstance] initWith:urlString];
    [[BSIWebServer sharedInstance] start:portNumber];
    return 0;
}

@end

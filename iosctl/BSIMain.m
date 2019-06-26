//
//  BSIMain.m
//  iosctl
//
//  Created by Suman Cherukuri on 6/25/19.
//  Copyright © 2019 Suman Cherukuri. All rights reserved.
//

#import "BSIMain.h"
#import "BSIWebServer.h"

@implementation BSIMain

+ (void)showUsage {
    printf("\niosctl - Commandline tool to control devices and simulators");
    printf("\nUsage:\n");
    printf("./iosctl [-h] [-port <port number>]\n");
    printf("   -h    display this message\n");
    printf("   -port <port numnber>    port number to listen on for commands\n");
}

+ (int)main:(int)argc argv:(const char **)argv {
    NSInteger portNumber = 4567;
    NSArray *args = [[NSProcessInfo processInfo] arguments];
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
    }

    if (portNumber <= 0) {
        printf("\n*** Invalid or missing port number: %ld ***\n", (long)portNumber);
        [BSIMain showUsage];
        return 2;
    }
//    printf("\niosctl listening on port: %ld\n", portNumber);
    [[BSIWebServer sharedInstance] start:portNumber];
//    [[NSRunLoop mainRunLoop] run];
    return 0;
}

@end

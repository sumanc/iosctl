//
//  BSICaptureSession.h
//  iosctl
//
//  Created by Suman Cherukuri on 7/9/19.
//  Copyright © 2019 Suman Cherukuri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface BSICaptureSession : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

+ (NSError *) startSession:(NSString *)udid fps:(NSInteger)fps;
+ (void) stopSession:(NSString *)udid;

@end


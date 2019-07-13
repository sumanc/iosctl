//
//  BSICaptureSession.m
//  iosctl
//
//  Created by Suman Cherukuri on 7/9/19.
//  Copyright © 2019 Suman Cherukuri. All rights reserved.
//

#import <CoreMediaIO/CMIOHardwareObject.h>
#import <CoreMediaIO/CMIOHardwareSystem.h>
#import <AppKit/AppKit.h>
#import "BSICaptureSession.h"
#import "BSIWebClient.h"

@implementation BSICaptureSession {
    dispatch_queue_t _writeQueue;
    AVCaptureSession *_session;
    NSString *_udid;
    NSInteger _fps;
    NSUInteger _frameCount;
}

+ (NSMutableDictionary *)sessionsDictionary {
    static NSMutableDictionary *_captureSessions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _captureSessions = [NSMutableDictionary dictionary];
    });
    return _captureSessions;
}

+ (NSError *) startSession:(NSString *)udid fps:(NSInteger)fps {
    BSICaptureSession *captureSession = [[BSICaptureSession alloc] init];
    return [captureSession startSession:udid fps:fps];
}

+ (void) stopSession:(NSString *)udid {
    BSICaptureSession *captureSession = [[self sessionsDictionary] objectForKey:udid];
    if (captureSession) {
        [captureSession stopSession];
    }
}

- (NSError *) startSession:(NSString *)udid fps:(NSInteger)fps {
    _udid = udid;
    _fps = fps;
    [self stopSession];
    
    if ([self allowAccessToScreenCapture] == NO) {
        return [[NSError alloc] initWithDomain:@"com.bytesized.iosctl" code:10 userInfo:@{@"Error reason": @"Failed to allow access to capture devices"}];
    }
    AVCaptureDevice *captureDevice = [AVCaptureDevice deviceWithUniqueID:udid];
    int i = 0;
    while (captureDevice == nil && i < 5) {
        [NSThread sleepForTimeInterval:1];
        captureDevice = [AVCaptureDevice deviceWithUniqueID:udid];
        i++;
    }
    if (captureDevice == nil) {
        return [[NSError alloc] initWithDomain:@"com.bytesized.iosctl" code:11 userInfo:@{@"Error reason": [NSString stringWithFormat:@"Device %@ not found", udid]}];
    }
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (deviceInput == nil) {
        return [[NSError alloc] initWithDomain:@"com.bytesized.iosctl" code:12 userInfo:@{@"Error reason": [NSString stringWithFormat:@"Failed to get device input: %@", error.localizedDescription]}];
    }
    _session = [[AVCaptureSession alloc] init];
    if (![_session canAddInput:deviceInput]) {
        return [[NSError alloc] initWithDomain:@"com.bytesized.iosctl" code:13 userInfo:@{@"Error reason": [NSString stringWithFormat:@"Cannot add Device Input to session for %@", captureDevice]}];
    }
    [_session addInput:deviceInput];
    
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    output.alwaysDiscardsLateVideoFrames = YES;
    output.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    
    self->_writeQueue = dispatch_queue_create("com.bytesized.iosctl", NULL);
    [output setSampleBufferDelegate:self queue:self->_writeQueue];

    if (![_session canAddOutput:output]) {
        return [[NSError alloc] initWithDomain:@"com.bytesized.iosctl" code:14 userInfo:@{@"Error reason": [NSString stringWithFormat:@"Cannot add Device Output to session for %@", captureDevice]}];
    }
    [_session addOutput:output];
    [_session startRunning];
    
    [[BSICaptureSession sessionsDictionary] setObject:self forKey:udid];
    return nil;
}

- (void)stopSession {
    [_session stopRunning];
    [[BSICaptureSession sessionsDictionary] removeObjectForKey:_udid];
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    _frameCount++;
    if ((_frameCount) % (60/_fps) != 0) {
//        NSLog(@"dropping %lu", _frameCount);
        return;
    }
//    NSLog(@"got sample buffer");
    NSData *data = [self imageDataFrom:sampleBuffer];
    [[BSIWebClient sharedInstance] sendData:data];
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection API_AVAILABLE(ios(6.0)) {
//    NSLog(@"dropped sample buffer");
}
- (BOOL)allowAccessToScreenCapture {
    CMIOObjectPropertyAddress properties = {
        kCMIOHardwarePropertyAllowScreenCaptureDevices,
        kCMIOObjectPropertyScopeGlobal,
        kCMIOObjectPropertyElementMaster,
    };
    UInt32 allow = 1;
    OSStatus status = CMIOObjectSetPropertyData(kCMIOObjectSystemObject,
                                                &properties,
                                                0,
                                                NULL,
                                                sizeof(allow),
                                                &allow);
    if (status != 0) {
        return NO;
    }
    return YES;
}

- (NSData *)imageDataFrom:(CMSampleBufferRef)sampleBufferRef {
    CVImageBufferRef imageBufferRef = CMSampleBufferGetImageBuffer(sampleBufferRef);
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:imageBufferRef];
    if (imageBufferRef == nil) {
        return nil;
    }
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCIImage:ciImage];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.0] forKey:NSImageCompressionFactor];
    NSData *imageData = [bitmapRep representationUsingType:NSBitmapImageFileTypeJPEG properties:imageProps];
    return imageData;
}

@end

//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "THCameraController.h"
#import <AVFoundation/AVFoundation.h>

@interface THCameraController () <AVCaptureMetadataOutputObjectsDelegate>   // 1
@property (strong, nonatomic) AVCaptureMetadataOutput *metadataOutput;
@end

@implementation THCameraController

- (BOOL)setupSessionOutputs:(NSError **)error {
    //因为不需要父类中的实现，所以此处不调用super的实现
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];           // 2

    if ([self.captureSession canAddOutput:self.metadataOutput]) {
        [self.captureSession addOutput:self.metadataOutput];
        //指定对象输出的元数据类型
        NSArray *metadataObjectTypes = @[AVMetadataObjectTypeFace];         // 3
        self.metadataOutput.metadataObjectTypes = metadataObjectTypes;
        //当有新的元数据被检测到时，AVCaptureMetadataOutput需要一个委托对象可以被调用，队列需要传入串行队列，以方便顺序执行。由于人脸识别用到硬件加速，所以需要知道这个参数为主队列
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        [self.metadataOutput setMetadataObjectsDelegate:self                // 4
                                                  queue:mainQueue];

        return YES;

    } else {                                                                // 5
        if (error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:
                                           @"Failed to still image output."};
            *error = [NSError errorWithDomain:THCameraErrorDomain
                                         code:THCameraErrorFailedToAddOutput
                                     userInfo:userInfo];
        }
        return NO;
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {

    for (AVMetadataFaceObject *face in metadataObjects) {                   // 2
        NSLog(@"Face detected with ID: %li", (long)face.faceID);
        NSLog(@"Face bounds: %@", NSStringFromCGRect(face.bounds));
    }

    [self.faceDetectionDelegate didDetectFaces:metadataObjects];            // 3
    
}

@end


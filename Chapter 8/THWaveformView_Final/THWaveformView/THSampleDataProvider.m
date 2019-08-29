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

#import "THSampleDataProvider.h"

@implementation THSampleDataProvider

+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset
                  completionBlock:(THSampleDataCompletionBlock)completionBlock {
    
    NSString *tracks = @"tracks";
    //对资源所需的键执行标准的异步载入操作
    [asset loadValuesAsynchronouslyForKeys:@[tracks] completionHandler:^{   // 1
        
        AVKeyValueStatus status = [asset statusOfValueForKey:tracks error:nil];
        
        NSData *sampleData = nil;
        //tracks属性载入成功后 从资源音频轨道中读取样本
        if (status == AVKeyValueStatusLoaded) {                             // 2
            sampleData = [self readAudioSamplesFromAsset:asset];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{                        // 3
            completionBlock(sampleData);
        });
    }];
    
}

+ (NSData *)readAudioSamplesFromAsset:(AVAsset *)asset {
    
    NSError *error = nil;
    
    AVAssetReader *assetReader =                                            // 1
        [[AVAssetReader alloc] initWithAsset:asset error:&error];
    
    if (!assetReader) {
        NSLog(@"Error creating asset reader: %@", [error localizedDescription]);
        return nil;
    }
    //获取资源中找到的第一个音频轨道
    AVAssetTrack *track =                                                   // 2
        [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    //设置样本为16位、小端字节顺序的有符号整型、未压缩的方式读取
    NSDictionary *outputSettings = @{                                       // 3
        AVFormatIDKey               : @(kAudioFormatLinearPCM),
        AVLinearPCMIsBigEndianKey   : @NO,
		AVLinearPCMIsFloatKey		: @NO,
		AVLinearPCMBitDepthKey		: @(16)
    };
    
    
    AVAssetReaderTrackOutput *trackOutput =                                 // 4
        [[AVAssetReaderTrackOutput alloc] initWithTrack:track
                                         outputSettings:outputSettings];
    
    [assetReader addOutput:trackOutput];
    
    [assetReader startReading];
    
    NSMutableData *sampleData = [NSMutableData data];
    //AVAssetReaderStatusReading表示reader已经准备好提供sampleBuffer
    while (assetReader.status == AVAssetReaderStatusReading) {
        
        CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];// 5
        
        if (sampleBuffer) {
            //Block buffer 用于在Core Media通道中传递任意字节的数据，该函数会得到一个unretained引用
            CMBlockBufferRef blockBufferRef =                               // 6
                CMSampleBufferGetDataBuffer(sampleBuffer);
            //创建一个16位的带符号整型数组来保存这些音频样本
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            SInt16 sampleBytes[length];
            CMBlockBufferCopyDataBytes(blockBufferRef,                      // 7
                                       0,
                                       length,
                                       sampleBytes);
            
            [sampleData appendBytes:sampleBytes length:length];
            //指定sampleBuffer已经处理和不可使用后释放该内容
            CMSampleBufferInvalidate(sampleBuffer);                         // 8
            CFRelease(sampleBuffer);
        }
    }
    
    if (assetReader.status == AVAssetReaderStatusCompleted) {               // 9
        return sampleData;
    } else {
        NSLog(@"Failed to read audio samples from asset");
        return nil;
    }
}

@end

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

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "THTimelineItem.h"

typedef void(^THPreparationCompletionBlock)(BOOL complete);
//该类是AVAsset类实例的封装并负责为组合内容合理的载入和准备资源
@interface THMediaItem : THTimelineItem

@property (strong, nonatomic) AVAsset *asset;
@property (nonatomic, readonly) BOOL prepared;
@property (nonatomic, readonly) NSString *mediaType;
@property (nonatomic, copy, readonly) NSString *title;

- (id)initWithURL:(NSURL *)url;

- (void)prepareWithCompletionBlock:(THPreparationCompletionBlock)completionBlock;

- (void)performPostPrepareActionsWithCompletionBlock:(THPreparationCompletionBlock)completionBlock;

- (BOOL)isTrimmed;

- (AVPlayerItem *)makePlayable;

@end

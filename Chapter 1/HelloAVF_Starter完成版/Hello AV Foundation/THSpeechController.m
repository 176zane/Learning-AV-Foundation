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

#import "THSpeechController.h"
#import <AVFoundation/AVFoundation.h>

@interface THSpeechController ()

@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;//在extension中重新定义该属性，这样就可以支持读写操作。
@property (strong, nonatomic) NSArray *voices;
@property (strong, nonatomic) NSArray *speechStrings;

@end

@implementation THSpeechController

+ (instancetype)speechController {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _voices = @[[AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"],//美式英语
                    [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"],//英式英语
                    [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"]];
        _speechStrings = [self buildSpeechStrings];
    }
    return self;
}
- (NSArray *)buildSpeechStrings {
    return @[@"试试汉语行不行。666",
             @"行行行，他日若遂凌云志，敢笑黄巢不丈夫。 哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈",
             @"Hell AV Foundation, How are you?",
             @"I'm well, Thanks for asking",
             @"Very! I have always felt so misunderstood",
             @"What's your favorite feature?",
             @"Oh, they're all my babies. I couldn't possible choose",
             @"It was great to speak with you",
             @"The pleasure was all mine! Have fun!"];
}
- (void)beginConversation {
    for (NSUInteger i = 0; i < self.speechStrings.count; i++) {
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:self.speechStrings[i]];
        if (i<2) {
            utterance.voice = self.voices[2];
        }else {
            utterance.voice = self.voices[i % 2];
        }
        utterance.rate = 0.4f;//播放速度
        utterance.pitchMultiplier = 0.8f;//i音调
        utterance.postUtteranceDelay = 0.1f;
        [self.synthesizer speakUtterance:utterance];
    }
}

@end

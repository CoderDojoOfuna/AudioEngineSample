//
//  ViewController.m
//  AudioEngineSample
//
//  Created by chieest on 2019/04/15.
//  Copyright © 2019年 chieest.com. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"

@interface ViewController ()
@property AVAudioEngine *engine;
@property AVAudioPlayerNode *playerNode;
@property AVAudioMixerNode *mainMixerNode;
@property AVAudioPCMBuffer *audioPCMBuffer;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@end
static NSString *const audioFileName = @"sample.mp3";
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if (!self.setupAudioBuffer) {
        [self enableUI:NO];
        return;
    }
    if (!self.setupAudioEngine) {
        [self enableUI:NO];
        return;
    }
}
-(IBAction)onStartTouchUpInside:(UIButton*)button {
    if (self.playerNode.isPlaying) {
        return;
    }
    [self.playerNode scheduleBuffer:self.audioPCMBuffer atTime:nil options: AVAudioPlayerNodeBufferLoops completionHandler:nil];
    [self.playerNode play];
}
-(IBAction)onStopTouchUpInside:(UIButton*)button {
    if (!self.playerNode.isPlaying) {
        return;
    }
    [self.playerNode stop];
}
#pragma mark setup UI
-(void)enableUI:(BOOL)enable {
    [self.startButton setEnabled:enable];
    [self.stopButton setEnabled:enable];
}
#pragma mark setup audio
-(BOOL)setupAudioBuffer {
    AVAudioFile *audioFile = self.defaultAudioFile;
    if (audioFile == nil) {
        return NO;
    }
    self.audioPCMBuffer = [self audioPCMBufferWith:audioFile];
    if (self.audioPCMBuffer == nil) {
        return NO;
    } else {
        return YES;
    }
}
-(AVAudioFile*)defaultAudioFile {
    NSError *error = nil;
    NSBundle *bundle = NSBundle.mainBundle;
    NSString *audioUrlString = [bundle pathForResource:audioFileName ofType:@""];
    NSURL *url = [NSURL fileURLWithPath:audioUrlString];
    AVAudioFile *audioFile = [AVAudioFile.alloc initForReading:url error:&error];
    if (audioFile == nil) {
        NSLog(@"error:%@", error);
    }
    return audioFile;
}
-(AVAudioPCMBuffer*)audioPCMBufferWith:(AVAudioFile*)file {
    NSError *error = nil;
    AVAudioFormat *audioFormat = file.processingFormat;
    AVAudioFrameCount audioFileFrameCount = (AVAudioFrameCount)file.length;
    AVAudioPCMBuffer *audioPCMBuffer = [AVAudioPCMBuffer.alloc initWithPCMFormat:audioFormat frameCapacity:audioFileFrameCount];
    if (![file readIntoBuffer:audioPCMBuffer error:&error]) {
        NSLog(@"error:%@", error);
        audioPCMBuffer = nil;
    }
    return audioPCMBuffer;
}
-(BOOL)setupAudioEngine {
    self.engine = AVAudioEngine.new;
    self.mainMixerNode = self.engine.mainMixerNode;
    self.playerNode = AVAudioPlayerNode.new;
    [self.engine attachNode:self.playerNode];
    return [self startAudioEngine];
}
-(BOOL)startAudioEngine {
    NSError *error = nil;
    if (self.audioPCMBuffer == nil) {
        return NO;
    }
    [self.engine connect:self.playerNode to:self.mainMixerNode format:self.audioPCMBuffer.format];
    [self.engine prepare];
    if ([self.engine startAndReturnError:&error]) {
        return YES;
    } else {
        NSLog(@"error:%@", error);
        return NO;
    }
}
@end

//
//  ViewController.m
//  MRSAudioMixer
//
//  Created by admin on 3/8/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MRSAudioMixer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (IBAction)click:(id)sender {
    // test
    NSString *audioPath1 = [[NSBundle mainBundle] pathForResource:@"6" ofType:@"m4a"];
    NSString *audioPath2 = [[NSBundle mainBundle] pathForResource:@"7" ofType:@"m4a"];
    
    [MRSAudioMixer mixAudio:audioPath1 andAudio:audioPath2 handler:^(NSString *outputFilepath) {
            NSLog(@"---filePath---%@----",outputFilepath);
            if (outputFilepath != nil && outputFilepath.length > 0) {
                [self playAudio:[NSURL fileURLWithPath:outputFilepath]];
            }
    }];
}


- (void)playAudio:(NSURL *)url {
    // 传入地址
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
//    playerItem.audioMix =
    // 播放器
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    // 播放器layer
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.view.frame;
    // 视频填充模式
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加到imageview的layer上
    [self.view.layer addSublayer:playerLayer];
    // 播放
    [player play];
    
}

@end

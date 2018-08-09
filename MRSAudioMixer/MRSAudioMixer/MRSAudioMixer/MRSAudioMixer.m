//
//  MRSAudioMixer.m
//  MRSAudioMixer
//
//  Created by admin on 3/8/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "MRSAudioMixer.h"
#import <AVFoundation/AVFoundation.h>

@implementation MRSAudioMixer

//+ (void)mixAudio:(NSString *)recordPath andAudio:(NSString *)backgroundPath handler:(void (^)(NSString *))handler {
//    NSURL *recordUrl = [NSURL fileURLWithPath:recordPath];
//    NSURL *backgroundUrl = [NSURL fileURLWithPath:backgroundPath];
//    
//    AVURLAsset *recordAsset = [AVURLAsset assetWithURL:recordUrl];
//    AVURLAsset *backgroundAsset = [AVURLAsset assetWithURL:backgroundUrl];
//    
//    // 设置合成后的时间，以录音时间为准
//    CMTime duration = recordAsset.duration;
//    // 创建可变的音视频组合
//    AVMutableComposition *composition = [AVMutableComposition composition];
//    
//    AVMutableCompositionTrack *recordAudio = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//    
//    AVAssetTrack *recordAsset =
//    
//    [record ];
//}

+ (void)audio1:(NSURL *)url1 audio2: (NSURL *)url2 handler: (void (^)(NSString *))handler {
    
    AVURLAsset *audioAsset1 = [AVURLAsset assetWithURL:url1];
    AVURLAsset *audioAsset2 = [AVURLAsset assetWithURL:url2];
        
    CMTime duration =   (audioAsset2.duration.value / audioAsset2.duration.timescale) <= (audioAsset1.duration.value / audioAsset1.duration.timescale) ? audioAsset2.duration : audioAsset1.duration;
    
    // 创建可变的音视频组合
    AVMutableComposition *compostion = [AVMutableComposition composition];
    
    // 音频采集通道
    AVMutableCompositionTrack *audio2 = [compostion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    // 加入合成轨道之中
    AVAssetTrack *track2 = [audioAsset2 tracksWithMediaType:AVMediaTypeAudio].firstObject;
    [audio2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration) ofTrack: track2 atTime:kCMTimeZero error:nil];
    
    AVAssetTrack *track1 = [audioAsset1 tracksWithMediaType:AVMediaTypeAudio].firstObject;
    AVMutableCompositionTrack *audio1 = [compostion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [audio1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration) ofTrack:track1 atTime:kCMTimeZero error:nil];
    
    // 得到对应轨道中的音频声音信息，并更改
    AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track2];
    //初始化开始渐变持续时间
    CMTime continueTime = CMTimeMakeWithSeconds(2, 1);
    //设置前2秒背景音音量从0到1.0
    [parameters setVolumeRampFromStartVolume:0 toEndVolume:1.0 timeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(0, 1), continueTime)];
    //计算结束渐变的时间
    CMTime fadeOutStartTime = CMTimeSubtract(audioAsset1.duration, continueTime);
    //设置最后2秒背景音音量从1.0到0
    [parameters setVolumeRampFromStartVolume:1.0 toEndVolume:0 timeRange:CMTimeRangeMake(fadeOutStartTime, continueTime)];
    
    //赋给对应的类
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = @[parameters];
    
    // 创建导出配置
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:compostion presetName:AVAssetExportPresetAppleM4A];
    // 渐变音添加到导出配置中
    session.audioMix = audioMix;
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    // 路径
    NSString *outPutFilePath = [filePath stringByAppendingPathComponent:@"Audio.m4a"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outPutFilePath error:nil];
    }
    
    session.outputURL = [NSURL fileURLWithPath:outPutFilePath];
    session.outputFileType = @"com.apple.m4a-audio";
    session.shouldOptimizeForNetworkUse = YES;
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath]) {
            handler(outPutFilePath);
        } else {
            NSLog(@"输出错误");
            handler(@"");
        }
    }];
}

@end

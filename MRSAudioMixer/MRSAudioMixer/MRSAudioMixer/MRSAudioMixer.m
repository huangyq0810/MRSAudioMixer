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

+ (void)mixAudio:(NSString *)recordPath andAudio:(NSString *)backgroundPath handler:(void (^)(NSString *))handler {
    
    if (recordPath.length == 0 || backgroundPath.length == 0) {
        return;
    }
    # pragma mark - 初始化
    
    // 录音来源
    NSURL *recordUrl = [NSURL fileURLWithPath:recordPath];
    // 背景音来源
    NSURL *backgroundUrl = [NSURL fileURLWithPath:backgroundPath];
    
    // 录音采集
    AVURLAsset *recordAsset = [AVURLAsset assetWithURL:recordUrl];
    // 背景音采集
    AVURLAsset *backgroundAsset = [AVURLAsset assetWithURL:backgroundUrl];
    
    # pragma mark - 合成设置
    
    // 设置合成后的时间，以录音时间为准
    CMTime duration = recordAsset.duration;
    // 创建可变的音视频组合
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    // 同上
    AVMutableCompositionTrack *backgroundTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *backgroundAssetTrack = [backgroundAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
    [backgroundTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration) ofTrack: backgroundAssetTrack atTime:kCMTimeZero error:nil];
    
    // 音频通道 枚举 kCMPersistentTrackID_Invalid = 0
    AVMutableCompositionTrack *recordTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    // 音频采集通道
    AVAssetTrack *recordAssetTrack = [recordAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    // 把采集轨道数据加入到可变轨道之中
    [recordTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration) ofTrack: recordAssetTrack atTime:kCMTimeZero error:nil];
    
    # pragma mark - 渐变音
    
    // 得到对应轨道中的音频声音信息，并更改
    AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:backgroundAssetTrack];
    //初始化开始渐变持续时间
    CMTime continueTime = CMTimeMakeWithSeconds(2, 1);
    //设置前2秒背景音音量从0到1.0
    [parameters setVolumeRampFromStartVolume:0 toEndVolume:1.0 timeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(0, 1), continueTime)];
    //计算结束渐变持续时间
    CMTime fadeOutStartTime = CMTimeSubtract(duration, continueTime);
    //设置最后2秒背景音音量从1.0到0
    [parameters setVolumeRampFromStartVolume:1.0 toEndVolume:0 timeRange:CMTimeRangeMake(fadeOutStartTime, continueTime)];
    
    //赋给对应的类
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = @[parameters];
    
    // 创建输出配置
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    // 渐变音添加到输出配置中
    session.audioMix = audioMix;
    
    # pragma mark - 输出
    
    NSString *documentFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    // 输出路径
    NSString *outPutFilePath = [documentFilePath stringByAppendingPathComponent:@"Audio.m4a"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outPutFilePath error:nil];
    }
    // 输出地址
    session.outputURL = [NSURL fileURLWithPath:outPutFilePath];
    // 输出类型
    session.outputFileType = @"com.apple.m4a-audio";
    // 优化
    session.shouldOptimizeForNetworkUse = YES;
    // 合成完毕
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

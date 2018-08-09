//
//  MRSAudioMixer.h
//  MRSAudioMixer
//
//  Created by admin on 3/8/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSAudioMixer : NSObject

+ (void)audio1:(NSURL *)url1 audio2: (NSURL *)url2 handler: (void (^)(NSString *filePath))handler;

+ (void)mixAudio:(NSString *)recordPath andAudio: (NSString *)backgroundPath handler: (void (^)(NSString *outputFilepath))handler;

@end

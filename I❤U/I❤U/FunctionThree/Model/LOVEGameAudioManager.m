//
//  LOVEGameAudioManager.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/13.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "LOVEGameAudioManager.h"
#import <AVFoundation/AVFoundation.h>

@interface LOVEGameAudioManager()
@property (nonatomic) AVAudioPlayer *uiAudioPlayer;
@end

@implementation LOVEGameAudioManager

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static LOVEGameAudioManager *manager;
    
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

+ (void)playUIAudio:(EnGameUIAudioType)type
{
    [[LOVEGameAudioManager shareInstance] playUIAudio:type];
}

- (void)playUIAudio:(EnGameUIAudioType)type
{
    NSString *audioName = [self uiAudioNameForType:type];
    NSString *audioPath = [[self uiAudioRootDir] stringByAppendingPathComponent:audioName];
    
    [self stopUIAudio];
    self.uiAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:nil];
    if (self.uiAudioPlayer) {
        self.uiAudioPlayer.volume = 1;
        self.uiAudioPlayer.numberOfLoops = 0;
        [self.uiAudioPlayer prepareToPlay];
        [self.uiAudioPlayer play];
    }
}

- (void)stopUIAudio
{
    if (self.uiAudioPlayer) {
        [self.uiAudioPlayer stop];
        self.uiAudioPlayer = nil;
    }
}

- (NSString *)uiAudioNameForType:(EnGameUIAudioType)type
{
    switch (type) {
        case kGameRoomUIAudioTypePopQuestion:
            return @"出题目声音.m4r";
        case kGameRoomUIAudioTypeBackground:
            return @"题目背景音乐.m4r";
        case kGameRoomUIAudioTypeClickEnableButton:
            return @"点击按钮声音.m4r";
        case kGameRoomUIAudioTypeClickDisableButton:
            return @"已淘汰点击按钮.m4r";
        case kGameRoomUIAudioTypeReciprocal_3s:
            return @"答题倒计时321.m4r";
        case kGameRoomUIAudioTypeTimeUp:
            return @"到点.m4r";
        case kGameRoomUIAudioTypeAnswerWrong:
            return @"答题错误.m4r";
        case kGameRoomUIAudioTypeAnswerRight:
            return @"答题正确.m4r";
        case kGameRoomUIAudioTypeGameOver:
            return @"resurrection_full.m4r";
        default:
            return nil;
    }
}

- (NSString *)rootDir
{
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"LOTLocalResource/RealTimeVoiceGame"];
}

- (NSString *)uiAudioRootDir
{
    return [[self rootDir] stringByAppendingPathComponent:@"Audio/UIAudio"];
}

@end

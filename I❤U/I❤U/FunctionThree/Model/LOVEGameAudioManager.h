//
//  LOVEGameAudioManager.h
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/13.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EnGameUIAudioType)
{
    kGameRoomUIAudioTypeNone,
    
    kGameRoomUIAudioTypePopQuestion,              // 出题目
    kGameRoomUIAudioTypeBackground,               // 背景音乐
    kGameRoomUIAudioTypeClickEnableButton,        // 点击可用按钮
    kGameRoomUIAudioTypeClickDisableButton,       // 点击不可用按钮
    
    kGameRoomUIAudioTypeReciprocal_3s,            // 答题3s倒计时
    kGameRoomUIAudioTypeTimeUp,                   // 答题时间结束
    kGameRoomUIAudioTypeAnswerWrong,              // 答题错误
    kGameRoomUIAudioTypeAnswerRight               // 答题正确
};

@interface LOVEGameAudioManager : NSObject

+ (void)playUIAudio:(EnGameUIAudioType)type;

@end

//
//  FunctionThreeViewModel.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/11.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "FunctionThreeViewModel.h"
#import "BaseHeaders.h"
#import "LOVEPlaneView.h"
#import <HyphenateLite/HyphenateLite.h>
#import "EaseConvertToCommonEmoticonsHelper.h"
#import "LOVEModel.h"
#import "IMManager.h"
#import "LOVEMessage.h"
#import "LOVEGameAudioManager.h"

#define CGPointError CGPointMake(100, 100)

@implementation FunctionThreeViewModel

- (void)initialize{
    [super initialize];
    self.planeList = [NSMutableArray array];
    
    self.iAmReady = NO;
    self.targetIsReady = NO;
    self.isEditing = NO;
    self.gameState = kGameStateEnded;
    self.targetPoint = CGPointError;
    self.myDestroyCount = 0;
    self.targetDestroyCount = 0;
    @weakify(self);
    [RACObserve(self, targetIsReady) subscribeNext:^(id x) {
        @strongify(self);
        if (self.iAmReady && self.targetIsReady) {
            [self resetGame];
            self.gameState = kGameStateStarting;
            [UIUtil showHint:@"Your Turn!"];
            [LOVEGameAudioManager playUIAudio:kGameRoomUIAudioTypeTimeUp];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[IMManager shareManager] genLocalGameMessage:@"游戏开始,你先攻击"];
            });
        }
    }];
    
    
    [RACObserve(self, iAmReady) subscribeNext:^(id x) {
        @strongify(self);
        if (self.iAmReady && self.targetIsReady) {
            [self resetGame];
            self.gameState = kGameStateStarting;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[IMManager shareManager] genLocalGameMessage:@"游戏开始,对方先攻击"];
            });
        }
    }];
    
    [RACObserve(self, targetDestroyCount) subscribeNext:^(id x) {
        @strongify(self);
        if (self.targetDestroyCount >= 3 && self.gameState == kGameStateStarting) {
            self.gameState = kGameStateEnded;
            [UIUtil showHint:@"你赢了!"];
            self.iAmReady = NO;
            self.targetPlanesMapString = nil;
            self.targetPlanesMap = nil;
            self.targetIsReady = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[IMManager shareManager] genLocalGameMessage:[NSString stringWithFormat:@"%@ 赢了",[[IMManager shareManager] nickForAccount:[LOVEModel shareModel].fromAccount]]];
                [LOVEGameAudioManager playUIAudio:kGameRoomUIAudioTypeGameOver];
            });
        }
    }];
    [RACObserve(self, myDestroyCount) subscribeNext:^(id x) {
        @strongify(self);
        if (self.myDestroyCount >= 3 && self.gameState == kGameStateStarting) {
            self.gameState = kGameStateEnded;
            [UIUtil showHint:@"你输了!"];
            self.iAmReady = NO;
            self.targetPlanesMapString = nil;
            self.targetPlanesMap = nil;
            self.targetIsReady = NO;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[IMManager shareManager] genLocalGameMessage:[NSString stringWithFormat:@"%@ 赢了",[[IMManager shareManager] nickForAccount:[LOVEModel shareModel].toAccount]]];
                [LOVEGameAudioManager playUIAudio:kGameRoomUIAudioTypeGameOver];
            });
        }
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationKeyFire object:nil] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification * info = (NSNotification *)x;
        LOVEMessage * message = info.object;
        EMTextMessageBody *textBody = (EMTextMessageBody *)message.emMessage.body;
        NSMutableString * text = [NSMutableString stringWithString:textBody.text];
        [text deleteCharactersInRange:NSMakeRange(0, kFireScheme.length)];
        LOVEMessage * lastMessage = [IMManager shareManager].gameMessageList.lastObject;
        if ([message.emMessage.from isEqualToString:lastMessage.emMessage.from]) {
            [Log info:NSStringFromClass(self.class) message:@"错误:玩家%@同一回合攻击了第二次:%@",message.emMessage.from,text];
            return;
        }
        if (message.isFromMe) {//我攻击了某一点
            NSMutableArray * destoryPoints = [NSMutableArray arrayWithArray:self.targetDestroyPoints];
            [destoryPoints addObject:text];
            self.targetDestroyPoints = destoryPoints;
            //音效
            NSInteger targetHang = [[text componentsSeparatedByString:@","].firstObject integerValue];
            NSInteger targetLie = [[text componentsSeparatedByString:@","].lastObject integerValue];
            NSString * mapString = self.targetPlanesMap[targetHang][targetLie];
            if ([mapString isEqualToString:kPlaneBody]) {
                [LOVEGameAudioManager playUIAudio:kGameRoomUIAudioTypePopQuestion];
            }else if ([mapString isEqualToString:kPlaneHead]){
                [LOVEGameAudioManager playUIAudio:kGameRoomUIAudioTypeAnswerRight];
            }else if ([mapString isEqualToString:kPlaneBlank]){
                [LOVEGameAudioManager playUIAudio:kGameRoomUIAudioTypeAnswerWrong];
            }
            
        }else{//对方攻击了某一点
            [UIUtil showHint:@"Your Turn!"];
            [LOVEGameAudioManager playUIAudio:kGameRoomUIAudioTypeTimeUp];
            NSMutableArray * destoryPoints = [NSMutableArray arrayWithArray:self.myDestroyPoints];
            [destoryPoints addObject:text];
            self.myDestroyPoints = destoryPoints;
        }
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationKeyStart object:nil] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification * info = (NSNotification *)x;
        LOVEMessage * message = info.object;
        if (message.isFromMe) {//我准备
            self.iAmReady = YES;
        }else{//对方准备
            EMTextMessageBody *textBody = (EMTextMessageBody *)message.emMessage.body;
            NSMutableString * text = [NSMutableString stringWithString:textBody.text];
            [text deleteCharactersInRange:NSMakeRange(0, kStartScheme.length)];
            
            //解码
            NSMutableArray * planeMap = [NSMutableArray array];
            NSArray *array = [text componentsSeparatedByString:@"\n"];
            for (NSString * string in array) {
                NSArray *array = [string componentsSeparatedByString:@" "];
                [planeMap addObject:array];
            }
            
            self.targetPlanesMapString = text;
            self.targetPlanesMap = planeMap;
            self.targetIsReady = YES;
        }
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationKeyEnd object:nil] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification * info = (NSNotification *)x;
        LOVEMessage * message = info.object;
        self.gameState = kGameStateEnded;
        if (message.isFromMe) {//我结束游戏
            self.iAmReady = NO;
        }else{//对方结束游戏
            self.targetPlanesMapString = nil;
            self.targetPlanesMap = nil;
            self.targetIsReady = NO;
        }
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationKeyReset object:nil] subscribeNext:^(id x) {
        @strongify(self);
        self.gameState = kGameStateEnded;
        
        //完全对出另一方的游戏,双方清空对方的所有状态 并 自己取消准备
        self.targetPlanesMapString = nil;
        self.targetPlanesMap = nil;
        self.targetDestroyPoints = nil;
        self.targetIsReady = NO;
        //自己取消准备
        self.iAmReady = NO;
    }];
}

- (RACCommand *)fireCommand{
    @weakify(self);
    if (!_fireCommand) {
        _fireCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            LOVEMessage * lastMessage = [IMManager shareManager].gameMessageList.lastObject;
            if (self.gameState != kGameStateStarting) {
                [UIUtil showHint:@"游戏尚未开始或已经结束"];
                return [RACSignal empty];
            }
            if (lastMessage.isFromMe) {
                [UIUtil showHint:@"请等待对方攻击"];
                return [RACSignal empty];
            }
            
            if (!CGPointEqualToPoint(self.targetPoint, CGPointError)) {
                NSString * sendString = [NSString stringWithFormat:@"%@%@",kFireScheme,[NSString stringWithFormat:@"%.0lf,%.0lf",self.targetPoint.x , self.targetPoint.y]];
                for (NSString * historyPointString in self.targetDestroyPoints) {
                    if ([sendString containsString:historyPointString]) {
                        [UIUtil showHint:@"这个位置已经攻击过了!"];
                        return [RACSignal empty];
                    }
                }
                EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:sendString];
                NSString *from = [[EMClient sharedClient] currentUsername];
                [Log info:NSStringFromClass(self.class) message:@"current user name = %@",from];
                //生成Message
                EMMessage *message = [[EMMessage alloc] initWithConversationID:[LOVEModel shareModel].conversationId from:from to:[LOVEModel shareModel].toAccount body:body ext:nil];
                message.chatType = EMChatTypeChat;
                
                [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
                    [Log info:NSStringFromClass(self.class) message:@"progress = %i" , progress];
                } completion:^(EMMessage *aMessage, EMError *aError) {
                    if (!aError) {
                        [IMManager.shareManager.receiveNewMessageCommand execute:@[aMessage]];
                        [Log info:NSStringFromClass(self.class) message:@"send complete = %@",sendString];
                    }else {
                        [Log info:NSStringFromClass(self.class) message:@"send fail error = %@",aError.errorDescription];
                        [UIUtil showHint:[NSString stringWithFormat:@"登录失效,请重启app(%@)",aError.errorDescription]];
                    }
                }];
            }else{
                [UIUtil showHint:@"请先选择攻击地点!"];
            }
            return [RACSignal empty];
        }];
    }
    return _fireCommand;
}

- (RACCommand *)editOrFinishCommand{
    if (!_editOrFinishCommand) {
        @weakify(self);
        _editOrFinishCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            if (self.isEditing) {
                self.myPlanesMapString = [self mappingPlanes];
                if (![self.myPlanesMapString isEqualToString:@""]) {
                    self.isEditing = !self.isEditing;
                }
            }else{
                self.isEditing = !self.isEditing;
            }
            return [RACSignal empty];
        }];
    }
    return _editOrFinishCommand;
}

- (RACCommand *)readyOrRemoveCommand{
    if (!_readyOrRemoveCommand) {
        @weakify(self);
        _readyOrRemoveCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            if (self.isEditing) {//减少飞机
                if (self.planeList.count > 0) {
                    [self.planeList removeLastObject];
                }else{
                    [UIUtil showHint:@"战场上已经没有飞机啦"];
                }
            }else{//准备
                if (self.myPlanesMapString && ![self.myPlanesMapString isEqualToString:@""]) {
                    NSString * sendString = [NSString stringWithFormat:@"%@%@",kStartScheme,self.myPlanesMapString];
                    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:sendString];
                    NSString *from = [[EMClient sharedClient] currentUsername];
                    [Log info:NSStringFromClass(self.class) message:@"current user name = %@",from];
                    //生成Message
                    EMMessage *message = [[EMMessage alloc] initWithConversationID:[LOVEModel shareModel].conversationId from:from to:[LOVEModel shareModel].toAccount body:body ext:nil];
                    message.chatType = EMChatTypeChat;
                    
                    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
                        [Log info:NSStringFromClass(self.class) message:@"progress = %i" , progress];
                    } completion:^(EMMessage *aMessage, EMError *aError) {
                        if (!aError) {
                            [IMManager.shareManager.receiveNewMessageCommand execute:@[aMessage]];
                            [Log info:NSStringFromClass(self.class) message:@"send complete = %@",sendString];
                        }else {
                            [Log info:NSStringFromClass(self.class) message:@"send fail error = %@",aError.errorDescription];
                            [UIUtil showHint:[NSString stringWithFormat:@"登录失效,请重启app(%@)",aError.errorDescription]];
                        }
                    }];
                }else{
                    [UIUtil showHint:@"请先布置战场!"];
                }
            }
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _readyOrRemoveCommand;
}

- (RACCommand *)endOrAddCommand{
    if (!_endOrAddCommand) {
        @weakify(self);
        _endOrAddCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            if (self.isEditing) {//增加飞机
                if (self.planeList.count < 3) {
                    LOVEPlaneView * plane = [LOVEPlaneView plane];
                    plane.frame = CGRectMake( pixelWH * 4, pixelWH * 3, pixelWH * 5, pixelWH * 4);
                    plane.planeDirection = kPlaneDirectionUp;
                    [self.planeList addObject:plane];
                }else{
                    [UIUtil showHint:@"战场上不能摆放更多的飞机了"];
                }
            }else{//结束游戏
                [self resetGame];
                
                NSString * sendString = [NSString stringWithFormat:@"%@%@",kEndScheme,[LOVEModel shareModel].fromAccount];
                EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:sendString];
                NSString *from = [[EMClient sharedClient] currentUsername];
                [Log info:NSStringFromClass(self.class) message:@"current user name = %@",from];
                //生成Message
                EMMessage *message = [[EMMessage alloc] initWithConversationID:[LOVEModel shareModel].conversationId from:from to:[LOVEModel shareModel].toAccount body:body ext:nil];
                message.chatType = EMChatTypeChat;
                
                [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
                    [Log info:NSStringFromClass(self.class) message:@"progress = %i" , progress];
                } completion:^(EMMessage *aMessage, EMError *aError) {
                    if (!aError) {
                        [IMManager.shareManager.receiveNewMessageCommand execute:@[aMessage]];
                        [Log info:NSStringFromClass(self.class) message:@"send complete = %@",sendString];
                    }else {
                        [Log info:NSStringFromClass(self.class) message:@"send fail error = %@",aError.errorDescription];
                        [UIUtil showHint:[NSString stringWithFormat:@"登录失效,请重启app(%@)",aError.errorDescription]];
                    }
                }];
            }
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _endOrAddCommand;
}

- (RACCommand *)endExpiredGameCommand{
    if (!_endExpiredGameCommand) {
        @weakify(self);
        _endExpiredGameCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            if (!LOVEModel.shareModel.lastToAccount || !LOVEModel.shareModel.lastConversationId || !LOVEModel.shareModel.lastConversation) {
                [Log info:NSStringFromClass(self.class) message:@"没有上一局游戏"];
                return [RACSignal empty];
            }
            [self resetGame];
            self.targetPlanesMapString = nil;
            self.targetPlanesMap = nil;
            self.targetDestroyPoints = nil;
            self.targetIsReady = NO;
            //todo...上面的清空放在收到消息的通知里来做
            NSString * sendString = [NSString stringWithFormat:@"%@%@",kResetScheme,[LOVEModel shareModel].fromAccount];
            EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:sendString];
            NSString *from = [[EMClient sharedClient] currentUsername];
            [Log info:NSStringFromClass(self.class) message:@"current user name = %@",from];
            //生成Message
            EMMessage *message = [[EMMessage alloc] initWithConversationID:[LOVEModel shareModel].lastConversationId from:from to:[LOVEModel shareModel].lastToAccount body:body ext:nil];
            message.chatType = EMChatTypeChat;
            
            [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
                [Log info:NSStringFromClass(self.class) message:@"progress = %i" , progress];
            } completion:^(EMMessage *aMessage, EMError *aError) {
                if (!aError) {
                    [IMManager.shareManager.receiveNewMessageCommand execute:@[aMessage]];
                    [Log info:NSStringFromClass(self.class) message:@"send complete = %@",sendString];
                }else {
                    [Log info:NSStringFromClass(self.class) message:@"send fail error = %@",aError.errorDescription];
                    [UIUtil showHint:[NSString stringWithFormat:@"登录失效,请重启app(%@)",aError.errorDescription]];
                }
            }];
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _endExpiredGameCommand;
}

#pragma mark - private
//触发外部监听,清空飞机场和战场上的所有攻击标记
- (void)resetGame{
    self.targetDestroyPoints = nil;
    self.myDestroyPoints = nil;
}
/**
 * 将飞机位置使用0,1,2标记成二维数组和字符串
 * 二维数组在游戏中主要用于记录飞机位置并回馈击中反馈
 * 字符串用户发送给另一位玩家自己的飞机坐标,为对方回馈击中反馈
 */
- (NSString *)mappingPlanes{
    NSString * blank = kPlaneBlank;
    NSString * body  = kPlaneBody;
    NSString * head  = kPlaneHead;
    //数量检测
    if (self.planeList.count != 3) {
        [UIUtil showHint:@"飞机数量不正确"];
        return @"";
    }
    
    //mapping
    NSMutableArray<NSMutableArray *> * hangs = [NSMutableArray array];
    for (int hang = 0; hang < airportHeight; ++hang) {
        NSMutableArray * lies = [NSMutableArray array];
        for (int lie = 0; lie < airportLength; ++lie) {
            [lies insertObject:blank atIndex:lie];
        }
        [hangs insertObject:lies atIndex:hang];
    }
    
    for (LOVEPlaneView * plane in self.planeList) {
        switch (plane.planeDirection) {
            case kPlaneDirectionUp:
                for (int hang = plane.position.y; hang < plane.position.y + 4; ++hang) {
                    for (int lie = plane.position.x; lie < plane.position.x + 5; ++lie) {
                        if (hang == plane.position.y + 1 ||//第二横排
                            lie == plane.position.x + 2 ||//第三竖排
                            (hang == plane.position.y + 3 && lie != plane.position.x && lie != plane.position.x + 4)) {//第四横排的指定点
                            if (![hangs[hang][lie] isEqualToString:blank]){//重叠检测
                                [UIUtil showHint:@"飞机摆放位置不正确"];
                                return @"";
                            }
                            hangs[hang][lie] = body;
                        }
                        if (hang == plane.position.y && lie == plane.position.x + 2) {
                            hangs[hang][lie] = head;
                        }
                    }
                }
                break;
            case kPlaneDirectionRight:
                for (int hang = plane.position.y; hang < plane.position.y + 5; ++hang) {
                    for (int lie = plane.position.x; lie < plane.position.x + 4; ++lie) {
                        if (hang == plane.position.y + 2 ||//第三横排
                            lie == plane.position.x + 2 ||//第三竖排
                            (lie == plane.position.x && hang != plane.position.y && hang != plane.position.y + 4)) {//第一列的指定点
                            if (![hangs[hang][lie] isEqualToString:blank]){//重叠检测
                                [UIUtil showHint:@"飞机摆放位置不正确"];
                                return @"";
                            }
                            hangs[hang][lie] = body;
                        }
                        if (hang == plane.position.y + 2 && lie == plane.position.x + 3) {
                            hangs[hang][lie] = head;
                        }
                    }
                }
                break;
            case kPlaneDirectionDown:
                for (int hang = plane.position.y; hang < plane.position.y + 4; ++hang) {
                    for (int lie = plane.position.x; lie < plane.position.x + 5; ++lie) {
                        if (hang == plane.position.y + 2 ||//第三横排
                            lie == plane.position.x + 2 ||//第三竖排
                            (hang == plane.position.y && lie != plane.position.x && lie != plane.position.x + 4)) {//第一横排的指定点
                            if (![hangs[hang][lie] isEqualToString:blank]){//重叠检测
                                [UIUtil showHint:@"飞机摆放位置不正确"];
                                return @"";
                            }
                            hangs[hang][lie] = body;
                        }
                        if (hang == plane.position.y  + 3 && lie == plane.position.x + 2) {
                            hangs[hang][lie] = head;
                        }
                    }
                }
                break;
            case kPlaneDirectionLeft:
                for (int hang = plane.position.y; hang < plane.position.y + 5; ++hang) {
                    for (int lie = plane.position.x; lie < plane.position.x + 4; ++lie) {
                        if (hang == plane.position.y + 2 ||//第三横排
                            lie == plane.position.x + 1 ||//第二竖排
                            (lie == plane.position.x + 3 && hang != plane.position.y && hang != plane.position.y + 4)) {//第三列的指定点
                            if (![hangs[hang][lie] isEqualToString:blank]){//重叠检测
                                [UIUtil showHint:@"飞机摆放位置不正确"];
                                return @"";
                            }
                            hangs[hang][lie] = body;
                        }
                        if (hang == plane.position.y + 2 && lie == plane.position.x) {
                            hangs[hang][lie] = head;
                        }
                    }
                }
                break;
            default:
                break;
        }
    }
    
    //->string
    NSMutableArray * hangStringList = [NSMutableArray array];
    for (NSArray * lies in hangs) {
        NSString * lieString = [lies componentsJoinedByString:@" "];
        [hangStringList addObject:lieString];
    }
    NSString * mapString = [hangStringList componentsJoinedByString:@"\n"];
    [Log info:NSStringFromClass(self.class) message:@"mapstring = %@",mapString];
    
    self.myPlanesMap = hangs;
    return mapString;
}

@end

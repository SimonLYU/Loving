//
//  IMManager.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/12.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "IMManager.h"
#import "LOVEModel.h"
#import <HyphenateLite/HyphenateLite.h>
#import "EaseConvertToCommonEmoticonsHelper.h"
#import "LOVEMessage.h"
#define IM_SYSTEM_CONTENT_TEXT_FONT [UIFont systemFontOfSize:15]

@interface IMManager()<EMChatManagerDelegate>

@property (nonatomic, strong) NSDictionary *nickAccountMap;
@end

@implementation IMManager

+ (IMManager *)shareManager{
    static IMManager * _shareManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareManager = [[IMManager alloc] init];
        [[EMClient sharedClient].chatManager addDelegate:_shareManager delegateQueue:nil];
        //        [[EMClient sharedClient].roomManager addDelegate:_shareManager delegateQueue:nil];
        
        NSDictionary * nickAccountMap = @{
                                                 husbandAccount : @"老公",
                                                 wifeAccount : @"老婆",
                                                 };
        _shareManager.nickAccountMap = nickAccountMap;
    });
    return _shareManager;
}

//根据message计算cell高度
+ (CGFloat)calculateCellHeight:(EMMessage *)message{
    NSDictionary *attributes = @{
                                 NSFontAttributeName:IM_SYSTEM_CONTENT_TEXT_FONT,
                                 };
    
    NSAttributedString * attributedMessageContent = [[NSAttributedString alloc] initWithString:((EMTextMessageBody *)(message.body)).text attributes:attributes];
    CGFloat maxWidth = 0.f;
    if ([message.from isEqualToString:[[EMClient sharedClient] currentUsername]]) {
        maxWidth = [UIScreen mainScreen].bounds.size.width - 25 - 5;
    }else{
        maxWidth = [UIScreen mainScreen].bounds.size.width - 5 - 5;
    }
    CGRect contentRect = [attributedMessageContent boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
    CGSize contentSize = CGRectIntegral(contentRect).size;
    CGFloat cellHeight = contentSize.height;
    cellHeight += 10;//上下边距
    return cellHeight;
}

//接收到新消息时的处理方法
- (RACCommand *)receiveNewMessageCommand{
    if (!_receiveNewMessageCommand) {
        _receiveNewMessageCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            NSArray * newMessages = (NSArray *)input;
            
            NSMutableArray * newMessageWithCommand = [NSMutableArray array];
            NSMutableArray * newCommand = [NSMutableArray array];
            for (EMMessage *message in newMessages) {
                EMMessageBody *msgBody = message.body;
                switch (msgBody.type) {
                    case EMMessageBodyTypeText:
                    {
                        // 收到的文字消息
                        EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
                        NSString *txt = textBody.text;
                        NSLog(@"收到的文字是 txt -- %@",txt);
                    }
                        break;
                        
                    default:
                        break;
                }
                //指令
                if (msgBody.type == EMMessageBodyTypeText) {
                    EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
                    if ([textBody.text hasPrefix:kFireScheme]){//攻击指定地点
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyFire object:[self getLoveMessagesFromEmmessages:@[message]].lastObject];
                    }else if ([textBody.text hasPrefix:kStartScheme]){//一方准备游戏
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyStart object:[self getLoveMessagesFromEmmessages:@[message]].lastObject];
                    }else if ([textBody.text hasPrefix:kEndScheme]){//一方结束游戏
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyEnd object:[self getLoveMessagesFromEmmessages:@[message]].lastObject];
                    }else if ([textBody.text hasPrefix:kResetScheme]){//一方完全退出游戏
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyReset object:[self getLoveMessagesFromEmmessages:@[message]].lastObject];
                    }
                }
                
                //信息流
                if (msgBody.type == EMMessageBodyTypeText) {
                    EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
                    if ([textBody.text hasPrefix:kFireScheme] ||
                        [textBody.text hasPrefix:kStartScheme] ||
                        [textBody.text hasPrefix:kResetScheme] ||
                        [textBody.text hasPrefix:kEndScheme]) {
                        
                        if ([textBody.text hasPrefix:kResetScheme] &&
                            [message.from isEqualToString:LOVEModel.shareModel.fromAccount]) {//如果是我发的reset消息,过掉不展示
                            break;
                        }
                        [newCommand addObject:message];
                    }else{
                        [newMessageWithCommand addObject:message];
                    }
                }
            }
            
            
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                NSMutableArray * messages = [NSMutableArray arrayWithArray:self.messageList];
                NSMutableArray * commands = [NSMutableArray arrayWithArray:self.gameMessageList];
                //封装一层message
                if (newMessageWithCommand.count > 0) {
                    NSArray * newLoveMessages = [self getLoveMessagesFromEmmessages:newMessageWithCommand];
                    [messages addObjectsFromArray:newLoveMessages];
                    self.messageList = messages;
                }
                if (newCommand.count > 0) {
                    NSArray * newLoveCommand = [self getLoveMessagesFromEmmessages:newCommand];
                    [commands addObjectsFromArray:newLoveCommand];
                    self.gameMessageList = commands;
                }
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _receiveNewMessageCommand;
}

//拉取历史消息
- (RACCommand *)fetchServiceMessageListCommand{
    if (!_fetchServiceMessageListCommand) {
        _fetchServiceMessageListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            BOOL shouldUpdateMessagelist = [input boolValue];
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                
                //本地历史消息
                [[LOVEModel shareModel].conversation loadMessagesStartFromId:nil count:999999 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
                    if (aError) {
                        [Log info:NSStringFromClass(self.class) message:@"拉取历史消息失败 error = %@",aError.description];
                        [subscriber sendNext:nil];
                        [subscriber sendCompleted];
                    }else{
                        //服务端历史消息
                        [[EMClient sharedClient].chatManager asyncFetchHistoryMessagesFromServer:[LOVEModel shareModel].conversationId conversationType:[LOVEModel shareModel].conversation.type startMessageId:((EMMessage *)aMessages.lastObject).messageId pageSize:999999 completion:^(EMCursorResult *aResult, EMError *aError) {
                            if (aError) {
                                [Log info:NSStringFromClass(self.class) message:@"拉取历史消息失败 error = %@",aError.description];
                            }else{
                                //DB消息
                                NSMutableArray * aMessagesWithoutCommand = [NSMutableArray array];
                                NSMutableArray * aCommands = [NSMutableArray array];
                                for (EMMessage *message in aMessages) {
                                    EMMessageBody *msgBody = message.body;
                                    if (msgBody.type == EMMessageBodyTypeText) {
                                        EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
                                        if ([textBody.text hasPrefix:kFireScheme] ||
                                            [textBody.text hasPrefix:kStartScheme] ||
                                            [textBody.text hasPrefix:kResetScheme] ||
                                            [textBody.text hasPrefix:kEndScheme]) {
                                            if ([textBody.text hasPrefix:kResetScheme] &&
                                                [message.from isEqualToString:LOVEModel.shareModel.fromAccount]) {//如果是我发的reset消息,过掉不展示
                                                break;
                                            }
                                            [aCommands addObject:message];
                                        }else{
                                            [aMessagesWithoutCommand addObject:message];
                                        }
                                    }
                                }
                                //封装一层message
                                NSArray * newLoveMessages = [self getLoveMessagesFromEmmessages:aMessagesWithoutCommand];
                                NSArray * newCommands = [self getLoveMessagesFromEmmessages:aCommands];
                                NSMutableArray * messages = [NSMutableArray arrayWithArray:newLoveMessages];
                                NSMutableArray * commands = [NSMutableArray arrayWithArray:newCommands];
                                //service丢失消息
                                NSMutableArray * aResultListWithoutCommand = [NSMutableArray array];
                                NSMutableArray * aResultCommands = [NSMutableArray array];
                                for (EMMessage *message in aResult.list) {
                                    EMMessageBody *msgBody = message.body;
                                    if (msgBody.type == EMMessageBodyTypeText) {
                                        EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
                                        if ([textBody.text hasPrefix:kFireScheme] ||
                                            [textBody.text hasPrefix:kStartScheme] ||
                                            [textBody.text hasPrefix:kResetScheme] ||
                                            [textBody.text hasPrefix:kEndScheme]) {
                                            if ([textBody.text hasPrefix:kResetScheme] &&
                                                [message.from isEqualToString:LOVEModel.shareModel.fromAccount]) {//如果是我发的reset消息,过掉不展示
                                                break;
                                            }
                                            [aResultCommands addObject:message];
                                        }else{
                                            [aResultListWithoutCommand addObject:message];
                                        }
                                    }
                                }
                                //IM:游戏初始化时,拉取历史消息,不需要更新IM,否则会重复出现两条相同的IM消息
                                if (shouldUpdateMessagelist) {
                                    NSArray * newServiceLoveMessages = [self getLoveMessagesFromEmmessages:aResultListWithoutCommand];
                                    [messages addObjectsFromArray:newServiceLoveMessages];
                                    [messages addObjectsFromArray:self.messageList];
                                    self.messageList = messages;
                                }
                                
                                //游戏:
                                NSArray * newServiceCommands = [self getLoveMessagesFromEmmessages:aResultCommands];
                                [commands addObjectsFromArray:newServiceCommands];
                                //插入一个提示
                                EMMessage *message = [[EMMessage alloc] initWithConversationID:[LOVEModel shareModel].conversationId from:[LOVEModel shareModel].toAccount to:[LOVEModel shareModel].fromAccount body:[[EMTextMessageBody alloc] initWithText:@">>以上为历史消息<<"] ext:nil];
                                message.chatType = EMChatTypeChat;
                                NSArray * aTipMessage = [self getLoveMessagesFromEmmessages:@[message]];
                                [commands addObjectsFromArray:aTipMessage];
                                //最新新消息
                                [commands addObjectsFromArray:self.gameMessageList];
                                self.gameMessageList = commands;
                            }
                            [subscriber sendNext:nil];
                            [subscriber sendCompleted];
                        }];
                    }
                }];
                
                return nil;
            }];
        }];
    }
    return _fetchServiceMessageListCommand;
}

#pragma mark - fucntions
//在游戏界面生成一条不插入DB的系统提示消息
- (void)genLocalGameMessage:(NSString *)text{
    LOVEMessage * lastMessage = self.gameMessageList.lastObject;
    //插入一个提示
    EMMessage *message = [[EMMessage alloc] initWithConversationID:[LOVEModel shareModel].conversationId from:lastMessage.emMessage.from to:lastMessage.emMessage.to body:[[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"%@%@",kSysScheme,text]] ext:nil];
    message.chatType = EMChatTypeChat;
    NSArray * aTipMessage = [self getLoveMessagesFromEmmessages:@[message]];
    NSMutableArray * newCommandlist = [NSMutableArray arrayWithArray:self.gameMessageList];
    [newCommandlist addObjectsFromArray:aTipMessage];
    self.gameMessageList = newCommandlist;
}
//根据account获取本地hardcode昵称
- (NSString *)nickForAccount:(NSString *)account{
    NSString * nick = self.nickAccountMap[account];
    if (nick) {
        return nick;
    }else{
        return account;
    }
}

//检测字符串是否符合kUserAccountRegiex正则表达式
- (BOOL)checkAccount:(NSString *)account
{
    NSPredicate *loginPwdPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kUserAccountRegiex];
    BOOL isRight = [loginPwdPre evaluateWithObject:account];
    return isRight;
}

#pragma mark - private
//在EMMessage上封装一层LOVEMessage
- (NSArray *)getLoveMessagesFromEmmessages:(NSArray *)messageList{
    NSMutableArray * newMessageList = [NSMutableArray array];
    for (EMMessage *message in messageList) {
        CGFloat cellHeight = [self.class calculateCellHeight:message];
        LOVEMessage * loveMessage = [LOVEMessage messageWithCellHeight:cellHeight emMessage:message];
        [newMessageList addObject:loveMessage];
    }
    return newMessageList;
}

#pragma mark - EMClientDelegate reveive message
//收到消息的回调
- (void)messagesDidReceive:(NSArray *)aMessages{
    [self.receiveNewMessageCommand execute:aMessages];
}

@end

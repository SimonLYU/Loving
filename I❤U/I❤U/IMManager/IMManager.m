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
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyFire object:[self insertCellHeight:@[message]].lastObject];
                    }else if ([textBody.text hasPrefix:kStartScheme]){//一方准备游戏
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyStart object:[self insertCellHeight:@[message]].lastObject];
                    }else if ([textBody.text hasPrefix:kEndScheme]){//一方结束游戏
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyEnd object:[self insertCellHeight:@[message]].lastObject];
                    }
                }
                
                //信息流
                if (msgBody.type == EMMessageBodyTypeText) {
                    EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
                    if ([textBody.text hasPrefix:kFireScheme] ||
                        [textBody.text hasPrefix:kStartScheme] ||
                        [textBody.text hasPrefix:kEndScheme]) {
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
                    NSArray * newLoveMessages = [self insertCellHeight:newMessageWithCommand];
                    [messages addObjectsFromArray:newLoveMessages];
                    self.messageList = messages;
                }
                if (newCommand.count > 0) {
                    NSArray * newLoveCommand = [self insertCellHeight:newCommand];
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

- (RACCommand *)fetchServiceMessageListCommand{
    if (!_fetchServiceMessageListCommand) {
        _fetchServiceMessageListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
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
                                            [textBody.text hasPrefix:kEndScheme]) {
                                            [aCommands addObject:message];
                                        }else{
                                            [aMessagesWithoutCommand addObject:message];
                                        }
                                    }
                                }
                                NSArray * newLoveMessages = [self insertCellHeight:aMessagesWithoutCommand];
                                NSArray * newCommands = [self insertCellHeight:aCommands];
                                NSMutableArray * messages = [NSMutableArray arrayWithArray:newLoveMessages];
                                NSMutableArray * commands = [NSMutableArray arrayWithArray:newCommands];
                                //封装一层message
                                //service丢失消息
                                NSMutableArray * aResultListWithoutCommand = [NSMutableArray array];
                                NSMutableArray * aResultCommands = [NSMutableArray array];
                                for (EMMessage *message in aResult.list) {
                                    EMMessageBody *msgBody = message.body;
                                    if (msgBody.type == EMMessageBodyTypeText) {
                                        EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
                                        if ([textBody.text hasPrefix:kFireScheme] ||
                                            [textBody.text hasPrefix:kStartScheme] ||
                                            [textBody.text hasPrefix:kEndScheme]) {
                                            [aResultCommands addObject:message];
                                        }else{
                                            [aResultListWithoutCommand addObject:message];
                                        }
                                    }
                                }
                                
                                NSArray * newServiceLoveMessages = [self insertCellHeight:aResultListWithoutCommand];
                                NSArray * newServiceCommands = [self insertCellHeight:aResultCommands];
                                [messages addObjectsFromArray:newServiceLoveMessages];
                                [commands addObjectsFromArray:newServiceCommands];
                                //插入一个提示
                                EMMessage *message = [[EMMessage alloc] initWithConversationID:[LOVEModel shareModel].conversationId from:[LOVEModel shareModel].toAccount to:[LOVEModel shareModel].fromAccount body:[[EMTextMessageBody alloc] initWithText:@">>以上为历史消息<<"] ext:nil];
                                message.chatType = EMChatTypeChat;
                                NSArray * aTipMessage = [self insertCellHeight:@[message]];
                                [commands addObjectsFromArray:aTipMessage];
                                //最新新消息
                                [messages addObjectsFromArray:self.messageList];
                                [commands addObjectsFromArray:self.gameMessageList];
                                self.messageList = messages;
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
- (void)genLocalGameMessage:(NSString *)text{
    LOVEMessage * lastMessage = self.gameMessageList.lastObject;
    //插入一个提示
    EMMessage *message = [[EMMessage alloc] initWithConversationID:[LOVEModel shareModel].conversationId from:lastMessage.emMessage.from to:lastMessage.emMessage.to body:[[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"%@%@",kSysScheme,text]] ext:nil];
    message.chatType = EMChatTypeChat;
    NSArray * aTipMessage = [self insertCellHeight:@[message]];
    NSMutableArray * newCommandlist = [NSMutableArray arrayWithArray:self.gameMessageList];
    [newCommandlist addObjectsFromArray:aTipMessage];
    self.gameMessageList = newCommandlist;
}

- (NSString *)nickForAccount:(NSString *)account{
    NSString * nick = self.nickAccountMap[account];
    if (nick) {
        return nick;
    }else{
        return account;
    }
}
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

#pragma mark - private
- (NSArray *)insertCellHeight:(NSArray *)messageList{
    NSMutableArray * newMessageList = [NSMutableArray array];
    for (EMMessage *message in messageList) {
        CGFloat cellHeight = [self.class calculateCellHeight:message];
        LOVEMessage * loveMessage = [LOVEMessage messageWithCellHeight:cellHeight emMessage:message];
        [newMessageList addObject:loveMessage];
    }
    return newMessageList;
}

#pragma mark - reveive message
#pragma mark - EMClientDelegate
- (void)messagesDidReceive:(NSArray *)aMessages{
    [self.receiveNewMessageCommand execute:aMessages];
}

@end

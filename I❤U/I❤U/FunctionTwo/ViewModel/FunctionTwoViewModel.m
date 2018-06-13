//
//  FunctionTwoViewModel.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/7.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "FunctionTwoViewModel.h"
#import "LOVEModel.h"
#import <HyphenateLite/HyphenateLite.h>
#import "EaseConvertToCommonEmoticonsHelper.h"
#import "LOVEMessage.h"
#import "IMManager.h"
#define IM_SYSTEM_CONTENT_TEXT_FONT [UIFont systemFontOfSize:15]

@implementation FunctionTwoViewModel

- (void)initialize{
    [super initialize];
}

- (RACCommand *)sendMessageCommand{
    if (!_sendMessageCommand) {
        _sendMessageCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                
                EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:self.inputMessage];
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
                        [Log info:NSStringFromClass(self.class) message:@"send complete = %@",self.inputMessage];
                        self.inputMessage = nil;
                    }else {
                        [Log info:NSStringFromClass(self.class) message:@"send fail error = %@",aError.errorDescription];
                        [UIUtil showHint:[NSString stringWithFormat:@"登录失效,请重启app(%@)",aError.errorDescription]];
                    }
                }];
                
                
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _sendMessageCommand;
}

//- (RACCommand *)receiveNewMessageCommand{
//    if (!_receiveNewMessageCommand) {
//        _receiveNewMessageCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
//            NSArray * newMessages = (NSArray *)input;
//            
//            NSMutableArray * newMessageWithCommand = [NSMutableArray array];
//            for (EMMessage *message in newMessages) {
//                EMMessageBody *msgBody = message.body;
//                switch (msgBody.type) {
//                    case EMMessageBodyTypeText:
//                    {
//                        // 收到的文字消息
//                        EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
//                        NSString *txt = textBody.text;
//                        NSLog(@"收到的文字是 txt -- %@",txt);
//                    }
//                        break;
//                    case EMMessageBodyTypeImage:
//                    {
//                        // 得到一个图片消息body
//                        EMImageMessageBody *body = ((EMImageMessageBody *)msgBody);
//                        NSLog(@"大图remote路径 -- %@"   ,body.remotePath);
//                        NSLog(@"大图local路径 -- %@"    ,body.localPath); // // 需要使用sdk提供的下载方法后才会存在
//                        NSLog(@"大图的secret -- %@"    ,body.secretKey);
//                        NSLog(@"大图的W -- %f ,大图的H -- %f",body.size.width,body.size.height);
//                        NSLog(@"大图的下载状态 -- %lu",body.downloadStatus);
//                        
//                        // 缩略图sdk会自动下载
//                        NSLog(@"小图remote路径 -- %@"   ,body.thumbnailRemotePath);
//                        NSLog(@"小图local路径 -- %@"    ,body.thumbnailLocalPath);
//                        NSLog(@"小图的secret -- %@"    ,body.thumbnailSecretKey);
//                        NSLog(@"小图的W -- %f ,大图的H -- %f",body.thumbnailSize.width,body.thumbnailSize.height);
//                        NSLog(@"小图的下载状态 -- %lu",body.thumbnailDownloadStatus);
//                    }
//                        break;
//                    case EMMessageBodyTypeLocation:
//                    {
//                        EMLocationMessageBody *body = (EMLocationMessageBody *)msgBody;
//                        NSLog(@"纬度-- %f",body.latitude);
//                        NSLog(@"经度-- %f",body.longitude);
//                        NSLog(@"地址-- %@",body.address);
//                    }
//                        break;
//                    case EMMessageBodyTypeVoice:
//                    {
//                        // 音频sdk会自动下载
//                        EMVoiceMessageBody *body = (EMVoiceMessageBody *)msgBody;
//                        NSLog(@"音频remote路径 -- %@"      ,body.remotePath);
//                        NSLog(@"音频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在（音频会自动调用）
//                        NSLog(@"音频的secret -- %@"        ,body.secretKey);
//                        NSLog(@"音频文件大小 -- %lld"       ,body.fileLength);
//                        NSLog(@"音频文件的下载状态 -- %lu"   ,body.downloadStatus);
//                        NSLog(@"音频的时间长度 -- %lu"      ,body.duration);
//                    }
//                        break;
//                    case EMMessageBodyTypeVideo:
//                    {
//                        EMVideoMessageBody *body = (EMVideoMessageBody *)msgBody;
//                        
//                        NSLog(@"视频remote路径 -- %@"      ,body.remotePath);
//                        NSLog(@"视频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
//                        NSLog(@"视频的secret -- %@"        ,body.secretKey);
//                        NSLog(@"视频文件大小 -- %lld"       ,body.fileLength);
//                        NSLog(@"视频文件的下载状态 -- %lu"   ,body.downloadStatus);
//                        NSLog(@"视频的时间长度 -- %lu"      ,body.duration);
//                        NSLog(@"视频的W -- %f ,视频的H -- %f", body.thumbnailSize.width, body.thumbnailSize.height);
//                        
//                        // 缩略图sdk会自动下载
//                        NSLog(@"缩略图的remote路径 -- %@"     ,body.thumbnailRemotePath);
//                        NSLog(@"缩略图的local路径 -- %@"      ,body.thumbnailLocalPath);
//                        NSLog(@"缩略图的secret -- %@"        ,body.thumbnailSecretKey);
//                        NSLog(@"缩略图的下载状态 -- %lu"      ,body.thumbnailDownloadStatus);
//                    }
//                        break;
//                    case EMMessageBodyTypeFile:
//                    {
//                        EMFileMessageBody *body = (EMFileMessageBody *)msgBody;
//                        NSLog(@"文件remote路径 -- %@"      ,body.remotePath);
//                        NSLog(@"文件local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
//                        NSLog(@"文件的secret -- %@"        ,body.secretKey);
//                        NSLog(@"文件文件大小 -- %lld"       ,body.fileLength);
//                        NSLog(@"文件文件的下载状态 -- %lu"   ,body.downloadStatus);
//                    }
//                        break;
//                        
//                    default:
//                        break;
//                }
//                
//                //信息流
//                if (msgBody.type == EMMessageBodyTypeText) {
//                    EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
//                    if ([textBody.text hasPrefix:kFireScheme] ||
//                        [textBody.text hasPrefix:kStartScheme] ||
//                        [textBody.text hasPrefix:kEndScheme]) {
//                        //do nothing
//                    }else{
//                        [newMessageWithCommand addObject:message];
//                    }
//                }
//            }
//            
//            
//            
//            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//                NSMutableArray * messages = [NSMutableArray arrayWithArray:self.messageList];
//                //封装一层message
//                if (newMessageWithCommand.count > 0) {
//                    NSArray * newLoveMessages = [self insertCellHeight:newMessageWithCommand];
//                    [messages addObjectsFromArray:newLoveMessages];
//                    self.messageList = messages;
//                }
//                [subscriber sendNext:nil];
//                [subscriber sendCompleted];
//                return nil;
//            }];
//        }];
//    }
//    return _receiveNewMessageCommand;
//}
//
//- (RACCommand *)fetchServiceMessageListCommand{
//    if (!_fetchServiceMessageListCommand) {
//        _fetchServiceMessageListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
//            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//                
//                //本地历史消息
//                [[LOVEModel shareModel].conversation loadMessagesStartFromId:nil count:999999 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
//                    if (aError) {
//                        [Log info:NSStringFromClass(self.class) message:@"拉取历史消息失败 error = %@",aError.description];
//                        [subscriber sendNext:nil];
//                        [subscriber sendCompleted];
//                    }else{
//                        //服务端历史消息
//                        [[EMClient sharedClient].chatManager asyncFetchHistoryMessagesFromServer:[LOVEModel shareModel].conversationId conversationType:[LOVEModel shareModel].conversation.type startMessageId:((EMMessage *)aMessages.lastObject).messageId pageSize:999999 completion:^(EMCursorResult *aResult, EMError *aError) {
//                            if (aError) {
//                                [Log info:NSStringFromClass(self.class) message:@"拉取历史消息失败 error = %@",aError.description];
//                            }else{
//                                //DB消息
//                                NSMutableArray * aMessagesWithoutCommand = [NSMutableArray array];
//                                for (EMMessage *message in aMessages) {
//                                    EMMessageBody *msgBody = message.body;
//                                    if (msgBody.type == EMMessageBodyTypeText) {
//                                        EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
//                                        if ([textBody.text hasPrefix:kFireScheme] ||
//                                            [textBody.text hasPrefix:kStartScheme] ||
//                                            [textBody.text hasPrefix:kEndScheme]) {
//                                            //do nothing
//                                        }else{
//                                            [aMessagesWithoutCommand addObject:message];
//                                        }
//                                    }
//                                }
//                                NSArray * newLoveMessages = [self insertCellHeight:aMessagesWithoutCommand];
//                                NSMutableArray * messages = [NSMutableArray arrayWithArray:newLoveMessages];
//                                //封装一层message
//                                //service丢失消息
//                                NSMutableArray * aResultListWithoutCommand = [NSMutableArray array];
//                                for (EMMessage *message in aResult.list) {
//                                    EMMessageBody *msgBody = message.body;
//                                    if (msgBody.type == EMMessageBodyTypeText) {
//                                        EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
//                                        if ([textBody.text hasPrefix:kFireScheme] ||
//                                            [textBody.text hasPrefix:kStartScheme] ||
//                                            [textBody.text hasPrefix:kEndScheme]) {
//                                            //do nothing
//                                        }else{
//                                            [aResultListWithoutCommand addObject:message];
//                                        }
//                                    }
//                                }
//                                
//                                NSArray * newServiceLoveMessages = [self insertCellHeight:aResultListWithoutCommand];
//                                [messages addObjectsFromArray:newServiceLoveMessages];
//                                //最新新消息
//                                [messages addObjectsFromArray:self.messageList];
//                                self.messageList = messages;
//                            }
//                            [subscriber sendNext:nil];
//                            [subscriber sendCompleted];
//                        }];
//                    }
//                }];
//                
//                return nil;
//            }];
//        }];
//    }
//    return _fetchServiceMessageListCommand;
//}
//
//#pragma mark - private
//- (NSArray *)insertCellHeight:(NSArray *)messageList{
//    NSMutableArray * newMessageList = [NSMutableArray array];
//    for (EMMessage *message in messageList) {
//        CGFloat cellHeight = [self.class calculateCellHeight:message];
//        LOVEMessage * loveMessage = [LOVEMessage messageWithCellHeight:cellHeight emMessage:message];
//        [newMessageList addObject:loveMessage];
//    }
//    return newMessageList;
//}
//+ (CGFloat)calculateCellHeight:(EMMessage *)message{
//    NSDictionary *attributes = @{
//                                 NSFontAttributeName:IM_SYSTEM_CONTENT_TEXT_FONT,
//                                 };
//    
//    NSAttributedString * attributedMessageContent = [[NSAttributedString alloc] initWithString:((EMTextMessageBody *)(message.body)).text attributes:attributes];
//    CGFloat maxWidth = 0.f;
//    if ([message.from isEqualToString:[[EMClient sharedClient] currentUsername]]) {
//        maxWidth = [UIScreen mainScreen].bounds.size.width - 25 - 5;
//    }else{
//        maxWidth = [UIScreen mainScreen].bounds.size.width - 5 - 5;
//    }
//    CGRect contentRect = [attributedMessageContent boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
//    CGSize contentSize = CGRectIntegral(contentRect).size;
//    CGFloat cellHeight = contentSize.height;
//    cellHeight += 10;//上下边距
//    return cellHeight;
//}

@end

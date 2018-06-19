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
            @weakify(self);
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
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

@end
